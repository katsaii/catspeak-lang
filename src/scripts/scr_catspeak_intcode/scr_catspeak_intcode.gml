//! Boilerplate for the [CatspeakIntcode] enum.

// NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Represents a kind of Catspeak VM instruction.
enum CatspeakIntcode {
    CALLSPAN,
    CALL,
    SELF,
    JMP,
    JMPF,
    RET,
    MOV,
    LDC,
    LDA,
    GSET,
    GGET,
}

/// Gets the name for a value of [CatspeakIntcode].
/// Will return `<unknown>` if the value is unexpected.
///
/// @param {Enum.CatspeakIntcode} value
///   The value of [CatspeakIntcode] to convert.
///
/// @return {String}
function catspeak_intcode_show(value) {
    switch (value) {
    case CatspeakIntcode.CALLSPAN:
        return "CALLSPAN";
    case CatspeakIntcode.CALL:
        return "CALL";
    case CatspeakIntcode.SELF:
        return "SELF";
    case CatspeakIntcode.JMP:
        return "JMP";
    case CatspeakIntcode.JMPF:
        return "JMPF";
    case CatspeakIntcode.RET:
        return "RET";
    case CatspeakIntcode.MOV:
        return "MOV";
    case CatspeakIntcode.LDC:
        return "LDC";
    case CatspeakIntcode.LDA:
        return "LDA";
    case CatspeakIntcode.GSET:
        return "GSET";
    case CatspeakIntcode.GGET:
        return "GGET";
    }
    return "<unknown>";
}

/// Parses a string into a value of [CatspeakIntcode].
/// Will return `undefined` if the value cannot be parsed.
///
/// @param {Any} str
///   The string to parse.
///
/// @return {Enum.CatspeakIntcode}
function catspeak_intcode_read(str) {
    switch (str) {
    case "CALLSPAN":
        return CatspeakIntcode.CALLSPAN;
    case "CALL":
        return CatspeakIntcode.CALL;
    case "SELF":
        return CatspeakIntcode.SELF;
    case "JMP":
        return CatspeakIntcode.JMP;
    case "JMPF":
        return CatspeakIntcode.JMPF;
    case "RET":
        return CatspeakIntcode.RET;
    case "MOV":
        return CatspeakIntcode.MOV;
    case "LDC":
        return CatspeakIntcode.LDC;
    case "LDA":
        return CatspeakIntcode.LDA;
    case "GSET":
        return CatspeakIntcode.GSET;
    case "GGET":
        return CatspeakIntcode.GGET;
    }
    return undefined;
}

/// Returns the integer representation for a value of [CatspeakIntcode].
/// Will return `undefined` if the value is unexpected.
///
/// @param {Enum.CatspeakIntcode} value
///   The value of [CatspeakIntcode] to convert.
///
/// @return {Real}
function catspeak_intcode_valueof(value) {
    gml_pragma("forceinline");
    return value;
}

/// Returns the number of elements of [CatspeakIntcode].
///
/// @return {Real}
function catspeak_intcode_sizeof() {
    gml_pragma("forceinline");
    return CatspeakIntcode.GGET + 1;
}
