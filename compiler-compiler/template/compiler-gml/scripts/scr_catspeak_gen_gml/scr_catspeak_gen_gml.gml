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

{% for instr in InstrItem.enum(ir) %}
    /// @ignore
    static {{ instr.name_handler }} = function ({{
        join(", ", ["dbg"] + args(InstrArgItem.enum(instr.ir)))
    }}) {
        var exec;
        exec = method({
            ctx : ctx,
            // TODO :: debug information
{%  for arg in InstrArgItem.enum(instr.ir) %}
            {{ arg.name_id }} : {{ arg.name_id }},
{%  endfor %}
        }, __catspeak_instr_{{ case_snake(instr.name_short) }}__);
        ds_stack_push(exprStack, exec);
    };
{% endfor %}
}

/// @ignore
function __catspeak_function_simple__() {
    return body();
}

{% for instr in InstrItem.enum(ir) %}
{%  if instr.comptime != None %}
{%   set ns = namespace(ctstr = instr.comptime) %}
{%   for arg in InstrArgItem.enum(instr.ir) %}
{%    set ns.ctstr = ns.ctstr.replace("$" + arg.name + "$", arg.name_id) %}
{%   endfor %}
/// @ignore
function __catspeak_instr_{{ case_snake(instr.name_short) }}__() {
    return {{ ns.ctstr }};
}
{%  endif %}
{% endfor %}