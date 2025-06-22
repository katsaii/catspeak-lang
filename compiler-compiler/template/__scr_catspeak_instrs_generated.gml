//# feather use syntax-errors
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_name = instr['name-short'] or instr['name'] %}
{%  if "comptime" in instr %}

/// @ignore
function __catspeak_instr_{{ case_snake(instr_name) }}__() {
    return {{ gml_instr_get_comptime_vm(instr) }};
}
{%  endif %}
{% endfor %}

function __catspeak_const_value__() {
    return value;
}