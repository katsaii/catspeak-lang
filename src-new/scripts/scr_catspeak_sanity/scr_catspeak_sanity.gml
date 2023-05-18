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
function __catspeak_error_bug() {
    gml_pragma("forceinline");
    __catspeak_error(
        "you have likely encountered a compiler bug! ",
        "please get in contact and report this as an issue on the official ",
        "GitHub page: https://github.com/katsaii/catspeak-lang/issues"
    );
}

/// @ignore
///
/// @param {Any} feature
function __catspeak_error_unimplemented(feature) {
    gml_pragma("forceinline");
    __catspeak_error(
        "the feature '", feature, "' has not been implemented yet"
    );
}

/// @ignore
function __catspeak_check_init() {
    gml_pragma("forceinline");
    if (catspeak_force_init()) {
        __catspeak_error(
            "Catspeak was not initialised at this point, make sure to call ",
            "'catspeak_force_init' at the start of your code if you are ",
            "using Catspeak inside of a script resource"
        );
    }
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
        expect += "'" + __catspeak_string(argument[i]) + "'";
    }
    __catspeak_error(
        "expected arg '", name, "' to be one of ", expect,
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
/// @param {Function} p
/// @param {Any} handleType
function __catspeak_check_typeof_handle(name, val, p, handleType) {
    gml_pragma("forceinline");
    __catspeak_check_typeof_numeric(name, val);
    if (!p(val)) {
        __catspeak_error(
            "expected arg '", name, "' to be a valid ", handleType
        );
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Any} ...
function __catspeak_check_instanceof(name, val) {
    var actual = instanceof(val);
    var expect = "";
    for (var i = 2; i < argument_count; i += 1) {
        if (actual == argument[i]) {
            return;
        }
        if (expect != "") {
            expect += " | ";
        }
        expect += "'" + __catspeak_string(argument[i]) + "'";
    }
    __catspeak_error(
        "expected arg '", name, "' to be one of ", expect,
        ", but got '", actual, "'"
    );
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
        __catspeak_error("arg '", name, "' must not be negative, got", val);
    }
    if (val >= power(2, size)) {
        __catspeak_error(
            "arg '", name, "' is too large, it must fit within ", size, " bits"
        );
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} struct
/// @param {Any} key
function __catspeak_check_var_exists(name, struct, key) {
    gml_pragma("forceinline");
    if (!variable_struct_exists(struct, key)) {
        __catspeak_error(
            "arg '", name, "' struct variable '", key, "' does not exist"
        );
    }
}

/// @ignore
///
/// @param {Any} name
function __catspeak_check_global_exists(name) {
    gml_pragma("forceinline");
    if (!variable_global_exists(name)) {
        __catspeak_error(
            "global variable '", name, "' does not exist"
        );
    }
}