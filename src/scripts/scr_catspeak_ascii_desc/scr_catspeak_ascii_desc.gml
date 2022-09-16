//! Boilerplate for the [CatspeakASCIIDesc] enum.

//NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Simple tags that identify ASCII characters read from a GML buffer.
enum CatspeakASCIIDesc {
    NONE = 0,
    NEWLINE = (1 << 0),
    WHITESPACE = (1 << 1),
    ALPHABETIC = (1 << 2),
    DIGIT = (1 << 3),
    OPERATOR = (1 << 4),
    GRAPHIC = (1 << 5),
    IDENT = (1 << 6),
    ALL = (
        CatspeakASCIIDesc.NONE
        | CatspeakASCIIDesc.NEWLINE
        | CatspeakASCIIDesc.WHITESPACE
        | CatspeakASCIIDesc.ALPHABETIC
        | CatspeakASCIIDesc.DIGIT
        | CatspeakASCIIDesc.OPERATOR
        | CatspeakASCIIDesc.GRAPHIC
        | CatspeakASCIIDesc.IDENT
    ),
}

/// Compares instances of [CatspeakASCIIDesc].
/// Returns whether one contains another.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakASCIIDesc} flags
///   The flags of [CatspeakASCIIDesc] to check.
///
/// @return {Bool}
function catspeak_ascii_desc_contains(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) == flags;
}

/// Compares instances of [CatspeakASCIIDesc].
/// Returns whether they are equal to each other.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakASCIIDesc} flags
///   The flags of [CatspeakASCIIDesc] to check.
///
/// @return {Bool}
function catspeak_ascii_desc_equals(value, flags) {
    gml_pragma("forceinline");
    return value == flags;
}

/// Compares instances of [CatspeakASCIIDesc].
/// Returns whether their flags intersect.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakASCIIDesc} flags
///   The flags of [CatspeakASCIIDesc] to check.
///
/// @return {Bool}
function catspeak_ascii_desc_intersects(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) != 0;
}

/// Gets the name for an instance of [CatspeakASCIIDesc].
/// Will return the empty string if the value is unexpected.
///
/// @param {Enum.CatspeakASCIIDesc} value
///   The value of [CatspeakASCIIDesc] to convert, must be a numeric value.
///
/// @return {String}
function catspeak_ascii_desc_show(value) {
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
    if ((value & CatspeakASCIIDesc.IDENT) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "IDENT";
    }
    return msg;
}
