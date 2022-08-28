//! Boilerplate for the `CatspeakASCIIDesc` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Simple tags that identify ASCII characters read from a GML buffer.
enum CatspeakASCIIDesc {
    NONE = 0,
    NEWLINE = (1 << 0),
    WHITESPACE = (1 << 1),
    ALPHABETIC = (1 << 2),
    DIGIT = (1 << 3),
    DIGIT_HEX = (1 << 4),
    DIGIT_BIN = (1 << 5),
    OPERATOR = (1 << 6),
    GRAPHIC = (1 << 7),
    ALL = (
        CatspeakASCIIDesc.NONE
        | CatspeakASCIIDesc.NEWLINE
        | CatspeakASCIIDesc.WHITESPACE
        | CatspeakASCIIDesc.ALPHABETIC
        | CatspeakASCIIDesc.DIGIT
        | CatspeakASCIIDesc.DIGIT_HEX
        | CatspeakASCIIDesc.DIGIT_BIN
        | CatspeakASCIIDesc.OPERATOR
        | CatspeakASCIIDesc.GRAPHIC
    ),
}

/// Returns whether an instance of `CatspeakASCIIDesc` contains an expected flag.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakASCIIDesc} flags
///   The flags of `CatspeakASCIIDesc` to check.
///
/// @return {Bool}
function catspeak_asciidesc_contains(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) == flags;
}

/// Returns whether an instance of `CatspeakASCIIDesc` equals an expected flag.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakASCIIDesc} flags
///   The flags of `CatspeakASCIIDesc` to check.
///
/// @return {Bool}
function catspeak_asciidesc_equals(value, flags) {
    gml_pragma("forceinline");
    return value == flags;
}

/// Returns whether an instance of `CatspeakASCIIDesc` intersects a set of expected flags.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakASCIIDesc} flags
///   The flags of `CatspeakASCIIDesc` to check.
///
/// @return {Bool}
function catspeak_asciidesc_intersects(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) != 0;
}

/// Gets the name for a value of `CatspeakASCIIDesc`.
/// Will return the empty string if the value is unexpected.
///
/// @param {Enum.CatspeakASCIIDesc} value
///   The value of `CatspeakASCIIDesc` to convert, must be a numeric value.
///
/// @return {String}
function catspeak_asciidesc_show(value) {
    var msg = "";
    var delimiter = undefined;
    if ((value & CatspeakASCIIDesc.NEWLINE) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "NEWLINE";
    }
    if ((value & CatspeakASCIIDesc.WHITESPACE) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "WHITESPACE";
    }
    if ((value & CatspeakASCIIDesc.ALPHABETIC) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "ALPHABETIC";
    }
    if ((value & CatspeakASCIIDesc.DIGIT) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "DIGIT";
    }
    if ((value & CatspeakASCIIDesc.DIGIT_HEX) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "DIGIT_HEX";
    }
    if ((value & CatspeakASCIIDesc.DIGIT_BIN) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "DIGIT_BIN";
    }
    if ((value & CatspeakASCIIDesc.OPERATOR) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "OPERATOR";
    }
    if ((value & CatspeakASCIIDesc.GRAPHIC) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "GRAPHIC";
    }
    return msg;
}
