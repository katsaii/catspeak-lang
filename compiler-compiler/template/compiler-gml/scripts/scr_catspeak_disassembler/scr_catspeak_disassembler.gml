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
    var disassembly
    try {
        var reader = new CatspeakCartReader(buff, disassembler);
        do {
            var keepReading = reader.readInstr();
        } until (!keepReading);
        disassembly = disassembler.out;
        if (disassembly == "") { disassembly = "-- empty" }
    } catch (err_) {
        __catspeak_error(__catspeak_cat(
            "failed to disassemble cartridge: ", err_.message, "\n",
            "partial disassembly:\n", disassembler.out
        ));
    } finally {
        disassembler.out = "";
        buffer_seek(buff, buffer_seek_start, buffStart);
    }
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    out = "";

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
        out += "\nfun f" + string(idx) + "\n";
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
        out += "  " + string({{ arg.name_id }});
{%  endfor %}
        __writeDbg(dbg);
    };
{% endfor %}
}