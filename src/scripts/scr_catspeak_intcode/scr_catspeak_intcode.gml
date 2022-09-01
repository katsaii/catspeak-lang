//! Boilerplate for the `CatspeakIntcode` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Represents a kind of Catspeak VM instruction.
enum CatspeakIntcode {
    JMP,
    JMP_FALSE,
    MOV,
    LDC,
    GLOBAL,
    ARR_GET,
    ARR_SET,
    OBJ_GET,
    OBJ_SET,
    ARG,
    CALL,
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
    case CatspeakIntcode.GLOBAL:
        return "GLOBAL";
    case CatspeakIntcode.ARR_GET:
        return "ARR_GET";
    case CatspeakIntcode.ARR_SET:
        return "ARR_SET";
    case CatspeakIntcode.OBJ_GET:
        return "OBJ_GET";
    case CatspeakIntcode.OBJ_SET:
        return "OBJ_SET";
    case CatspeakIntcode.ARG:
        return "ARG";
    case CatspeakIntcode.CALL:
        return "CALL";
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
    case "GLOBAL":
        return CatspeakIntcode.GLOBAL;
    case "ARR_GET":
        return CatspeakIntcode.ARR_GET;
    case "ARR_SET":
        return CatspeakIntcode.ARR_SET;
    case "OBJ_GET":
        return CatspeakIntcode.OBJ_GET;
    case "OBJ_SET":
        return CatspeakIntcode.OBJ_SET;
    case "ARG":
        return CatspeakIntcode.ARG;
    case "CALL":
        return CatspeakIntcode.CALL;
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
