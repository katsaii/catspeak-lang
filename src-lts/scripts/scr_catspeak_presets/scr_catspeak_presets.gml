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
    /// Exposes safe struct functions.
    STRUCT,
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
        //"is_callable", is_callable,
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
function __catspeak_preset_array(env) {
    env.addFunction(
        "array_create", array_create,
        "array_copy", array_copy,
        "array_equals", array_equals,
        "array_get", array_get,
        "array_set", array_set,
        "array_push", array_push,
        "array_pop", array_pop,
        //"array_shift", array_shift,
        "array_insert", array_insert,
        "array_delete", array_delete,
        //"array_get_index", array_get_index,
        //"array_contains", array_contains,
        //"array_contains_ext", array_contains_ext,
        "array_sort", array_sort,
        //"array_reverse", array_reverse,
        //"array_shuffle", array_shuffle,
        "array_length", array_length,
        "array_resize", array_resize,
        //"array_first", array_first,
        //"array_last", array_last,
        //"array_find_index", array_find_index,
        //"array_any", array_any,
        //"array_all", array_all,
        //"array_foreach", array_foreach,
        //"array_reduce", array_reduce,
        //"array_concat", array_concat,
        //"array_union", array_union,
        //"array_intersection", array_intersection,
        //"array_filter", array_filter,
        //"array_map", array_map,
        //"array_unique", array_unique,
        //"array_copy_while", array_copy_while,
        //"array_create_ext", array_create_ext,
        //"array_filter_ext", array_filter_ext,
        //"array_map_ext", array_map_ext,
        //"array_unique_ext", array_unique_ext,
        //"array_reverse_ext", array_reverse_ext,
        //"array_shuffle_ext", array_shuffle_ext
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_struct(env) {
    env.addFunction(
        "struct_exists", variable_struct_exists,
        "struct_get", variable_struct_get,
        "struct_set", variable_struct_set,
        "struct_remove", variable_struct_remove,
        "struct_get_names", variable_struct_get_names,
        "struct_names_count", variable_struct_names_count,
        //"is_instanceof", is_instanceof,
        "instanceof", instanceof,
        //"struct_foreach", struct_foreach,
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_string(env) {
    env.addFunction(
        "ansi_char", ansi_char,
        "chr", chr,
        "ord", ord,
        "string_byte_at", string_byte_at,
        "string_byte_length", string_byte_length,
        "string_set_byte_at", string_set_byte_at,
        "string_char_at", string_char_at,
        "string_ord_at", string_ord_at,
        "string_length", string_length,
        "string_pos", string_pos,
        "string_pos_ext", string_pos_ext,
        "string_last_pos", string_last_pos,
        "string_last_pos_ext", string_last_pos_ext,
        "string_starts_with", string_starts_with,
        "string_ends_with", string_ends_with,
        "string_count", string_count,
        "string_copy", string_copy,
        "string_delete", string_delete,
        "string_digits", string_digits,
        "string_format", string_format,
        "string_insert", string_insert,
        "string_letters", string_letters,
        "string_lettersdigits", string_lettersdigits,
        "string_lower", string_lower,
        "string_repeat", string_repeat,
        "string_replace", string_replace,
        "string_replace_all", string_replace_all,
        "string_upper", string_upper,
        "string_hash_to_newline", string_hash_to_newline,
        "string_trim", string_trim,
        "string_trim_start", string_trim_start,
        "string_trim_end", string_trim_end,
        "string_split", string_split,
        "string_split_ext", string_split_ext,
        "string_join", string_join,
        "string_join_ext", string_join_ext,
        "string_concat", string_concat,
        "string_concat_ext", string_concat_ext,
        "string_width", string_width,
        "string_width_ext", string_width_ext,
        "string_height", string_height,
        "string_height_ext", string_height_ext,
        "string_foreach", string_foreach
    );
}

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
function __catspeak_preset_unsafe(env) {
    env.addFunction(
        "asset_get_index", asset_get_index,
        "asset_get_type", asset_get_type,
        "tag_get_asset_ids", tag_get_asset_ids,
        "tag_get_assets", tag_get_assets,
        "asset_get_tags", asset_get_tags,
        "asset_add_tags", asset_add_tags,
        "asset_remove_tags", asset_remove_tags,
        "asset_has_tags", asset_has_tags,
        "asset_has_any_tag", asset_has_any_tag,
        "asset_clear_tags", asset_clear_tags
    );
}

/// @ignore
function __catspeak_init_presets() {
    var presets = array_create(CatspeakPreset.__SIZE__, undefined);
    presets[@ CatspeakPreset.GML] = __catspeak_preset_gml;
    presets[@ CatspeakPreset.TYPE] = __catspeak_preset_type;
    presets[@ CatspeakPreset.ARRAY] = __catspeak_preset_array;
    presets[@ CatspeakPreset.STRUCT] = __catspeak_preset_struct;
    presets[@ CatspeakPreset.STRING] = __catspeak_preset_string;
    presets[@ CatspeakPreset.MATH] = __catspeak_preset_math;
    presets[@ CatspeakPreset.MATH_3D] = __catspeak_preset_math_3d;
    presets[@ CatspeakPreset.COLOUR] = __catspeak_preset_colour;
    presets[@ CatspeakPreset.RANDOM] = __catspeak_preset_random;
    presets[@ CatspeakPreset.UNSAFE] = __catspeak_preset_unsafe;
    /// @ignore
    global.__catspeakPresets = presets;
}