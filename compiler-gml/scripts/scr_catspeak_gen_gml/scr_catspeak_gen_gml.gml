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
function CatspeakCodegenGML(globals_ = undefined) constructor {
    /// @ignore
    stack = array_create(32);
    /// @ignore
    globals = globals_ ?? { };
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
        ctx = {
            callTime : -1,
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
    static handleInstrConstString = function (value, dbg) {
        var exec = method({
            ctx : ctx,
            value : value,
            dbg : dbg,
        }, __catspeak_instr_get_s__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        var exec = method({
            ctx : ctx,
            dbg : dbg,
        }, __catspeak_instr_get_u__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBlock = function (n, dbg) {
        var values = array_create(n);
        for (var i = n - 1; i >= 0; i -= 1) {
            values[@ i] = popValue();
        }
        var exec = method({
            ctx : ctx,
            n : n,
            dbg : dbg,
            values : values,
        }, __catspeak_instr_pop_n__);
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
        var result = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            result : result,
        }, __catspeak_instr_ret__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBreak = function (dbg) {
        var result = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            result : result,
        }, __catspeak_instr_brk__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrContinue = function (dbg) {
        var exec = method({
            ctx : ctx,
            dbg : dbg,
        }, __catspeak_instr_cont__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrThrow = function (dbg) {
        var result = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            result : result,
        }, __catspeak_instr_thrw__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrClosure = function (locals, dbg) {
        var body = popValue();
        var exec = method({
            ctx : ctx,
            locals : locals,
            dbg : dbg,
            body : body,
        }, __catspeak_instr_fclo__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGetLocal = function (idx, dbg) {
        var exec = method({
            ctx : ctx,
            idx : idx,
            dbg : dbg,
        }, __catspeak_instr_get_l__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSetLocal = function (idx, dbg) {
        var value = popValue();
        var exec = method({
            ctx : ctx,
            idx : idx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_set_l__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGetGlobal = function (name, dbg) {
        var exec = method({
            ctx : ctx,
            name : name,
            dbg : dbg,
        }, __catspeak_instr_get_g__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSetGlobal = function (name, dbg) {
        var value = popValue();
        var exec = method({
            ctx : ctx,
            name : name,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_set_g__);
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
    static handleInstrNegative = function (dbg) {
        var value = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_neg__);
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
    static handleInstrPositive = function (dbg) {
        var value = popValue();
        var exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_pos__);
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
    return value;
}

/// @ignore
function __catspeak_instr_get_s__() {
    return value;
}

/// @ignore
function __catspeak_instr_get_u__() {
    return undefined;
}

/// @ignore
function __catspeak_instr_ifte__() {
    return condition() ? if_true() : if_false();
}

/// @ignore
function __catspeak_instr_rem__() {
    return lhs() % rhs();
}

/// @ignore
function __catspeak_instr_mult__() {
    return lhs() * rhs();
}

/// @ignore
function __catspeak_instr_div__() {
    return lhs() / rhs();
}

/// @ignore
function __catspeak_instr_idiv__() {
    return lhs() div rhs();
}

/// @ignore
function __catspeak_instr_sub__() {
    return lhs() - rhs();
}

/// @ignore
function __catspeak_instr_neg__() {
    return -value();
}

/// @ignore
function __catspeak_instr_add__() {
    return lhs() + rhs();
}

/// @ignore
function __catspeak_instr_pos__() {
    return +value();
}

/// @ignore
function __catspeak_instr_eq__() {
    return lhs() == rhs();
}

/// @ignore
function __catspeak_instr_neq__() {
    return lhs() != rhs();
}

/// @ignore
function __catspeak_instr_gt__() {
    return lhs() > rhs();
}

/// @ignore
function __catspeak_instr_geq__() {
    return lhs() >= rhs();
}

/// @ignore
function __catspeak_instr_lt__() {
    return lhs() < rhs();
}

/// @ignore
function __catspeak_instr_leq__() {
    return lhs() <= rhs();
}

/// @ignore
function __catspeak_instr_not__() {
    return !value();
}

/// @ignore
function __catspeak_instr_and__() {
    return eager() && lazy();
}

/// @ignore
function __catspeak_instr_or__() {
    return eager() || lazy();
}

/// @ignore
function __catspeak_instr_xor__() {
    return lhs() ^^ rhs();
}

/// @ignore
function __catspeak_instr_bnot__() {
    return ~value();
}

/// @ignore
function __catspeak_instr_band__() {
    return lhs() & rhs();
}

/// @ignore
function __catspeak_instr_bor__() {
    return lhs() | rhs();
}

/// @ignore
function __catspeak_instr_bxor__() {
    return lhs() ^ rhs();
}

/// @ignore
function __catspeak_instr_rshift__() {
    return value() >> amount();
}

/// @ignore
function __catspeak_instr_lshift__() {
    return value() << amount();
}

/// @ignore
function __catspeak_instr_ret__() {
    var returnBox = __catspeak_gml_exec_get_return();
    returnBox[@ 0] = result();
    throw returnBox;
}

/// @ignore
function __catspeak_instr_brk__() {
    var breakBox = __catspeak_gml_exec_get_break();
    breakBox[@ 0] = result();
    throw breakBox;
}

/// @ignore
function __catspeak_instr_cont__() {
    throw __catspeak_gml_exec_get_continue();
}

/// @ignore
function __catspeak_instr_thrw__() {
    throw result();
}

/// @ignore
function __catspeak_instr_fclo__() {
    return __catspeak_create_function(ctx, body, locals, dbg);
}

/// @ignore
function __catspeak_instr_pop_n__() {
    var values_ = values;
    var n_ = n - 1;
    for (var i = 0; i < n_; i += 1) {
        var value = values_[i];
        value();
    }
    var result = values_[n_];
    return result();
}

/// @ignore
function __catspeak_instr_get_l__() {
    return ctx.callee_.locals[idx];
}

/// @ignore
function __catspeak_instr_set_l__() {
    ctx.callee_.locals[idx] = value();
}

/// @ignore
function __catspeak_instr_get_g__() {
    return ctx.globals[$ name];
}

/// @ignore
function __catspeak_instr_set_g__() {
    ctx.globals[$ name] = value();
}

/// @ignore
function __catspeak_create_function(ctx, body, locals, dbg) {
    return method({
        ctx : ctx,
        body : body,
        locals : array_create(locals),
        dbg : dbg,
    }, __catspeak_function__);
}

/// @ignore
function __catspeak_function__() {
    var ctx_ = ctx;
    var prevCallee = ctx_.callee_;
    ctx_.callee_ = self;
    var returnValue = body();
    ctx_.callee_ = prevCallee;
    /* TODO: repurpose
    if (doThrowValue) {
        if (is_struct(throwValue)) {
            var catspeakErr = "CATSPEAK RUNTIME ERROR -- " +
                    __catspeak_gml_exec_get_error(body);
            if (variable_struct_exists(throwValue, "message")) {
                // add where the error occurred (really bad implementation, might be good enough for now)
                throwValue.message = catspeakErr + ": " + throwValue.message;
            }
            if (variable_struct_exists(throwValue, "longMessage")) {
                // add where the error occurred (really bad implementation, might be good enough for now)
                throwValue.longMessage += "\n-----\n" + catspeakErr + "\n";
            }
        }
        throw throwValue;
    }
    */
    return returnValue;
}

/// @ignore
function __catspeak_catch_return__() {
    var returnValue = undefined;
    try {
        returnValue = body();
    } catch (err_) {
        if (err_ == __catspeak_gml_exec_get_return()) {
            returnValue = err_[0];
        } else {
            throw err_;
        }
    }
    return returnValue;
}

/// @ignore
function __catspeak_catch_break__() {
    var returnValue = undefined;
    try {
        returnValue = body();
    } catch (err_) {
        if (err_ == __catspeak_gml_exec_get_break()) {
            returnValue = err_[0];
        } else {
            throw err_;
        }
    }
    return returnValue;
}

/// @ignore
function __catspeak_catch_continue__() {
    try {
        body();
    } catch (err_) {
        if (err_ != __catspeak_gml_exec_get_continue()) {
            throw err_;
        }
    }
}