// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/compiler-gml/scripts/scr_catspeak_gen_gml/scr_catspeak_gen_gml.gml

//! Transforms Catspeak IR into callable GML functions.
//!
//! This stage of the compiler is very unintelligent, and may produce bad
//! results if given invalid IR.

//# feather use syntax-errors

/// TODO
function CatspeakGenGML() constructor {
    /// @ignore
    exprStack = undefined;
    /// @ignore
    funcs = undefined;
    /// @ignore
    globals = undefined;
    /// @ignore
    ctx = undefined;
    /// @ignore
    isAlive = false;

    /// Frees any dynamically allocated resources managed by this generator.
    ///
    /// @warning
    ///   This **must** be called in a `finally` block if you expect exceptions.
    static destroy = function () {
        if (!isAlive) {
            return;
        }
        ds_stack_destroy(exprStack);
        exprStack = undefined;
        ds_list_destroy(funcs);
        funcs = undefined;
        isAlive = false;
    };

    /// Finalises the code generation of the current cartridge, returning the
    /// entrypoint function.
    ///
    /// This method will also free the memory allocated by this builder, and
    /// mark it for garbage collection.
    ///
    /// @return {Function}
    static finalise = function () {
        __catspeak_assert(isAlive, __catspeak_cat(
            "cannot call `finalise` method on empty cartridge ",
            "(check you haven't called `finalise` more than once!)"
        ));
        var program;
        try {
            __catspeak_assert_eq(0, ds_stack_size(exprStack),
                "unbalanced stack! this may be caused by malformed cartridge"
            );
            var programIdx = ds_list_size(funcs) - 1;
            __catspeak_assert(programIdx >= 0,
                "cartridge is missing an entry-point"
            );
            program = funcs[| programIdx];
        } finally {
            destroy();
        }
        return program;
    };

    /// @ignore
    static handleMeta = function (
        name, author, version, versionMinor, patch, path, date
    ) {
        isAlive = true;
        exprStack = ds_stack_create();
        funcs = ds_list_create();
        ctx = {
            globals : globals ?? { },
            callee_ : undefined,
            self_ : undefined,
            other_ : undefined,
            dbg : CATSPEAK_NOLOCATION,
            name : name,
            author : author,
            version : version,
            versionMinor : versionMinor,
            patch : patch,
            path : path,
            date : date,
        };
    };

    /// @ignore
    static handleFunc = function (idx) {
        var body = ds_stack_pop(exprStack);
        __catspeak_assert(body != undefined,
            "unbalanced stack! function is missing body"
        );
        var func;
        func = __genExpr({
            body : body,
        }, __catspeak_function_simple__);
        funcs[| idx] = func;
    };

    /// @ignore
    static __attachDbg = function (dbg, expr) {
        if (dbg == CATSPEAK_NOLOCATION) {
            return expr;
        } else {
            // insert instruction to track debug info
            return __genExpr({
                dbg : dbg,
                body : expr,
            }, __catspeak_dbg__);
        }
    };

    /// @ignore
    static __genExpr = function (self_, func_) {
        if (variable_struct_names_count(self_) == 0) {
            return method(undefined, func_);
        } else {
            self_.ctx = ctx;
            return method(self_, func_);
        }
    };

    /// @ignore
    static __genExprClosure = function (idx) {
        return __genExpr({
            value : funcs[| idx],
        }, __catspeak_instr_fclo_simple__);
    };

    /// @ignore
    static __genExprSequence_vers = undefined;
    static __genExprSequence_versN = 0;
    if (__genExprSequence_vers == undefined) {
        __genExprSequence_vers = [
            __catspeak_instr_seq_0__,
            __catspeak_instr_seq_1__,
            __catspeak_instr_seq_2__,
            __catspeak_instr_seq_3__,
            __catspeak_instr_seq_4__,
            __catspeak_instr_seq_5__,
            __catspeak_instr_seq_6__,
            __catspeak_instr_seq_7__,
            __catspeak_instr_seq_8__,
            __catspeak_instr_seq_9__,
        ];
        __genExprSequence_versN = array_length(__genExprSequence_vers);
    }

    /// @ignore
    static __genExprSequence = function (n, stmts) {
        var nStatic = min(n, __genExprSequence_versN - 1);
        var closure_ = { };
        for (var i = 0; i < nStatic; i += 1) {
            closure_[$ "_" + string(i + 1)] = stmts[i];
        }
        if (n == nStatic) {
            return __genExpr(closure_, __genExprSequence_vers[n]);
        } else {
            // encode statments in reverse for (maybe) faster iteration
            var moreN = n - __genExprSequence_versN;
            var more = array_create(moreN);
            for (var i = 0; i < moreN; i += 1) {
                more[@ i] = stmts[n - 2 - i];
            }
            closure_.moreN = moreN;
            closure_.more = more;
            closure_.result = stmts[n - 1];
            return __genExpr(closure_, __catspeak_instr_seq__);
        }
    };

    // automatically generated code generation functions (here be dragons)

    /// @ignore
    static handleInstrSequence = function (dbg, n) {
        var exprStack_ = exprStack;
        var stmts = array_create(n);
        for (var i = array_length(stmts) - 1; i >= 0; i -= 1) {
            stmts[@ i] = ds_stack_pop(exprStack_);
        }
        var expr;
        expr = __genExprSequence(n, stmts);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrClosure = function (dbg, idx) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprClosure(idx);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrIfThenElse = function (dbg) {
        var exprStack_ = exprStack;
        var if_false = ds_stack_pop(exprStack_);
        var if_true = ds_stack_pop(exprStack_);
        var condition = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            condition : condition,
            if_true : if_true,
            if_false : if_false,
        }, __catspeak_instr_ifte__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrOr = function (dbg) {
        var exprStack_ = exprStack;
        var lazy = ds_stack_pop(exprStack_);
        var eager = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_or__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrXor = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_xor__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrAnd = function (dbg) {
        var exprStack_ = exprStack;
        var lazy = ds_stack_pop(exprStack_);
        var eager = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_and__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrEqual = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_eq__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrNotEqual = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_neq__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLessThan = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_lt__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLessThanOrEqualTo = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_leq__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGreaterThan = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_gt__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGreaterThanOrEqualTo = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_geq__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseAnd = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_band__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseOr = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bor__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseXor = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bxor__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseShiftLeft = function (dbg) {
        var exprStack_ = exprStack;
        var amount = ds_stack_pop(exprStack_);
        var value = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            value : value,
            amount : amount,
        }, __catspeak_instr_lshift__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseShiftRight = function (dbg) {
        var exprStack_ = exprStack;
        var amount = ds_stack_pop(exprStack_);
        var value = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            value : value,
            amount : amount,
        }, __catspeak_instr_rshift__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_add__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSubtract = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_sub__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrMultiply = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_mult__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrDivide = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_div__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrDivideInt = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_idiv__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrRemainder = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        var lhs = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_rem__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrPositive = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_pos__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrNegative = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_neg__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrNot = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_not__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseNot = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_bnot__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstNumber = function (dbg, value) {
        var exprStack_ = exprStack;
        var expr;
        if (value == 0) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_0__);
        } else
        if (value == 1) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_1__);
        } else
        if (value == 2) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_2__);
        } else
        if (value == 3) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_3__);
        } else
        if (value == 4) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_4__);
        } else
        if (value == 8) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_8__);
        } else
        if (value == 16) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_16__);
        } else
        if (value == 24) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_24__);
        } else
        if (value == 32) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_32__);
        } else
        if (value == 64) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_64__);
        } else
        if (value == 128) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_128__);
        } else
        if (value == 256) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_256__);
        } else
        if (value == 10) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_10__);
        } else
        if (value == 100) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_100__);
        } else
        if (value == 1000) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_1k__);
        } else
        if (value == 1000000) {
            expr = __genExpr({
            }, __catspeak_instr_get_n_1m__);
        } else
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_get_n__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstString = function (dbg, value) {
        var exprStack_ = exprStack;
        var expr;
        if (value == "") {
            expr = __genExpr({
            }, __catspeak_instr_get_s_empty__);
        } else
        if (value == "*") {
            expr = __genExpr({
            }, __catspeak_instr_get_s_star__);
        } else
        if (value == "/") {
            expr = __genExpr({
            }, __catspeak_instr_get_s_slash__);
        } else
        if (value == "x") {
            expr = __genExpr({
            }, __catspeak_instr_get_s_x__);
        } else
        if (value == "y") {
            expr = __genExpr({
            }, __catspeak_instr_get_s_y__);
        } else
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_get_s__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExpr({
        }, __catspeak_instr_get_u__);
        ds_stack_push(exprStack_, expr);
    };
}

/// @ignore
function __catspeak_function_simple__() {
    // recover from errors
    var result;
    try {
        result = body();
    } catch (ex) {
        ex.longMessage += " " + catspeak_location_show(ctx.dbg, ctx.path) + "\n";
        throw ex;
    }
    return result;
}

/// @ignore
function __catspeak_dbg__() {
    var ctx_ = ctx;
    var dbgPrev = ctx_.dbg;
    ctx_.dbg = dbg;
    var result = body();
    // don't want to use `finally` here, because we want to track the error
    // location when an exception occurs
    ctx_.dbg = dbgPrev;
    return result;
}

/// @ignore
function __catspeak_instr_fclo_simple__() {
    return value;
}

/** @ignore */ function __catspeak_instr_seq_0__() { return undefined }
/** @ignore */ function __catspeak_instr_seq_1__() { return _1() }
/** @ignore */ function __catspeak_instr_seq_2__() { _1(); return _2() }
/** @ignore */ function __catspeak_instr_seq_3__() { _1(); _2(); return _3() }
/** @ignore */ function __catspeak_instr_seq_4__() { _1(); _2(); _3(); return _4() }
/** @ignore */ function __catspeak_instr_seq_5__() { _1(); _2(); _3(); _4(); return _5() }
/** @ignore */ function __catspeak_instr_seq_6__() { _1(); _2(); _3(); _4(); _5(); return _6() }
/** @ignore */ function __catspeak_instr_seq_7__() { _1(); _2(); _3(); _4(); _5(); _6(); return _7() }
/** @ignore */ function __catspeak_instr_seq_8__() { _1(); _2(); _3(); _4(); _5(); _6(); _7(); return _8() }
/** @ignore */ function __catspeak_instr_seq_9__() { _1(); _2(); _3(); _4(); _5(); _6(); _7(); _8(); return _9() }

/// @ignore
function __catspeak_instr_seq__() {
    _1(); _2(); _3(); _4(); _5(); _6(); _7(); _8(); _9();
    var more_ = more;
    for (var i = moreN - 1; i >= 0; i -= 1) {
        var comp = more_[i];
        comp();
    }
    return result();
}

// automatically generated instructions below (here be dragons)

/** @ignore */ function __catspeak_instr_ifte__() { return condition() ? if_true() : if_false() }
/** @ignore */ function __catspeak_instr_or__() { return eager() || lazy() }
/** @ignore */ function __catspeak_instr_xor__() { return lhs() ^^ rhs() }
/** @ignore */ function __catspeak_instr_and__() { return eager() && lazy() }
/** @ignore */ function __catspeak_instr_eq__() { return lhs() == rhs() }
/** @ignore */ function __catspeak_instr_neq__() { return lhs() != rhs() }
/** @ignore */ function __catspeak_instr_lt__() { return lhs() < rhs() }
/** @ignore */ function __catspeak_instr_leq__() { return lhs() <= rhs() }
/** @ignore */ function __catspeak_instr_gt__() { return lhs() > rhs() }
/** @ignore */ function __catspeak_instr_geq__() { return lhs() >= rhs() }
/** @ignore */ function __catspeak_instr_band__() { return lhs() & rhs() }
/** @ignore */ function __catspeak_instr_bor__() { return lhs() | rhs() }
/** @ignore */ function __catspeak_instr_bxor__() { return lhs() ^ rhs() }
/** @ignore */ function __catspeak_instr_lshift__() { return value() << amount() }
/** @ignore */ function __catspeak_instr_rshift__() { return value() >> amount() }
/** @ignore */ function __catspeak_instr_add__() { return lhs() + rhs() }
/** @ignore */ function __catspeak_instr_sub__() { return lhs() - rhs() }
/** @ignore */ function __catspeak_instr_mult__() { return lhs() * rhs() }
/** @ignore */ function __catspeak_instr_div__() { return lhs() / rhs() }
/** @ignore */ function __catspeak_instr_idiv__() { return lhs() div rhs() }
/** @ignore */ function __catspeak_instr_rem__() { return lhs() % rhs() }
/** @ignore */ function __catspeak_instr_pos__() { return +value() }
/** @ignore */ function __catspeak_instr_neg__() { return -value() }
/** @ignore */ function __catspeak_instr_not__() { return !value() }
/** @ignore */ function __catspeak_instr_bnot__() { return ~value() }
/** @ignore */ function __catspeak_instr_get_n__() { return value }
/** @ignore */ function __catspeak_instr_get_n_0__() { return 0 }
/** @ignore */ function __catspeak_instr_get_n_1__() { return 1 }
/** @ignore */ function __catspeak_instr_get_n_2__() { return 2 }
/** @ignore */ function __catspeak_instr_get_n_3__() { return 3 }
/** @ignore */ function __catspeak_instr_get_n_4__() { return 4 }
/** @ignore */ function __catspeak_instr_get_n_8__() { return 8 }
/** @ignore */ function __catspeak_instr_get_n_16__() { return 16 }
/** @ignore */ function __catspeak_instr_get_n_24__() { return 24 }
/** @ignore */ function __catspeak_instr_get_n_32__() { return 32 }
/** @ignore */ function __catspeak_instr_get_n_64__() { return 64 }
/** @ignore */ function __catspeak_instr_get_n_128__() { return 128 }
/** @ignore */ function __catspeak_instr_get_n_256__() { return 256 }
/** @ignore */ function __catspeak_instr_get_n_10__() { return 10 }
/** @ignore */ function __catspeak_instr_get_n_100__() { return 100 }
/** @ignore */ function __catspeak_instr_get_n_1k__() { return 1000 }
/** @ignore */ function __catspeak_instr_get_n_1m__() { return 1000000 }
/** @ignore */ function __catspeak_instr_get_s__() { return value }
/** @ignore */ function __catspeak_instr_get_s_empty__() { return "" }
/** @ignore */ function __catspeak_instr_get_s_star__() { return "*" }
/** @ignore */ function __catspeak_instr_get_s_slash__() { return "/" }
/** @ignore */ function __catspeak_instr_get_s_x__() { return "x" }
/** @ignore */ function __catspeak_instr_get_s_y__() { return "y" }
/** @ignore */ function __catspeak_instr_get_u__() { return undefined }
