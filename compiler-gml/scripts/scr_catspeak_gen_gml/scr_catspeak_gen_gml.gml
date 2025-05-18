// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/scr_catspeak_gen_gml.gml

//! TODO

//# feather use syntax-errors

/// The number of microseconds before a Catspeak program times out. The
/// default is 1 second.
///
/// @return {Real}
#macro CATSPEAK_TIMEOUT 1000

/// TODO
function CatspeakCodegenGML() constructor {
    /// @ignore
    stack = array_create(32);
    /// @ignore
    funcData = array_create(4);
    /// @ignore
    globals = undefined;
    /// @ignore
    ctx = undefined;
    /// @ignore
    inProgress = true;

    /// Returns the compiled Catspeak program.
    ///
    /// @warning
    ///   Attempting to call this function before the program is fully compiled
    ///   will raise a runtime error.
    ///
    /// @returns {Function}
    static getProgram = function () {
        __catspeak_assert(stackTop != -1, "no cartridge loaded");
        __catspeak_assert(!inProgress, "compilation is still in progress");
        __catspeak_assert_eq(stackTop, 0,
            "error occurred during compilation, values still remaining on the stack"
        );
        return popValue();
    };

    /// @ignore
    static handleInit = function () {
        inProgress = true;
        array_resize(stack, 0);
        /// @ignore
        stackTop = -1;
        array_resize(funcData, 0);
        ctx = {
            globals : globals ?? { },
            callee_ : undefined, // current function
            self_ : undefined,
            other_ : undefined,
            entry : undefined,
        };
    };

    /// @ignore
    static handleDeinit = function () {
        ctx = undefined;
        inProgress = false;
    };

    /// @ignore
    static handleFunc = function (idx, locals) {
        funcData[@ idx] = {
            locals : locals
        };
    };

    /// @ignore
    static handleMeta = function (path, author) {
        var ctx_ = ctx;
        ctx_.metaPath = path;
        ctx_.metaAuthor = author;
    };

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
    static handleInstrConstNumber = function (value, dbg) {
        var exec = method({
            ctx : ctx,
            value : value,
            dbg : dbg,
        }, __catspeak_instr_get_n__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrConstBool = function (value, dbg) {
        var exec = method({
            ctx : ctx,
            value : value,
            dbg : dbg,
        }, __catspeak_instr_get_b__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrConstString = function (value, dbg) {
        var exec = method({
            ctx : ctx,
            value : value,
            dbg : dbg,
        }, __catspeak_instr_get_s__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrReturn = function (dbg) {
        // unpack stack args in reverse order
        var result = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            result : result,
        }, __catspeak_instr_ret__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_add__);
        pushValue(exec);
    };
}

/// @ignore
function __catspeak_gml_exec_get_return() {
    static special = [undefined];
    return special;
}

/// @ignore
function __catspeak_gml_exec_get_break() {
    static special = [undefined];
    return special;
}

/// @ignore
function __catspeak_gml_exec_get_continue() {
    static special = [];
    return special;
}

/// @ignore
function __catspeak_gml_exec_get_error(exec) {
    var closure_ = method_get_self(exec);
    return catspeak_location_show(closure_[$ "dbg"], closure_.ctx[$ "filename"]);
}

/// @ignore
function __catspeak_instr_get_n__() {
    // get a numeric constant
    return value;
}

/// @ignore
function __catspeak_instr_get_b__() {
    // get a boolean constant
    return value;
}

/// @ignore
function __catspeak_instr_get_s__() {
    // get a string constant
    return value;
}

/// @ignore
function __catspeak_instr_ret__() {
    // return a value from the current function
    var returnBox = __catspeak_gml_exec_get_return();
    returnBox[@ 0] = result();
    throw returnBox;
}

/// @ignore
function __catspeak_instr_add__() {
    // calculate the sum of two values
    var lhs = self.lhs();
    var rhs = self.rhs();
    return lhs + rhs;
}
