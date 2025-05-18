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
    static handleInstrIfThenElse = function (dbg) {
        // unpack stack args in reverse order
        var if_false = popValue();
        var if_true = popValue();
        var condition = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            condition : condition,
            if_true : if_true,
            if_false : if_false,
        }, __catspeak_instr_ifte__);
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
    static handleInstrRemainder = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_rem__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrMultiply = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_mult__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrDivide = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_div__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrDivideInt = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_idiv__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSubtract = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_sub__);
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

    /// @ignore
    static handleInstrEqual = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_eq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrNotEqual = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_neq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGreaterThan = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_gt__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGreaterThanOrEqualTo = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_geq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrLessThan = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_lt__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrLessThanOrEqualTo = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_leq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrNot = function (dbg) {
        // unpack stack args in reverse order
        var value = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_not__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrAnd = function (dbg) {
        // unpack stack args in reverse order
        var lazy = popValue();
        var eager = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_and__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrOr = function (dbg) {
        // unpack stack args in reverse order
        var lazy = popValue();
        var eager = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_or__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrXor = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_xor__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseNot = function (dbg) {
        // unpack stack args in reverse order
        var value = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_bnot__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseAnd = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_band__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseOr = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bor__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseXor = function (dbg) {
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bxor__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseShiftRight = function (dbg) {
        // unpack stack args in reverse order
        var amount = popValue();
        var value = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
            amount : amount,
        }, __catspeak_instr_rshift__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseShiftLeft = function (dbg) {
        // unpack stack args in reverse order
        var amount = popValue();
        var value = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
            amount : amount,
        }, __catspeak_instr_lshift__);
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
function __catspeak_instr_ifte__() {
    // evaluates one of two expressions, depending on whether a condition is true or false
    return condition() ? if_true() : if_false();
}

/// @ignore
function __catspeak_instr_ret__() {
    // return a value from the current function
    var returnBox = __catspeak_gml_exec_get_return();
    returnBox[@ 0] = result();
    throw returnBox;
}

/// @ignore
function __catspeak_instr_rem__() {
    // calculate the remainder of two values
    return lhs() % rhs();
}

/// @ignore
function __catspeak_instr_mult__() {
    // calculate the product of two values
    return lhs() * rhs();
}

/// @ignore
function __catspeak_instr_div__() {
    // calculate the division of two values
    return lhs() / rhs();
}

/// @ignore
function __catspeak_instr_idiv__() {
    // calculate the integer division of two values
    return lhs() div rhs();
}

/// @ignore
function __catspeak_instr_sub__() {
    // calculate the difference of two values
    return lhs() - rhs();
}

/// @ignore
function __catspeak_instr_add__() {
    // calculate the sum of two values
    return lhs() + rhs();
}

/// @ignore
function __catspeak_instr_eq__() {
    // check whether two values are equal
    return lhs() == rhs();
}

/// @ignore
function __catspeak_instr_neq__() {
    // check whether two values are NOT equal
    return lhs() != rhs();
}

/// @ignore
function __catspeak_instr_gt__() {
    // check whether a value is greater than another
    return lhs() > rhs();
}

/// @ignore
function __catspeak_instr_geq__() {
    // check whether a value is greater than or equal to another
    return lhs() >= rhs();
}

/// @ignore
function __catspeak_instr_lt__() {
    // check whether a value is less than another
    return lhs() < rhs();
}

/// @ignore
function __catspeak_instr_leq__() {
    // check whether a value is less than or equal to another
    return lhs() <= rhs();
}

/// @ignore
function __catspeak_instr_not__() {
    // calculate the logical negation of a value
    return !value();
}

/// @ignore
function __catspeak_instr_and__() {
    // calculate the logical AND of two values
    return eager() && lazy();
}

/// @ignore
function __catspeak_instr_or__() {
    // calculate the logical OR of two values
    return eager() || lazy();
}

/// @ignore
function __catspeak_instr_xor__() {
    // calculate the logical XOR of two values
    return lhs() ^^ rhs();
}

/// @ignore
function __catspeak_instr_bnot__() {
    // calculate the bitwise negation of a value
    return ~value();
}

/// @ignore
function __catspeak_instr_band__() {
    // calculate the bitwise AND of two values
    return lhs() & rhs();
}

/// @ignore
function __catspeak_instr_bor__() {
    // calculate the bitwise OR of two values
    return lhs() | rhs();
}

/// @ignore
function __catspeak_instr_bxor__() {
    // calculate the bitwise XOR of two values
    return lhs() ^ rhs();
}

/// @ignore
function __catspeak_instr_rshift__() {
    // calculate the bitwise right shift of two values
    return value() >> amount();
}

/// @ignore
function __catspeak_instr_lshift__() {
    // calculate the bitwise left shift of two values
    return value() << amount();
}
