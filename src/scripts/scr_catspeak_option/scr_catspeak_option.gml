//! Boilerplate for the `CatspeakOption` enum.

//NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// The set of feature flags Catspeak can be configured with.
enum CatspeakOption {
    NONE = 0,
    TOTAL = (1 << 0),
    ALL = (
        CatspeakOption.NONE
        | CatspeakOption.TOTAL
    ),
}

/// Returns whether an instance of `CatspeakOption` contains an expected flag.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakOption} flags
///   The flags of `CatspeakOption` to check.
///
/// @return {Bool}
function catspeak_option_contains(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) == flags;
}

/// Returns whether an instance of `CatspeakOption` equals an expected flag.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakOption} flags
///   The flags of `CatspeakOption` to check.
///
/// @return {Bool}
function catspeak_option_equals(value, flags) {
    gml_pragma("forceinline");
    return value == flags;
}

/// Returns whether an instance of `CatspeakOption` intersects a set of expected flags.
///
/// @param {Any} value
///   The value to check for flags of, must be a numeric value.
///
/// @param {Enum.CatspeakOption} flags
///   The flags of `CatspeakOption` to check.
///
/// @return {Bool}
function catspeak_option_intersects(value, flags) {
    gml_pragma("forceinline");
    return (value & flags) != 0;
}

/// Gets the name for a value of `CatspeakOption`.
/// Will return the empty string if the value is unexpected.
///
/// @param {Enum.CatspeakOption} value
///   The value of `CatspeakOption` to convert, must be a numeric value.
///
/// @return {String}
function catspeak_option_show(value) {
    var msg = "";
    var delimiter = undefined;
    if ((value & CatspeakOption.TOTAL) != 0) {
        msg += delimiter ?? "";
        delimiter ??= " | ";
        msg += "TOTAL";
    }
    return msg;
}
