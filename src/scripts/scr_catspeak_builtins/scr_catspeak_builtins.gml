//! Defines the standard library functions of the Catspeak prelude.

//# feather use syntax-errors

/// @ignore
function __catspeak_string_to_builtin(name) {
    gml_pragma("forceinline");
    return global.__catspeakDatabasePrelude[$ name];
}

/// @ignore
function __catspeak_string_is_builtin(name) {
    gml_pragma("forceinline");
    return variable_struct_exists(global.__catspeakDatabasePrelude, name);
}

/// @ignore
function __catspeak_builtin_add(lhs, rhs) {
    return rhs == undefined ? +lhs : lhs + rhs;
}

/// @ignore
function __catspeak_builtin_add_string(lhs, rhs) {
    var lhs_ = is_string(lhs) ? lhs : string(lhs);
    var rhs_ = is_string(rhs) ? rhs : string(rhs);
    return lhs_ + rhs_;
}

/// @ignore
function __catspeak_builtin_sub(lhs, rhs) {
    return rhs == undefined ? -lhs : lhs - rhs;
}

/// @ignore
function __catspeak_builtin_mul(lhs, rhs) {
    return lhs * rhs;
}

/// @ignore
function __catspeak_builtin_div(lhs, rhs) {
    return lhs / rhs;
}

/// @ignore
function __catspeak_builtin_mod(lhs, rhs) {
    return lhs % rhs;
}

/// @ignore
function  __catspeak_builtin_div_int(lhs, rhs) {
    return lhs div rhs;
}

/// @ignore
function __catspeak_builtin_bit_or(lhs, rhs) {
    return lhs | rhs;
}

/// @ignore
function __catspeak_builtin_bit_and(lhs, rhs) {
    return lhs & rhs;
}

/// @ignore
function __catspeak_builtin_bit_xor(lhs, rhs) {
    return lhs ^ rhs;
}

/// @ignore
function __catspeak_builtin_bit_not(lhs) {
    return ~lhs;
}

/// @ignore
function  __catspeak_builtin_bit_lshift(lhs, rhs) {
    return lhs << rhs;
}

/// @ignore
function  __catspeak_builtin_bit_rshift(lhs, rhs) {
    return lhs >> rhs;
}

/// @ignore
function  __catspeak_builtin_or(lhs, rhs) {
    return lhs || rhs;
}

/// @ignore
function  __catspeak_builtin_and(lhs, rhs) {
    return lhs && rhs;
}

/// @ignore
function  __catspeak_builtin_xor(lhs, rhs) {
    return lhs ^^ rhs;
}

/// @ignore
function __catspeak_builtin_not(lhs) {
    return !lhs;
}

/// @ignore
function  __catspeak_builtin_eq(lhs, rhs) {
    return lhs == rhs;
}

/// @ignore
function  __catspeak_builtin_neq(lhs, rhs) {
    return lhs != rhs;
}

/// @ignore
function  __catspeak_builtin_geq(lhs, rhs) {
    return lhs >= rhs;
}

/// @ignore
function  __catspeak_builtin_leq(lhs, rhs) {
    return lhs <= rhs;
}

/// @ignore
function __catspeak_builtin_gt(lhs, rhs) {
    return lhs > rhs;
}

/// @ignore
function __catspeak_builtin_lt(lhs, rhs) {
    return lhs < rhs;
}

/// @ignore
function __catspeak_builtin_array() {
    var arr = array_create(argument_count);
    for (var i = 0; i < argument_count; i += 1) {
        arr[i] = argument[i];
    }
    return arr;
}

/// @ignore
function __catspeak_builtin_struct() {
    var obj = { };
    for (var i = 0; i < argument_count; i += 2) {
        obj[$ argument[i + 0]] = argument[i + 1];
    }
    return obj;
}

/// @ignore
function __catspeak_builtin_get(collection, key) {
    if (is_array(collection)) {
        if (key < 0 || key >= array_length(collection)) {
            return undefined;
        } else {
            return collection[key];
        }
    } else {
        __catspeak_builtin_verify_struct(collection);
        return collection[$ key];
    }
}

/// @ignore
function __catspeak_builtin_set(collection, key, value) {
    if (is_array(collection)) {
        collection[@ key] = value;
    } else {
        __catspeak_builtin_verify_struct(collection);
        collection[$ key] = value;
    }
    return value;
}

/// @ignore
function __catspeak_builtin_length(collection) {
    if (is_array(collection)) {
        return array_length(collection);
    } else {
        return 0;
    }
}

/// @ignore
function __catspeak_builtin_print() {
    var msg = "";
    for (var i = 0; i < argument_count; i += 1) {
        var item = argument[i];
        msg += is_string(item) ? item : string(item);
    }
    show_debug_message(msg);
    return msg;
}

/// @ignore
function __catspeak_builtin_verify_struct(collection) {
    gml_pragma("forceinline");
    if (!is_struct(collection)) {
        return;
    }
    if (string_pos("Catspeak", instanceof(collection)) == 1) {
        throw new CatspeakError(undefined,
                "self-modification is prohibited by Catspeak");
    }
}

/// @ignore
function __catspeak_init_builtins() {
    catspeak_add_function(
        "+", __catspeak_builtin_add,
        "++", __catspeak_builtin_add_string,
        "-", __catspeak_builtin_sub,
        "*", __catspeak_builtin_mul,
        "/", __catspeak_builtin_div,
        "%", __catspeak_builtin_mod,
        "//", __catspeak_builtin_div_int,
        "|", __catspeak_builtin_bit_or,
        "&", __catspeak_builtin_bit_and,
        "^", __catspeak_builtin_bit_xor,
        "~", __catspeak_builtin_bit_not,
        "<<", __catspeak_builtin_bit_lshift,
        ">>", __catspeak_builtin_bit_rshift,
        "||", __catspeak_builtin_or,
        "&&", __catspeak_builtin_and,
        "^^", __catspeak_builtin_xor,
        "!", __catspeak_builtin_not,
        "==", __catspeak_builtin_eq,
        "!=", __catspeak_builtin_neq,
        ">=", __catspeak_builtin_geq,
        "<=", __catspeak_builtin_leq,
        ">", __catspeak_builtin_gt,
        "<", __catspeak_builtin_lt,
        "[]", __catspeak_builtin_get,
        "[]=", __catspeak_builtin_set,
        "len", __catspeak_builtin_length,
        "print", __catspeak_builtin_print,
        "bool", bool,
        "string", string,
        "real", real,
        "int64", int64,
        "typeof", typeof,
        "instanceof", instanceof,
        "is_array", is_array,
        "is_bool", is_bool,
        "is_infinity", is_infinity,
        "is_int32", is_int32,
        "is_int64", is_int64,
        "is_method", is_method,
        "is_nan", is_nan,
        "is_numeric", is_numeric,
        "is_ptr", is_ptr,
        "is_real", is_real,
        "is_string", is_string,
        "is_struct", is_struct,
        "is_undefined", is_undefined
    );
    catspeak_add_constant(
        "null", pointer_null,
        "undefiend", undefined,
        "true", true,
        "false", false,
        "NaN", NaN,
        "infinity", infinity
    );
}