//! Catspeak presets database.

//# feather use syntax-errors

/// Represents the set of environment presets understood by Catspeak.
/// When used with [setPreset], this enum determines what functions,
/// constants, and keywords get exposed.
enum CatspeakPreset {
    /// Changes keywords to resemble GML code.
    GML,
    /// Exposes safe type checking and type conversion functions.
    TYPE,
    /// Exposes safe array functions.
    ARRAY,
    /// Exposes safe string functions.
    STRING,
    /// Exposes safe mathematical and statistical functions.
    MATH,
    /// Exposes safe 3D functions.
    MATH_3D,
    /// Exposes safe colour functions and constants.
    COLOUR,
    /// Exposes safe randomisation functions.
    RANDOM,
    /// Exposes unsafe reflection and debug functions.
    /// Use this preset with extreme caution, because all bets are off.
    UNSAFE,
    __SIZE__,
}

/// @ignore
///
/// @param {Enum.CatspeakPreset} preset
/// @return {Function}
function __catspeak_preset_get(preset) {
    var presetFunc = global.__catspeakPresets[preset];

    if (CATSPEAK_DEBUG_MODE && presetFunc == undefined) {
        __catspeak_error_bug();
    }

    return presetFunc;
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_gml(env) {
    env.renameKeyword(
        "//", "div",
        "--", "//",
        "let", "var",
        "fun", "function",
        "impl", "constructor",
    );
    env.addKeyword(
        "&&", CatspeakToken.AND,
        "||", CatspeakToken.OR,
        "mod", CatspeakToken.REMAINDER,
        "not", CatspeakToken.NOT
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_type(env) {
    env.addFunction(
        "is_string", is_string,
        "is_real", is_real,
        "is_numeric", is_numeric,
        "is_bool", is_bool,
        "is_array", is_array,
        "is_struct", is_struct,
        "is_method", is_method,
        "is_callable", is_callable,
        "is_ptr", is_ptr,
        "is_int32", is_int32,
        "is_int64", is_int64,
        "is_undefined", is_undefined,
        "is_nan", is_nan,
        "is_infinity", is_infinity,
        "typeof", typeof,
        "bool", bool,
        "ptr", ptr,
        "int64", int64,
        "string", string,
        "real", real
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_array(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_string(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_math(env) {
    env.addFunction(
        "round", round,
        "frac", frac,
        "abs", abs,
        "sign", sign,
        "floor", floor,
        "ceil", ceil,
        "min", min,
        "max", max,
        "mean", mean,
        "median", median,
        "lerp", lerp,
        "clamp", clamp,
        "exp", exp,
        "ln", ln,
        "power", power,
        "sqr", sqr,
        "sqrt", sqrt,
        "log2", log2,
        "log10", log10,
        "logn", logn,
        "arccos", arccos,
        "arcsin", arcsin,
        "arctan", arctan,
        "arctan2", arctan2,
        "cos", cos,
        "sin", sin,
        "tan", tan,
        "dcos", dcos,
        "dsin", dsin,
        "dtan", dtan,
        "darccos", darccos,
        "darcsin", darcsin,
        "darctan", darctan,
        "darctan2", darctan2,
        "degtorad", degtorad,
        "radtodeg", radtodeg,
        "point_direction", point_direction,
        "point_distance", point_distance,
        //"distance_to_object", distance_to_object,
        "distance_to_point", distance_to_point,
        "dot_product", dot_product,
        "dot_product_normalised", dot_product_normalised,
        "angle_difference", angle_difference,
        "lengthdir_x", lengthdir_x,
        "lengthdir_y", lengthdir_y
    );
    env.addConstant("pi", pi);
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_math_3d(env) {
    env.addFunction(
        "point_distance_3d", point_distance_3d,
        "dot_product_3d", dot_product_3d,
        "dot_product_3d_normalised", dot_product_3d_normalised,
        "matrix_build", matrix_build,
        "matrix_multiply", matrix_multiply,
        "matrix_build_identity", matrix_build_identity,
        "matrix_build_lookat", matrix_build_lookat,
        "matrix_build_projection_ortho", matrix_build_projection_ortho,
        "matrix_build_projection_perspective", matrix_build_projection_perspective,
        "matrix_build_projection_perspective_fov", matrix_build_projection_perspective_fov,
        "matrix_transform_vertex", matrix_transform_vertex
    );
    env.addConstant("pi", pi);
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_colour(env) {
    env.addFunction(
        "colour_get_blue", colour_get_blue,
        "colour_get_green", colour_get_green,
        "colour_get_red", colour_get_red,
        "colour_get_hue", colour_get_hue,
        "colour_get_saturation", colour_get_saturation,
        "colour_get_value", colour_get_value,
        "make_colour_rgb", make_colour_rgb,
        "make_colour_hsv", make_colour_hsv,
        "merge_colour", merge_colour
    );
    env.addConstant(
        "c_aqua", c_aqua,
        "c_black", c_black,
        "c_blue", c_blue,
        "c_dkgray", c_dkgray,
        "c_fuchsia", c_fuchsia,
        "c_grey", c_grey,
        "c_green", c_green,
        "c_lime", c_lime,
        "c_ltgrey", c_ltgrey,
        "c_maroon", c_maroon,
        "c_navy", c_navy,
        "c_olive", c_olive,
        "c_orange", c_orange,
        "c_purple", c_purple,
        "c_red", c_red,
        "c_silver", c_silver,
        "c_teal", c_teal,
        "c_white", c_white,
        "c_yellow", c_yellow
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_random(env) {
    env.addFunction(
        "choose", choose,
        "random", random,
        "random_range", random_range,
        "irandom", irandom,
        "irandom_range", irandom_range
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_unsafe(env) { }

/// @ignore
function __catspeak_init_presets() {
    var presets = array_create(CatspeakPreset.__SIZE__, undefined);
    presets[@ CatspeakPreset.GML] = __catspeak_preset_gml;
    presets[@ CatspeakPreset.TYPE] = __catspeak_preset_type;
    presets[@ CatspeakPreset.ARRAY] = __catspeak_preset_array;
    presets[@ CatspeakPreset.STRING] = __catspeak_preset_string;
    presets[@ CatspeakPreset.MATH] = __catspeak_preset_math;
    presets[@ CatspeakPreset.MATH_3D] = __catspeak_preset_math_3d;
    presets[@ CatspeakPreset.COLOUR] = __catspeak_preset_colour;
    presets[@ CatspeakPreset.RANDOM] = __catspeak_preset_random;
    presets[@ CatspeakPreset.UNSAFE] = __catspeak_preset_unsafe;
    /// @ignore
    global.__catspeakPresets = presets;
}