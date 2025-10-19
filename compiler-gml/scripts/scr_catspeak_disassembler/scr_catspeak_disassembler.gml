// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/compiler-gml/scripts/scr_catspeak_disassembler/scr_catspeak_disassembler.gml

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
        name, author, version, versionMinor, patch, path, date
    ) {
        if (name != "untitled") {
            out += "-- name:  " + string(name) + "\n";
        }
        if (author != "") {
            out += "-- author:  " + string(author) + "\n";
        }
        if (version != 1) {
            out += "-- version:  " + string(version) + "\n";
        }
        if (versionMinor != 0) {
            out += "-- version-minor:  " + string(versionMinor) + "\n";
        }
        if (patch != 0) {
            out += "-- patch:  " + string(patch) + "\n";
        }
        if (path != "") {
            out += "-- path:  " + string(path) + "\n";
        }
        if (date != 0) {
            out += "-- date:  " + string(date) + "\n";
        }
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

    /// @ignore
    static handleInstrConstNumber = function (dbg, value) {
        out += "\n  get_n";
        out += "  " + string(value);
        __writeDbg(dbg);
    };
}