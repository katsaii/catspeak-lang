//! Presets are built-in collections of GML functions and constants which
//! can be shared between different instances of `CatspeakEnvironment` in
//! bulk.
//!
//! A limited set of safe, built-in GML standard library functions and
//! constants are packaged with Catspeak by default. See `Catspeak.interface`
//! if you need to expose individual functions instead of many.
//!
//! @experimental

//# feather use syntax-errors

/// Represents the set of environment presets understood by Catspeak.
/// When used with `setPreset`, this enum determines what GML
/// functions, constants, and keywords get exposed.
///
/// @experimental
enum CatspeakPreset {
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
    /// Exposes safe drawing functions.
    DRAW,
    /// Exposes safe randomisation functions.
    RANDOM,
    /// Exposes unsafe reflection and debug functions.
    /// Use this preset with extreme caution, because all bets are off.
    UNSAFE,
    /// @ignore
    __SIZE__,
}

/// @ignore
///
/// @param {Enum.CatspeakPreset} preset
/// @return {Function}
function __catspeak_preset_get(preset) {
    var presetFunc = global.__catspeakPresets[? preset];
    if (CATSPEAK_DEBUG_MODE && __catspeak_is_nullish(presetFunc)) {
        __catspeak_error(
            "a Catspeak preset with the key '",
            preset, "' does not exist, make sure the preset exists in the ",
            "`CatspeakPreset` enum"
        );
    }
    return presetFunc;
}

/// @ignore
///
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_type(ffi) {
    ffi.exposeFunction(
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
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_array(ffi) {
    ffi.exposeFunction(
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
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_struct(ffi) {
    ffi.exposeFunction(
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
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_string(ffi) {
    ffi.exposeFunction(
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
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_math(ffi) {
    ffi.exposeFunction(
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
    ffi.exposeConstant("pi", pi);
}

/// @ignore
///
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_math_3d(ffi) {
    ffi.exposeFunction(
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
}

/// @ignore
///
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_colour(ffi) {
    ffi.exposeFunction(
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
    ffi.exposeConstant(
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
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_draw(ffi) {
    ffi.exposeFunction(
        "draw_self", draw_self,
        "draw_sprite", draw_sprite,
        "draw_sprite_pos", draw_sprite_pos,
        "draw_sprite_ext", draw_sprite_ext,
        "draw_sprite_stretched", draw_sprite_stretched,
        "draw_sprite_stretched_ext", draw_sprite_stretched_ext,
        "draw_sprite_tiled", draw_sprite_tiled,
        "draw_sprite_tiled_ext", draw_sprite_tiled_ext,
        "draw_sprite_part", draw_sprite_part,
        "draw_sprite_part_ext", draw_sprite_part_ext,
        "draw_sprite_general", draw_sprite_general,
        "draw_clear", draw_clear,
        "draw_clear_alpha", draw_clear_alpha,
        "draw_point", draw_point,
        "draw_line", draw_line,
        "draw_line_width", draw_line_width,
        "draw_rectangle", draw_rectangle,
        "draw_roundrect", draw_roundrect,
        "draw_roundrect_ext", draw_roundrect_ext,
        "draw_triangle", draw_triangle,
        "draw_circle", draw_circle,
        "draw_ellipse", draw_ellipse,
        "draw_set_circle_precision", draw_set_circle_precision,
        "draw_arrow", draw_arrow,
        "draw_button", draw_button,
        "draw_path", draw_path,
        "draw_healthbar", draw_healthbar,
        "draw_getpixel", draw_getpixel,
        "draw_getpixel_ext", draw_getpixel_ext,
        "draw_set_colour", draw_set_colour,
        "draw_set_color", draw_set_color,
        "draw_set_alpha", draw_set_alpha,
        "draw_get_colour", draw_get_colour,
        "draw_get_color", draw_get_color,
        "draw_get_alpha", draw_get_alpha,
        "draw_set_font", draw_set_font,
        "draw_get_font", draw_get_font,
        "draw_set_halign", draw_set_halign,
        "draw_get_halign", draw_get_halign,
        "draw_set_valign", draw_set_valign,
        "draw_get_valign", draw_get_valign,
        "draw_text", draw_text,
        "draw_text_ext", draw_text_ext,
        "draw_text_transformed", draw_text_transformed,
        "draw_text_ext_transformed", draw_text_ext_transformed,
        "draw_text_colour", draw_text_colour,
        "draw_text_ext_colour", draw_text_ext_colour,
        "draw_text_transformed_colour", draw_text_transformed_colour,
        "draw_text_ext_transformed_colour", draw_text_ext_transformed_colour,
        "draw_text_color", draw_text_color,
        "draw_text_ext_color", draw_text_ext_color,
        "draw_text_transformed_color", draw_text_transformed_color,
        "draw_text_ext_transformed_color", draw_text_ext_transformed_color,
        "draw_point_colour", draw_point_colour,
        "draw_line_colour", draw_line_colour,
        "draw_line_width_colour", draw_line_width_colour,
        "draw_rectangle_colour", draw_rectangle_colour,
        "draw_roundrect_colour", draw_roundrect_colour,
        "draw_roundrect_colour_ext", draw_roundrect_colour_ext,
        "draw_triangle_colour", draw_triangle_colour,
        "draw_circle_colour", draw_circle_colour,
        "draw_ellipse_colour", draw_ellipse_colour,
        "draw_point_color", draw_point_color,
        "draw_line_color", draw_line_color,
        "draw_line_width_color", draw_line_width_color,
        "draw_rectangle_color", draw_rectangle_color,
        "draw_roundrect_color", draw_roundrect_color,
        "draw_roundrect_color_ext", draw_roundrect_color_ext,
        "draw_triangle_color", draw_triangle_color,
        "draw_circle_color", draw_circle_color,
        "draw_ellipse_color", draw_ellipse_color,
        "draw_primitive_begin", draw_primitive_begin,
        "draw_vertex", draw_vertex,
        "draw_vertex_colour", draw_vertex_colour,
        "draw_vertex_color", draw_vertex_color,
        "draw_primitive_end", draw_primitive_end,
        "draw_primitive_begin_texture", draw_primitive_begin_texture,
        "draw_vertex_texture", draw_vertex_texture,
        "draw_vertex_texture_colour", draw_vertex_texture_colour,
        "draw_vertex_texture_color", draw_vertex_texture_color,
        "draw_surface", draw_surface,
        "draw_surface_stretched", draw_surface_stretched,
        "draw_surface_tiled", draw_surface_tiled,
        "draw_surface_part", draw_surface_part,
        "draw_surface_ext", draw_surface_ext,
        "draw_surface_stretched_ext", draw_surface_stretched_ext,
        "draw_surface_tiled_ext", draw_surface_tiled_ext,
        "draw_surface_part_ext", draw_surface_part_ext,
        "draw_surface_general", draw_surface_general,
        "draw_highscore", draw_highscore,
        "draw_enable_drawevent", draw_enable_drawevent,
        "draw_enable_swf_aa", draw_enable_swf_aa,
        "draw_set_swf_aa_level", draw_set_swf_aa_level,
        "draw_get_swf_aa_level", draw_get_swf_aa_level,
        "draw_texture_flush", draw_texture_flush,
        "draw_flush", draw_flush,
        "draw_light_define_ambient", draw_light_define_ambient,
        "draw_light_define_direction", draw_light_define_direction,
        "draw_light_define_point", draw_light_define_point,
        "draw_light_enable", draw_light_enable,
        "draw_set_lighting", draw_set_lighting,
        "draw_light_get_ambient", draw_light_get_ambient,
        "draw_light_get", draw_light_get,
        "draw_get_lighting", draw_get_lighting,
        "draw_tilemap", draw_tilemap,
        "draw_tile", draw_tile,
        // vertex buffers
        "vertex_format_begin", vertex_format_begin,
        "vertex_format_end", vertex_format_end,
        "vertex_format_delete", vertex_format_delete,
        "vertex_format_add_position", vertex_format_add_position,
        "vertex_format_add_position_3d", vertex_format_add_position_3d,
        "vertex_format_add_colour", vertex_format_add_colour,
        "vertex_format_add_color", vertex_format_add_color,
        "vertex_format_add_normal", vertex_format_add_normal,
        "vertex_format_add_texcoord", vertex_format_add_texcoord,
        "vertex_format_add_textcoord", vertex_format_add_texcoord,
        "vertex_format_add_custom", vertex_format_add_custom,
        "vertex_create_buffer", vertex_create_buffer,
        "vertex_create_buffer_ext", vertex_create_buffer_ext,
        "vertex_delete_buffer", vertex_delete_buffer,
        "vertex_begin", vertex_begin,
        "vertex_end", vertex_end,
        "vertex_position", vertex_position,
        "vertex_position_3d", vertex_position_3d,
        "vertex_colour", vertex_colour,
        "vertex_color", vertex_color,
        "vertex_argb", vertex_argb,
        "vertex_texcoord", vertex_texcoord,
        "vertex_normal", vertex_normal,
        "vertex_float1", vertex_float1,
        "vertex_float2", vertex_float2,
        "vertex_float3", vertex_float3,
        "vertex_float4", vertex_float4,
        "vertex_ubyte4", vertex_ubyte4,
        "vertex_submit", vertex_submit,
        "vertex_freeze", vertex_freeze,
        "vertex_get_number", vertex_get_number,
        "vertex_get_buffer_size", vertex_get_buffer_size,
    );
    ffi.exposeConstant(
        "vertex_usage_position", vertex_usage_position,
        "vertex_usage_colour", vertex_usage_colour,
        "vertex_usage_color", vertex_usage_color,
        "vertex_usage_normal", vertex_usage_normal,
        "vertex_usage_texcoord", vertex_usage_texcoord,
        "vertex_usage_textcoord", vertex_usage_texcoord,
        "vertex_usage_blendweight", vertex_usage_blendweight,
        "vertex_usage_blendindices", vertex_usage_blendindices,
        "vertex_usage_psize", vertex_usage_psize,
        "vertex_usage_tangent", vertex_usage_tangent,
        "vertex_usage_binormal", vertex_usage_binormal,
        "vertex_usage_fog", vertex_usage_fog,
        "vertex_usage_depth", vertex_usage_depth,
        "vertex_usage_sample", vertex_usage_sample,
        "vertex_type_float1", vertex_type_float1,
        "vertex_type_float2", vertex_type_float2,
        "vertex_type_float3", vertex_type_float3,
        "vertex_type_float4", vertex_type_float4,
        "vertex_type_colour", vertex_type_colour,
        "vertex_type_color", vertex_type_color,
        "vertex_type_ubyte4", vertex_type_ubyte4,
    );
}

/// @ignore
///
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_random(ffi) {
    ffi.exposeFunction(
        "choose", choose,
        "random", random,
        "random_range", random_range,
        "irandom", irandom,
        "irandom_range", irandom_range
    );
}

/// @ignore
///
/// @param {Struct.CatspeakForeignInterface} ffi
function __catspeak_preset_unsafe(ffi) {
    ffi.exposeFunction(
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

/// Adds a new global preset function which can be used to initialise any new
/// catspeak environments.
///
/// @experimental
///
/// @param {Any} key
///   The key to use for the preset. Preferably a string, but it can be any
///   value type.
///
/// @param {Function} callback
///   The function to call to initialise the environment.
///
/// @example
///   Adds a new preset called "my-custom" which, when applied, will
///   add an `rgb` function to the given `CatspeakEnvironment`.
///
///   ```gml
///   catspeak_preset_add("my-custom", function (interface, keywords) {
///     interface.exposeFunction("rgb", make_colour_rgb);
///   });
///   ```
///
///   This preset can then be applied using `Catspeak.applyPreset`:
///   ```gml
///   Catspeak.applyPreset("my-custom");
///   ```
function catspeak_preset_add(key, callback) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
    }
    var presets = global.__catspeakPresets;
    if (ds_map_exists(presets, key)) {
       __catspeak_error("a preset with the key '", key, "' already exists");
    }
    presets[? key] = callback;
}

/// @ignore
function __catspeak_init_presets() {
    /// @ignore
    global.__catspeakPresets = ds_map_create();
    catspeak_preset_add(CatspeakPreset.TYPE, __catspeak_preset_type);
    catspeak_preset_add(CatspeakPreset.ARRAY, __catspeak_preset_array);
    catspeak_preset_add(CatspeakPreset.STRUCT, __catspeak_preset_struct);
    catspeak_preset_add(CatspeakPreset.STRING, __catspeak_preset_string);
    catspeak_preset_add(CatspeakPreset.MATH, __catspeak_preset_math);
    catspeak_preset_add(CatspeakPreset.MATH_3D, __catspeak_preset_math_3d);
    catspeak_preset_add(CatspeakPreset.COLOUR, __catspeak_preset_colour);
    catspeak_preset_add(CatspeakPreset.DRAW, __catspeak_preset_draw);
    catspeak_preset_add(CatspeakPreset.RANDOM, __catspeak_preset_random);
    catspeak_preset_add(CatspeakPreset.UNSAFE, __catspeak_preset_unsafe);
}