// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir-disassembler.py

//# feather use syntax-errors

//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

/// TODO
function catspeak_cart_disassemble(buff) {
}

/// @ignore
function __CatspeakCartDisassembler() : CatspeakCartReader() constructor {
    self.str = undefined;
    self.__handleHeader__ = function (refCount) {
        str = "[main, refs=" + string(refCount) + "]\nfun ():";
    };
    self.__handleConstNumber__ = function (n) {
        str += "\n  CONST_NUMBER";
        str += "  " + string(n);
    };
    self.__handleConstBool__ = function (condition) {
        str += "\n  CONST_BOOL";
        str += "  " + string(condition);
    };
    self.__handleConstString__ = function (string_) {
        str += "\n  CONST_STRING";
        str += "  " + string(string_);
    };
    self.__handleReturn__ = function () {
        str += "\n  RETURN";
    };
}
