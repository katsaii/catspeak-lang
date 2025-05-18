// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/template/scr_catspeak_disassembler.gml

//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

//# feather use syntax-errors

/// Disassembles a supplied Catspeak cartridge into a string.
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
    disassembler.asmStr = "";
    buffer_seek(buff, buffer_seek_start, buffStart);
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    asmStr = "";

    /// @ignore
    static handleFunc = function (idx, locals) {
        // TODO
    };

    /// @ignore
    static handleMeta = function (idx, path, author) {
        // TODO
    };

    /// @ignore
    static handleInstrConstNumber = function (argN) {
        asmStr += "  get_n";
        asmStr += "  " + string(argN);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrConstBool = function (argCondition) {
        asmStr += "  get_b";
        asmStr += "  " + string(argCondition);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrConstString = function (argString_) {
        asmStr += "  get_s";
        asmStr += "  " + string(argString_);
        asmStr += "\n"
    };

    /// @ignore
    static handleInstrReturn = function () {
        asmStr += "  ret";
    };
}