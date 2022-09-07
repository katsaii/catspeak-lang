//! Boilerplate for the `CatspeakIntcode` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Represents a kind of Catspeak VM instruction.
enum CatspeakIntcode {
    JMP,
    JMP_FALSE,
    MOV,
    LDC,
    IMPORT,
    ARG,
    CALL,
    CALL_SIMPLE,
    RET,
}

/// Gets the name for a value of `CatspeakIntcode`.
/// Will return `<unknown>` if the value is unexpected.
///
/// @param {Enum.CatspeakIntcode} value
///   The value of `CatspeakIntcode` to convert.
///
/// @return {String}
function catspeak_intcode_show(value) {
    switch (value) {
    case CatspeakIntcode.JMP:
        return "JMP";
    case CatspeakIntcode.JMP_FALSE:
        return "JMP_FALSE";
    case CatspeakIntcode.MOV:
        return "MOV";
    case CatspeakIntcode.LDC:
        return "LDC";
    case CatspeakIntcode.IMPORT:
        return "IMPORT";
    case CatspeakIntcode.ARG:
        return "ARG";
    case CatspeakIntcode.CALL:
        return "CALL";
    case CatspeakIntcode.CALL_SIMPLE:
        return "CALL_SIMPLE";
    case CatspeakIntcode.RET:
        return "RET";
    }
    return "<unknown>";
}

/// Parses a string into a value of `CatspeakIntcode`.
/// Will return `undefined` if the value cannot be parsed.
///
/// @param {Any} str
///   The string to parse.
///
/// @return {Enum.CatspeakIntcode}
function catspeak_intcode_read(str) {
    switch (str) {
    case "JMP":
        return CatspeakIntcode.JMP;
    case "JMP_FALSE":
        return CatspeakIntcode.JMP_FALSE;
    case "MOV":
        return CatspeakIntcode.MOV;
    case "LDC":
        return CatspeakIntcode.LDC;
    case "IMPORT":
        return CatspeakIntcode.IMPORT;
    case "ARG":
        return CatspeakIntcode.ARG;
    case "CALL":
        return CatspeakIntcode.CALL;
    case "CALL_SIMPLE":
        return CatspeakIntcode.CALL_SIMPLE;
    case "RET":
        return CatspeakIntcode.RET;
    }
    return undefined;
}

/// Returns the integer representation for a value of `CatspeakIntcode`.
/// Will return `undefined` if the value is unexpected.
///
/// @param {Enum.CatspeakIntcode} value
///   The value of `CatspeakIntcode` to convert.
///
/// @return {Real}
function catspeak_intcode_valueof(value) {
    gml_pragma("forceinline");
    return value;
}

/// Returns the number of elements of `CatspeakIntcode`.
///
/// @return {Real}
function catspeak_intcode_sizeof() {
    gml_pragma("forceinline");
    return CatspeakIntcode.RET + 1;
}
