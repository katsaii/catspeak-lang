// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/scr_catspeak_disassembler.gml

//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

//# feather use syntax-errors

/// Disassembles a supplied Catspeak cartridge into a string.
///
/// @experimental
///
/// @warning
///   This should only be used for debug purposes.
///
/// @returns {String}
function catspeak_cart_disassemble(buff, offset = undefined) {
    static disassembler = new __CatspeakCartDisassembler();
    var buffStart = buffer_tell(buff);
    if (offset != undefined) {
        buffer_seek(buff, buffer_seek_start, offset);
    }
    var disassembly
    try {
        var reader = new CatspeakCartReader(buff, disassembler);
        do {
            var moreRemains = reader.readInstr();
        } until (!moreRemains);
        disassembly = disassembler.asmStr;
    } catch (err_) {
        __catspeak_error(
            "failed to disassemble cartridge: ", err_.message, "\n",
            "partial disassembly:\n", disassembler.asmStr
        );
    } finally {
        disassembler.asmStr = undefined;
        buffer_seek(buff, buffer_seek_start, buffStart);
    }
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    asmStr = undefined;

    /// @ignore
    static handleInit = function () {
        /// @ignore
        asmStr = "";
    };

    /// @ignore
    static handleDeinit = function () { };

    /// @ignore
    static handleMeta = function (path, author) {
        // TODO
    };

    /// @ignore
    static handleInstrConstNumber = function (value, dbg) {
        asmStr += "  get_n";
        asmStr += "  " + string(value);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrConstString = function (value, dbg) {
        asmStr += "  get_s";
        asmStr += "  " + string(value);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        asmStr += "  get_u";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBlock = function (n, dbg) {
        asmStr += "  pop_n";
        asmStr += "  " + string(n);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrIfThenElse = function (dbg) {
        asmStr += "  ifte";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrReturn = function (dbg) {
        asmStr += "  ret";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBreak = function (dbg) {
        asmStr += "  brk";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrContinue = function (dbg) {
        asmStr += "  cont";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrThrow = function (dbg) {
        asmStr += "  thrw";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrClosure = function (locals, dbg) {
        asmStr += "  fclo";
        asmStr += "  " + string(locals);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrGetLocal = function (idx, dbg) {
        asmStr += "  get_l";
        asmStr += "  " + string(idx);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrSetLocal = function (idx, dbg) {
        asmStr += "  set_l";
        asmStr += "  " + string(idx);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrGetGlobal = function (name, dbg) {
        asmStr += "  get_g";
        asmStr += "  " + string(name);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrSetGlobal = function (name, dbg) {
        asmStr += "  set_g";
        asmStr += "  " + string(name);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrRemainder = function (dbg) {
        asmStr += "  rem";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrMultiply = function (dbg) {
        asmStr += "  mult";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrDivide = function (dbg) {
        asmStr += "  div";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrDivideInt = function (dbg) {
        asmStr += "  idiv";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrSubtract = function (dbg) {
        asmStr += "  sub";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrNegative = function (dbg) {
        asmStr += "  neg";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        asmStr += "  add";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrPositive = function (dbg) {
        asmStr += "  pos";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrEqual = function (dbg) {
        asmStr += "  eq";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrNotEqual = function (dbg) {
        asmStr += "  neq";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrGreaterThan = function (dbg) {
        asmStr += "  gt";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrGreaterThanOrEqualTo = function (dbg) {
        asmStr += "  geq";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrLessThan = function (dbg) {
        asmStr += "  lt";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrLessThanOrEqualTo = function (dbg) {
        asmStr += "  leq";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrNot = function (dbg) {
        asmStr += "  not";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrAnd = function (dbg) {
        asmStr += "  and";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrOr = function (dbg) {
        asmStr += "  or";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrXor = function (dbg) {
        asmStr += "  xor";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBitwiseNot = function (dbg) {
        asmStr += "  bnot";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBitwiseAnd = function (dbg) {
        asmStr += "  band";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBitwiseOr = function (dbg) {
        asmStr += "  bor";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBitwiseXor = function (dbg) {
        asmStr += "  bxor";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBitwiseShiftRight = function (dbg) {
        asmStr += "  rshift";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrBitwiseShiftLeft = function (dbg) {
        asmStr += "  lshift";
        asmStr += "\n"
    };
}