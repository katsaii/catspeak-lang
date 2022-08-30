//! Boilerplate for the `CatspeakIntcode` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Represents a kind of Catspeak VM instruction.
enum CatspeakIntcode {
    JUMP,
    JUMP_FALSE,
    GET,
    GET_REF,
    SET,
    SET_REF,
    ARG,
    CALL,
    RETURN,
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
    case CatspeakIntcode.JUMP:
        return "JUMP";
    case CatspeakIntcode.JUMP_FALSE:
        return "JUMP_FALSE";
    case CatspeakIntcode.GET:
        return "GET";
    case CatspeakIntcode.GET_REF:
        return "GET_REF";
    case CatspeakIntcode.SET:
        return "SET";
    case CatspeakIntcode.SET_REF:
        return "SET_REF";
    case CatspeakIntcode.ARG:
        return "ARG";
    case CatspeakIntcode.CALL:
        return "CALL";
    case CatspeakIntcode.RETURN:
        return "RETURN";
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
    case "JUMP":
        return CatspeakIntcode.JUMP;
    case "JUMP_FALSE":
        return CatspeakIntcode.JUMP_FALSE;
    case "GET":
        return CatspeakIntcode.GET;
    case "GET_REF":
        return CatspeakIntcode.GET_REF;
    case "SET":
        return CatspeakIntcode.SET;
    case "SET_REF":
        return CatspeakIntcode.SET_REF;
    case "ARG":
        return CatspeakIntcode.ARG;
    case "CALL":
        return CatspeakIntcode.CALL;
    case "RETURN":
        return CatspeakIntcode.RETURN;
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
    return CatspeakIntcode.RETURN + 1;
}
