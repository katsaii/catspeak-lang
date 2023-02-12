//! Responsible for the creation of diagnostic information used by failing
//! Catspeak programs.

//# feather use syntax-errors

/// 0b00000000000011111111111111111111
///
/// @ignore
#macro __CATSPEAK_LOCATION_ROW_MASK 0x000FFFFF

/// 0b11111111111100000000000000000000
///
/// @ignore
#macro __CATSPEAK_LOCATION_COLUMN_MASK 0xFFF00000

/// Line and column numbers are encoded into a single 32-bit integer, where
/// 20 bits are reserved for the row number and the remaining 12 bits are
/// used for the (less important) column number.
///
/// Mask layout:
/// | 00000000000011111111111111111111 |
/// | <--column--><-------line-------> |
///
/// @ignore
///
/// @param {Real} row
/// @param {Real} column
/// @return {Real}
function __catspeak_location_create(row, column) {
    gml_pragma("forceinline");
    if (CATSPEAK_DEBUG_MODE) {
        if (row >= power(2, 20) || row < 0) {
            __catspeak_error(
                "row number " + __catspeak_string(row) +
                        " too large, must fit within 20 bits"
            );
        }
        if (column >= power(2, 12) || column < 0) {
            __catspeak_error(
                "column number " + __catspeak_string(column) +
                        " too large, must fit within 12 bits"
            );
        }
    }
    var bitsRow = row & __CATSPEAK_LOCATION_ROW_MASK;
    var bitsCol = (column << 20) & __CATSPEAK_LOCATION_COLUMN_MASK;
    return bitsRow | bitsCol;
}

/// @ignore
///
/// @param {Real} location
/// @return {Real}
function __catspeak_location_get_row(location) {
    gml_pragma("forceinline");
    return location & __CATSPEAK_LOCATION_ROW_MASK;
}

/// @ignore
///
/// @param {Real} location
/// @return {Real}
function __catspeak_location_get_column(location) {
    gml_pragma("forceinline");
    return (location & __CATSPEAK_LOCATION_COLUMN_MASK) >> 20;
}