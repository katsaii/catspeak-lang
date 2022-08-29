//! Boilerplate for the `CatspeakIntcode` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Represents a kind of Catspeak VM instruction.
enum CatspeakIntcode {
    PUSH,
    POP,
    VAR_GET,
    VAR_SET,
    REF_GET,
    REF_SET,
    ARG_GET,
    MAKE_ARRAY,
    MAKE_OBJECT,
    MAKE_FUNCTION,
    MAKE_ITERATOR,
    UPDATE_ITERATOR,
    PRINT,
    RETURN,
    RETURN_IMPLICIT,
    CALL,
    JUMP,
    JUMP_FALSE,
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
    case CatspeakIntcode.PUSH:
        return "PUSH";
    case CatspeakIntcode.POP:
        return "POP";
    case CatspeakIntcode.VAR_GET:
        return "VAR_GET";
    case CatspeakIntcode.VAR_SET:
        return "VAR_SET";
    case CatspeakIntcode.REF_GET:
        return "REF_GET";
    case CatspeakIntcode.REF_SET:
        return "REF_SET";
    case CatspeakIntcode.ARG_GET:
        return "ARG_GET";
    case CatspeakIntcode.MAKE_ARRAY:
        return "MAKE_ARRAY";
    case CatspeakIntcode.MAKE_OBJECT:
        return "MAKE_OBJECT";
    case CatspeakIntcode.MAKE_FUNCTION:
        return "MAKE_FUNCTION";
    case CatspeakIntcode.MAKE_ITERATOR:
        return "MAKE_ITERATOR";
    case CatspeakIntcode.UPDATE_ITERATOR:
        return "UPDATE_ITERATOR";
    case CatspeakIntcode.PRINT:
        return "PRINT";
    case CatspeakIntcode.RETURN:
        return "RETURN";
    case CatspeakIntcode.RETURN_IMPLICIT:
        return "RETURN_IMPLICIT";
    case CatspeakIntcode.CALL:
        return "CALL";
    case CatspeakIntcode.JUMP:
        return "JUMP";
    case CatspeakIntcode.JUMP_FALSE:
        return "JUMP_FALSE";
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
    case "PUSH":
        return CatspeakIntcode.PUSH;
    case "POP":
        return CatspeakIntcode.POP;
    case "VAR_GET":
        return CatspeakIntcode.VAR_GET;
    case "VAR_SET":
        return CatspeakIntcode.VAR_SET;
    case "REF_GET":
        return CatspeakIntcode.REF_GET;
    case "REF_SET":
        return CatspeakIntcode.REF_SET;
    case "ARG_GET":
        return CatspeakIntcode.ARG_GET;
    case "MAKE_ARRAY":
        return CatspeakIntcode.MAKE_ARRAY;
    case "MAKE_OBJECT":
        return CatspeakIntcode.MAKE_OBJECT;
    case "MAKE_FUNCTION":
        return CatspeakIntcode.MAKE_FUNCTION;
    case "MAKE_ITERATOR":
        return CatspeakIntcode.MAKE_ITERATOR;
    case "UPDATE_ITERATOR":
        return CatspeakIntcode.UPDATE_ITERATOR;
    case "PRINT":
        return CatspeakIntcode.PRINT;
    case "RETURN":
        return CatspeakIntcode.RETURN;
    case "RETURN_IMPLICIT":
        return CatspeakIntcode.RETURN_IMPLICIT;
    case "CALL":
        return CatspeakIntcode.CALL;
    case "JUMP":
        return CatspeakIntcode.JUMP;
    case "JUMP_FALSE":
        return CatspeakIntcode.JUMP_FALSE;
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
    return value;
}

/// Returns the number of elements of `CatspeakIntcode`.
///
/// @return {Real}
function catspeak_intcode_sizeof() {
    return CatspeakIntcode.JUMP_FALSE + 1;
}
