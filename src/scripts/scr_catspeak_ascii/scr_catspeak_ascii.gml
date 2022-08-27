//! Boilerplate for the `CatspeakASCII` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Simple tags that identify ASCII characters read from a GML buffer.
enum CatspeakASCII {
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
        CatspeakASCII.NONE
        | CatspeakASCII.NEWLINE
        | CatspeakASCII.WHITESPACE
        | CatspeakASCII.ALPHABETIC
        | CatspeakASCII.GRAPHIC
        | CatspeakASCII.DIGIT
        | CatspeakASCII.DIGIT_HEX
        | CatspeakASCII.DIGIT_BIN
        | CatspeakASCII.OPERATOR
    ),
}
