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
    disassembler.setTarget(buff);
    do {
        var moreRemains = disassembler.readInstr();
    } until (!moreRemains);
    var disassembly = disassembler.asmStr;
    disassembler.asmStr = undefined;
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() : CatspeakCartReader() constructor {
    self.asmStr = undefined;
    self.indent = "\n  ";
    self.__handleMeta__ = function (filepath_, reg_, global_) {
        asmStr = ""
        asmStr += "#[filepath=" + string(filepath_) + "]\n";
        asmStr += "#[reg=" + string(reg_) + "]\n";
        asmStr += "#[global=" + string(global_) + "]\n";
        asmStr += "fun () do";
    };
    self.__handleConstNumber__ = function (n) {
        asmStr += indent + "get_n";
        asmStr += "    " + string(n);
    };
    self.__handleConstBool__ = function (condition) {
        asmStr += indent + "get_b";
        asmStr += "    " + string(condition);
    };
    self.__handleConstString__ = function (string_) {
        asmStr += indent + "get_s";
        asmStr += "    " + string(string_);
    };
    self.__handleReturn__ = function () {
        asmStr += indent + "ret";
    };
}