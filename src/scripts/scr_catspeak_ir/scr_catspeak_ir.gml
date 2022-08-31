//! Handles the flat, executable representation of Catspeak programs.

//# feather use syntax-errors

/// Represents the executable Catspeak VM code. Also exposes methods for
/// constructing custom IR manually.
function CatspeakFunction() constructor {
    self.blocks = [];
    self.registers = []; // stores debug info about registers
    self.currentBlock = self.emitBlock(new CatspeakBlock());

    /// Adds a Catspeak block to the end of this function.
    ///
    /// @param {Struct.CatspeakBlock} block
    ///   The Catspeak block to insert.
    ///
    /// @return {Struct.CatspeakBlock}
    static emitBlock = function(block) {
        var idx = array_length(blocks);
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
        var idx = array_length(registers);
        array_push(registers, pos);
        return idx;
    };

    /// Emits the special unreachable "register." The existence of this
    /// flag will make dead code elimination easier in an optimisation phase.
    ///
    /// @return {Real}
    static emitUnreachable = function() {
        return -1;
    };

    /// Generates the code to assign a constant to a register.
    ///
    /// @param {Any} value
    ///   The constant value to load.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this constant.
    ///
    /// @return {Real}
    static emitConstant = function(value, pos) {
        var reg = emitRegister(pos);
        emitCode(CatspeakIntcode.LDC, reg, value);
        return reg;
    };

    /// Generates the code to return a value from this function. Since
    /// statements are expressions, this returns the never register.
    ///
    /// @param {Real} [reg]
    ///   The register containing the value to return. If not supplied, a
    ///   register containing `undefined` is used instead.
    ///
    /// @return {Real}
    static emitReturn = function(reg) {
        var reg_ = reg ?? emitConstant(undefined);
        emitCode(CatspeakIntcode.RET, reg_);
        return emitUnreachable();
    };

    /// Generates the code to move the value of one register to another.
    ///
    /// @param {Real} source
    ///   The register containing the value to move.
    ///
    /// @param {Real} dest
    ///   The register containing the destination to move to.
    ///
    /// @return {Real}
    static emitMove = function(source, dest) {
        emitCode(CatspeakIntcode.MOV, source, dest);
    };

    /// Generates the code to call a Catspeak function. Returns a register
    /// containing the result of the call.
    ///
    /// @param {Real} callee
    ///   The register containing function to be called.
    ///
    /// @param {Real} arg
    ///   The register containing the arguments array to pass to the function.
    ///
    /// @param {Struct.CatspeakLocation} [pos]
    ///   The debug info for this constant.
    ///
    /// @return {Real}
    static emitCall = function(callee, arg, pos) {
        var reg = emitRegister(pos);
        emitCode(CatspeakIntcode.CALL, callee, arg, reg);
        return reg;
    };

    /// Emits a new Catspeak intcode instruction for the current block.
    ///
    /// @param {Struct.CatspeakIntcode} inst
    ///   The Catspeak intcode instruction to perform.
    ///
    /// @param {Any} ...
    ///   The parameters to emit for this instruction, can be any kind of
    ///   value, but most likely will be register IDs.
    static emitCode = function() {
        var inst = currentBlock.code;
        for (var i = 0; i < argument_count; i += 1) {
            array_push(inst, argument[i]);
        }
    };

    /// Debug display for Catspeak functions, attempts to resemble the GML
    /// function `toString` behaviour.
    static toString = function() {
        return "function catspeak_" + instanceof(self);
    }

    /// Returns the disassembly for this IR function. Does not handle
    /// sub-function definitions, sorry!
    static disassembly = function() {
        var msg = "fun () {"
        var blockCount = array_length(blocks);
        for (var i = 0; i < blockCount; i += 1) {
            var block = blocks[i];
            var code_ = block.code;
            msg += "\n" + __blockName(block) + ":";
            var codeCount = array_length(code_);
            for (var j = 0; j < codeCount; j += 1) {
                var inst = code_[j];
                msg += "\n  " + catspeak_intcode_show(inst);
                switch (inst) {
                case CatspeakIntcode.JMP:
                    msg += " " + __blockName(code_[j + 1]);
                    j += 1;
                    break;
                case CatspeakIntcode.JMP_FALSE:
                    msg += " " + __blockName(code_[j + 1]);
                    msg += " " + __registerName(code_[j + 2]);
                    j += 2;
                    break;
                case CatspeakIntcode.MOV:
                    msg += " " + __registerName(code_[j + 1]);
                    msg += " " + __registerName(code_[j + 2]);
                    j += 2;
                    break;
                case CatspeakIntcode.LDC:
                    msg += " " + __registerName(code_[j + 1]);
                    msg += " " + string(code_[j + 2]);
                    j += 2;
                    break;
                case CatspeakIntcode.ARG:
                case CatspeakIntcode.RET:
                    msg += " " + __registerName(code_[j + 1]);
                    j += 1;
                    break;
                case CatspeakIntcode.CALL:
                    msg += " " + __registerName(code_[j + 1]);
                    msg += " " + __registerName(code_[j + 2]);
                    msg += " " + __registerName(code_[j + 3]);
                    j += 3;
                    break;
                }
            }
        }
        msg += "\n}";
        return msg;
    }

    /// @ignore
    static __registerName = function(reg) {
        return reg < 0 ? "!" : "r" + string(reg);
    }

    /// @ignore
    static __blockName = function(blk) {
        var idx = blk.idx;
        return idx == 0 ? "entry" : "blk" + string(idx);
    }
}

/// Represents a block of executable code.
function CatspeakBlock() constructor {
    self.code = [];
    self.idx = -1;
}