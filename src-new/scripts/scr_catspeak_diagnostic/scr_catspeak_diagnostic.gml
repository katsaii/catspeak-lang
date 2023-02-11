//! Responsible for the creation of diagnostic information used by failing
//! Catspeak programs.
//!
//! Line and column numbers are encoded into a single 32-bit integer, where
//! 20 bits are reserved for the row number and the remaining 12 bits are
//! used for the (less important) column number.

//# feather use syntax-errors

/// 0b00000000000011111111111111111111
///
/// @ignore
#macro __CATSPEAK_LOCATION_ROW_MASK 0x000FFFFF

/// 0b11111111111100000000000000000000
///
/// @ignore
#macro __CATSPEAK_LOCATION_COLUMN_MASK 0xFFF00000

/// @ignore
function __catspeak_location_create(row, column) {
    gml_pragma("forceinline");
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_assert_arg_typeof("row", row, "number");
        __catspeak_assert_arg_typeof("column", column, "number");
        if (row >= power(2, 20)) {
            __catspeak_assert(
                "row number " + __catspeak_string(row) +
                        " too large, must fit within 20 bits"
            );
        }
        if (column >= power(2, 12)) {
            __catspeak_assert(
                "column number " + __catspeak_string(column) +
                        " too large, must fit within 12 bits"
            );
        }
    }
    var bitsRow = row & __CATSPEAK_LOCATION_ROW_MASK;
    var bitsCol = (column << 20) & __CATSPEAK_LOCATION_COLUMN_MASK;
    return bitsRow | bitsCol;
}

/// Gets the column component of a Catspeak source location. This is stored
/// as a 12-bit unsigned integer within the most significant bits of the
/// supplied Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the source location of a compiled
///   Catspeak source file.
///
/// @returns {Real}
function catspeak_get_column(location) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_assert_arg_typeof("location", location, "number");
        if (location >= power(2, 32)) {
            __catspeak_assert(
                "location handle" + __catspeak_string(location) +
                        "too large, must fit within 32 bits"
            );
        }
    }
    return location & __CATSPEAK_LOCATION_ROW_MASK;
}

/// Represents an error raised by the Catspeak runtime. Follows a similar
/// structure to the built-in error struct.
///
/// @param {Struct.CatspeakLocation} location
///   The location where this error occurred.
///
/// @param {String} [message]
///   The error message to display. Defaults to "No message".
function CatspeakError(location, message="no message") constructor {
    try {
        show_error(message, false);
    } catch (e) {
        self.message = e.message;
        self.longMessage = e.longMessage;
        self.script = e.script;
        self.stacktrace = e.stacktrace;
    }
    self.location = location == undefined ? undefined : location.clone();

    /// Renders this Catspeak error with its location followed by the error
    /// message.
    ///
    /// @param {Bool} [verbose]
    ///   Whether to include the stack trace as part of the error output.
    ///
    /// @return {String}
    static toString = function (verbose=false) {
        var msg = "";
        msg += instanceof(self) + " " + string(location);
        msg += ": " + string(message);
        if (verbose) {
            msg += "\nStacktrace:";
            var count = array_length(stacktrace);
            for (var i = 0; i < count; i += 1) {
                msg += "\nat " + string(stacktrace[i]);
            }
        }
        return msg;
    };
}