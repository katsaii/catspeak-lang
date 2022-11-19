//! Boilerplate for the [__CatspeakASCIIDesc] enum.

//NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// @ignore
enum __CatspeakASCIIDesc {
    NONE = 0,
    NEWLINE = (1 << 0),
    WHITESPACE = (1 << 1),
    ALPHABETIC = (1 << 2),
    DIGIT = (1 << 3),
    OPERATOR = (1 << 4),
    GRAPHIC = (1 << 5),
    IDENT = (1 << 6),
    ALL = (
        __CatspeakASCIIDesc.NONE
        | __CatspeakASCIIDesc.NEWLINE
        | __CatspeakASCIIDesc.WHITESPACE
        | __CatspeakASCIIDesc.ALPHABETIC
        | __CatspeakASCIIDesc.DIGIT
        | __CatspeakASCIIDesc.OPERATOR
        | __CatspeakASCIIDesc.GRAPHIC
        | __CatspeakASCIIDesc.IDENT
    ),
}

/// @ignore
function __catspeak_ascii_desc_contains(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) == flags;
}

/// @ignore
function __catspeak_ascii_desc_equals(value, flags) {
    gml_pragma("forceinline");
    return value == flags;
}

/// @ignore
function __catspeak_ascii_desc_intersects(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) != 0;
}

/// @ignore
function __catspeak_ascii_desc_show(value) {
    var msg = "";
    var delimiter = undefined;
    if ((value & __CatspeakASCIIDesc.NEWLINE) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "NEWLINE";
    }
    if ((value & __CatspeakASCIIDesc.WHITESPACE) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "WHITESPACE";
    }
    if ((value & __CatspeakASCIIDesc.ALPHABETIC) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "ALPHABETIC";
    }
    if ((value & __CatspeakASCIIDesc.DIGIT) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "DIGIT";
    }
    if ((value & __CatspeakASCIIDesc.OPERATOR) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "OPERATOR";
    }
    if ((value & __CatspeakASCIIDesc.GRAPHIC) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "GRAPHIC";
    }
    if ((value & __CatspeakASCIIDesc.IDENT) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "IDENT";
    }
    return msg;
}
