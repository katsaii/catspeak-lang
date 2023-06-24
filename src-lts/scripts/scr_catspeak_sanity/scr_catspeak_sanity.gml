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
///
/// @param {Any} ...
function __catspeak_error_silent() {
    var msg = "Catspeak v" + CATSPEAK_VERSION;
    if (argument_count > 0) {
        msg += ": ";
        for (var i = 0; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    show_debug_message(msg);
}

/// @ignore
///
/// @param {Any} msg
/// @param {Any} got
function __catspeak_error_got(msg, got) {
    var gotStr;
    if (is_numeric(got)) {
        gotStr = string(got);
    } else if (is_string(got) && string_length(got) < 16) {
        gotStr = got;
    } else {
        gotStr = typeof(got);
    }
    __catspeak_error(msg, ", got '", gotStr, "'");
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
/// @param {Function} func
/// @param {Any} [typeName]
function __catspeak_check_arg(name, val, func, typeName=undefined) {
    if (func(val)) {
        return;
    }
    if (typeName == undefined) {
        switch (func) {
            case is_string: typeName = "string"; break;
            case is_real: typeName = "real"; break;
            case is_numeric: typeName = "numeric"; break;
            case is_bool: typeName = "bool"; break;
            case is_array: typeName = "array"; break;
            case is_struct: typeName = "struct"; break;
            case is_method: typeName = "method"; break;
            case is_callable: typeName = "callable"; break;
            case is_ptr: typeName = "pointer"; break;
            case is_int32: typeName = "int32"; break;
            case is_int64: typeName = "int64"; break;
            case is_undefined: typeName = "undefined"; break;
            case is_nan: typeName = "NaN"; break;
            case is_infinity: typeName = "infinity"; break;
            case buffer_exists: typeName = "buffer"; break;
        }
    }
    __catspeak_error(
        "expected argument '", name, "' to be of type '", typeName, "'",
        ", but got '", typeof(val), "' instead"
    );
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Any} ...
function __catspeak_check_arg_struct(name, val) {
    __catspeak_check_arg(name, val, is_struct);
    for (var i = 2; i < argument_count; i += 2) {
        var varName = argument[i];
        var varFunc = argument[i + 1];
        if (!variable_struct_exists(val, varName)) {
            __catspeak_error(
                "expected struct argument '", name,
                "' to contain a variable '", varName, "'"
            );
        }
        if (varFunc != undefined) {
            __catspeak_check_arg(
                    name + "." + varName, val[$ varName], varFunc);
        }
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Any} expect
function __catspeak_check_arg_struct_instanceof(name, val, expect) {
    __catspeak_check_arg(name, val, is_struct);
    var actual = instanceof(val);
    if (actual != expect) {
        __catspeak_error(
            "expected struct argument '", name, "' to be an instance of '",
            expect, "', but got '", actual, "'"
        );
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Real} size
function __catspeak_check_arg_size_bits(name, val, size) {
    gml_pragma("forceinline");
    __catspeak_check_arg(name, val, is_numeric);
    if (val < 0) {
        __catspeak_error("argument '", name, "' must not be negative, got", val);
    }
    if (val >= power(2, size)) {
        __catspeak_error(
            "argument '", name, "' is too large (", val,
            ") it must fit within ", size, " bits"
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