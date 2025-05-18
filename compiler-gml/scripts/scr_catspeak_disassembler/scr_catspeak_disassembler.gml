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
    var reader = new CatspeakCartReader(buff, disassembler);
    do {
        var moreRemains = reader.readInstr();
    } until (!moreRemains);
    var disassembly = disassembler.asmStr;
    disassembler.asmStr = undefined;
    buffer_seek(buff, buffer_seek_start, buffStart);
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    static handleInit = function () {
        /// @ignore
        asmStr = "";
    };

    /// @ignore
    static handleDeinit = function () { };

    /// @ignore
    static handleFunc = function (idx, locals) {
        // TODO
    };

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
    static handleInstrConstBool = function (value, dbg) {
        asmStr += "  get_b";
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
    static handleInstrReturn = function (dbg) {
        asmStr += "  ret";
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        asmStr += "  add";
        asmStr += "\n"
    };
}