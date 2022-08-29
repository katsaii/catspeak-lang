//! Boilerplate for the `CatspeakCompilerState` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Represents a kind of Catspeak parser production.
enum CatspeakCompilerState {
    PROGRAM,
    STATEMENT,
    SEQUENCE_BEGIN,
    SEQUENCE_END,
    SET_BEGIN,
    SET_END,
    IF_BEGIN,
    IF_ELSE,
    IF_END,
    WHILE_BEGIN,
    WHILE_END,
    FOR_BEGIN,
    FOR_END,
    FUN_BEGIN,
    FUN_END,
    BREAK,
    CONTINUE,
    RETURN,
    EXPRESSION,
    BINARY_BEGIN,
    BINARY_END,
    CALL_BEGIN,
    CALL_END,
    SUBSCRIPT_BEGIN,
    SUBSCRIPT_END,
    TERMINAL,
    GROUPING_BEGIN,
    GROUPING_END,
    ARRAY,
    OBJECT,
}

/// Gets the name for a value of `CatspeakCompilerState`.
/// Will return `<unknown>` if the value is unexpected.
///
/// @param {Enum.CatspeakCompilerState} value
///   The value of `CatspeakCompilerState` to convert.
///
/// @return {String}
function catspeak_compiler_state_show(value) {
    switch (value) {
    case CatspeakCompilerState.PROGRAM:
        return "PROGRAM";
    case CatspeakCompilerState.STATEMENT:
        return "STATEMENT";
    case CatspeakCompilerState.SEQUENCE_BEGIN:
        return "SEQUENCE_BEGIN";
    case CatspeakCompilerState.SEQUENCE_END:
        return "SEQUENCE_END";
    case CatspeakCompilerState.SET_BEGIN:
        return "SET_BEGIN";
    case CatspeakCompilerState.SET_END:
        return "SET_END";
    case CatspeakCompilerState.IF_BEGIN:
        return "IF_BEGIN";
    case CatspeakCompilerState.IF_ELSE:
        return "IF_ELSE";
    case CatspeakCompilerState.IF_END:
        return "IF_END";
    case CatspeakCompilerState.WHILE_BEGIN:
        return "WHILE_BEGIN";
    case CatspeakCompilerState.WHILE_END:
        return "WHILE_END";
    case CatspeakCompilerState.FOR_BEGIN:
        return "FOR_BEGIN";
    case CatspeakCompilerState.FOR_END:
        return "FOR_END";
    case CatspeakCompilerState.FUN_BEGIN:
        return "FUN_BEGIN";
    case CatspeakCompilerState.FUN_END:
        return "FUN_END";
    case CatspeakCompilerState.BREAK:
        return "BREAK";
    case CatspeakCompilerState.CONTINUE:
        return "CONTINUE";
    case CatspeakCompilerState.RETURN:
        return "RETURN";
    case CatspeakCompilerState.EXPRESSION:
        return "EXPRESSION";
    case CatspeakCompilerState.BINARY_BEGIN:
        return "BINARY_BEGIN";
    case CatspeakCompilerState.BINARY_END:
        return "BINARY_END";
    case CatspeakCompilerState.CALL_BEGIN:
        return "CALL_BEGIN";
    case CatspeakCompilerState.CALL_END:
        return "CALL_END";
    case CatspeakCompilerState.SUBSCRIPT_BEGIN:
        return "SUBSCRIPT_BEGIN";
    case CatspeakCompilerState.SUBSCRIPT_END:
        return "SUBSCRIPT_END";
    case CatspeakCompilerState.TERMINAL:
        return "TERMINAL";
    case CatspeakCompilerState.GROUPING_BEGIN:
        return "GROUPING_BEGIN";
    case CatspeakCompilerState.GROUPING_END:
        return "GROUPING_END";
    case CatspeakCompilerState.ARRAY:
        return "ARRAY";
    case CatspeakCompilerState.OBJECT:
        return "OBJECT";
    }
    return "<unknown>";
}

/// Parses a string into a value of `CatspeakCompilerState`.
/// Will return `undefined` if the value cannot be parsed.
///
/// @param {Any} str
///   The string to parse.
///
/// @return {Enum.CatspeakCompilerState}
function catspeak_compiler_state_read(str) {
    switch (str) {
    case "PROGRAM":
        return CatspeakCompilerState.PROGRAM;
    case "STATEMENT":
        return CatspeakCompilerState.STATEMENT;
    case "SEQUENCE_BEGIN":
        return CatspeakCompilerState.SEQUENCE_BEGIN;
    case "SEQUENCE_END":
        return CatspeakCompilerState.SEQUENCE_END;
    case "SET_BEGIN":
        return CatspeakCompilerState.SET_BEGIN;
    case "SET_END":
        return CatspeakCompilerState.SET_END;
    case "IF_BEGIN":
        return CatspeakCompilerState.IF_BEGIN;
    case "IF_ELSE":
        return CatspeakCompilerState.IF_ELSE;
    case "IF_END":
        return CatspeakCompilerState.IF_END;
    case "WHILE_BEGIN":
        return CatspeakCompilerState.WHILE_BEGIN;
    case "WHILE_END":
        return CatspeakCompilerState.WHILE_END;
    case "FOR_BEGIN":
        return CatspeakCompilerState.FOR_BEGIN;
    case "FOR_END":
        return CatspeakCompilerState.FOR_END;
    case "FUN_BEGIN":
        return CatspeakCompilerState.FUN_BEGIN;
    case "FUN_END":
        return CatspeakCompilerState.FUN_END;
    case "BREAK":
        return CatspeakCompilerState.BREAK;
    case "CONTINUE":
        return CatspeakCompilerState.CONTINUE;
    case "RETURN":
        return CatspeakCompilerState.RETURN;
    case "EXPRESSION":
        return CatspeakCompilerState.EXPRESSION;
    case "BINARY_BEGIN":
        return CatspeakCompilerState.BINARY_BEGIN;
    case "BINARY_END":
        return CatspeakCompilerState.BINARY_END;
    case "CALL_BEGIN":
        return CatspeakCompilerState.CALL_BEGIN;
    case "CALL_END":
        return CatspeakCompilerState.CALL_END;
    case "SUBSCRIPT_BEGIN":
        return CatspeakCompilerState.SUBSCRIPT_BEGIN;
    case "SUBSCRIPT_END":
        return CatspeakCompilerState.SUBSCRIPT_END;
    case "TERMINAL":
        return CatspeakCompilerState.TERMINAL;
    case "GROUPING_BEGIN":
        return CatspeakCompilerState.GROUPING_BEGIN;
    case "GROUPING_END":
        return CatspeakCompilerState.GROUPING_END;
    case "ARRAY":
        return CatspeakCompilerState.ARRAY;
    case "OBJECT":
        return CatspeakCompilerState.OBJECT;
    }
    return undefined;
}

/// Returns the integer representation for a value of `CatspeakCompilerState`.
/// Will return `undefined` if the value is unexpected.
///
/// @param {Enum.CatspeakCompilerState} value
///   The value of `CatspeakCompilerState` to convert.
///
/// @return {Real}
function catspeak_compiler_state_valueof(value) {
    return value;
}

/// Returns the number of elements of `CatspeakCompilerState`.
///
/// @return {Real}
function catspeak_compiler_state_sizeof() {
    return CatspeakCompilerState.OBJECT + 1;
}
