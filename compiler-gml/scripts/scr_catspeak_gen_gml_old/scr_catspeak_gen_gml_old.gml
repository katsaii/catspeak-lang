// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir-outdated.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir-gml.py
//  - scr_catspeak_gen_gml.gml

//! TODO

//# feather use syntax-errors

/*
/// TODO
function CatspeakCodegenGML() constructor {
    /// @ignore
    stack = array_create(32);
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
        __catspeak_assert_eq(0, stackTop,
            "error occurred during compilation, values still remaining on the stack"
        );
        var programValue = popValue();
        return programValue(); // unwrap the program
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
    static handleInstrThrow = function (dbg) {
        var exec;
        var result = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            result : result,
        }, __catspeak_instr_thrw__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrCatch = function (idx, dbg) {
        var exec;
        // unpack stack args in reverse order
        var lazy = popValue();
        var eager = popValue();
        exec = method({
            ctx : ctx,
            idx : idx,
            dbg : dbg,
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_cat__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrUnwind = function (label, dbg) {
        var exec;
        var result = popValue();
        exec = method({
            ctx : ctx,
            label : label,
            dbg : dbg,
            result : result,
        }, __catspeak_instr_uwnd__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrCatchUnwind = function (label, dbg) {
        var exec;
        var body = popValue();
        exec = method({
            ctx : ctx,
            label : label,
            dbg : dbg,
            body : body,
        }, __catspeak_instr_cat_uwnd__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGetLocal = function (idx, dbg) {
        var exec;
        exec = method({
            ctx : ctx,
            idx : idx,
            dbg : dbg,
        }, __catspeak_instr_get_l__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSetLocal = function (idx, op, dbg) {
        var exec;
        var value = popValue();
        if (op == "multiply") {
            exec = method({
                ctx : ctx,
                idx : idx,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_l_multiply__);
        } else
        if (op == "divide") {
            exec = method({
                ctx : ctx,
                idx : idx,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_l_divide__);
        } else
        if (op == "add") {
            exec = method({
                ctx : ctx,
                idx : idx,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_l_add__);
        } else
        if (op == "subtract") {
            exec = method({
                ctx : ctx,
                idx : idx,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_l_subtract__);
        } else
        exec = method({
            ctx : ctx,
            idx : idx,
            op : op,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_set_l__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGetGlobal = function (name, dbg) {
        var exec;
        exec = method({
            ctx : ctx,
            name : name,
            dbg : dbg,
        }, __catspeak_instr_get_g__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSetGlobal = function (name, op, dbg) {
        var exec;
        var value = popValue();
        if (op == "multiply") {
            exec = method({
                ctx : ctx,
                name : name,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_g_multiply__);
        } else
        if (op == "divide") {
            exec = method({
                ctx : ctx,
                name : name,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_g_divide__);
        } else
        if (op == "add") {
            exec = method({
                ctx : ctx,
                name : name,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_g_add__);
        } else
        if (op == "subtract") {
            exec = method({
                ctx : ctx,
                name : name,
                dbg : dbg,
                value : value,
            }, __catspeak_instr_set_g_subtract__);
        } else
        exec = method({
            ctx : ctx,
            name : name,
            op : op,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_set_g__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSequence = function (n, dbg) {
        var exec;
        // unpack stack args in reverse order
        var result = popValue();
        var stmtsN = n - 1;
        var stmts = array_create(stmtsN);
        for (var i = stmtsN - 1; i >= 0; i -= 1) {
            stmts[@ i] = popValue();
        }
        if (stmtsN == 0) {
            exec = method({
                ctx : ctx,
                n : n,
                dbg : dbg,
                result : result,
            }, __catspeak_instr_seq_stmts_0__);
        } else
        if (stmtsN == 1) {
            exec = method({
                ctx : ctx,
                n : n,
                dbg : dbg,
                stmts0 : stmts[0],
                result : result,
            }, __catspeak_instr_seq_stmts_1__);
        } else
        if (stmtsN == 2) {
            exec = method({
                ctx : ctx,
                n : n,
                dbg : dbg,
                stmts0 : stmts[0],
                stmts1 : stmts[1],
                result : result,
            }, __catspeak_instr_seq_stmts_2__);
        } else
        if (stmtsN == 3) {
            exec = method({
                ctx : ctx,
                n : n,
                dbg : dbg,
                stmts0 : stmts[0],
                stmts1 : stmts[1],
                stmts2 : stmts[2],
                result : result,
            }, __catspeak_instr_seq_stmts_3__);
        } else
        if (stmtsN == 4) {
            exec = method({
                ctx : ctx,
                n : n,
                dbg : dbg,
                stmts0 : stmts[0],
                stmts1 : stmts[1],
                stmts2 : stmts[2],
                stmts3 : stmts[3],
                result : result,
            }, __catspeak_instr_seq_stmts_4__);
        } else
        exec = method({
            ctx : ctx,
            n : n,
            dbg : dbg,
            stmts : stmts,
            result : result,
        }, __catspeak_instr_seq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrIfThenElse = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var if_false = popValue();
        var if_true = popValue();
        var condition = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            condition : condition,
            if_true : if_true,
            if_false : if_false,
        }, __catspeak_instr_ifte__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrClosure = function (locals, dbg) {
        var exec;
        var body = popValue();
        exec = method({
            ctx : ctx,
            locals : locals,
            dbg : dbg,
            body : body,
        }, __catspeak_instr_fclo__);
        if (true) {
            // pre-calculate the expression
            var execValue_ = exec();
            exec = method({
                ctx : ctx,
                value : execValue_,
            }, __catspeak_const_value__);
        }
        pushValue(exec);
    };

    /// @ignore
    static handleInstrOr = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var lazy = popValue();
        var eager = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_or__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrXor = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_xor__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrAnd = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var lazy = popValue();
        var eager = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_and__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrEqual = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_eq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrNotEqual = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_neq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrLessThan = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_lt__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrLessThanOrEqualTo = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_leq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGreaterThan = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_gt__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrGreaterThanOrEqualTo = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_geq__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseAnd = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_band__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseOr = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bor__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseXor = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bxor__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseShiftLeft = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var amount = popValue();
        var value = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
            amount : amount,
        }, __catspeak_instr_lshift__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseShiftRight = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var amount = popValue();
        var value = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
            amount : amount,
        }, __catspeak_instr_rshift__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_add__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrSubtract = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_sub__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrMultiply = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_mult__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrDivide = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_div__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrDivideInt = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_idiv__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrRemainder = function (dbg) {
        var exec;
        // unpack stack args in reverse order
        var rhs = popValue();
        var lhs = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_rem__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrPositive = function (dbg) {
        var exec;
        var value = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_pos__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrNegative = function (dbg) {
        var exec;
        var value = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_neg__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrNot = function (dbg) {
        var exec;
        var value = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_not__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrBitwiseNot = function (dbg) {
        var exec;
        var value = popValue();
        exec = method({
            ctx : ctx,
            dbg : dbg,
            value : value,
        }, __catspeak_instr_bnot__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrConstNumber = function (value, dbg) {
        var exec;
        exec = method({
            ctx : ctx,
            value : value,
            dbg : dbg,
        }, __catspeak_instr_get_n__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrConstString = function (value, dbg) {
        var exec;
        exec = method({
            ctx : ctx,
            value : value,
            dbg : dbg,
        }, __catspeak_instr_get_s__);
        pushValue(exec);
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        var exec;
        exec = method({
            ctx : ctx,
            dbg : dbg,
        }, __catspeak_instr_get_u__);
        pushValue(exec);
    };
}