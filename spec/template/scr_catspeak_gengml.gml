//! TODO

//# feather use syntax-errors

{% set meta = spec["meta"] -%}
{% set instrs = spec["instrs"] -%}

/// TODO
function CatspeakCodegenGML() constructor {
    /// @ignore
    self.stack = array_create(32);
    /// @ignore
    self.stackTop = -1;

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
    static handleMeta = function ({{ map(gml_name, map(fn_field("name"), meta) ) | join(", ") }}) {
        // TODO
    };
{% for instr in instrs["set"] %}
{%  set name_handler = "handle" + case_camel_upper(instr["name"]) %}
{%  set instr_args = instr.get("args", []) %}

    /// @ignore
    static {{ name_handler }} = function ({{ map(fn_field("name"), instr_args) | join(", ") }}) {
        asmStr += indent + "{{ name_instr }}";
{%  for arg in instr_args %}
        asmStr += "    " + string({{ arg["name"] }});
{%  endfor %}
    };
{% endfor %}
}