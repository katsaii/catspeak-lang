//! Handles the flat, executable representation of Catspeak programs.

//# feather use syntax-errors

/// Represents the executable Catspeak VM code. Also exposes methods for
/// constructing custom IR manually.
///
/// @param {String} [name]
///   The name to give this function, defaults to "main".
///
/// @param {Struct.CatspeakFunction} [parent]
///   The function this new function was defined in. Inherits its global
///   variables.
function CatspeakFunction(name, parent) constructor {
    self.name = name ?? "main";
    self.parent = parent;
    self.blocks = [];
    self.registers = []; // stores debug info about registers
    self.permanentRegisters = [];
    // stores any previously allocated registers which are safe to reuse
    // using a priority queue offers more opportunity for optimisations
    self.discardedRegisters = __catspeak_alloc_ds_priority(self);
    self.permanentConstantTable = __catspeak_alloc_ds_map(self);
    // the NaN lookup needs to be handled separately because they are not
    // comparable
    self.permanentConstantNaN = undefined;
    self.initialBlock = undefined;
    self.currentBlock = self.emitBlock(new CatspeakBlock("entry"));
    self.argCount = 0;
    self.subFunctions = [];
    if (parent == undefined) {
        self.globalRegisters = []; // stores the values of global variables
        self.globalRegisterTable = { };
    } else {
        array_push(parent.subFunctions, self);
        self.globalRegisters = parent.globalRegisters;
        self.globalRegisterTable = parent.globalRegisterTable;
    }

    /// Sets the value of a global variable with this name.
    ///
    /// @param {String} name
    ///   The name of the global variable to set.
    ///
    /// @param {Any} value
    ///   The value to assign to this global variable.
    static setGlobal = function(name, value) {
        var gReg = __getGlobalRegister(name);
        globalRegisters[@ gReg] = value;
    };

    /// Behaves similarly to [setGlobal], except if the value is not a method
    /// it is converted into a method type.
    ///
    /// @param {String} name
    ///   The name of the global variable to set.
    ///
    /// @param {Any} value
    ///   The value to assign to this global variable.
    static setGlobalFunction = function(name, value) {
        setGlobal(name, is_method(value) ? value : method(undefined, value));
    };

    /// Gets the value of a global variable with this name.
    ///
    /// @param {String} name
    ///   The name of the global variable to get.
    ///
    /// @return {Any}
    static getGlobal = function(name) {
        var gReg = __getGlobalRegister(name);
        return globalRegisters[gReg];
    };

    /// Returns whether a global variable exists with this name.
    ///
    /// @param {String} name
    ///   The name of the global variable to get.
    ///
    /// @return {Bool}
    static existsGlobal = function(name) {
        return variable_struct_exists(globalRegisterTable, name);
    };

    /// Returns the names of all created global variables
    ///
    /// @return {Array<String>}
    static getGlobalNames = function() {
        return variable_struct_get_names(globalRegisterTable);
    };

    /// Adds a Catspeak block to the end of this function.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The Catspeak block to insert.
    ///
    /// @return {Struct.CatspeakBlock}
    static emitBlock = function(block) {
        var idx = array_length(blocks);
        if (idx > 0 && !blocks[idx - 1].terminated) {
            // jump from the previous block if it exists and has not
            // been terminated yet
            emitJump(block);
        }
        array_push(blocks, block);
        block.idx = idx;
        currentBlock = block;
        return block;
    };

    /// Creates a new sub-function and returns its reference.
    ///
    /// @param {String} [name]
    ///   The name of the sub-function.
    ///
    /// @return {Struct.CatspeakFunction}
    static emitFunction = function(name) {
        return new CatspeakFunction(name, self);
    };

    /// Allocates space for a new Catspeak register. This just returns the
    /// id of the register, since there is no "physical" representation.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this register.
    ///
    /// @return {Real}
    static emitRegister = function(pos) {
        var idx;
        var pos_ = pos == undefined ? undefined : pos.clone();
        if (!ds_priority_empty(discardedRegisters)) {
            // reuse a discarded register
            // using a priority queue offers more opportunity for optimisation
            idx = ds_priority_delete_min(discardedRegisters);
            var meta = registers[idx];
            meta.pos ??= pos_;
            meta.discarded = false;
        } else {
            idx = array_length(registers);
            array_push(registers, {
                pos : pos_,
                discarded : false,
            });
        }
        return idx;
    };

    /// Returns the next persistent register ID. Persistent registers are not
    /// allocated immediately, they hold a temporary ID until the rest of the
    /// code is generated. Once this is complete, these special registers are
    /// allocated at the end of the register list. This is done in order to
    /// avoid messing up CALLSPAN instruction optimisations, where arguments are
    /// expected to be adjacent.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this register.
    ///
    /// @return {Real}
    static emitPermanentRegister = function(pos) {
        var idx;
        var pos_ = pos == undefined ? undefined : pos.clone();
        idx = array_length(permanentRegisters);
        array_push(permanentRegisters, {
            pos : pos_,
            marks : [],
        });
        return -(idx + 1);
    };

    /// Discards a register so it can be recycled somewhere else.
    ///
    /// @param {Any} reg
    ///   The register or accessor to check.
    static discardRegister = function(reg) {
        if (reg < 0) {
            // ignore persistent registers
            return;
        }
        var meta = registers[reg];
        if (meta.discarded) {
            // already discarded, should this be an error?
            return;
        }
        meta.discarded = true;
        ds_priority_add(discardedRegisters, reg, reg);
    };

    /// Emits the special unreachable "register." The existence of this
    /// flag will make dead code elimination easier in an optimisation phase.
    ///
    /// @return {Real}
    static emitUnreachable = function() {
        return NaN;
    };

    /// Returns whether a register is unreachable. Used to perform dead code
    /// elimination.
    ///
    /// @param {Any} reg
    ///   The register or accessor to check.
    ///
    /// @return {Bool}
    static isUnreachable = function(reg) {
        return is_numeric(reg) && is_nan(reg);
    };

    /// Generates the code to assign a set of constants to a set of
    /// temporary registers.
    ///
    /// @param {Any} value
    ///   The constant value to load.
    ///
    /// @return {Any}
    static emitConstant = function(value) {
        var result = emitRegister();
        var inst = lastCode();
        if (inst != undefined
                && inst[0] == CatspeakIntcode.LDC
                && inst[1] + inst[2] == result) {
            // if the last code was a LDC, and the two registers are
            // adjacent, use a single instruction
            inst[@ 2] += 1;
            array_push(inst, value);
        } else {
            emitCode(CatspeakIntcode.LDC, result, 1, value);
        }
        return new CatspeakTempRegisterAccessor(result, self);
    };

    /// Generates the code to assign a constant to a permanent register.
    ///
    /// @param {Any} value
    ///   The constant value to load.
    ///
    /// @return {Any}
    static emitPermanentConstant = function(value) {
        var result;
        var isNaN = is_numeric(value) && is_nan(value); // is_nan is borked
        if (isNaN && permanentConstantNaN != undefined) {
            result = permanentConstantNaN;
        } else if ((os_browser == browser_not_a_browser || is_string(value))
                && ds_map_exists(permanentConstantTable, value)) {
            result = permanentConstantTable[? value]
        } else {
            result = emitPermanentRegister();
            var inst = lastCodeHoisted();
            if (inst != undefined
                    && inst[0] == CatspeakIntcode.LDC
                    && inst[1] - inst[2] == result) {
                // if the last code was a LDC, and the two registers are
                // adjacent, use a single instruction
                inst[@ 2] += 1;
                array_push(inst, value);
            } else {
                var newInst = emitCodeHoisted(
                        CatspeakIntcode.LDC, result, 1, value);
                __registerMark(newInst, 1);
            }
            if (isNaN) {
                permanentConstantNaN = result;
            } else if (os_browser == browser_not_a_browser
                    // maps only support string keys in HTML5
                    || is_string(value)) {
                permanentConstantTable[? value] = result;
            }
        }
        return new CatspeakReadOnlyAccessor(result);
    };

    /// Generates the code assign the arguments array into a sequence of
    /// registers.
    ///
    /// @param {Any} reg
    ///   The register or accessor containing the register to write to.
    ///
    ///   NOTE: this will also write values to following `n`-many registers,
    ///         depending on how many arguments you decide to load statically.
    ///         Therefore, you should make sure to pre-allocate the registers
    ///         for arguments before you make this call.
    ///
    /// @param {Any} n
    ///   The number of arguments to load.
    ///
    /// @return {Any}
    static emitArgs = function(reg, n) {
        argCount = n;
        emitCode(CatspeakIntcode.LDA, reg, n);
    };

    /// Generates the code to read a global variable.
    ///
    /// @param {String} name
    ///   The name of the global to read.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitGlobalGet = function(name, pos) {
        var gReg = __getGlobalRegister(name);
        var result = emitRegister(pos);
        var inst = emitCode(CatspeakIntcode.GGET, result, gReg);
        __registerMark(inst, 1);
        return new CatspeakTempRegisterAccessor(result, self);
    };

    /// Generates the code to write to a global variable.
    ///
    /// @param {String} name
    ///   The name of the global to write to.
    ///
    /// @param {Any} reg
    ///   The register or accessor containing the value to write.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitGlobalSet = function(name, reg, pos) {
        var gReg = __getGlobalRegister(name);
        var result = emitClone(reg, pos);
        var inst = emitCode(CatspeakIntcode.GSET, undefined, gReg, result);
        __registerMark(inst, 3);
        return new CatspeakTempRegisterAccessor(result, self);
    };

    /// Generates the code to return a value from this function. Since
    /// statements are expressions, this returns the never register.
    ///
    /// @param {Any} [reg]
    ///   The register or accessor containing the value to return.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Real}
    static emitReturn = function(reg, pos) {
        var reg_ = emitGet(reg ?? emitConstant(undefined), pos);
        var inst = emitCode(CatspeakIntcode.RET, undefined, reg_);
        __registerMark(inst, 2);
        currentBlock.terminated = true;
        return emitUnreachable();
    };

    /// Generates the code to move the value of one register to another.
    ///
    /// @param {Any} source
    ///   The register or accessor containing the value to move.
    ///
    /// @param {Any} dest
    ///   The register or accessor containing the destination to move to.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    static emitMove = function(source, dest, pos) {
        var source_ = emitGet(source, pos);
        var dest_ = emitGet(dest, pos);
        if (source_ == dest_) {
            // the registers are already equal
            return;
        }
        var inst = lastCode();
        if (inst != undefined
                && inst[0] == CatspeakIntcode.MOV
                && inst[3] + inst[2] == source_
                && inst[1] + inst[2] == dest_) {
            // if the last code was a MOV, and the two registers are
            // adjacent, use a single instruction
            inst[@ 2] += 1;
        } else {
            var newInst = emitCode(CatspeakIntcode.MOV, dest_, 1, source_);
            __registerMark(newInst, 1);
            __registerMark(newInst, 3);
        }
    };

    /// Generates the code to clone a value into a manually managed register.
    ///
    /// @param {Any} reg
    ///   The register or accessor containing the value to copy.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    static emitClone = function(reg, pos) {
        var reg_ = emitGet(reg, pos);
        var result = emitRegister(pos);
        emitMove(reg_, result, pos);
        return result;
    };

    /// Generates the code to clone a value into a temporary register. This
    /// is useful for optimising function calls, since it helps align all
    /// arguments so they're adjacent.
    ///
    /// @param {Any} reg
    ///   The register or accessor containing the value to copy.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    static emitCloneTemp = function(reg, pos) {
        return new CatspeakTempRegisterAccessor(emitClone(reg, pos), self);
    };

    /// Generates the code to jump to a new block of code.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The block to jump to.
    static emitJump = function(block) {
        emitCode(CatspeakIntcode.JMP, undefined, block);
        currentBlock.terminated = true;
    };

    /// Generates the code to jump to a new block of code if a condition
    /// is false.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The block to jump to.
    ///
    /// @param {Any} condition
    ///   The register or accessor containing the condition code to check.
    static emitJumpFalse = function(block, condition) {
        var condition_ = emitGet(condition);
        var inst = emitCode(CatspeakIntcode.JMPF, undefined, block, condition_);
        __registerMark(inst, 3);
    };

    /// Generates the code to jump to a new block of code if a condition
    /// is true.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The block to jump to.
    ///
    /// @param {Any} condition
    ///   The register or accessor containing the condition code to check.
    static emitJumpTrue = function(block, condition) {
        var entry = new CatspeakBlock(
                (block.name ?? "jump") + " entry", block.pos);
        emitJumpFalse(entry, condition);
        emitJump(block);
        emitBlock(entry);
    };

    /// Generates the code to call a Catspeak function. Returns a register
    /// containing the result of the call. This version takes an additional
    /// argument for setting the "self".
    ///
    /// @param {Any} self_
    ///   The register or accessor containing self value.
    ///
    /// @param {Any} callee
    ///   The register or accessor containing function to be called.
    ///
    /// @param {Array<Any>} args
    ///   The array of registers or accessors containing the arguments to
    ///   pass.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitCallSelf = function(self_, callee, args, pos) {
        var callee_ = emitGet(callee, pos);
        var argCount = array_length(args);
        var callself = self_ == undefined ? undefined : emitGet(self_, pos);
        var inst = [CatspeakIntcode.CALLSPAN, undefined, callself, callee_, 0];
        __registerMark(inst, 1, 3);
        // add arguments using run-length encoding, in the best case all
        // arguments can be simplified to a single span
        if (argCount > 0) {
            var prevReg = emitGet(args[0], pos);
            var currLength = 1;
            var simpleCall = true;
            for (var i = 1; i < argCount; i += 1) {
                var nextReg = emitGet(args[i], pos);
                if (prevReg + 1 == nextReg) {
                    currLength += 1;
                } else {
                    array_push(inst, prevReg - currLength + 1, currLength);
                    __registerMark(inst, array_length(inst) - 2);
                    inst[@ 4] += 1;
                    currLength = 1;
                    simpleCall = false;
                }
                prevReg = nextReg;
            }
            if (simpleCall) {
                array_pop(inst);
                inst[@ 0] = CatspeakIntcode.CALL;
            } else {
                inst[@ 4] += 1;
            }
            array_push(inst, prevReg - currLength + 1, currLength);
            __registerMark(inst, array_length(inst) - 2);
        }
        // backpatch return register, since if an argument is discarded during
        // the call, it can be reused as the return value this is incredibly
        // important for emitting fast code
        var result = emitRegister(pos);
        inst[@ 1] = result;
        // must push the instruction after emitting code for the accessors
        array_push(currentBlock.code, inst);
        return new CatspeakTempRegisterAccessor(result, self);
    };

    /// Generates the code to call a Catspeak function. Returns a register
    /// containing the result of the call.
    ///
    /// @param {Any} callee
    ///   The register or accessor containing function to be called.
    ///
    /// @param {Array<Any>} args
    ///   The array of registers or accessors containing the arguments to
    ///   pass.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitCall = function(callee, args, pos) {
        return emitCallSelf(undefined, callee, args, pos);
    };

    /// Generates the code to get the current "self" context.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitSelf = function(pos) {
        var result = emitRegister(pos);
        var inst = emitCode(CatspeakIntcode.SELF, result);
        __registerMark(inst, 1);
        return result;
    };

    /// Emits a new Catspeak intcode instruction for the current block.
    /// Returns the array containing the instruction information.
    ///
    /// @param {Enum.CatspeakIntcode} inst
    ///   The Catspeak intcode instruction to perform.
    ///
    /// @param {Real} returnReg
    ///   The register to return the value to. If the return value is ignored,
    ///   then use `undefined`.
    ///
    /// @param {Any} ...
    ///   The parameters to emit for this instruction, can be any kind of
    ///   value, but most likely will be register IDs.
    ///
    /// @return {Array<Any>}
    static emitCode = function() {
        var inst = [];
        array_push(currentBlock.code, inst);
        for (var i = 0; i < argument_count; i += 1) {
            array_push(inst, argument[i]);
        }
        return inst;
    };

    /// Emits a new Catspeak intcode instruction, hoisted into the
    /// initialisation block.
    ///
    /// @param {Enum.CatspeakIntcode} inst
    ///   The Catspeak intcode instruction to perform.
    ///
    /// @param {Real} returnReg
    ///   The register to return the value to. If the return value is ignored,
    ///   then use `undefined`.
    ///
    /// @param {Any} ...
    ///   The parameters to emit for this instruction, can be any kind of
    ///   value, but most likely will be register IDs.
    ///
    /// @return {Array<Any>}
    static emitCodeHoisted = function() {
        var inst = [];
        var initialBlock_ = initialBlock;
        if (initialBlock_ == undefined) {
            initialBlock_ = new CatspeakBlock("init");
            initialBlock = initialBlock_;
            array_push(initialBlock_.code,
                    [CatspeakIntcode.JMP, undefined, blocks[0]]);
            array_insert(blocks, 0, initialBlock_);
        }
        var code = initialBlock_.code;
        array_insert(code, array_length(code) - 1, inst);
        for (var i = 0; i < argument_count; i += 1) {
            array_push(inst, argument[i]);
        }
        return inst;
    };

    /// Attempts to get the value of an accessor if it exists. If the accessor
    /// does not implement the `getValue` function, a Catspeak error is
    /// raised.
    ///
    /// @param {Any} accessor
    ///   The register or accessor to get the value of.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitGet = function(accessor, pos) {
        if (is_numeric(accessor)) {
            return accessor;
        }
        var getter = accessor.getValue;
        if (getter == undefined) {
            throw new CatspeakError(pos, "value is not readable");
        }
        var result = getter();
        return emitGet(result, pos);
    };

    /// Attempts to get the value of an accessor if it exists. If the accessor
    /// does not implement the `getValue` function, a Catspeak error is
    /// raised.
    ///
    /// @param {Any} accessor
    ///   The register or accessor to set the value of.
    ///
    /// @param {Any} value
    ///   The register or accessor to assign to the accessor 
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitSet = function(accessor, value, pos) {
        var valueReg = emitGet(value, pos);
        if (is_numeric(accessor)) {
            if (accessor < 0) {
                throw new CatspeakError(pos, "constant is not writable");
            }
            emitMove(valueReg, accessor, pos);
            return valueReg;
        }
        var setter = accessor.setValue;
        if (setter == undefined) {
            throw new CatspeakError(pos, "value is not writable");
        }
        var result = setter(valueReg);
        return emitGet(result, pos);
    };

    /// Returns a reference to the last instruction emitted to this function.
    /// If no instruction exists in the current block, `undefined` is returned
    /// instead.
    ///
    /// @return {Array<Any>}
    static lastCode = function() {
        var code = currentBlock.code;
        var n = array_length(code);
        if (n == 0) {
            return undefined;
        }
        return code[n - 1];
    };

    /// Returns a reference to the last instruction emitted to the
    /// initialisation block, ignoring the final branch instruction. If no
    /// instruction exists, then `undefined` is returned instead.
    ///
    /// @return {Array<Any>}
    static lastCodeHoisted = function() {
        var initialBlock_ = initialBlock;
        if (initialBlock_ == undefined) {
            return undefined;
        }
        var code = initialBlock_.code;
        var n = array_length(code) - 1;
        if (n == 0) {
            return undefined;
        }
        return code[n - 1];
    };

    /// Modifies the opcode component of this instruction.
    ///
    /// @deprecated
    ///
    /// @param {Array<Any>} inst
    ///   The instruction to modify.
    ///
    /// @param {Enum.CatspeakIntcode} code
    ///   The opcode to replace the current opcode with.
    static patchInst = function(inst, code) {
        inst[@ 0] = code;
    };

    /// Modifies the return register of this instruction.
    ///
    /// @deprecated
    ///
    /// @param {Array<Any>} inst
    ///   The instruction to modify.
    ///
    /// @param {Real} reg
    ///   The register to return the result of the instruction to.
    static patchInstReturn = function(inst, reg) {
        inst[@ 1] = reg;
        __registerMark(inst, 1);
    };

    /// Modifies the return register of this instruction.
    /// Fair warning: this is a dumb operation, so no checks are performed
    /// to validate that the value you're replacing is correct. This may
    /// result in undefined behaviour at runtime! Only use this function
    /// if you absolutely know what you're doing.
    ///
    /// @param {Array<Any>} inst
    ///   The instruction to modify.
    ///
    /// @param {Real} argIdx
    ///   The ID of the argument to modify.
    ///
    /// @param {Real} reg
    ///   The register containing to value to replace.
    static patchArg = function(inst, argIdx, reg) {
        inst[@ 2 + argIdx] = reg;
        __registerMark(inst, 2 + argIdx);
    };

    /// Backpatches the current set of persistent registers, and promotes
    /// them to true registers.
    static patchPermanentRegisters = function() {
        var registers_ = registers;
        var permanentRgisters_ = permanentRegisters;
        var registerCount = array_length(registers_);
        var permanentCount = array_length(permanentRgisters_);
        for (var i = 0; i < permanentCount; i += 1) {
            var meta = permanentRgisters_[i];
            var marks = meta.marks;
            array_push(registers_, {
                pos : meta.pos,
                discarded : false,
            });
            var markCount = array_length(marks);
            for (var j = 0; j < markCount; j += 2) {
                var inst = marks[j + 0];
                var offset = marks[j + 1];
                var reg = inst[offset];
                if (reg < 0) {
                    inst[@ offset] = -(reg + 1) + registerCount;
                }
            }
        }
        permanentRegisters = [];
    };

    /// Debug display for Catspeak functions, attempts to resemble the GML
    /// function `toString` behaviour.
    static toString = function() {
        var msg = "catspeak function";
        if (name != undefined) {
            msg += " " + (is_string(name) ? name : string(name));
        }
        return msg;
    };

    /// Returns the disassembly for this IR function.
    static disassembly = function() {
        var msg = "";
        // emit function body
        msg += "fun ";
        if (name != undefined) {
            msg += string(name);
        }
        msg += "() {";
        var blockCount = array_length(blocks);
        for (var i = 0; i < blockCount; i += 1) {
            // emit blocks
            var block = blocks[i];
            var code_ = block.code;
            msg += "\n" + __blockName(block) + ":";
            var codeCount = array_length(code_);
            for (var j = 0; j < codeCount; j += 1) {
                // emit instructions
                var inst = code_[j];
                var opcode = inst[0];
                var resultReg = inst[1];
                msg += "\n  ";
                if (resultReg != undefined) {
                    msg += __registerName(resultReg) + " = ";
                }
                msg += catspeak_intcode_show(opcode);
                var instCount = array_length(inst);
                switch (opcode) {
                case CatspeakIntcode.JMP:
                    msg += " " + __blockName(inst[2]);
                    break;
                case CatspeakIntcode.JMPF:
                    msg += " " + __blockName(inst[2]);
                    msg += " " + __registerName(inst[3]);
                    break;
                case CatspeakIntcode.MOV:
                    msg += " " + __valueName(inst[2]);
                    msg += " " + __registerName(inst[3]);
                    break;
                case CatspeakIntcode.LDC:
                    msg += " " + __valueName(inst[2]);
                    for (var k = 3; k < instCount; k += 1) {
                        msg += " " + __valueName(inst[k]);
                    }
                    break;
                case CatspeakIntcode.LDA:
                    msg += " " + __valueName(inst[2]);
                    break;
                case CatspeakIntcode.GGET:
                    msg += " " + __registerNameGlobal(inst[2]);
                    break;
                case CatspeakIntcode.GSET:
                    msg += " " + __registerNameGlobal(inst[2]);
                    msg += " " + __registerName(inst[3]);
                    break;
                case CatspeakIntcode.CALLSPAN:
                    msg += " " + __registerName(inst[2]);
                    msg += " " + __registerName(inst[3]);
                    msg += " " + __valueName(inst[4]);
                    for (var k = 5; k < instCount; k += 2) {
                        msg += " " + __registerName(inst[k + 0]);
                        msg += " " + __valueName(inst[k + 1]);
                    }
                    break;
                case CatspeakIntcode.CALL:
                    msg += " " + __registerName(inst[2]);
                    msg += " " + __registerName(inst[3]);
                    msg += " " + __registerName(inst[4]);
                    msg += " " + __valueName(inst[5]);
                    break;
                case CatspeakIntcode.RET:
                    msg += " " + __registerName(inst[2]);
                    break;
                }
            }
        }
        msg += "\n}";
        // emit sub-functions
        var subFunctionCount = array_length(subFunctions);
        for (var i = 0; i < subFunctionCount; i += 1) {
            msg += "\n\n" + subFunctions[i].disassembly();
        }
        return msg;
    };

    /// @ignore
    static __registerMark = function(inst, offset, n=1) {
        // marks a persistent register for backpatching
        for (var i = 0; i < n; i += 1) {
            var pos = offset + i;
            var reg = inst[pos];
            if (!(reg < 0)) {
                continue;
            }
            array_push(permanentRegisters[-(reg + 1)].marks, inst, pos);
        }
    };

    /// @ignore
    static __getGlobalRegister = function(name) {
        if (variable_struct_exists(globalRegisterTable, name)) {
            return globalRegisterTable[$ name];
        }
        var idx = array_length(globalRegisters);
        globalRegisters[@ idx] = undefined;
        globalRegisterTable[$ name] = idx;
        return idx;
    };

    /// @ignore
    static __registerName = function(reg) {
        if (reg == undefined) {
            return "none";
        }
        if (isUnreachable(reg)) {
            return "!";
        }
        if (reg < 0) {
            // this shouldn't ever appear, but it helps debug
            return "!r" + string(array_length(registers) + -(reg + 1));
        }
        var meta = registers[reg];
        var pos = meta.pos;
        if (pos == undefined || pos.lexeme == undefined) {
            return "r" + string(reg);
        }
        var lexeme = pos.lexeme;
        return "r`" + (is_string(lexeme) ? lexeme : string(lexeme)) + "`";
    };

    /// @ignore
    static __registerNameGlobal = function(reg) {
        return "g" + string(reg);
    };

    /// @ignore
    static __blockName = function(blk) {
        var msg = "blk";
        var pos = blk.pos;
        if (pos != undefined) {
            msg += "_" + string(pos.line) + "_" + string(pos.column);
        }
        var name = blk.name;
        if (name != undefined) {
            msg += "[" + __valueName(name) + "]";
        }
        return msg;
    };

    /// @ignore
    static __valueName = function(value) {
        if (is_string(value)) {
            var msg = value;
            msg = string_replace_all(msg, "\n", "\\n");
            msg = string_replace_all(msg, "\r", "\\r");
            msg = string_replace_all(msg, "\t", "\\t");
            msg = string_replace_all(msg, "\v", "\\v");
            msg = string_replace_all(msg, "\f", "\\f");
            msg = string_replace_all(msg, "\"", "\\\"");
            return "\"" + msg + "\"";
        } else if (is_struct(value)) {
            var inst = instanceof(value);
            if (os_browser == browser_not_a_browser) {
                // HTML5 tends to not like using the `toString` method,
                // so just default to the instance name
                if (inst == "function" || inst == "CatspeakFunction") {
                    inst = undefined;
                }
                inst ??= string(value);
            }
            return "(" + inst + ")";
        }
        return string(value);
    }
}

/// Represents a block of executable code.
///
/// @param {Any} [name]
///   The name to give this block, leave blank for no name.
///
/// @param {Struct.CatspeakLocation} [pos]
///   The debug info for this block.
function CatspeakBlock(name, pos) constructor {
    self.code = [];
    self.name = name;
    self.pos = pos == undefined ? undefined : pos.clone();
    self.terminated = false;
}

/// Represents a special assignment target which generates different code
/// depending on whether it used as a getter or setter. The simplest example
/// is with array and struct accessors, but it is not limited to just this.
///
/// The `getValue` function expects no arguments and should return a
/// register ID.
///
/// The `setValue` function expects a single argument, a register containing
/// the value to set, and should return a register containing the result of
/// the assignment. If there is no result, return `undefined`.
function CatspeakAccessor() constructor {
    self.getValue = undefined;
    self.setValue = undefined;
}

/// Used for constants, compile error on attempted assignment to constant
/// value.
///
/// @param {Real} reg
///   The register to mark as read-only.
function CatspeakReadOnlyAccessor(reg) : CatspeakAccessor() constructor {
    self.reg = reg;
    self.getValue = function() { return reg };
}

/// Used for call return values, most cases expect the value to be read once
/// and then be discarded. This adds a sanity check so that a compiler error
/// is raised if this fails.
///
/// @param {Real} reg
///   The register to read from once.
///
/// @param {Struct.CatspeakFunction} ir
///   The IR function associated with this register.
///
/// @param {Real} [count]
///   The number of times this register can be read before it's discarded.
///   Defaults to 1 time.
function CatspeakTempRegisterAccessor(reg, ir, count=1) : CatspeakAccessor() constructor {
    self.reg = reg;
    self.ir = ir;
    self.count = count;
    self.getValue = function() {
        count -= 1;
        if (count < 1) {
            getValue = undefined;
            ir.discardRegister(reg);
        }
        return reg;
    };
}