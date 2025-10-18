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
        disassembler.out = undefined;
        buffer_seek(buff, buffer_seek_start, buffStart);
    }
    return disassembly;
}

/// @ignore
function __CatspeakCartDisassembler() constructor {
    /// @ignore
    out = undefined;

    /// @ignore
    static handleMeta = function (meta) {
        out = "";
        var val;
{% for meta in MetaItem.enum(ir) %}
        val = meta.{{ meta.name_id }};
        if (val != {{ meta.value_lit }}) { out += "-- {{ meta.name }}:\t" + string(val) + "\n" }
{% endfor %}
    };
}