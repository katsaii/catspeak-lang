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
    static handleMeta = function (
        {{ join(", ", args(MetaItem.enum(ir))) }}
    ) {
{% for meta in MetaItem.enum(ir) %}
        if ({{ meta.name_id }} != {{ meta.value_lit }}) {
            out += "-- {{ meta.name }}:  " + string({{ meta.name_id }}) + "\n";
        }
{% endfor %}
    };

    /// @ignore
    static handleFunc = function (idx) {
        out += "\nfun " + string(idx) + "\n";
    };

    /// @ignore
    static __writeDbg = function (dbg) {
        if (dbg != CATSPEAK_NOLOCATION) {
            out += "  \t-- " + string(catspeak_location_get_row(dbg));
            out += ":" + string(catspeak_location_get_column(dbg));
        }
    };
{% for instr in InstrItem.enum(ir) %}

    /// @ignore
    static {{ instr.name_handler }} = function ({{
        join(", ", ["dbg"] + args(InstrArgItem.enum(instr.ir)))
    }}) {
        out += "\n  {{ instr.name_short }}";
{%  for arg in InstrArgItem.enum(instr.ir) %}
        out += "  " + string({{ arg.name }});
{%  endfor %}
        __writeDbg(dbg);
    };
{% endfor %}
}