//! TODO

//# feather use syntax-errors

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
{% for section_name, section in ir_enumerate(ir, "data") %}
{%  set section_handler = gml_var_ref(section_name, "handle") %}

    /// @ignore
{%  if section_name == "func" %}
{%   set funcvar_args = map(fn_field(0), ir_enumerate(ir["data"], "func")) %}
    static {{ section_handler }} = function (idx, {{ gml_func_args_var_ref(funcvar_args, None) }}) {
        funcData[@ idx] = {
{%   for arg_name, _ in ir_enumerate(ir["data"], "func") %}
{%    set arg_varname = gml_var_ref(arg_name, None) %}
            {{ arg_varname }} : {{ arg_varname }}
{%   endfor %}
        };
    };
{%  endif %}
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
{% if instr["stackargs"] %}
        // unpack stack args in reverse order
{%  for stackarg in instr["stackargs"][::-1] %}
{%   set stackarg_name = gml_var_ref(stackarg["name"], None) %}
        var {{ stackarg_name }} = popValue();
{%  endfor %}
{% endif %}
        var exec = method({
            ctx : ctx,
{% for arg in instr["args"] %}
{%  set arg_name = gml_var_ref(arg["name"], None) %}
            {{ arg_name }} : {{ arg_name }},
{% endfor %}
{% for stackarg in instr["stackargs"] %}
{%  set stackarg_name = gml_var_ref(stackarg["name"], None) %}
            {{ stackarg_name }} : {{ stackarg_name }},
{% endfor %}
        }, __catspeak_instr_{{ case_snake(instr_name) }}__);
        pushValue(exec);
    };
{% endfor %}
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
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_name = instr['name-short'] or instr['name'] %}

/// @ignore
function __catspeak_instr_{{ case_snake(instr_name) }}__() {
    // {{ instr["desc"] }}
{%  if "comptime" in instr %}
{%   for stackarg in instr["stackargs"] %}
    var {{ stackarg["name"] }} = self.{{ stackarg["name"] }}();
{%   endfor %}
    return {{ instr["comptime"] }};
{%  elif instr_name == "ret" %}
    var returnBox = __catspeak_gml_exec_get_return();
    returnBox[@ 0] = result();
    throw returnBox;
{%  else %}
    // TODO
{%  endif %}
}
{% endfor %}