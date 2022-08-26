//! Basic predicate functions for ASCII chars.

/// Returns a new predicate that checks whether an ASCII character equals
/// an expected character.
///
/// @param {Real} char
///   The character to expect.
function catspeak_byte_equals(char) {
    return {
        expect : char,
        callee : function(char) {
            return char == expect;
        },
    }.callee;
}

/// Returns whether an ASCII character is a valid newline character.
///
/// @param {Real} char
///   The character to check.
function catspeak_byte_is_newline(char) {
    switch (char) {
    case ord("\n"):
    case ord("\r"):
        return true;
    default:
        return false;
    }
}

/// @desc Returns whether a byte is a valid whitespace character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_whitespace(_byte) {
    switch (_byte) {
    case ord(" "):
    case ord("\t"):
        return true;
    default:
        return false;
    }
}

/// @desc Returns whether a byte is a valid alphabetic character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_alphabetic(_byte) {
    return _byte >= ord("a") && _byte <= ord("z")
            || _byte >= ord("A") && _byte <= ord("Z")
            || _byte == ord("_")
            || _byte == ord("'");
}

/// @desc Returns whether a byte is a valid digit character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_digit(_byte) {
    return _byte >= ord("0") && _byte <= ord("9");
}

/// @desc Returns whether a byte is a valid hexadecimal digit character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_hex_digit(_byte) {
    return __catspeak_legacy_byte_is_digit(_byte)
            || _byte >= ord("a") && _byte <= ord("z")
            || _byte >= ord("A") && _byte <= ord("Z");
}

/// @desc Returns whether a byte is a valid binary digit character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_bin_digit(_byte) {
    return _byte == ord("0") || _byte == ord("1");
}

/// @desc Returns whether a byte is a valid alphanumeric character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_alphanumeric(_byte) {
    return __catspeak_legacy_byte_is_alphabetic(_byte)
            || __catspeak_legacy_byte_is_digit(_byte);
}

/// @desc Returns whether a byte is a valid operator character.
/// @param {real} byte The byte to check.
function __catspeak_legacy_byte_is_operator(_byte) {
    return _byte == ord("!")
            || _byte >= ord("#") && _byte <= ord("&")
            || _byte == ord("*")
            || _byte == ord("+")
            || _byte == ord("-")
            || _byte == ord("/")
            || _byte >= ord("<") && _byte <= ord("@")
            || _byte == ord("^")
            || _byte == ord("|")
            || _byte == ord("~");
}