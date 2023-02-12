//! Internal sanity checking module for catching bugs early.

//# feather use syntax-errors

/// @ignore
///
/// @param {Any} val
/// @return {String}
function __catspeak_string(val) {
    gml_pragma("forceinline");
    return is_string(val) ? val : string(val);
}

/// @ignore
///
/// @param {Any} ...
function __catspeak_error() {
    gml_pragma("forceinline");
    var msg = "Catspeak v" + CATSPEAK_VERSION;
    if (argument_count > 0) {
        msg += ": ";
        for (var i = 0; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    show_error(msg, false);
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Any} ...
function __catspeak_check_typeof(name, val) {
    var actual = typeof(val);
    var expect = "";
    for (var i = 2; i < argument_count; i += 1) {
        if (actual == argument[i]) {
            return;
        }
        if (expect != "") {
            expect += " | ";
        }
        expect += __catspeak_string(argument[i]);
    }
    __catspeak_error(
        "expected arg ", name, ": ", expect,
        ", but got '", actual, "'"
    );
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
function __catspeak_check_typeof_numeric(name, val) {
    gml_pragma("forceinline");
    __catspeak_check_typeof(name, val, "number", "bool", "int32", "int64");
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Real} size
function __catspeak_check_size_bits(name, val, size) {
    gml_pragma("forceinline");
    __catspeak_check_typeof_numeric(name, val);
    if (val < 0) {
        __catspeak_error("arg ", name, " must not be negative, got", val);
    }
    if (val >= power(2, size)) {
        __catspeak_error(
            "arg ", name, " is too large, it must fit within ", size, " bits"
        );
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Real} size
function __catspeak_check_global_exists(name) {
    gml_pragma("forceinline");
    if (!variable_global_exists(name)) {
        __catspeak_error(
            "global variable '", name, "' does not exist"
        );
    }
}