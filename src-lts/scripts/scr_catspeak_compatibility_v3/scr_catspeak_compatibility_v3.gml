//! Contains a simple compatibility layer for help with converting projects
//! from Catspeak 3 to Catspeak 4.

//# feather use syntax-errors

// CATSPEAK 3 //

/// @ignore
/// @deprecated {4.0.0}
function __catspeak_location_show(location, filepath) {
    catspeak_location_show(location, filepath);
}

/// @ignore
/// @deprecated {4.0.0}
function __catspeak_location_show_ext(location, filepath) {
    var msg = __catspeak_location_show(location, filepath);
    if (argument_count > 2) {
        msg += " -- ";
        for (var i = 2; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    return msg;
}

/// Gets the line component of a Catspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the supplied
/// Catspeak location handle.
///
/// @deprecated {4.0.0}
///   Use `catspeak_location_get_line` instead.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_row(location) {
    gml_pragma("forceinline");
    __catspeak_check_arg_size_bits("location", location, 32);
    return location & __CATSPEAK_LOCATION_ROW_MASK;
}