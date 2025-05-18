//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

//# feather use syntax-errors

/// Disassembles a supplied Catspeak cartridge into a string.
///
/// @experimental
///
/// @warning
///   This should only be used for debug purposes.
///
/// @returns {String}
function catspeak_cart_disassemble(buff, offset = undefined) {
    static disassembler = new __CatspeakCartDisassembler();
    var buffStart = buffer_tell(buff);
    if (offset != undefined) {
        buffer_seek(buff, buffer_seek_start, offset);
    }
    var reader = new CatspeakCartReader(buff, disassembler);
    do {
        var moreRemains = reader.readInstr();
    } until (!moreRemains);
    var disassembly = disassembler.asmStr;
    disassembler.asmStr = "";
    buffer_seek(buff, buffer_seek_start, buffStart);
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    asmStr = "";
{% for section_name, section in ir_enumerate(ir, "data") %}
{%  set section_handler = gml_var_ref(section_name, "handle") %}

    /// @ignore
{%  if section_name == "func" %}
{%   set funcvar_args = map(fn_field(0), ir_enumerate(ir["data"], "func")) %}
    static {{ section_handler }} = function (idx, {{ gml_func_args_var_ref(funcvar_args, None) }}) {
        // TODO
    };
{%  endif %}
{%  if section_name == "meta" %}
{%   set metavar_args = map(fn_field(0), ir_enumerate(ir["data"], "meta")) %}
    static {{ section_handler }} = function (idx, {{ gml_func_args_var_ref(metavar_args, None) }}) {
        // TODO
    };
{%  endif %}
{% endfor %}
{% for _, instr in ir_enumerate(ir, "instr") %}
{%  set instr_handler = gml_var_ref(instr["name"], "handleInstr") %}
{%  set instr_name = instr['name-short'] or instr['name'] %}
{%  set instrarg_args = map(fn_field("name"), instr["args"]) %}

    /// @ignore
    static {{ instr_handler }} = function ({{ gml_func_args_var_ref(instrarg_args, "arg") }}) {
        asmStr += "  {{ instr_name }}";
{% for arg in instr["args"] %}
{%  if arg["name"] != "dbg" %}
{%   set arg_name = gml_var_ref(arg["name"], "arg") %}
        asmStr += "  " + string({{ arg_name }});
{%  endif %}
{% endfor %}
        asmStr += "\n"
    };
{% endfor %}
}