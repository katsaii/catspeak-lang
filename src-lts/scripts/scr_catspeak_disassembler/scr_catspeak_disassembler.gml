// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/template/scr_catspeak_disassembler.gml

//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

//# feather use syntax-errors

/// TODO
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
    self.asmStr = undefined;
    /// @ignore
    self.indent = "\n  ";

    /// @ignore
    static handleMeta = function (filepath_, global_) {
        asmStr = ""
        asmStr += "#[filepath=" + string(filepath_) + "]\n";
        asmStr += "#[global=" + string(global_) + "]\n";
        asmStr += "fun () do";
    };

    /// @ignore
    static handleConstNumber = function (n, location) {
        asmStr += indent + "get_n";
        asmStr += "    " + string(n);
    };

    /// @ignore
    static handleConstBool = function (condition, location) {
        asmStr += indent + "get_b";
        asmStr += "    " + string(condition);
    };

    /// @ignore
    static handleConstString = function (string_, location) {
        asmStr += indent + "get_s";
        asmStr += "    " + string(string_);
    };

    /// @ignore
    static handleReturn = function (location) {
        asmStr += indent + "ret";
    };
}