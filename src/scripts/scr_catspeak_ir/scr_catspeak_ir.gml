//! Handles the flat, executable representation of Catspeak programs.

//# feather use syntax-errors

/// Represents the executable Catspeak VM code. Also exposes methods for
/// constructing custom IR manually.
function CatspeakFunction() constructor {
    self.blocks = [];
    self.registers = []; // stores debug info about registers
    self.constants = []; // stores the values of constants
    // stores any previously allocated registers which are safe to reuse
    // using a priority queue offers more opportunity for optimisations
    self.discardedRegisters = catspeak_alloc_ds_priority(self);
    self.runtimeConstantTable = { };
    self.constantBlock = self.emitBlock(new CatspeakBlock());
    self.currentBlock = self.emitBlock(new CatspeakBlock());

    /// Adds a Catspeak block to the end of this function.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The Catspeak block to insert.
    ///
    /// @return {Struct.CatspeakBlock}
    static emitBlock = function(block) {
        var idx = array_length(blocks);
        if (idx > 0) {
            emitJump(block);
        }
        array_push(blocks, block);
        block.idx = idx;
        currentBlock = block;
        return block;
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

    /// Discards a register so it can be recycled somewhere else.
    ///
    /// @param {Any} reg
    ///   The register or accessor to check.
    static discardRegister = function(reg) {
        if (reg < 0) {
            // ignore constants
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

    /// Generates the code to assign a constant to a register.
    ///
    /// @param {Any} value
    ///   The constant value to load.
    ///
    /// @return {Any}
    static emitConstant = function(value) {
        var result = emitRegister();
        var code = lastCode();
        if (code != undefined
                && code[0] == CatspeakIntcode.LDC
                && code[1] + code[2] == result) {
            // if the last code was a LDC, and the two registers are
            // adjacent, use a single instruction
            code[@ 2] += 1;
            array_push(code, value);
        } else {
            emitCode(CatspeakIntcode.LDC, result, 1, value);
        }
        return new CatspeakTempRegisterAccessor(result, self);
    };

    /// Generates the code to read a constant at runtime using its identifier.
    ///
    /// @param {String} name
    ///   The name of the constant to load.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Any}
    static emitRuntimeConstant = function(name, pos) {
        /*if (variable_struct_exists(runtimeConstantTable, name)) {
            return runtimeConstantTable[$ name];
        }
        // hoist the definition
        var constantBlock_ = constantBlock;
        var code = constantBlock_.code;
        var result = emitRegister(pos);
        var inst = [CatspeakIntcode.LDC, result, name];
        array_insert(code, array_length(code) - 1, inst); // yuck!
        runtimeConstantTable[$ name] = result;
        return new CatspeakReadOnlyAccessor(result);*/
        throw new CatspeakError(pos, "unimplemented");
    };

    /// Generates the code to return a value from this function. Since
    /// statements are expressions, this returns the never register.
    ///
    /// @param {Any} reg
    ///   The register or accessor containing the value to return.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this instruction.
    ///
    /// @return {Real}
    static emitReturn = function(reg, pos) {
        var reg_ = emitGet(reg, pos);
        emitCode(CatspeakIntcode.RET, undefined, reg_);
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
        emitCode(CatspeakIntcode.MOV, dest_, source_);
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

    /// Generates the code to jump to a new block of code.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The block to jump to.
    static emitJump = function(block) {
        emitCode(CatspeakIntcode.JMP, undefined, block);
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
        emitCode(CatspeakIntcode.JMP_FALSE, undefined, block, condition_);
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
    /// @return {Real}
    static emitCall = function(callee, args, pos) {
        var callee_ = emitGet(callee, pos);
        var argCount = array_length(args);
        var inst = [CatspeakIntcode.CALL, undefined, callee_, 0];
        // add arguments using run-length encoding, in the best case all
        // arguments can be simplified to a single span
        if (argCount > 0) {
            var prevReg = emitGet(args[0], pos);
            var currLength = 1;
            for (var i = 1; i < argCount; i += 1) {
                var nextReg = emitGet(args[i], pos);
                if (prevReg + 1 == nextReg) {
                    currLength += 1;
                } else {
                    array_push(inst, prevReg - currLength + 1, currLength);
                    inst[@ 3] += 1;
                    currLength = 1;
                }
                prevReg = nextReg;
            }
            array_push(inst, prevReg - currLength + 1, currLength);
            inst[@ 3] += 1;
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
        var code_ = currentBlock.code;
        var n = array_length(code_);
        if (n == 0) {
            return undefined;
        }
        return code_[n - 1];
    };

    /// Modifies the opcode component of this instruction.
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
    /// @param {Array<Any>} inst
    ///   The instruction to modify.
    ///
    /// @param {Real} reg
    ///   The register to return the result of the instruction to.
    static patchInst = function(inst, reg) {
        inst[@ 1] = reg;
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
    };

    /// Debug display for Catspeak functions, attempts to resemble the GML
    /// function `toString` behaviour.
    static toString = function() {
        return "function catspeak_" + instanceof(self);
    };

    /// Returns the disassembly for this IR function. Does not handle
    /// sub-function definitions, sorry!
    static disassembly = function() {
        var msg = "";
        // emit function body
        msg += "fun () {"
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
                case CatspeakIntcode.JMP_FALSE:
                    msg += " " + __blockName(inst[2]);
                    msg += " " + __registerName(inst[3]);
                    break;
                case CatspeakIntcode.MOV:
                    msg += " " + __registerName(inst[2]);
                    break;
                case CatspeakIntcode.LDC:
                    msg += " " + __valueName(inst[2]);
                    for (var k = 3; k < instCount; k += 1) {
                        msg += " " + __valueName(inst[k]);
                    }
                    break;
                case CatspeakIntcode.IMPORT:
                    msg += " " + __valueName(inst[2]);
                    break;
                case CatspeakIntcode.ARG:
                    break;
                case CatspeakIntcode.RET:
                    msg += " " + __registerName(inst[2]);
                    break;
                case CatspeakIntcode.CALL:
                    msg += " " + __registerName(inst[2]);
                    msg += " " + __valueName(inst[3]);
                    for (var k = 4; k < instCount; k += 2) {
                        msg += " " + __registerName(inst[k + 0]);
                        msg += " " + __valueName(inst[k + 1]);
                    }
                    break;
                }
            }
        }
        msg += "\n}";
        return msg;
    };

    /// @ignore
    static __registerName = function(reg) {
        if (isUnreachable(reg)) {
            return "!";
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
    static __blockName = function(blk) {
        var idx = blk.idx;
        return idx == 0 ? "entry" : "blk" + string(idx);
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
            if (inst == "function") {
                inst = undefined;
            }
            inst ??= string(value);
            return inst;
        }
        return string(value);
    }
}

/// Represents a block of executable code.
function CatspeakBlock() constructor {
    self.code = [];
    self.idx = -1;
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
function CatspeakTempRegisterAccessor(reg, ir) : CatspeakAccessor() constructor {
    self.reg = reg;
    self.ir = ir;
    self.getValue = function() {
        getValue = undefined;
        ir.discardRegister(reg);
        return reg;
    };
}