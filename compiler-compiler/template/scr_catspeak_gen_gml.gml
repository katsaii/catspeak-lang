//! TODO

//# feather use syntax-errors

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
{% for section_name, section in ir_enumerate(ir, "data") %}
{%  set section_handler = gml_var_ref(section_name, "handle") %}

    /// @ignore
{%  if section_name == "meta" %}
{%   set metavar_args = map(fn_field(0), ir_enumerate(ir["data"], "meta")) %}
    static {{ section_handler }} = function ({{ gml_func_args_var_ref(metavar_args, None) }}) {
        var ctx_ = ctx;
{%   for meta_name, _ in ir_enumerate(ir["data"], "meta") %}
{%    set meta_varname = gml_var_ref(meta_name, "meta") %}
{%    set meta_argname = gml_var_ref(meta_name, None) %}
        ctx_.{{ meta_varname }} = {{ meta_argname }};
{%   endfor %}
    };
{%  endif %}
{% endfor %}

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
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_handler = gml_var_ref(instr["name"], "handleInstr") %}
{%  set instr_name = instr['name-short'] or instr['name'] %}
{%  set instrarg_args = map(fn_field("name"), instr["args"]) %}

    /// @ignore
    static {{ instr_handler }} = function ({{ gml_func_args_var_ref(instrarg_args, None) }}) {
        var exec;
{%  if instr["stackargs"] %}
{%   if len(instr["stackargs"]) > 1 %}
        // unpack stack args in reverse order
{%   endif %}
{%   for stackarg in instr["stackargs"][::-1] %}
{%    set stackarg_name = gml_var_ref(stackarg["name"], None) %}
{%    if "many" in stackarg %}
{%     set many_name = stackarg["many"] %}
        var {{ stackarg_name }}N = {{ many_name }};
        var {{ stackarg_name }} = array_create({{ stackarg_name }}N);
        for (var i = {{ stackarg_name }}N - 1; i >= 0; i -= 1) {
            {{ stackarg_name }}[@ i] = popValue();
        }
{%    else %}
        var {{ stackarg_name }} = popValue();
{%    endif %}
{%   endfor %}
{%   for arg in instr["args"] %}
{%    set arg_name = gml_var_ref(arg["name"], None) %}
{%    for arg_variant in arg["inline-variants"] %}
        if ({{ arg_name }} == {{ gml_literal(arg["type"], arg_variant) }}) {
            exec = method({
                ctx : ctx,
{%       for arg2 in instr["args"] %}
{%        set arg2_name = gml_var_ref(arg2["name"], None) %}
{%        if arg_name != arg2_name %}
                {{ arg2_name }} : {{ arg2_name }},
{%        endif %}
{%       endfor %}
{%       for stackarg in instr["stackargs"] %}
{%        set stackarg_name = gml_var_ref(stackarg["name"], None) %}
                {{ stackarg_name }} : {{ stackarg_name }},
{%       endfor %}
            }, __catspeak_instr_{{ case_snake(instr_name) }}_{{ arg_variant }}__);
        } else
{%    endfor %}
{%   endfor %}
{%   for stackarg in instr["stackargs"][::-1] %}
{%    set stackarg_name = gml_var_ref(stackarg["name"], None) %}
{%    if "many-inline" in stackarg %}
{%     for stackarg_i in range(0, stackarg["many-inline"]) %}
        if ({{ stackarg_name }}N == {{ stackarg_i }}) {
            exec = method({
                ctx : ctx,
{%      for arg in instr["args"] %}
{%       set arg_name = gml_var_ref(arg["name"], None) %}
                {{ arg_name }} : {{ arg_name }},
{%      endfor %}
{%      for stackarg2 in instr["stackargs"] %}
{%       set stackarg_name2 = gml_var_ref(stackarg2["name"], None) %}
{%       if stackarg_name2 != stackarg_name %}
                {{ stackarg_name2 }} : {{ stackarg_name2 }},
{%       else %}
{%        for stackarg_i2 in range(0, stackarg_i) %}
                {{ stackarg_name }}{{ stackarg_i2 }} : {{ stackarg_name }}[{{ stackarg_i2 }}],
{%        endfor %}
{%       endif %}
{%      endfor %}
            }, __catspeak_instr_{{ case_snake(instr_name) }}_{{ stackarg_name }}_{{ stackarg_i }}__);
        } else
{%     endfor %}
{%    endif %}
{%   endfor %}
{%  endif %}
        exec = method({
            ctx : ctx,
{%  for arg in instr["args"] %}
{%   set arg_name = gml_var_ref(arg["name"], None) %}
            {{ arg_name }} : {{ arg_name }},
{%  endfor %}
{%  for stackarg in instr["stackargs"] %}
{%   set stackarg_name = gml_var_ref(stackarg["name"], None) %}
            {{ stackarg_name }} : {{ stackarg_name }},
{%  endfor %}
        }, __catspeak_instr_{{ case_snake(instr_name) }}__);
{%  if "precalc-if" in instr %}
        if ({{ instr["precalc-if"] }}) {
            // pre-calculate the expression
            var execValue_ = exec();
            exec = method({
                ctx : ctx,
                value : execValue_,
            }, __catspeak_const_value__);
        }
{%  endif %}
        pushValue(exec);
    };
{% endfor %}
}