//! Responsible for disassembling a Catspeak cartridge and printing its content
//! in a human-readable bytecode format.
//!
//! @advanced
//! @experimental

//# feather use syntax-errors

/// Disassembles a supplied Catspeak cartridge into a string.
///
/// @warning
///   This should only be used for debug purposes.
///
/// @returns {String}
function catspeak_cart_disassemble(cart, offset = undefined) {
    static disassembler = new __CatspeakCartDisassembler();
    var cartStart = buffer_tell(cart);
    if (offset != undefined) {
        buffer_seek(cart, buffer_seek_start, offset);
    }
    var disassembly
    try {
        var reader = new CatspeakCartReader(cart, disassembler);
        do {
            var keepReading = reader.readInstr();
        } until (!keepReading);
    } catch (err_) {
        __catspeak_error(__catspeak_cat(
            "failed to disassemble cartridge: ", err_.message, "\n",
            "partial disassembly:\n", disassembler.out
        ));
    } finally {
        disassembly = disassembler.finalise();
        buffer_seek(cart, buffer_seek_start, cartStart);
    }
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    out = "";

    /// @ignore
    static finalise = function () {
        var disasm = out == "" ? "-- empty" : out;
        out = "";
        return disasm;
    };

    /// @ignore
    static handleMeta = function ({{ join(", ", ir_enum_ids(ir, "meta")) }}) {
{% for meta_name, meta in ir_enum(ir, "meta") %}
{%  set meta_id = case_camel(meta_name) %}
{%  set meta_value = type_to_gml_literal(meta["type"], meta["default"]) %}
        if ({{ meta_id }} != {{ meta_value }}) {
            out += "-- {{ meta_name }}:  " + string({{ meta_id }}) + "\n";
        }
{% endfor %}
    };

    /// @ignore
    static handleInclude = function (path, alias) {
        out += "include " + string(path);
        out += "as " + (alias == CATSPEAK_CURRENT_MODULE ? "self" : string(alias));
        out += "\n";
    };

    /// @ignore
    static handleFunc = function ({{ join(", ", ["idx"], ir_enum_ids(ir, "func")) }}) {
        out += "\nfun " + string(idx) + "\n";
{% for func_name, func in ir_enum(ir, "func") %}
{%  set func_id = case_camel(func_name) %}
        out += "--^ {{ func_name }}:  " + string({{ func_id }}) + "\n";
{% endfor %}
    };

    /// @ignore
    static __writeDbg = function (dbg) {
        if (dbg != CATSPEAK_NOLOCATION) {
            out += "  \t-- " + string(catspeak_location_get_row(dbg));
            out += ":" + string(catspeak_location_get_column(dbg));
        }
    };
{% for _, instr in ir_enum(ir, "instr-ops") %}

    /// @ignore
    static handleInstr{{ case_camel_upper(instr["name"]) }} = function ({{
        join(", ", ["dbg"], ir_enum_ids(instr, "args"))
    }}) {
        out += "\n  {{ instr['name-short'] or instr['name'] }}";
{%  for _, arg in ir_enum(instr, "args") %}
        out += "  " + {{ type_to_gml_format(arg["type"], arg["name"]) }};
{%  endfor %}
        __writeDbg(dbg);
    };
{% endfor %}
}