//! Handles the flat, executable representation of Catspeak programs.

//# feather use syntax-errors

/// Represents the executable Catspeak VM code. Also exposes methods for
/// constructing custom IR manually.
function CatspeakFunction() constructor {
    self.blocks = [];
    self.registers = []; // stores debug info about registers
    self.constants = []; // stores the values of constants
    self.discardedRegisters = []; // stores any previously allocated registers
                                  // which are safe to reuse
    self.currentBlock = self.emitBlock(new CatspeakBlock());
    self.constantTable = catspeak_alloc_ds_map(self);
    self.constantNaN = undefined; // the NaN lookup needs to be handled
                                  // separately because they are not
                                  // comparable

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
        if (array_length(discardedRegisters) > 0) {
            // reuse a discarded register
            idx = array_pop(discardedRegisters);
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
        array_push(discardedRegisters, reg);
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

    /// Returns whether a register is a constant memory location.
    ///
    /// @param {Any} reg
    ///   The register or accessor to check.
    ///
    /// @return {Bool}
    static isConstant = function(reg) {
        return reg < 0;
    };

    /// Generates the code to assign a constant to a register.
    ///
    /// @param {Any} value
    ///   The constant value to load.
    ///
    /// @return {Any}
    static emitConstant = function(value) {
        var result;
        var isNaN = is_numeric(value) && is_nan(value); // is_nan is borked
        if (isNaN && constantNaN != undefined) {
            result = constantNaN;
        } else if (ds_map_exists(constantTable, value)) {
            result = constantTable[? value]
        } else {
            result = array_length(constants);
            array_push(constants, value);
            if (isNaN) {
                constantNaN = result;
            } else {
                constantTable[? value] = result;
            }
        }
        // constants use negative ids, offset by 1
        // e.g. constant 0 has the register id of `-1`
        return -(result + 1);
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
        var inst = [CatspeakIntcode.CALL, undefined, callee_];
        var argCount = array_length(args);
        for (var i = 0; i < argCount; i += 1) {
            array_push(inst, emitGet(args[i], pos));
        }
        // backpatch return register, since if an argument is discarded during
        // the call, it can be reused as the return value
        var result = emitRegister(pos);
        inst[@ 1] = result;
        // must push the instruction after emitting code for the accessors
        array_push(currentBlock.code, inst);
        return new CatspeakTempRegisterAccessor(result, self);
    };

    /// Emits a new Catspeak intcode instruction for the current block.
    /// Returns the array containing the instruction information.
    ///
    /// @param {Struct.CatspeakIntcode} inst
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
        if (is_real(accessor)) {
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
        if (is_real(accessor)) {
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

    /// Debug display for Catspeak functions, attempts to resemble the GML
    /// function `toString` behaviour.
    static toString = function() {
        return "function catspeak_" + instanceof(self);
    };

    /// Returns the disassembly for this IR function. Does not handle
    /// sub-function definitions, sorry!
    static disassembly = function() {
        var msg = "";
        // emit constants
        var constCount = array_length(constants);
        for (var i = 0; i < constCount; i += 1) {
            var reg = -(i + 1);
            if (i != 0) {
                msg += "\n";
            }
            msg += "const " + __registerName(reg);
            msg += " = " + __valueName(constants[i]);
        }
        // emit function body
        if (constCount > 0) {
            msg += "\n\n";
        }
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
                    break;
                case CatspeakIntcode.GLOBAL:
                    break;
                case CatspeakIntcode.ARG:
                    break;
                case CatspeakIntcode.RET:
                    msg += " " + __registerName(inst[2]);
                    break;
                case CatspeakIntcode.CALL:
                    var argCount = array_length(inst);
                    for (var k = 2; k < argCount; k += 1) {
                        msg += " " + __registerName(inst[k]);
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
        if (isConstant(reg)) {
            // constant register
            return "c" + string(abs(reg) - 1);
        }
        var meta = registers[reg];
        var pos = meta.pos;
        if (pos == undefined || pos.lexeme == undefined) {
            return "r" + string(reg);
        }
        var lexeme = pos.lexeme;
        return "`" + (is_string(lexeme) ? lexeme : string(lexeme)) + "`";
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