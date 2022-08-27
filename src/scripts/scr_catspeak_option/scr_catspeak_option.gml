//! Boilerplate for the `CatspeakOption` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// The set of feature flags Catspeak can be configured with.
enum CatspeakOption {
    NONE = 0,
    TOTAL = (1 << 0),
    UNSAFE = (1 << 1),
    NO_PRELUDE = (1 << 2),
    PERSISTENT = (1 << 3),
    ALL = (
        CatspeakOption.NONE
        | CatspeakOption.TOTAL
        | CatspeakOption.UNSAFE
        | CatspeakOption.NO_PRELUDE
        | CatspeakOption.PERSISTENT
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
