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
    localsN = 0;
    /// @ignore
    hasDebug = false;
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
        {{ join(", ", args(MetaItem.enum(ir))) }}
    ) {
        isAlive = true;
        exprStack = ds_stack_create();
        funcs = ds_list_create();
        ctx = {
            globals : globals ?? { },
            stack : [],
            stackN : 0, // current stack size
            callee_ : undefined,
            self_ : undefined,
            other_ : undefined,
            dbg : CATSPEAK_NOLOCATION,
            meta : {
{% for meta in MetaItem.enum(ir) %}
                {{ meta.name_id }} : {{ meta.name_id }},
{% endfor %}
            },
        };
    };

    /// @ignore
    static handleFunc = function (idx) {
        var body = ds_stack_pop(exprStack);
        __catspeak_assert(body != undefined,
            "unbalanced stack! function is missing body"
        );
        if (hasDebug) {
            body = __genExpr({
                body : body,
            }, __catspeak_dbg_trace__);
        }
        var func;
        if (localsN > 0) {
            func = __genExpr({
                body : body,
                n : localsN,
            }, __catspeak_function__);
        } else {
            func = body;
        }
        funcs[| idx] = func;
        localsN = 0;
        hasDebug = false;
    };

    /// @ignore
    static __attachDbg = function (dbg, expr) {
        if (dbg == CATSPEAK_NOLOCATION) {
            return expr;
        } else {
            // insert instruction to track debug info
            hasDebug = true;
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

    /// @ignore
    static __localIdx2Offset = function (idx) { return -1 - idx }

    /// @ignore
    static __genExprGetLocal = function (idx) {
        localsN = max(localsN, idx + 1);
        return __genExpr({
            off : __localIdx2Offset(idx), // relative to the top of the stack
        }, __catspeak_instr_get_l__);
    };

    /// @ignore
    static __genExprSetLocal = function (flavour, idx, value) {
        localsN = max(localsN, idx + 1);
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_l__; break;
        case ord("+"): func = __catspeak_instr_set_l_add__; break;
        case ord("-"): func = __catspeak_instr_set_l_sub__; break;
        case ord("*"): func = __catspeak_instr_set_l_mul__; break;
        case ord("/"): func = __catspeak_instr_set_l_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            off : __localIdx2Offset(idx),
        }, func);
    };

    /// @ignore
    static __genExprGetGlobal = function (name) {
        return __genExpr({
            name : name,
        }, __catspeak_instr_get_g__);
    };

    /// @ignore
    static __genExprSetGlobal = function (flavour, name, value) {
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_g__; break;
        case ord("+"): func = __catspeak_instr_set_g_add__; break;
        case ord("-"): func = __catspeak_instr_set_g_sub__; break;
        case ord("*"): func = __catspeak_instr_set_g_mul__; break;
        case ord("/"): func = __catspeak_instr_set_g_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            name : name,
        }, func);
    };

    /// @ignore
    static __genExprGetIndex = function (data, idx) {
        return __genExpr({
            data : data,
            idx : idx,
        }, __catspeak_instr_get_i__);
    };

    /// @ignore
    static __genExprSetIndex = function (flavour, data, idx, value) {
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_i__; break;
        case ord("+"): func = __catspeak_instr_set_i_add__; break;
        case ord("-"): func = __catspeak_instr_set_i_sub__; break;
        case ord("*"): func = __catspeak_instr_set_i_mul__; break;
        case ord("/"): func = __catspeak_instr_set_i_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            data : data,
            idx : idx,
        }, func);
    };

    /// @ignore
    static __genExprThrow = function (value) {
        return __genExpr({
            value : value,
        }, __catspeak_instr_thrw__);
    };

    /// @ignore
    static __genExprCatch = function (idx, eager, lazy) {
        localsN = max(localsN, idx + 1);
        return __genExpr({
            off : __localIdx2Offset(idx),
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_cat__);
    };

    if (!variable_global_exists("__catspeakSharedUnwindBox")) {
        // guarantee the special unwind box exists if we're generating code
        global.__catspeakSharedUnwindBox = [undefined, undefined];
    }

    /// @ignore
    static __genExprUnwind = function (label, value) {
        return __genExpr({
            magicBox : global.__catspeakSharedUnwindBox,
            label : label,
            value : value,
        }, __catspeak_instr_uwnd__);
    };

    /// @ignore
    static __genExprUnwindLanding = function (label, body) {
        return __genExpr({
            magicBox : global.__catspeakSharedUnwindBox,
            label : label,
            body : body,
        }, __catspeak_instr_land__);
    };

    /// @ignore
    static __genExprLoopInf = function (body) {
        return __genExpr({
            body : body,
        }, __catspeak_instr_loop_inf__);
    };

    /// @ignore
    static __genExprLoop = function (cond, body) {
        return __genExpr({
            cond : cond,
            body : body,
        }, __catspeak_instr_loop__);
    };

    /// @ignore
    static __genExprLoopStep = function (cond, step, body) {
        return __genExpr({
            cond : cond,
            step : step,
            body : body,
        }, __catspeak_instr_loop_s__);
    };

    /// @ignore
    static __genExprLoopWith = function (cond, body) {
        return __genExpr({
            cond : cond,
            body : body,
        }, __catspeak_instr_loop_w__);
    };

    /// @ignore
    static __genExprArray_vers = undefined;
    static __genExprArray_versN = 0;
    if (__genExprArray_vers == undefined) {
        __genExprArray_vers = [
            __catspeak_instr_arr_0__,
            __catspeak_instr_arr_1__,
            __catspeak_instr_arr_2__,
            __catspeak_instr_arr_3__,
            __catspeak_instr_arr_4__,
            __catspeak_instr_arr_5__,
            __catspeak_instr_arr_6__,
            __catspeak_instr_arr_7__,
            __catspeak_instr_arr_8__,
            __catspeak_instr_arr_9__,
        ];
        __genExprArray_versN = array_length(__genExprArray_vers);
    }

    /// @ignore
    static __genExprArray = function (n, values) {
        var nStatic = min(n, __genExprArray_versN - 1);
        var closure_ = { };
        for (var i = 0; i < nStatic; i += 1) {
            closure_[$ "_" + string(i + 1)] = values[i];
        }
        if (n == nStatic) {
            return __genExpr(closure_, __genExprArray_vers[n]);
        } else {
            // encode values in reverse for (maybe) faster iteration
            var moreN = n - __genExprArray_versN + 1;
            var more = array_create(moreN);
            for (var i = 0; i < moreN; i += 1) {
                more[@ i] = values[n - 1 - i];
            }
            closure_.moreN = moreN;
            closure_.more = more;
            return __genExpr(closure_, __catspeak_instr_arr__);
        }
    };

    /// @ignore
    static __genExprStruct_vers = undefined;
    static __genExprStruct_versN = 0;
    if (__genExprStruct_vers == undefined) {
        __genExprStruct_vers = [
            __catspeak_instr_obj_0__,
            __catspeak_instr_obj_1__,
            __catspeak_instr_obj_2__,
            __catspeak_instr_obj_3__,
            __catspeak_instr_obj_4__,
        ];
        __genExprStruct_versN = array_length(__genExprStruct_vers);
    }

    /// @ignore
    static __genExprStruct = function (n, values) {
        __catspeak_assert(n % 2 == 0,
            "'obj' instructions must have an even number of 'values'"
        );
        n = n div 2;
        var nStatic = min(n, __genExprStruct_versN - 1);
        var closure_ = { };
        for (var i = 0; i < nStatic; i += 1) {
            closure_[$ "_k" + string(i + 1)] = values[i * 2];
            closure_[$ "_v" + string(i + 1)] = values[i * 2 + 1];
        }
        if (n == nStatic) {
            return __genExpr(closure_, __genExprStruct_vers[n]);
        } else {
            // encode values in reverse for (maybe) faster iteration
            var moreN = n - __genExprStruct_versN + 1;
            var more = array_create(moreN * 2);
            for (var i = 0; i < moreN; i += 1) {
                more[@ i * 2] = values[n - 2 - i];
                more[@ i * 2 + 1] = values[n - 1 - i];
            }
            closure_.moreN = moreN;
            closure_.more = more;
            return __genExpr(closure_, __catspeak_instr_obj__);
        }
    };

    // automatically generated code generation functions (here be dragons)
{% for instr in InstrItem.enum(ir) %}

    /// @ignore
    static {{ instr.name_handler }} = function ({{
        join(", ", ["dbg"] + args(InstrArgItem.enum(instr.ir)))
    }}) {
        var exprStack_ = exprStack;
{#  pop stackargs in reverse order #}
{%  for arg in list(InstrStackargItem.enum(instr.ir))[::-1] %}
{%   if arg.many %}
{#    pop many arguments and put them into an array #}
        var {{ arg.name }}__n = {{ arg.many }};
        var {{ arg.name }}__nGot = ds_stack_size(exprStack_);
        if ({{ arg.name }}__nGot < {{ arg.name }}__n) {
            __catspeak_error(__catspeak_cat(
                "not enough stack space for '{{ arg.name }}' argument of '{{ instr.name_id_op }}' instruction (expected ",
                {{ arg.name }}__n, ", got ", {{ arg.name }}__nGot, ")"
            ));
        }
        var {{ arg.name }} = array_create({{ arg.name }}__n);
        for (var i = {{ arg.name }}__n - 1; i >= 0; i -= 1) {
            {{ arg.name }}[@ i] = ds_stack_pop(exprStack_);
        }
{%   else %}
        var {{ arg.name }} = ds_stack_pop(exprStack_);
        __catspeak_assert({{ arg.name }} != undefined,
            "not enough stack space for '{{ arg.name }}' argument of '{{ instr.name_id_op }}' instruction"
        );
{%   endif %}
{%  endfor %}
        var expr;
{%  if instr.comptime %}
{#   special case for inlined arguments #}
{%   for inlined in InstrInlineItem.enum(instr.ir) %}
        if (
{%-   for name, value_lit in inlined.conditions.items() -%}
            {{- name }} == {{ value_lit -}}
            {{- " && " if not loop.last else "" -}}
{%-   endfor -%}
        ) {
            expr = __genExpr({
{%    for arg in InstrArgItem.enum(instr.ir) %}
{%     if arg.name not in inlined.conditions %}
                {{ arg.name }} : {{ arg.name }},
{%     endif %}
{%    endfor %}
{%    for arg in InstrStackargItem.enum(instr.ir) %}
                {{ arg.name }} : {{ arg.name }},
{%    endfor %}
            }, __catspeak_instr_{{ instr.name_id_op }}_{{ inlined.name }}__);
        } else
{%   endfor %}
{#   default case for instructions #}
{%   if InstrInlineItem.has_default_impl(instr.ir) %}
        expr = __genExpr({
{%    for arg in InstrArgItem.enum(instr.ir) %}
            {{ arg.name }} : {{ arg.name }},
{%    endfor %}
{%    for arg in InstrStackargItem.enum(instr.ir) %}
            {{ arg.name }} : {{ arg.name }},
{%    endfor %}
        }, __catspeak_instr_{{ instr.name_id_op }}__);
{%   else %}
        __catspeak_error(
            "instruction {{ instr.name_short }} has no implementation for the given args"
        );
{%   endif %}
{%  else %}
        expr = __genExpr{{ case_camel_upper(instr.name) }}({{
            join(", ",
                args(InstrArgItem.enum(instr.ir)) +
                args(InstrStackargItem.enum(instr.ir))
            )
        }});
{%  endif %}
{%  if instr.exceptional %}
        expr = __attachDbg(dbg, expr);
{%  endif %}
        ds_stack_push(exprStack_, expr);
    };
{% endfor %}
}

/// @ignore
function __catspeak_function__() {
    var ctx_ = ctx;
    var n_ = n;
    ctx_.stackN += n_;
    array_resize(ctx_.stack, ctx_.stackN);
    var result;
    try {
        result = body();
    } finally {
        ctx_.stackN -= n_;
        // NOTE :: enable this in the future if it matters
        //array_resize(ctx_.stack, ctx_.stackN);
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
function __catspeak_dbg_trace__() {
    var result;
    try {
        result = body();
    } catch (ex) {
        catspeak_location_trace(ex, ctx.dbg, ctx.meta.path);
        throw ex;
    }
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

/// @ignore
function __catspeak_instr_get_l__() {
    var ctx_ = ctx;
    return ctx_.stack[ctx_.stackN + off];
}

/// @ignore
function __catspeak_instr_set_l__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[ctx_.stackN + off] = value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_add__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[ctx_.stackN + off] += value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_sub__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[ctx_.stackN + off] -= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_mul__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[ctx_.stackN + off] *= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_div__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[ctx_.stackN + off] /= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_get_g__() { return ctx.globals[$ name] }

/// @ignore
function __catspeak_instr_set_g__() {
    var value_ = value();
    ctx.globals[$ name] = value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_add__() {
    var value_ = value();
    ctx.globals[$ name] += value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_sub__() {
    var value_ = value();
    ctx.globals[$ name] -= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_mul__() {
    var value_ = value();
    ctx.globals[$ name] *= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_div__() {
    var value_ = value();
    ctx.globals[$ name] /= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_get_i__() {
    var data_ = data();
    var idx_ = idx();
    if (is_array(data_)) {
        return data_[idx_];
    } else {
        return data_[$ idx_];
    }
}

/// @ignore
function __catspeak_instr_set_i__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[idx_] = value_;
    } else {
        data_[$ idx_] = value_;
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_add__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[idx_] += value_;
    } else {
        data_[$ idx_] += value_;
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_sub__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[idx_] -= value_;
    } else {
        data_[$ idx_] -= value_;
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_mul__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[idx_] *= value_;
    } else {
        data_[$ idx_] *= value_;
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_div__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[idx_] /= value_;
    } else {
        data_[$ idx_] /= value_;
    }
    return value_;
}

/// @ignore
function __catspeak_instr_thrw__() {
    throw value();
}

/// @ignore
function __catspeak_instr_cat__() {
    var ctx_ = ctx;
    var result;
    try {
        result = eager();
    } catch (ex) {
        // TODO :: let the special unwind boxed type pass through
        ctx_.stack[ctx_.stackN + off] = ex;
        result = lazy();
    }
    return result;
}

/// @ignore
function __catspeak_instr_uwnd__() {
    var box_ = magicBox;
    box_[@ 0] = label;
    box_[@ 1] = value();
    throw box_;
}

/// @ignore
function __catspeak_instr_land__() {
    var box_ = magicBox;
    var result;
    try {
        result = body();
    } catch (ex) {
        if (ex == box_ && box_[0] == label) {
            result = box_[1];
        } else {
            throw ex;
        }
    }
    return result;
}

/// @ignore
function __catspeak_instr_loop_inf__() {
    var body_ = body;
    while (true) {
        body_();
    }
}

/// @ignore
function __catspeak_instr_loop__() {
    var cond_ = cond;
    var body_ = body;
    while (cond_()) {
        body_();
    }
}

/// @ignore
function __catspeak_instr_loop_s__() {
    var cond_ = cond;
    var body_ = body;
    var step_ = step;
    while (cond_()) {
        body_();
        step_();
    }
}

/// @ignore
function __catspeak_instr_loop_w__() {
    var cond_ = cond;
    var body_ = body;
    with (cond_()) {
        body_();
    }
}

/// @ignore
function __catspeak_instr_arr_0__() { return [] }

/// @ignore
function __catspeak_instr_arr_1__() { return [_1()] }

/// @ignore
function __catspeak_instr_arr_2__() {
    var a1 = _1();
    return [a1, _2()];
}

/// @ignore
function __catspeak_instr_arr_3__() {
    var a1 = _1(); var a2 = _2();
    return [a1, a2, _3()];
}

/// @ignore
function __catspeak_instr_arr_4__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3();
    return [a1, a2, a3, _4()];
}

/// @ignore
function __catspeak_instr_arr_5__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    return [a1, a2, a3, a4, _5()];
}

/// @ignore
function __catspeak_instr_arr_6__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5();
    return [a1, a2, a3, a4, a5, _6()];
}

/// @ignore
function __catspeak_instr_arr_7__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6();
    return [a1, a2, a3, a4, a5, a6, _7()];
}

/// @ignore
function __catspeak_instr_arr_8__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7();
    return [a1, a2, a3, a4, a5, a6, a7, _8()];
}

/// @ignore
function __catspeak_instr_arr_9__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7(); var a8 = _8();
    return [a1, a2, a3, a4, a5, a6, a7, a8, _9()];
}

/// @ignore
function __catspeak_instr_arr__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7(); var a8 = _8();
    var arr = [a1, a2, a3, a4, a5, a6, a7, a8, _9()];
    var more_ = more;
    for (var i = moreN - 1; i >= 0; i -= 1) {
        var value = more_[i];
        arr[@ 10 + i] = value();
    }
    return arr;
}

/// @ignore
function __catspeak_instr_obj_0__() { return { } }

/// @ignore
function __catspeak_instr_obj_1__() {
    var k1 = _k1(); var v1 = _v1();
    var obj = { };
    obj[$ k1] = v1;
    return obj;
}

/// @ignore
function __catspeak_instr_obj_2__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    return obj;
}

/// @ignore
function __catspeak_instr_obj_3__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var k3 = _k3(); var v3 = _v3();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    obj[$ k3] = v3;
    return obj;
}

/// @ignore
function __catspeak_instr_obj_4__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var k3 = _k3(); var v3 = _v3(); var k4 = _k4(); var v4 = _v4();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    obj[$ k3] = v3;
    obj[$ k4] = v4;
    return obj;
}

/// @ignore
function __catspeak_instr_obj__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var k3 = _k3(); var v3 = _v3(); var k4 = _k4(); var v4 = _v4();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    obj[$ k3] = v3;
    obj[$ k4] = v4;
    var more_ = more;
    for (var i = moreN - 1; i >= 0; i -= 1) {
        var key = more_[i * 2];
        var value = more_[i * 2 + 1];
        var key_ = key();
        obj[$ key_] = value();
    }
    return obj;
}

// automatically generated instructions below (here be dragons)

{# generate comptime instructions #}
{% for instr in InstrItem.enum(ir) %}
{%  if instr.comptime != None %}
{%   set ns = namespace(expr = instr.comptime) %}
{%   for arg in InstrStackargItem.enum(instr.ir) %}
{%    set ns.expr = ns.expr.replace("$" + arg.name + "$", arg.name + "()") %}
{%   endfor %}
{%   set expr_stackargs = ns.expr %}
{%   if InstrInlineItem.has_default_impl(instr.ir) %}
{%    for arg in InstrArgItem.enum(instr.ir) %}
{%     set ns.expr = ns.expr.replace("$" + arg.name + "$", arg.name) %}
{%    endfor %}
/** @ignore */ function __catspeak_instr_{{ instr.name_id_op }}__() { return {{ ns.expr }} }
{%   endif %}
{#   special case for inlined arguments #}
{%   for inlined in InstrInlineItem.enum(instr.ir) %}
{%    set ns.expr = expr_stackargs %}
{%-   for name, value_lit in inlined.conditions.items() -%}
{%     set ns.expr = ns.expr.replace("$" + name + "$", value_lit) %}
{%    endfor %}
{%    for arg in InstrArgItem.enum(instr.ir) %}
{%     set ns.expr = ns.expr.replace("$" + arg.name + "$", arg.name) %}
{%    endfor %}
/** @ignore */ function __catspeak_instr_{{ instr.name_id_op }}_{{ inlined.name }}__() { return {{ ns.expr }} }
{%   endfor %}
{%  endif %}
{% endfor %}