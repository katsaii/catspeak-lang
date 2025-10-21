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
        {{ join(", ", args(MetaItem.enum(ir))) }}
    ) {
        isAlive = true;
        exprStack = ds_stack_create();
        funcs = ds_list_create();
        ctx = {
            globals : globals ?? { },
            callee_ : undefined,
            self_ : undefined,
            other_ : undefined,
{% for meta in MetaItem.enum(ir) %}
            {{ meta.name_id }} : {{ meta.name_id }},
{% endfor %}
        };
    };

    /// @ignore
    static handleFunc = function (idx) {
        var body = ds_stack_pop(exprStack);
        __catspeak_assert(body != undefined,
            "unbalanced stack! function is missing body"
        );
        var func;
        func = method({
            body : body,
        }, __catspeak_function_simple__);
        funcs[| idx] = func;
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
        var {{ arg.name }} = array_create({{ arg.many }});
        for (var i = array_length({{ arg.name }}) - 1; i >= 0; i -= 1) {
            {{ arg.name }}[@ i] = ds_stack_pop(exprStack_);
        }
{%   else %}
        var {{ arg.name }} = ds_stack_pop(exprStack_);
{%   endif %}
{%  endfor %}
        var exec;
{%  if instr.comptime %}
{#   special case for inlined arguments #}
{%   for inlined in InstrInlineItem.enum(instr.ir) %}
        if (
{%-   for name, value_lit in inlined.conditions.items() -%}
            {{- name }} == {{ value_lit -}}
            {{- " && " if not loop.last else "" -}}
{%-   endfor -%}
        ) {
            exec = __genExpr({
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
        exec = __genExpr({
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
        exec = __genExpr{{ case_camel_upper(instr.name) }}({{
            join(", ",
                args(InstrArgItem.enum(instr.ir)) +
                args(InstrStackargItem.enum(instr.ir))
            )
        }});
{%  endif %}
{%  if instr.exceptional %}
        // TODO :: debug information
{%  endif %}
        ds_stack_push(exprStack_, exec);
    };
{% endfor %}
}

/// @ignore
function __catspeak_function_simple__() {
    return body();
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