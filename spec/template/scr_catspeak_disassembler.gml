//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.

//# feather use syntax-errors

{% set meta = spec["meta"] -%}
{% set instrs = spec["instrs"] -%}

/// TODO
function catspeak_cart_disassemble(buff, offset = undefined) {
    static disassembler = new __CatspeakCartDisassembler();
    disassembler.setTarget(buff);
    do {
        var moreRemains = disassembler.readInstr();
    } until (!moreRemains);
    var disassembly = disassembler.asmStr;
    disassembler.asmStr = undefined;
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() : CatspeakCartReader() constructor {
    self.asmStr = undefined;
    self.indent = "\n  ";
    self.__handleMeta__ = function ({{ map(gml_name, map(fn_field("name"), meta) ) | join(", ") }}) {
        asmStr = ""
{% for item in meta %}
        asmStr += "#[{{ item['name'] }}=" + string({{ gml_name(item['name']) }}) + "]\n";
{% endfor %}
        asmStr += "fun () do";
    };
{% for instr in instrs["set"] %}
{%  set name_handler = "__handle" + case_camel_upper(instr["name"]) + "__" %}
{%  set name_instr = instr["name-short"] %}
{%  set instr_args = instr.get("args", []) %}
    self.{{ name_handler }} = function ({{ map(fn_field("name"), instr_args) | join(", ") }}) {
        asmStr += indent + "{{ name_instr }}";
{%  for arg in instr_args %}
        asmStr += "    " + string({{ arg["name"] }});
{%  endfor %}
    };
{% endfor %}
}
