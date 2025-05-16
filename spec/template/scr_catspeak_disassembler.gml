//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

//# feather use syntax-errors

{% set meta = spec["meta"] -%}
{% set instrs = spec["instrs"] -%}

/// TODO
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
    disassembler.asmStr = undefined;
    buffer_seek(buff, buffer_seek_start, buffStart);
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    self.asmStr = undefined;
    /// @ignore
    self.indent = "\n  ";

    /// @ignore
    static handleMeta = function ({{ map(gml_name, map(fn_field("name"), meta) ) | join(", ") }}) {
        asmStr = ""
{% for item in meta %}
        asmStr += "#[{{ item['name'] }}=" + string({{ gml_name(item['name']) }}) + "]\n";
{% endfor %}
        asmStr += "fun () do";
    };
{% for instr in instrs["set"] %}
{%  set name_handler = "handle" + case_camel_upper(instr["name"]) %}
{%  set name_instr = instr["name-short"] %}
{%  set instr_args = instr.get("args", []) %}

    /// @ignore
    static {{ name_handler }} = function ({{ map(fn_field("name"), instr_args) | join(", ") }}) {
        asmStr += indent + "{{ name_instr }}";
{%  for arg in instr_args %}
{%   if arg["name"] != "location" %}
        asmStr += "    " + string({{ arg["name"] }});
{%   endif %}
{%  endfor %}
    };
{% endfor %}
}