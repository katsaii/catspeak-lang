#region LOCATION

/// 0b00000000000011111111111111111111
///
/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_LOCATION_LINE_MASK 0x000FFFFF

/// 0b11111111111100000000000000000000
///
/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_LOCATION_COLUMN_MASK 0xFFF00000

/// Indicates a lack of location in a source file.
///
/// @return {Real}
#macro CATSPEAK_NOLOCATION \
        (__CATSPEAK_LOCATION_LINE_MASK | __CATSPEAK_LOCATION_COLUMN_MASK)

/// When compiling programs, diagnostic information can be added into
/// the generated IR. This information (such as the line and column numbers
/// of an expression or statement) can be used by failing Catspeak programs
/// to offer clearer error messages.
///
/// Encodes the line and column numbers of a source location into a 32-bit
/// integer. The first 20 least-significant bits are reserved for the row
/// number, with the remaining 12 bits used for the (less important)
/// column number.
///
/// Because a lot of diagnostic information may be created for any given
/// Catspeak program, it is important that this information has zero memory
/// impact; hence, the line and column numbers are encoded into a 32-bit
/// integer--which can be created and discarded without allocating
/// memory--instead of as a struct.
///
/// **Mask layout**
/// ```txt
/// | 00000000000011111111111111111111 |
/// | <--column--><-------line-------> |
/// ```
///
/// @remark
///   Because of this, the maximum line number is 1,048,576 and the maximum
///   column number is 4,096. Any line/column counts beyond this will raise
///   an exception in debug mode, and just be garbage data in release mode.
///
/// @param {Real} row
///   The row number of the source location.
///
/// @param {Real} column
///   The column number of the source location. This is the number of
///   Unicode codepoints since the previous new-line character. As a result,
///   tabs are considered a single column, not 2, 4, 8, etc. columns.
///
/// @return {Real}
function catspeak_location_create(row, column) {
    gml_pragma("forceinline");
    __catspeak_check_arg_size_bits("row", row, 20);
    __catspeak_check_arg_size_bits("column", column, 12);
    var bitsRow = row & __CATSPEAK_LOCATION_LINE_MASK;
    var bitsCol = (column << 20) & __CATSPEAK_LOCATION_COLUMN_MASK;
    return bitsRow | bitsCol;
}

/// Gets the line component of a Catspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the supplied
/// Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_line(location) {
    gml_pragma("forceinline");
    __catspeak_check_arg_size_bits("location", location, 32);
    return location & __CATSPEAK_LOCATION_LINE_MASK;
}

/// Gets the column component of a Catspeak source location. This is stored
/// as a 12-bit unsigned integer within the most significant bits of the
/// supplied Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_column(location) {
    gml_pragma("forceinline");
    __catspeak_check_arg_size_bits("location", location, 32);
    return (location & __CATSPEAK_LOCATION_COLUMN_MASK) >> 20;
}

/// Displays the line and column numbers this location represents. Optionally
/// takes a filepath to associate this location information with.
///
/// @example
///   With both `location` and `filepath` passed:
///   ```
///   in mods/example.meow at (line 3, column 6)
///   ```
///
///   With only `location` passed:
///   ```
///   in a file at (line 3, column 6)
///   ```
///
///   With only `filepath` passed:
///   ```
///   in mods/example.meow
///   ```
///
///   With neither argument passed:
///   ```
///   in a file
///   ```
///
/// @param {Real} [location]
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @param {String} [filepath]
///   A path to a file to associate this diagnostic information with. A file
///   at the given path does not need to exist.
///
/// @returns {String}
function catspeak_location_show(location, filepath) {
    var msg = "in ";
    if (filepath != undefined) {
        msg += string(filepath);
    } else {
        msg += "a file";
    }
    if (location != undefined) {
        msg += " at (line " + string(catspeak_location_get_row(location));
        msg += ", column " + string(catspeak_location_get_column(location)) + ")";
    }
    return msg;
}

#endregion

#region VALIDATION

/// @ignore
function __catspeak_assert(expect, message_="assertion failed") {
    gml_pragma("forceinline");
    if (!expect) {
        __catspeak_error(message_);
    }
}

/// @ignore
function __catspeak_assert_eq(expect, got, message_="assertion failed") {
    gml_pragma("forceinline");
    if (expect != got) {
        __catspeak_error(message_);
    }
}

#endregion