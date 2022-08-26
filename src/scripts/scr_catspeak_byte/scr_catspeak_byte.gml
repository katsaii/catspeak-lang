//! Basic predicate functions for ASCII chars.

/// Returns whether an ASCII character is a valid newline character.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_newline(char) {
    switch (char) {
    case 0x0A: // LINE FEED ('\n')
    case 0x0D: // CARRIAGE RETURN ('\r')
        return true;
    default:
        return false;
    }
}

/// Returns whether an ASCII character is a valid whitespace character.
/// This predicate will return `false` if the character is a newline.
/// If you need to check for both whitespace and newline characters, use
/// the `catspeak_byte_is_newline_or_whitespace` function.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_whitespace(char) {
    switch (char) {
    case 0x09: // CHARACTER TABULATION ('\t')
    case 0x0B: // LINE TABULATION ('\v')
    case 0x0C: // FORM FEED ('\f')
    case 0x20: // SPACE (' ')
    case 0x85: // NEXT LINE
        return true;
    default:
        return false;
    }
}

/// Helper function for checking wether an ASCII character is whitespace,
/// including newline characters.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_newline_or_whitespace(char) {
    return catspeak_byte_is_newline(char)
            || catspeak_byte_is_whitespace(char);
}

/// Returns whether an ASCII character is an alphabetic character.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_alphabetic(char) {
    return char >= ord("a") && char <= ord("z")
            || char >= ord("A") && char <= ord("Z");
}

/// Returns whether an ASCII character is a valid digit.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_digit(char) {
    return char >= ord("0") && char <= ord("9");
}

/// Returns whether an ASCII character is a valid hexadecimal digit.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_digit_hex(char) {
    return catspeak_byte_is_digit(char)
            || char >= ord("a") && char <= ord("f")
            || char >= ord("A") && char <= ord("F");
}

/// Returns whether an ASCII character is a valid binary digit.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_digit_bin(char) {
    return char == ord("1") || char == ord("0");
}

/// Returns whether an ASCII character is a valid graphic.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_graphic(char) {
    return catspeak_byte_is_alphabetic(char)
            || catspeak_byte_is_digit(char)
            || char == ord("'")
            || char == ord("_");
}

/// Returns whether an ASCII character is a valid operator.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Bool}
function catspeak_byte_is_operator(char) {
    return char == ord("!")
            || char >= ord("#") && char <= ord("&")
            || char == ord("*")
            || char == ord("+")
            || char == ord("-")
            || char == ord("/")
            || char >= ord("<") && char <= ord("@")
            || char == ord("^")
            || char == ord("|")
            || char == ord("~");
}