// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/template/scr_catspeak_gengml.gml

//! TODO

//# feather use syntax-errors

/// TODO
function CatspeakCodegenGML() constructor {
    /// @ignore
    self.stack = array_create(32);
    /// @ignore
    self.stackTop = -1;

    /// @ignore
    static pushValue = function (v) {
        stackTop += 1;
        stack[@ stackTop] = v;
    };

    /// @ignore
    static popValue = function () {
        var stackTop_ = stackTop;
        __catspeak_assert(stackTop_ >= 0, "stack underflow");
        var v = stack[@ stackTop_];
        stackTop -= 1;
        return v;
    };

    /// @ignore
    static handleMeta = function (filepath_, global_) {
        // TODO
    };

    /// @ignore
    static handleConstNumber = function (n, location) {
        asmStr += indent + "";
        asmStr += "    " + string(n);
        asmStr += "    " + string(location);
    };

    /// @ignore
    static handleConstBool = function (condition, location) {
        asmStr += indent + "";
        asmStr += "    " + string(condition);
        asmStr += "    " + string(location);
    };

    /// @ignore
    static handleConstString = function (string_, location) {
        asmStr += indent + "";
        asmStr += "    " + string(string_);
        asmStr += "    " + string(location);
    };

    /// @ignore
    static handleReturn = function (location) {
        asmStr += indent + "";
        asmStr += "    " + string(location);
    };
}