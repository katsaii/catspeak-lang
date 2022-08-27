//! Boilerplate for the `CatspeakASCIIDesc` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Simple tags that identify ASCII characters read from a GML buffer.
enum CatspeakASCIIDesc {
    NONE = 0,
    NEWLINE = (1 << 0),
    WHITESPACE = (1 << 1),
    ALPHABETIC = (1 << 2),
    GRAPHIC = (1 << 3),
    DIGIT = (1 << 4),
    DIGIT_HEX = (1 << 5),
    DIGIT_BIN = (1 << 6),
    OPERATOR = (1 << 7),
    ALL = (
        CatspeakASCIIDesc.NONE
        | CatspeakASCIIDesc.NEWLINE
        | CatspeakASCIIDesc.WHITESPACE
        | CatspeakASCIIDesc.ALPHABETIC
        | CatspeakASCIIDesc.GRAPHIC
        | CatspeakASCIIDesc.DIGIT
        | CatspeakASCIIDesc.DIGIT_HEX
        | CatspeakASCIIDesc.DIGIT_BIN
        | CatspeakASCIIDesc.OPERATOR
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
