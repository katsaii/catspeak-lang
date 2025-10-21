// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/compiler-gml/scripts/scr_catspeak_disassembler/scr_catspeak_disassembler.gml

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
function catspeak_cart_disassemble(cart, offset = undefined) {
    static disassembler = new __CatspeakCartDisassembler();
    var cartStart = buffer_tell(cart);
    if (offset != undefined) {
        buffer_seek(cart, buffer_seek_start, offset);
    }
    var disassembly
    try {
        var reader = new CatspeakCartReader(cart, disassembler);
        do {
            var keepReading = reader.readInstr();
        } until (!keepReading);
    } catch (err_) {
        __catspeak_error(__catspeak_cat(
            "failed to disassemble cartridge: ", err_.message, "\n",
            "partial disassembly:\n", disassembler.out
        ));
    } finally {
        disassembly = disassembler.finalise();
        buffer_seek(cart, buffer_seek_start, cartStart);
    }
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    out = "";

    /// @ignore
    static finalise = function () {
        var disasm = out == "" ? "-- empty" : out;
        out = "";
        return disasm;
    };

    /// @ignore
    static handleMeta = function (
        name, author, version, version-minor, patch, path, date
    ) {
        if (name != "untitled") {
            out += "-- name:  " + string(name) + "\n";
        }
        if (author != "") {
            out += "-- author:  " + string(author) + "\n";
        }
        if (version != 1) {
            out += "-- version:  " + string(version) + "\n";
        }
        if (version-minor != 0) {
            out += "-- version-minor:  " + string(version-minor) + "\n";
        }
        if (patch != 0) {
            out += "-- patch:  " + string(patch) + "\n";
        }
        if (path != "") {
            out += "-- path:  " + string(path) + "\n";
        }
        if (date != 0) {
            out += "-- date:  " + string(date) + "\n";
        }
    };

    /// @ignore
    static handleFunc = function (idx) {
        out += "\nfun " + string(idx) + "\n";
    };

    /// @ignore
    static __writeDbg = function (dbg) {
        if (dbg != CATSPEAK_NOLOCATION) {
            out += "  \t-- " + string(catspeak_location_get_row(dbg));
            out += ":" + string(catspeak_location_get_column(dbg));
        }
    };

    /// @ignore
    static handleInstrSequence = function (dbg, n) {
        out += "\n  seq";
        out += "  " + string(n);
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrClosure = function (dbg, idx) {
        out += "\n  fclo";
        out += "  " + string(idx);
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrIfThenElse = function (dbg) {
        out += "\n  ifte";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrOr = function (dbg) {
        out += "\n  or";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrXor = function (dbg) {
        out += "\n  xor";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrAnd = function (dbg) {
        out += "\n  and";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrEqual = function (dbg) {
        out += "\n  eq";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrNotEqual = function (dbg) {
        out += "\n  neq";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrLessThan = function (dbg) {
        out += "\n  lt";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrLessThanOrEqualTo = function (dbg) {
        out += "\n  leq";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrGreaterThan = function (dbg) {
        out += "\n  gt";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrGreaterThanOrEqualTo = function (dbg) {
        out += "\n  geq";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrBitwiseAnd = function (dbg) {
        out += "\n  band";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrBitwiseOr = function (dbg) {
        out += "\n  bor";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrBitwiseXor = function (dbg) {
        out += "\n  bxor";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrBitwiseShiftLeft = function (dbg) {
        out += "\n  lshift";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrBitwiseShiftRight = function (dbg) {
        out += "\n  rshift";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        out += "\n  add";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrSubtract = function (dbg) {
        out += "\n  sub";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrMultiply = function (dbg) {
        out += "\n  mult";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrDivide = function (dbg) {
        out += "\n  div";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrDivideInt = function (dbg) {
        out += "\n  idiv";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrRemainder = function (dbg) {
        out += "\n  rem";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrPositive = function (dbg) {
        out += "\n  pos";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrNegative = function (dbg) {
        out += "\n  neg";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrNot = function (dbg) {
        out += "\n  not";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrBitwiseNot = function (dbg) {
        out += "\n  bnot";
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrConstNumber = function (dbg, value) {
        out += "\n  get_n";
        out += "  " + string(value);
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrConstString = function (dbg, value) {
        out += "\n  get_s";
        out += "  " + string(value);
        __writeDbg(dbg);
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        out += "\n  get_u";
        __writeDbg(dbg);
    };
}