//! AUTO GENERATED, DON'T MODIFY THIS FILE
//! DELETE THIS FILE IF YOU DO NOT USE
//!
//! ```gml
//! Catspeak.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
//! ```

//# feather use syntax-errors

/// @ignore
function __catspeak_get_gml_interface() {
    static db = undefined;
    if (db == undefined) {
        skipped = false;
        db = { };
        with ({ }) { // protects from incorrectly reading a missing function from an instance variable
            try { db[$ "is_real"] = method(undefined, is_real) } catch (ce_) { skipped = true }
            try { db[$ "is_numeric"] = method(undefined, is_numeric) } catch (ce_) { skipped = true }
            try { db[$ "is_string"] = method(undefined, is_string) } catch (ce_) { skipped = true }
            try { db[$ "is_array"] = method(undefined, is_array) } catch (ce_) { skipped = true }
            try { db[$ "is_undefined"] = method(undefined, is_undefined) } catch (ce_) { skipped = true }
            try { db[$ "is_int32"] = method(undefined, is_int32) } catch (ce_) { skipped = true }
            try { db[$ "is_int64"] = method(undefined, is_int64) } catch (ce_) { skipped = true }
            try { db[$ "is_ptr"] = method(undefined, is_ptr) } catch (ce_) { skipped = true }
            try { db[$ "is_bool"] = method(undefined, is_bool) } catch (ce_) { skipped = true }
            try { db[$ "is_nan"] = method(undefined, is_nan) } catch (ce_) { skipped = true }
            try { db[$ "is_infinity"] = method(undefined, is_infinity) } catch (ce_) { skipped = true }
            try { db[$ "is_struct"] = method(undefined, is_struct) } catch (ce_) { skipped = true }
            try { db[$ "is_method"] = method(undefined, is_method) } catch (ce_) { skipped = true }
            try { db[$ "is_instanceof"] = method(undefined, is_instanceof) } catch (ce_) { skipped = true }
            try { db[$ "is_callable"] = method(undefined, is_callable) } catch (ce_) { skipped = true }
            try { db[$ "is_handle"] = method(undefined, is_handle) } catch (ce_) { skipped = true }
            try { db[$ "static_get"] = method(undefined, static_get) } catch (ce_) { skipped = true }
            try { db[$ "static_set"] = method(undefined, static_set) } catch (ce_) { skipped = true }
            try { db[$ "typeof"] = method(undefined, typeof) } catch (ce_) { skipped = true }
            try { db[$ "instanceof"] = method(undefined, instanceof) } catch (ce_) { skipped = true }
            try { db[$ "exception_unhandled_handler"] = method(undefined, exception_unhandled_handler) } catch (ce_) { skipped = true }
            try { db[$ "variable_global_exists"] = method(undefined, variable_global_exists) } catch (ce_) { skipped = true }
            try { db[$ "variable_global_get"] = method(undefined, variable_global_get) } catch (ce_) { skipped = true }
            try { db[$ "variable_global_set"] = method(undefined, variable_global_set) } catch (ce_) { skipped = true }
            try { db[$ "variable_instance_exists"] = method(undefined, variable_instance_exists) } catch (ce_) { skipped = true }
            try { db[$ "variable_instance_get"] = method(undefined, variable_instance_get) } catch (ce_) { skipped = true }
            try { db[$ "variable_instance_set"] = method(undefined, variable_instance_set) } catch (ce_) { skipped = true }
            try { db[$ "variable_instance_get_names"] = method(undefined, variable_instance_get_names) } catch (ce_) { skipped = true }
            try { db[$ "variable_instance_names_count"] = method(undefined, variable_instance_names_count) } catch (ce_) { skipped = true }
            try { db[$ "variable_struct_exists"] = method(undefined, variable_struct_exists) } catch (ce_) { skipped = true }
            try { db[$ "variable_struct_get"] = method(undefined, variable_struct_get) } catch (ce_) { skipped = true }
            try { db[$ "variable_struct_set"] = method(undefined, variable_struct_set) } catch (ce_) { skipped = true }
            try { db[$ "variable_struct_get_names"] = method(undefined, variable_struct_get_names) } catch (ce_) { skipped = true }
            try { db[$ "variable_struct_names_count"] = method(undefined, variable_struct_names_count) } catch (ce_) { skipped = true }
            try { db[$ "variable_struct_remove"] = method(undefined, variable_struct_remove) } catch (ce_) { skipped = true }
            try { db[$ "variable_get_hash"] = method(undefined, variable_get_hash) } catch (ce_) { skipped = true }
            try { db[$ "variable_clone"] = method(undefined, variable_clone) } catch (ce_) { skipped = true }
            try { db[$ "struct_exists"] = method(undefined, struct_exists) } catch (ce_) { skipped = true }
            try { db[$ "struct_get"] = method(undefined, struct_get) } catch (ce_) { skipped = true }
            try { db[$ "struct_set"] = method(undefined, struct_set) } catch (ce_) { skipped = true }
            try { db[$ "struct_get_names"] = method(undefined, struct_get_names) } catch (ce_) { skipped = true }
            try { db[$ "struct_names_count"] = method(undefined, struct_names_count) } catch (ce_) { skipped = true }
            try { db[$ "struct_remove"] = method(undefined, struct_remove) } catch (ce_) { skipped = true }
            try { db[$ "struct_foreach"] = method(undefined, struct_foreach) } catch (ce_) { skipped = true }
            try { db[$ "struct_get_from_hash"] = method(undefined, struct_get_from_hash) } catch (ce_) { skipped = true }
            try { db[$ "struct_set_from_hash"] = method(undefined, struct_set_from_hash) } catch (ce_) { skipped = true }
            try { db[$ "array_length"] = method(undefined, array_length) } catch (ce_) { skipped = true }
            try { db[$ "array_equals"] = method(undefined, array_equals) } catch (ce_) { skipped = true }
            try { db[$ "array_create"] = method(undefined, array_create) } catch (ce_) { skipped = true }
            try { db[$ "array_copy"] = method(undefined, array_copy) } catch (ce_) { skipped = true }
            try { db[$ "array_resize"] = method(undefined, array_resize) } catch (ce_) { skipped = true }
            try { db[$ "array_get"] = method(undefined, array_get) } catch (ce_) { skipped = true }
            try { db[$ "array_set"] = method(undefined, array_set) } catch (ce_) { skipped = true }
            try { db[$ "array_push"] = method(undefined, array_push) } catch (ce_) { skipped = true }
            try { db[$ "array_pop"] = method(undefined, array_pop) } catch (ce_) { skipped = true }
            try { db[$ "array_shift"] = method(undefined, array_shift) } catch (ce_) { skipped = true }
            try { db[$ "array_insert"] = method(undefined, array_insert) } catch (ce_) { skipped = true }
            try { db[$ "array_delete"] = method(undefined, array_delete) } catch (ce_) { skipped = true }
            try { db[$ "array_sort"] = method(undefined, array_sort) } catch (ce_) { skipped = true }
            try { db[$ "array_shuffle"] = method(undefined, array_shuffle) } catch (ce_) { skipped = true }
            try { db[$ "array_shuffle_ext"] = method(undefined, array_shuffle_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_get_index"] = method(undefined, array_get_index) } catch (ce_) { skipped = true }
            try { db[$ "array_contains"] = method(undefined, array_contains) } catch (ce_) { skipped = true }
            try { db[$ "array_contains_ext"] = method(undefined, array_contains_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_first"] = method(undefined, array_first) } catch (ce_) { skipped = true }
            try { db[$ "array_last"] = method(undefined, array_last) } catch (ce_) { skipped = true }
            try { db[$ "array_create_ext"] = method(undefined, array_create_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_find_index"] = method(undefined, array_find_index) } catch (ce_) { skipped = true }
            try { db[$ "array_any"] = method(undefined, array_any) } catch (ce_) { skipped = true }
            try { db[$ "array_all"] = method(undefined, array_all) } catch (ce_) { skipped = true }
            try { db[$ "array_foreach"] = method(undefined, array_foreach) } catch (ce_) { skipped = true }
            try { db[$ "array_reduce"] = method(undefined, array_reduce) } catch (ce_) { skipped = true }
            try { db[$ "array_filter"] = method(undefined, array_filter) } catch (ce_) { skipped = true }
            try { db[$ "array_filter_ext"] = method(undefined, array_filter_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_map"] = method(undefined, array_map) } catch (ce_) { skipped = true }
            try { db[$ "array_map_ext"] = method(undefined, array_map_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_copy_while"] = method(undefined, array_copy_while) } catch (ce_) { skipped = true }
            try { db[$ "array_unique"] = method(undefined, array_unique) } catch (ce_) { skipped = true }
            try { db[$ "array_unique_ext"] = method(undefined, array_unique_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_reverse"] = method(undefined, array_reverse) } catch (ce_) { skipped = true }
            try { db[$ "array_reverse_ext"] = method(undefined, array_reverse_ext) } catch (ce_) { skipped = true }
            try { db[$ "array_concat"] = method(undefined, array_concat) } catch (ce_) { skipped = true }
            try { db[$ "array_union"] = method(undefined, array_union) } catch (ce_) { skipped = true }
            try { db[$ "array_intersection"] = method(undefined, array_intersection) } catch (ce_) { skipped = true }
            try { db[$ "random"] = method(undefined, random) } catch (ce_) { skipped = true }
            try { db[$ "random_range"] = method(undefined, random_range) } catch (ce_) { skipped = true }
            try { db[$ "irandom"] = method(undefined, irandom) } catch (ce_) { skipped = true }
            try { db[$ "irandom_range"] = method(undefined, irandom_range) } catch (ce_) { skipped = true }
            try { db[$ "random_set_seed"] = method(undefined, random_set_seed) } catch (ce_) { skipped = true }
            try { db[$ "random_get_seed"] = method(undefined, random_get_seed) } catch (ce_) { skipped = true }
            try { db[$ "randomize"] = method(undefined, randomize) } catch (ce_) { skipped = true }
            try { db[$ "randomise"] = method(undefined, randomise) } catch (ce_) { skipped = true }
            try { db[$ "choose"] = method(undefined, choose) } catch (ce_) { skipped = true }
            try { db[$ "abs"] = method(undefined, abs) } catch (ce_) { skipped = true }
            try { db[$ "round"] = method(undefined, round) } catch (ce_) { skipped = true }
            try { db[$ "floor"] = method(undefined, floor) } catch (ce_) { skipped = true }
            try { db[$ "ceil"] = method(undefined, ceil) } catch (ce_) { skipped = true }
            try { db[$ "sign"] = method(undefined, sign) } catch (ce_) { skipped = true }
            try { db[$ "frac"] = method(undefined, frac) } catch (ce_) { skipped = true }
            try { db[$ "sqrt"] = method(undefined, sqrt) } catch (ce_) { skipped = true }
            try { db[$ "sqr"] = method(undefined, sqr) } catch (ce_) { skipped = true }
            try { db[$ "exp"] = method(undefined, exp) } catch (ce_) { skipped = true }
            try { db[$ "ln"] = method(undefined, ln) } catch (ce_) { skipped = true }
            try { db[$ "log2"] = method(undefined, log2) } catch (ce_) { skipped = true }
            try { db[$ "log10"] = method(undefined, log10) } catch (ce_) { skipped = true }
            try { db[$ "sin"] = method(undefined, sin) } catch (ce_) { skipped = true }
            try { db[$ "cos"] = method(undefined, cos) } catch (ce_) { skipped = true }
            try { db[$ "tan"] = method(undefined, tan) } catch (ce_) { skipped = true }
            try { db[$ "arcsin"] = method(undefined, arcsin) } catch (ce_) { skipped = true }
            try { db[$ "arccos"] = method(undefined, arccos) } catch (ce_) { skipped = true }
            try { db[$ "arctan"] = method(undefined, arctan) } catch (ce_) { skipped = true }
            try { db[$ "arctan2"] = method(undefined, arctan2) } catch (ce_) { skipped = true }
            try { db[$ "dsin"] = method(undefined, dsin) } catch (ce_) { skipped = true }
            try { db[$ "dcos"] = method(undefined, dcos) } catch (ce_) { skipped = true }
            try { db[$ "dtan"] = method(undefined, dtan) } catch (ce_) { skipped = true }
            try { db[$ "darcsin"] = method(undefined, darcsin) } catch (ce_) { skipped = true }
            try { db[$ "darccos"] = method(undefined, darccos) } catch (ce_) { skipped = true }
            try { db[$ "darctan"] = method(undefined, darctan) } catch (ce_) { skipped = true }
            try { db[$ "darctan2"] = method(undefined, darctan2) } catch (ce_) { skipped = true }
            try { db[$ "degtorad"] = method(undefined, degtorad) } catch (ce_) { skipped = true }
            try { db[$ "radtodeg"] = method(undefined, radtodeg) } catch (ce_) { skipped = true }
            try { db[$ "power"] = method(undefined, power) } catch (ce_) { skipped = true }
            try { db[$ "logn"] = method(undefined, logn) } catch (ce_) { skipped = true }
            try { db[$ "min"] = method(undefined, min) } catch (ce_) { skipped = true }
            try { db[$ "max"] = method(undefined, max) } catch (ce_) { skipped = true }
            try { db[$ "mean"] = method(undefined, mean) } catch (ce_) { skipped = true }
            try { db[$ "median"] = method(undefined, median) } catch (ce_) { skipped = true }
            try { db[$ "clamp"] = method(undefined, clamp) } catch (ce_) { skipped = true }
            try { db[$ "lerp"] = method(undefined, lerp) } catch (ce_) { skipped = true }
            try { db[$ "dot_product"] = method(undefined, dot_product) } catch (ce_) { skipped = true }
            try { db[$ "dot_product_3d"] = method(undefined, dot_product_3d) } catch (ce_) { skipped = true }
            try { db[$ "dot_product_normalised"] = method(undefined, dot_product_normalised) } catch (ce_) { skipped = true }
            try { db[$ "dot_product_3d_normalised"] = method(undefined, dot_product_3d_normalised) } catch (ce_) { skipped = true }
            try { db[$ "dot_product_normalized"] = method(undefined, dot_product_normalized) } catch (ce_) { skipped = true }
            try { db[$ "dot_product_3d_normalized"] = method(undefined, dot_product_3d_normalized) } catch (ce_) { skipped = true }
            try { db[$ "math_set_epsilon"] = method(undefined, math_set_epsilon) } catch (ce_) { skipped = true }
            try { db[$ "math_get_epsilon"] = method(undefined, math_get_epsilon) } catch (ce_) { skipped = true }
            try { db[$ "angle_difference"] = method(undefined, angle_difference) } catch (ce_) { skipped = true }
            try { db[$ "point_distance_3d"] = method(undefined, point_distance_3d) } catch (ce_) { skipped = true }
            try { db[$ "point_distance"] = method(undefined, point_distance) } catch (ce_) { skipped = true }
            try { db[$ "point_direction"] = method(undefined, point_direction) } catch (ce_) { skipped = true }
            try { db[$ "lengthdir_x"] = method(undefined, lengthdir_x) } catch (ce_) { skipped = true }
            try { db[$ "lengthdir_y"] = method(undefined, lengthdir_y) } catch (ce_) { skipped = true }
            try { db[$ "real"] = method(undefined, real) } catch (ce_) { skipped = true }
            try { db[$ "bool"] = method(undefined, bool) } catch (ce_) { skipped = true }
            try { db[$ "string"] = method(undefined, string) } catch (ce_) { skipped = true }
            try { db[$ "int64"] = method(undefined, int64) } catch (ce_) { skipped = true }
            try { db[$ "ptr"] = method(undefined, ptr) } catch (ce_) { skipped = true }
            try { db[$ "handle_parse"] = method(undefined, handle_parse) } catch (ce_) { skipped = true }
            try { db[$ "string_format"] = method(undefined, string_format) } catch (ce_) { skipped = true }
            try { db[$ "chr"] = method(undefined, chr) } catch (ce_) { skipped = true }
            try { db[$ "ansi_char"] = method(undefined, ansi_char) } catch (ce_) { skipped = true }
            try { db[$ "ord"] = method(undefined, ord) } catch (ce_) { skipped = true }
            try { db[$ "method"] = method(undefined, catspeak_method) } catch (ce_) { skipped = true }
            try { db[$ "method_get_index"] = method(undefined, method_get_index) } catch (ce_) { skipped = true }
            try { db[$ "method_get_self"] = method(undefined, method_get_self) } catch (ce_) { skipped = true }
            try { db[$ "string_length"] = method(undefined, string_length) } catch (ce_) { skipped = true }
            try { db[$ "string_byte_length"] = method(undefined, string_byte_length) } catch (ce_) { skipped = true }
            try { db[$ "string_pos"] = method(undefined, string_pos) } catch (ce_) { skipped = true }
            try { db[$ "string_pos_ext"] = method(undefined, string_pos_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_last_pos"] = method(undefined, string_last_pos) } catch (ce_) { skipped = true }
            try { db[$ "string_last_pos_ext"] = method(undefined, string_last_pos_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_copy"] = method(undefined, string_copy) } catch (ce_) { skipped = true }
            try { db[$ "string_char_at"] = method(undefined, string_char_at) } catch (ce_) { skipped = true }
            try { db[$ "string_ord_at"] = method(undefined, string_ord_at) } catch (ce_) { skipped = true }
            try { db[$ "string_byte_at"] = method(undefined, string_byte_at) } catch (ce_) { skipped = true }
            try { db[$ "string_set_byte_at"] = method(undefined, string_set_byte_at) } catch (ce_) { skipped = true }
            try { db[$ "string_delete"] = method(undefined, string_delete) } catch (ce_) { skipped = true }
            try { db[$ "string_insert"] = method(undefined, string_insert) } catch (ce_) { skipped = true }
            try { db[$ "string_lower"] = method(undefined, string_lower) } catch (ce_) { skipped = true }
            try { db[$ "string_upper"] = method(undefined, string_upper) } catch (ce_) { skipped = true }
            try { db[$ "string_repeat"] = method(undefined, string_repeat) } catch (ce_) { skipped = true }
            try { db[$ "string_letters"] = method(undefined, string_letters) } catch (ce_) { skipped = true }
            try { db[$ "string_digits"] = method(undefined, string_digits) } catch (ce_) { skipped = true }
            try { db[$ "string_lettersdigits"] = method(undefined, string_lettersdigits) } catch (ce_) { skipped = true }
            try { db[$ "string_replace"] = method(undefined, string_replace) } catch (ce_) { skipped = true }
            try { db[$ "string_replace_all"] = method(undefined, string_replace_all) } catch (ce_) { skipped = true }
            try { db[$ "string_count"] = method(undefined, string_count) } catch (ce_) { skipped = true }
            try { db[$ "string_hash_to_newline"] = method(undefined, string_hash_to_newline) } catch (ce_) { skipped = true }
            try { db[$ "string_ext"] = method(undefined, string_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_trim_start"] = method(undefined, string_trim_start) } catch (ce_) { skipped = true }
            try { db[$ "string_trim_end"] = method(undefined, string_trim_end) } catch (ce_) { skipped = true }
            try { db[$ "string_trim"] = method(undefined, string_trim) } catch (ce_) { skipped = true }
            try { db[$ "string_starts_with"] = method(undefined, string_starts_with) } catch (ce_) { skipped = true }
            try { db[$ "string_ends_with"] = method(undefined, string_ends_with) } catch (ce_) { skipped = true }
            try { db[$ "string_split"] = method(undefined, string_split) } catch (ce_) { skipped = true }
            try { db[$ "string_split_ext"] = method(undefined, string_split_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_join"] = method(undefined, string_join) } catch (ce_) { skipped = true }
            try { db[$ "string_join_ext"] = method(undefined, string_join_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_concat"] = method(undefined, string_concat) } catch (ce_) { skipped = true }
            try { db[$ "string_concat_ext"] = method(undefined, string_concat_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_foreach"] = method(undefined, string_foreach) } catch (ce_) { skipped = true }
            try { db[$ "clipboard_has_text"] = method(undefined, clipboard_has_text) } catch (ce_) { skipped = true }
            try { db[$ "clipboard_set_text"] = method(undefined, clipboard_set_text) } catch (ce_) { skipped = true }
            try { db[$ "clipboard_get_text"] = method(undefined, clipboard_get_text) } catch (ce_) { skipped = true }
            try { db[$ "date_current_datetime"] = method(undefined, date_current_datetime) } catch (ce_) { skipped = true }
            try { db[$ "date_create_datetime"] = method(undefined, date_create_datetime) } catch (ce_) { skipped = true }
            try { db[$ "date_valid_datetime"] = method(undefined, date_valid_datetime) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_year"] = method(undefined, date_inc_year) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_month"] = method(undefined, date_inc_month) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_week"] = method(undefined, date_inc_week) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_day"] = method(undefined, date_inc_day) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_hour"] = method(undefined, date_inc_hour) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_minute"] = method(undefined, date_inc_minute) } catch (ce_) { skipped = true }
            try { db[$ "date_inc_second"] = method(undefined, date_inc_second) } catch (ce_) { skipped = true }
            try { db[$ "date_get_year"] = method(undefined, date_get_year) } catch (ce_) { skipped = true }
            try { db[$ "date_get_month"] = method(undefined, date_get_month) } catch (ce_) { skipped = true }
            try { db[$ "date_get_week"] = method(undefined, date_get_week) } catch (ce_) { skipped = true }
            try { db[$ "date_get_day"] = method(undefined, date_get_day) } catch (ce_) { skipped = true }
            try { db[$ "date_get_hour"] = method(undefined, date_get_hour) } catch (ce_) { skipped = true }
            try { db[$ "date_get_minute"] = method(undefined, date_get_minute) } catch (ce_) { skipped = true }
            try { db[$ "date_get_second"] = method(undefined, date_get_second) } catch (ce_) { skipped = true }
            try { db[$ "date_get_weekday"] = method(undefined, date_get_weekday) } catch (ce_) { skipped = true }
            try { db[$ "date_get_day_of_year"] = method(undefined, date_get_day_of_year) } catch (ce_) { skipped = true }
            try { db[$ "date_get_hour_of_year"] = method(undefined, date_get_hour_of_year) } catch (ce_) { skipped = true }
            try { db[$ "date_get_minute_of_year"] = method(undefined, date_get_minute_of_year) } catch (ce_) { skipped = true }
            try { db[$ "date_get_second_of_year"] = method(undefined, date_get_second_of_year) } catch (ce_) { skipped = true }
            try { db[$ "date_year_span"] = method(undefined, date_year_span) } catch (ce_) { skipped = true }
            try { db[$ "date_month_span"] = method(undefined, date_month_span) } catch (ce_) { skipped = true }
            try { db[$ "date_week_span"] = method(undefined, date_week_span) } catch (ce_) { skipped = true }
            try { db[$ "date_day_span"] = method(undefined, date_day_span) } catch (ce_) { skipped = true }
            try { db[$ "date_hour_span"] = method(undefined, date_hour_span) } catch (ce_) { skipped = true }
            try { db[$ "date_minute_span"] = method(undefined, date_minute_span) } catch (ce_) { skipped = true }
            try { db[$ "date_second_span"] = method(undefined, date_second_span) } catch (ce_) { skipped = true }
            try { db[$ "date_compare_datetime"] = method(undefined, date_compare_datetime) } catch (ce_) { skipped = true }
            try { db[$ "date_compare_date"] = method(undefined, date_compare_date) } catch (ce_) { skipped = true }
            try { db[$ "date_compare_time"] = method(undefined, date_compare_time) } catch (ce_) { skipped = true }
            try { db[$ "date_date_of"] = method(undefined, date_date_of) } catch (ce_) { skipped = true }
            try { db[$ "date_time_of"] = method(undefined, date_time_of) } catch (ce_) { skipped = true }
            try { db[$ "date_datetime_string"] = method(undefined, date_datetime_string) } catch (ce_) { skipped = true }
            try { db[$ "date_date_string"] = method(undefined, date_date_string) } catch (ce_) { skipped = true }
            try { db[$ "date_time_string"] = method(undefined, date_time_string) } catch (ce_) { skipped = true }
            try { db[$ "date_days_in_month"] = method(undefined, date_days_in_month) } catch (ce_) { skipped = true }
            try { db[$ "date_days_in_year"] = method(undefined, date_days_in_year) } catch (ce_) { skipped = true }
            try { db[$ "date_leap_year"] = method(undefined, date_leap_year) } catch (ce_) { skipped = true }
            try { db[$ "date_is_today"] = method(undefined, date_is_today) } catch (ce_) { skipped = true }
            try { db[$ "date_set_timezone"] = method(undefined, date_set_timezone) } catch (ce_) { skipped = true }
            try { db[$ "date_get_timezone"] = method(undefined, date_get_timezone) } catch (ce_) { skipped = true }
            try { db[$ "game_set_speed"] = method(undefined, game_set_speed) } catch (ce_) { skipped = true }
            try { db[$ "game_get_speed"] = method(undefined, game_get_speed) } catch (ce_) { skipped = true }
            try { db[$ "motion_set"] = method(undefined, motion_set) } catch (ce_) { skipped = true }
            try { db[$ "motion_add"] = method(undefined, motion_add) } catch (ce_) { skipped = true }
            try { db[$ "place_free"] = method(undefined, place_free) } catch (ce_) { skipped = true }
            try { db[$ "place_empty"] = method(undefined, place_empty) } catch (ce_) { skipped = true }
            try { db[$ "place_meeting"] = method(undefined, place_meeting) } catch (ce_) { skipped = true }
            try { db[$ "place_snapped"] = method(undefined, place_snapped) } catch (ce_) { skipped = true }
            try { db[$ "move_random"] = method(undefined, move_random) } catch (ce_) { skipped = true }
            try { db[$ "move_snap"] = method(undefined, move_snap) } catch (ce_) { skipped = true }
            try { db[$ "move_towards_point"] = method(undefined, move_towards_point) } catch (ce_) { skipped = true }
            try { db[$ "move_contact_solid"] = method(undefined, move_contact_solid) } catch (ce_) { skipped = true }
            try { db[$ "move_contact_all"] = method(undefined, move_contact_all) } catch (ce_) { skipped = true }
            try { db[$ "move_outside_solid"] = method(undefined, move_outside_solid) } catch (ce_) { skipped = true }
            try { db[$ "move_outside_all"] = method(undefined, move_outside_all) } catch (ce_) { skipped = true }
            try { db[$ "move_bounce_solid"] = method(undefined, move_bounce_solid) } catch (ce_) { skipped = true }
            try { db[$ "move_bounce_all"] = method(undefined, move_bounce_all) } catch (ce_) { skipped = true }
            try { db[$ "move_wrap"] = method(undefined, move_wrap) } catch (ce_) { skipped = true }
            try { db[$ "move_and_collide"] = method(undefined, move_and_collide) } catch (ce_) { skipped = true }
            try { db[$ "distance_to_point"] = method(undefined, distance_to_point) } catch (ce_) { skipped = true }
            try { db[$ "distance_to_object"] = method(undefined, distance_to_object) } catch (ce_) { skipped = true }
            try { db[$ "position_empty"] = method(undefined, position_empty) } catch (ce_) { skipped = true }
            try { db[$ "position_meeting"] = method(undefined, position_meeting) } catch (ce_) { skipped = true }
            try { db[$ "path_start"] = method(undefined, path_start) } catch (ce_) { skipped = true }
            try { db[$ "path_end"] = method(undefined, path_end) } catch (ce_) { skipped = true }
            try { db[$ "mp_linear_step"] = method(undefined, mp_linear_step) } catch (ce_) { skipped = true }
            try { db[$ "mp_potential_step"] = method(undefined, mp_potential_step) } catch (ce_) { skipped = true }
            try { db[$ "mp_linear_step_object"] = method(undefined, mp_linear_step_object) } catch (ce_) { skipped = true }
            try { db[$ "mp_potential_step_object"] = method(undefined, mp_potential_step_object) } catch (ce_) { skipped = true }
            try { db[$ "mp_potential_settings"] = method(undefined, mp_potential_settings) } catch (ce_) { skipped = true }
            try { db[$ "mp_linear_path"] = method(undefined, mp_linear_path) } catch (ce_) { skipped = true }
            try { db[$ "mp_potential_path"] = method(undefined, mp_potential_path) } catch (ce_) { skipped = true }
            try { db[$ "mp_linear_path_object"] = method(undefined, mp_linear_path_object) } catch (ce_) { skipped = true }
            try { db[$ "mp_potential_path_object"] = method(undefined, mp_potential_path_object) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_create"] = method(undefined, mp_grid_create) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_destroy"] = method(undefined, mp_grid_destroy) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_clear_all"] = method(undefined, mp_grid_clear_all) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_clear_cell"] = method(undefined, mp_grid_clear_cell) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_clear_rectangle"] = method(undefined, mp_grid_clear_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_add_cell"] = method(undefined, mp_grid_add_cell) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_get_cell"] = method(undefined, mp_grid_get_cell) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_add_rectangle"] = method(undefined, mp_grid_add_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_add_instances"] = method(undefined, mp_grid_add_instances) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_path"] = method(undefined, mp_grid_path) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_draw"] = method(undefined, mp_grid_draw) } catch (ce_) { skipped = true }
            try { db[$ "mp_grid_to_ds_grid"] = method(undefined, mp_grid_to_ds_grid) } catch (ce_) { skipped = true }
            try { db[$ "collision_point"] = method(undefined, collision_point) } catch (ce_) { skipped = true }
            try { db[$ "collision_rectangle"] = method(undefined, collision_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "collision_circle"] = method(undefined, collision_circle) } catch (ce_) { skipped = true }
            try { db[$ "collision_ellipse"] = method(undefined, collision_ellipse) } catch (ce_) { skipped = true }
            try { db[$ "collision_line"] = method(undefined, collision_line) } catch (ce_) { skipped = true }
            try { db[$ "collision_point_list"] = method(undefined, collision_point_list) } catch (ce_) { skipped = true }
            try { db[$ "collision_rectangle_list"] = method(undefined, collision_rectangle_list) } catch (ce_) { skipped = true }
            try { db[$ "collision_circle_list"] = method(undefined, collision_circle_list) } catch (ce_) { skipped = true }
            try { db[$ "collision_ellipse_list"] = method(undefined, collision_ellipse_list) } catch (ce_) { skipped = true }
            try { db[$ "collision_line_list"] = method(undefined, collision_line_list) } catch (ce_) { skipped = true }
            try { db[$ "instance_position_list"] = method(undefined, instance_position_list) } catch (ce_) { skipped = true }
            try { db[$ "instance_place_list"] = method(undefined, instance_place_list) } catch (ce_) { skipped = true }
            try { db[$ "point_in_rectangle"] = method(undefined, point_in_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "point_in_triangle"] = method(undefined, point_in_triangle) } catch (ce_) { skipped = true }
            try { db[$ "point_in_circle"] = method(undefined, point_in_circle) } catch (ce_) { skipped = true }
            try { db[$ "rectangle_in_rectangle"] = method(undefined, rectangle_in_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "rectangle_in_triangle"] = method(undefined, rectangle_in_triangle) } catch (ce_) { skipped = true }
            try { db[$ "rectangle_in_circle"] = method(undefined, rectangle_in_circle) } catch (ce_) { skipped = true }
            try { db[$ "instance_find"] = method(undefined, instance_find) } catch (ce_) { skipped = true }
            try { db[$ "instance_exists"] = method(undefined, instance_exists) } catch (ce_) { skipped = true }
            try { db[$ "instance_number"] = method(undefined, instance_number) } catch (ce_) { skipped = true }
            try { db[$ "instance_position"] = method(undefined, instance_position) } catch (ce_) { skipped = true }
            try { db[$ "instance_nearest"] = method(undefined, instance_nearest) } catch (ce_) { skipped = true }
            try { db[$ "instance_furthest"] = method(undefined, instance_furthest) } catch (ce_) { skipped = true }
            try { db[$ "instance_place"] = method(undefined, instance_place) } catch (ce_) { skipped = true }
            try { db[$ "instance_create_depth"] = method(undefined, instance_create_depth) } catch (ce_) { skipped = true }
            try { db[$ "instance_create_layer"] = method(undefined, instance_create_layer) } catch (ce_) { skipped = true }
            try { db[$ "instance_copy"] = method(undefined, instance_copy) } catch (ce_) { skipped = true }
            try { db[$ "instance_change"] = method(undefined, instance_change) } catch (ce_) { skipped = true }
            try { db[$ "instance_destroy"] = method(undefined, instance_destroy) } catch (ce_) { skipped = true }
            try { db[$ "position_destroy"] = method(undefined, position_destroy) } catch (ce_) { skipped = true }
            try { db[$ "position_change"] = method(undefined, position_change) } catch (ce_) { skipped = true }
            try { db[$ "instance_id_get"] = method(undefined, instance_id_get) } catch (ce_) { skipped = true }
            try { db[$ "instance_deactivate_all"] = method(undefined, instance_deactivate_all) } catch (ce_) { skipped = true }
            try { db[$ "instance_deactivate_object"] = method(undefined, instance_deactivate_object) } catch (ce_) { skipped = true }
            try { db[$ "instance_deactivate_region"] = method(undefined, instance_deactivate_region) } catch (ce_) { skipped = true }
            try { db[$ "instance_activate_all"] = method(undefined, instance_activate_all) } catch (ce_) { skipped = true }
            try { db[$ "instance_activate_object"] = method(undefined, instance_activate_object) } catch (ce_) { skipped = true }
            try { db[$ "instance_activate_region"] = method(undefined, instance_activate_region) } catch (ce_) { skipped = true }
            try { db[$ "room_goto"] = method(undefined, room_goto) } catch (ce_) { skipped = true }
            try { db[$ "room_goto_previous"] = method(undefined, room_goto_previous) } catch (ce_) { skipped = true }
            try { db[$ "room_goto_next"] = method(undefined, room_goto_next) } catch (ce_) { skipped = true }
            try { db[$ "room_previous"] = method(undefined, room_previous) } catch (ce_) { skipped = true }
            try { db[$ "room_next"] = method(undefined, room_next) } catch (ce_) { skipped = true }
            try { db[$ "room_restart"] = method(undefined, room_restart) } catch (ce_) { skipped = true }
            try { db[$ "game_end"] = method(undefined, game_end) } catch (ce_) { skipped = true }
            try { db[$ "game_restart"] = method(undefined, game_restart) } catch (ce_) { skipped = true }
            try { db[$ "game_load"] = method(undefined, game_load) } catch (ce_) { skipped = true }
            try { db[$ "game_save"] = method(undefined, game_save) } catch (ce_) { skipped = true }
            try { db[$ "game_save_buffer"] = method(undefined, game_save_buffer) } catch (ce_) { skipped = true }
            try { db[$ "game_load_buffer"] = method(undefined, game_load_buffer) } catch (ce_) { skipped = true }
            try { db[$ "game_change"] = method(undefined, game_change) } catch (ce_) { skipped = true }
            try { db[$ "scheduler_resolution_set"] = method(undefined, scheduler_resolution_set) } catch (ce_) { skipped = true }
            try { db[$ "scheduler_resolution_get"] = method(undefined, scheduler_resolution_get) } catch (ce_) { skipped = true }
            try { db[$ "event_perform"] = method(undefined, event_perform) } catch (ce_) { skipped = true }
            try { db[$ "event_perform_async"] = method(undefined, event_perform_async) } catch (ce_) { skipped = true }
            try { db[$ "event_user"] = method(undefined, event_user) } catch (ce_) { skipped = true }
            try { db[$ "event_perform_object"] = method(undefined, event_perform_object) } catch (ce_) { skipped = true }
            try { db[$ "event_inherited"] = method(undefined, event_inherited) } catch (ce_) { skipped = true }
            try { db[$ "show_debug_message"] = method(undefined, show_debug_message) } catch (ce_) { skipped = true }
            try { db[$ "show_debug_message_ext"] = method(undefined, show_debug_message_ext) } catch (ce_) { skipped = true }
            try { db[$ "show_debug_overlay"] = method(undefined, show_debug_overlay) } catch (ce_) { skipped = true }
            try { db[$ "is_debug_overlay_open"] = method(undefined, is_debug_overlay_open) } catch (ce_) { skipped = true }
            try { db[$ "is_mouse_over_debug_overlay"] = method(undefined, is_mouse_over_debug_overlay) } catch (ce_) { skipped = true }
            try { db[$ "is_keyboard_used_debug_overlay"] = method(undefined, is_keyboard_used_debug_overlay) } catch (ce_) { skipped = true }
            try { db[$ "show_debug_log"] = method(undefined, show_debug_log) } catch (ce_) { skipped = true }
            try { db[$ "debug_event"] = method(undefined, debug_event) } catch (ce_) { skipped = true }
            try { db[$ "debug_get_callstack"] = method(undefined, debug_get_callstack) } catch (ce_) { skipped = true }
            try { db[$ "alarm_get"] = method(undefined, alarm_get) } catch (ce_) { skipped = true }
            try { db[$ "alarm_set"] = method(undefined, alarm_set) } catch (ce_) { skipped = true }
            try { db[$ "dbg_view"] = method(undefined, dbg_view) } catch (ce_) { skipped = true }
            try { db[$ "dbg_section"] = method(undefined, dbg_section) } catch (ce_) { skipped = true }
            try { db[$ "dbg_view_delete"] = method(undefined, dbg_view_delete) } catch (ce_) { skipped = true }
            try { db[$ "dbg_section_delete"] = method(undefined, dbg_section_delete) } catch (ce_) { skipped = true }
            try { db[$ "dbg_slider"] = method(undefined, dbg_slider) } catch (ce_) { skipped = true }
            try { db[$ "dbg_slider_int"] = method(undefined, dbg_slider_int) } catch (ce_) { skipped = true }
            try { db[$ "dbg_drop_down"] = method(undefined, dbg_drop_down) } catch (ce_) { skipped = true }
            try { db[$ "dbg_watch"] = method(undefined, dbg_watch) } catch (ce_) { skipped = true }
            try { db[$ "dbg_text"] = method(undefined, dbg_text) } catch (ce_) { skipped = true }
            try { db[$ "dbg_sprite"] = method(undefined, dbg_sprite) } catch (ce_) { skipped = true }
            try { db[$ "dbg_text_input"] = method(undefined, dbg_text_input) } catch (ce_) { skipped = true }
            try { db[$ "dbg_checkbox"] = method(undefined, dbg_checkbox) } catch (ce_) { skipped = true }
            try { db[$ "dbg_colour"] = method(undefined, dbg_colour) } catch (ce_) { skipped = true }
            try { db[$ "dbg_color"] = method(undefined, dbg_color) } catch (ce_) { skipped = true }
            try { db[$ "dbg_button"] = method(undefined, dbg_button) } catch (ce_) { skipped = true }
            try { db[$ "dbg_same_line"] = method(undefined, dbg_same_line) } catch (ce_) { skipped = true }
            try { db[$ "dbg_add_font_glyphs"] = method(undefined, dbg_add_font_glyphs) } catch (ce_) { skipped = true }
            try { db[$ "ref_create"] = method(undefined, ref_create) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_set_map"] = method(undefined, keyboard_set_map) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_get_map"] = method(undefined, keyboard_get_map) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_unset_map"] = method(undefined, keyboard_unset_map) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_check"] = method(undefined, keyboard_check) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_check_pressed"] = method(undefined, keyboard_check_pressed) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_check_released"] = method(undefined, keyboard_check_released) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_check_direct"] = method(undefined, keyboard_check_direct) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_get_numlock"] = method(undefined, keyboard_get_numlock) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_set_numlock"] = method(undefined, keyboard_set_numlock) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_key_press"] = method(undefined, keyboard_key_press) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_key_release"] = method(undefined, keyboard_key_release) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_clear"] = method(undefined, keyboard_clear) } catch (ce_) { skipped = true }
            try { db[$ "io_clear"] = method(undefined, io_clear) } catch (ce_) { skipped = true }
            try { db[$ "mouse_check_button"] = method(undefined, mouse_check_button) } catch (ce_) { skipped = true }
            try { db[$ "mouse_check_button_pressed"] = method(undefined, mouse_check_button_pressed) } catch (ce_) { skipped = true }
            try { db[$ "mouse_check_button_released"] = method(undefined, mouse_check_button_released) } catch (ce_) { skipped = true }
            try { db[$ "mouse_wheel_up"] = method(undefined, mouse_wheel_up) } catch (ce_) { skipped = true }
            try { db[$ "mouse_wheel_down"] = method(undefined, mouse_wheel_down) } catch (ce_) { skipped = true }
            try { db[$ "mouse_clear"] = method(undefined, mouse_clear) } catch (ce_) { skipped = true }
            try { db[$ "draw_self"] = method(undefined, draw_self) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite"] = method(undefined, draw_sprite) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_pos"] = method(undefined, draw_sprite_pos) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_ext"] = method(undefined, draw_sprite_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_stretched"] = method(undefined, draw_sprite_stretched) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_stretched_ext"] = method(undefined, draw_sprite_stretched_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_tiled"] = method(undefined, draw_sprite_tiled) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_tiled_ext"] = method(undefined, draw_sprite_tiled_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_part"] = method(undefined, draw_sprite_part) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_part_ext"] = method(undefined, draw_sprite_part_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_sprite_general"] = method(undefined, draw_sprite_general) } catch (ce_) { skipped = true }
            try { db[$ "draw_clear"] = method(undefined, draw_clear) } catch (ce_) { skipped = true }
            try { db[$ "draw_clear_alpha"] = method(undefined, draw_clear_alpha) } catch (ce_) { skipped = true }
            try { db[$ "draw_point"] = method(undefined, draw_point) } catch (ce_) { skipped = true }
            try { db[$ "draw_line"] = method(undefined, draw_line) } catch (ce_) { skipped = true }
            try { db[$ "draw_line_width"] = method(undefined, draw_line_width) } catch (ce_) { skipped = true }
            try { db[$ "draw_rectangle"] = method(undefined, draw_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "draw_roundrect"] = method(undefined, draw_roundrect) } catch (ce_) { skipped = true }
            try { db[$ "draw_roundrect_ext"] = method(undefined, draw_roundrect_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_triangle"] = method(undefined, draw_triangle) } catch (ce_) { skipped = true }
            try { db[$ "draw_circle"] = method(undefined, draw_circle) } catch (ce_) { skipped = true }
            try { db[$ "draw_ellipse"] = method(undefined, draw_ellipse) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_circle_precision"] = method(undefined, draw_set_circle_precision) } catch (ce_) { skipped = true }
            try { db[$ "draw_arrow"] = method(undefined, draw_arrow) } catch (ce_) { skipped = true }
            try { db[$ "draw_button"] = method(undefined, draw_button) } catch (ce_) { skipped = true }
            try { db[$ "draw_path"] = method(undefined, draw_path) } catch (ce_) { skipped = true }
            try { db[$ "draw_healthbar"] = method(undefined, draw_healthbar) } catch (ce_) { skipped = true }
            try { db[$ "draw_getpixel"] = method(undefined, draw_getpixel) } catch (ce_) { skipped = true }
            try { db[$ "draw_getpixel_ext"] = method(undefined, draw_getpixel_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_colour"] = method(undefined, draw_set_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_color"] = method(undefined, draw_set_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_alpha"] = method(undefined, draw_set_alpha) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_colour"] = method(undefined, draw_get_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_color"] = method(undefined, draw_get_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_alpha"] = method(undefined, draw_get_alpha) } catch (ce_) { skipped = true }
            try { db[$ "merge_colour"] = method(undefined, merge_colour) } catch (ce_) { skipped = true }
            try { db[$ "make_colour_rgb"] = method(undefined, make_colour_rgb) } catch (ce_) { skipped = true }
            try { db[$ "make_colour_hsv"] = method(undefined, make_colour_hsv) } catch (ce_) { skipped = true }
            try { db[$ "colour_get_red"] = method(undefined, colour_get_red) } catch (ce_) { skipped = true }
            try { db[$ "colour_get_green"] = method(undefined, colour_get_green) } catch (ce_) { skipped = true }
            try { db[$ "colour_get_blue"] = method(undefined, colour_get_blue) } catch (ce_) { skipped = true }
            try { db[$ "colour_get_hue"] = method(undefined, colour_get_hue) } catch (ce_) { skipped = true }
            try { db[$ "colour_get_saturation"] = method(undefined, colour_get_saturation) } catch (ce_) { skipped = true }
            try { db[$ "colour_get_value"] = method(undefined, colour_get_value) } catch (ce_) { skipped = true }
            try { db[$ "merge_color"] = method(undefined, merge_color) } catch (ce_) { skipped = true }
            try { db[$ "make_color_rgb"] = method(undefined, make_color_rgb) } catch (ce_) { skipped = true }
            try { db[$ "make_color_hsv"] = method(undefined, make_color_hsv) } catch (ce_) { skipped = true }
            try { db[$ "color_get_red"] = method(undefined, color_get_red) } catch (ce_) { skipped = true }
            try { db[$ "color_get_green"] = method(undefined, color_get_green) } catch (ce_) { skipped = true }
            try { db[$ "color_get_blue"] = method(undefined, color_get_blue) } catch (ce_) { skipped = true }
            try { db[$ "color_get_hue"] = method(undefined, color_get_hue) } catch (ce_) { skipped = true }
            try { db[$ "color_get_saturation"] = method(undefined, color_get_saturation) } catch (ce_) { skipped = true }
            try { db[$ "color_get_value"] = method(undefined, color_get_value) } catch (ce_) { skipped = true }
            try { db[$ "screen_save"] = method(undefined, screen_save) } catch (ce_) { skipped = true }
            try { db[$ "screen_save_part"] = method(undefined, screen_save_part) } catch (ce_) { skipped = true }
            try { db[$ "gif_open"] = method(undefined, gif_open) } catch (ce_) { skipped = true }
            try { db[$ "gif_add_surface"] = method(undefined, gif_add_surface) } catch (ce_) { skipped = true }
            try { db[$ "gif_save"] = method(undefined, gif_save) } catch (ce_) { skipped = true }
            try { db[$ "gif_save_buffer"] = method(undefined, gif_save_buffer) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_font"] = method(undefined, draw_set_font) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_font"] = method(undefined, draw_get_font) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_halign"] = method(undefined, draw_set_halign) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_halign"] = method(undefined, draw_get_halign) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_valign"] = method(undefined, draw_set_valign) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_valign"] = method(undefined, draw_get_valign) } catch (ce_) { skipped = true }
            try { db[$ "draw_text"] = method(undefined, draw_text) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_ext"] = method(undefined, draw_text_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_width"] = method(undefined, string_width) } catch (ce_) { skipped = true }
            try { db[$ "string_height"] = method(undefined, string_height) } catch (ce_) { skipped = true }
            try { db[$ "string_width_ext"] = method(undefined, string_width_ext) } catch (ce_) { skipped = true }
            try { db[$ "string_height_ext"] = method(undefined, string_height_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_transformed"] = method(undefined, draw_text_transformed) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_ext_transformed"] = method(undefined, draw_text_ext_transformed) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_colour"] = method(undefined, draw_text_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_ext_colour"] = method(undefined, draw_text_ext_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_transformed_colour"] = method(undefined, draw_text_transformed_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_ext_transformed_colour"] = method(undefined, draw_text_ext_transformed_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_color"] = method(undefined, draw_text_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_ext_color"] = method(undefined, draw_text_ext_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_transformed_color"] = method(undefined, draw_text_transformed_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_text_ext_transformed_color"] = method(undefined, draw_text_ext_transformed_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_point_colour"] = method(undefined, draw_point_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_line_colour"] = method(undefined, draw_line_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_line_width_colour"] = method(undefined, draw_line_width_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_rectangle_colour"] = method(undefined, draw_rectangle_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_roundrect_colour"] = method(undefined, draw_roundrect_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_roundrect_colour_ext"] = method(undefined, draw_roundrect_colour_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_triangle_colour"] = method(undefined, draw_triangle_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_circle_colour"] = method(undefined, draw_circle_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_ellipse_colour"] = method(undefined, draw_ellipse_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_point_color"] = method(undefined, draw_point_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_line_color"] = method(undefined, draw_line_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_line_width_color"] = method(undefined, draw_line_width_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_rectangle_color"] = method(undefined, draw_rectangle_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_roundrect_color"] = method(undefined, draw_roundrect_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_roundrect_color_ext"] = method(undefined, draw_roundrect_color_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_triangle_color"] = method(undefined, draw_triangle_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_circle_color"] = method(undefined, draw_circle_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_ellipse_color"] = method(undefined, draw_ellipse_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_primitive_begin"] = method(undefined, draw_primitive_begin) } catch (ce_) { skipped = true }
            try { db[$ "draw_vertex"] = method(undefined, draw_vertex) } catch (ce_) { skipped = true }
            try { db[$ "draw_vertex_colour"] = method(undefined, draw_vertex_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_vertex_color"] = method(undefined, draw_vertex_color) } catch (ce_) { skipped = true }
            try { db[$ "draw_primitive_end"] = method(undefined, draw_primitive_end) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_uvs"] = method(undefined, sprite_get_uvs) } catch (ce_) { skipped = true }
            try { db[$ "font_get_uvs"] = method(undefined, font_get_uvs) } catch (ce_) { skipped = true }
            try { db[$ "font_get_info"] = method(undefined, font_get_info) } catch (ce_) { skipped = true }
            try { db[$ "font_cache_glyph"] = method(undefined, font_cache_glyph) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_texture"] = method(undefined, sprite_get_texture) } catch (ce_) { skipped = true }
            try { db[$ "font_get_texture"] = method(undefined, font_get_texture) } catch (ce_) { skipped = true }
            try { db[$ "texture_get_width"] = method(undefined, texture_get_width) } catch (ce_) { skipped = true }
            try { db[$ "texture_get_height"] = method(undefined, texture_get_height) } catch (ce_) { skipped = true }
            try { db[$ "texture_get_uvs"] = method(undefined, texture_get_uvs) } catch (ce_) { skipped = true }
            try { db[$ "draw_primitive_begin_texture"] = method(undefined, draw_primitive_begin_texture) } catch (ce_) { skipped = true }
            try { db[$ "draw_vertex_texture"] = method(undefined, draw_vertex_texture) } catch (ce_) { skipped = true }
            try { db[$ "draw_vertex_texture_colour"] = method(undefined, draw_vertex_texture_colour) } catch (ce_) { skipped = true }
            try { db[$ "draw_vertex_texture_color"] = method(undefined, draw_vertex_texture_color) } catch (ce_) { skipped = true }
            try { db[$ "texture_global_scale"] = method(undefined, texture_global_scale) } catch (ce_) { skipped = true }
            try { db[$ "surface_create"] = method(undefined, surface_create) } catch (ce_) { skipped = true }
            try { db[$ "surface_create_ext"] = method(undefined, surface_create_ext) } catch (ce_) { skipped = true }
            try { db[$ "surface_resize"] = method(undefined, surface_resize) } catch (ce_) { skipped = true }
            try { db[$ "surface_free"] = method(undefined, surface_free) } catch (ce_) { skipped = true }
            try { db[$ "surface_exists"] = method(undefined, surface_exists) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_width"] = method(undefined, surface_get_width) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_height"] = method(undefined, surface_get_height) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_texture"] = method(undefined, surface_get_texture) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_format"] = method(undefined, surface_get_format) } catch (ce_) { skipped = true }
            try { db[$ "surface_set_target"] = method(undefined, surface_set_target) } catch (ce_) { skipped = true }
            try { db[$ "surface_set_target_ext"] = method(undefined, surface_set_target_ext) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_target"] = method(undefined, surface_get_target) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_target_ext"] = method(undefined, surface_get_target_ext) } catch (ce_) { skipped = true }
            try { db[$ "surface_reset_target"] = method(undefined, surface_reset_target) } catch (ce_) { skipped = true }
            try { db[$ "surface_depth_disable"] = method(undefined, surface_depth_disable) } catch (ce_) { skipped = true }
            try { db[$ "surface_get_depth_disable"] = method(undefined, surface_get_depth_disable) } catch (ce_) { skipped = true }
            try { db[$ "surface_format_is_supported"] = method(undefined, surface_format_is_supported) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface"] = method(undefined, draw_surface) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_stretched"] = method(undefined, draw_surface_stretched) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_tiled"] = method(undefined, draw_surface_tiled) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_part"] = method(undefined, draw_surface_part) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_ext"] = method(undefined, draw_surface_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_stretched_ext"] = method(undefined, draw_surface_stretched_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_tiled_ext"] = method(undefined, draw_surface_tiled_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_part_ext"] = method(undefined, draw_surface_part_ext) } catch (ce_) { skipped = true }
            try { db[$ "draw_surface_general"] = method(undefined, draw_surface_general) } catch (ce_) { skipped = true }
            try { db[$ "surface_getpixel"] = method(undefined, surface_getpixel) } catch (ce_) { skipped = true }
            try { db[$ "surface_getpixel_ext"] = method(undefined, surface_getpixel_ext) } catch (ce_) { skipped = true }
            try { db[$ "surface_save"] = method(undefined, surface_save) } catch (ce_) { skipped = true }
            try { db[$ "surface_save_part"] = method(undefined, surface_save_part) } catch (ce_) { skipped = true }
            try { db[$ "surface_copy"] = method(undefined, surface_copy) } catch (ce_) { skipped = true }
            try { db[$ "surface_copy_part"] = method(undefined, surface_copy_part) } catch (ce_) { skipped = true }
            try { db[$ "application_surface_draw_enable"] = method(undefined, application_surface_draw_enable) } catch (ce_) { skipped = true }
            try { db[$ "application_get_position"] = method(undefined, application_get_position) } catch (ce_) { skipped = true }
            try { db[$ "application_surface_enable"] = method(undefined, application_surface_enable) } catch (ce_) { skipped = true }
            try { db[$ "application_surface_is_enabled"] = method(undefined, application_surface_is_enabled) } catch (ce_) { skipped = true }
            try { db[$ "video_open"] = method(undefined, video_open) } catch (ce_) { skipped = true }
            try { db[$ "video_close"] = method(undefined, video_close) } catch (ce_) { skipped = true }
            try { db[$ "video_set_volume"] = method(undefined, video_set_volume) } catch (ce_) { skipped = true }
            try { db[$ "video_draw"] = method(undefined, video_draw) } catch (ce_) { skipped = true }
            try { db[$ "video_pause"] = method(undefined, video_pause) } catch (ce_) { skipped = true }
            try { db[$ "video_resume"] = method(undefined, video_resume) } catch (ce_) { skipped = true }
            try { db[$ "video_enable_loop"] = method(undefined, video_enable_loop) } catch (ce_) { skipped = true }
            try { db[$ "video_seek_to"] = method(undefined, video_seek_to) } catch (ce_) { skipped = true }
            try { db[$ "video_get_duration"] = method(undefined, video_get_duration) } catch (ce_) { skipped = true }
            try { db[$ "video_get_position"] = method(undefined, video_get_position) } catch (ce_) { skipped = true }
            try { db[$ "video_get_status"] = method(undefined, video_get_status) } catch (ce_) { skipped = true }
            try { db[$ "video_get_format"] = method(undefined, video_get_format) } catch (ce_) { skipped = true }
            try { db[$ "video_is_looping"] = method(undefined, video_is_looping) } catch (ce_) { skipped = true }
            try { db[$ "video_get_volume"] = method(undefined, video_get_volume) } catch (ce_) { skipped = true }
            try { db[$ "display_get_width"] = method(undefined, display_get_width) } catch (ce_) { skipped = true }
            try { db[$ "display_get_height"] = method(undefined, display_get_height) } catch (ce_) { skipped = true }
            try { db[$ "display_get_orientation"] = method(undefined, display_get_orientation) } catch (ce_) { skipped = true }
            try { db[$ "display_get_gui_width"] = method(undefined, display_get_gui_width) } catch (ce_) { skipped = true }
            try { db[$ "display_get_gui_height"] = method(undefined, display_get_gui_height) } catch (ce_) { skipped = true }
            try { db[$ "display_get_frequency"] = method(undefined, display_get_frequency) } catch (ce_) { skipped = true }
            try { db[$ "display_reset"] = method(undefined, display_reset) } catch (ce_) { skipped = true }
            try { db[$ "display_mouse_get_x"] = method(undefined, display_mouse_get_x) } catch (ce_) { skipped = true }
            try { db[$ "display_mouse_get_y"] = method(undefined, display_mouse_get_y) } catch (ce_) { skipped = true }
            try { db[$ "display_mouse_set"] = method(undefined, display_mouse_set) } catch (ce_) { skipped = true }
            try { db[$ "display_set_ui_visibility"] = method(undefined, display_set_ui_visibility) } catch (ce_) { skipped = true }
            try { db[$ "window_set_showborder"] = method(undefined, window_set_showborder) } catch (ce_) { skipped = true }
            try { db[$ "window_get_showborder"] = method(undefined, window_get_showborder) } catch (ce_) { skipped = true }
            try { db[$ "window_set_fullscreen"] = method(undefined, window_set_fullscreen) } catch (ce_) { skipped = true }
            try { db[$ "window_get_fullscreen"] = method(undefined, window_get_fullscreen) } catch (ce_) { skipped = true }
            try { db[$ "window_set_caption"] = method(undefined, window_set_caption) } catch (ce_) { skipped = true }
            try { db[$ "window_set_min_width"] = method(undefined, window_set_min_width) } catch (ce_) { skipped = true }
            try { db[$ "window_set_max_width"] = method(undefined, window_set_max_width) } catch (ce_) { skipped = true }
            try { db[$ "window_set_min_height"] = method(undefined, window_set_min_height) } catch (ce_) { skipped = true }
            try { db[$ "window_set_max_height"] = method(undefined, window_set_max_height) } catch (ce_) { skipped = true }
            try { db[$ "window_get_visible_rects"] = method(undefined, window_get_visible_rects) } catch (ce_) { skipped = true }
            try { db[$ "window_get_caption"] = method(undefined, window_get_caption) } catch (ce_) { skipped = true }
            try { db[$ "window_set_cursor"] = method(undefined, window_set_cursor) } catch (ce_) { skipped = true }
            try { db[$ "window_enable_borderless_fullscreen"] = method(undefined, window_enable_borderless_fullscreen) } catch (ce_) { skipped = true }
            try { db[$ "window_get_borderless_fullscreen"] = method(undefined, window_get_borderless_fullscreen) } catch (ce_) { skipped = true }
            try { db[$ "window_get_cursor"] = method(undefined, window_get_cursor) } catch (ce_) { skipped = true }
            try { db[$ "window_set_colour"] = method(undefined, window_set_colour) } catch (ce_) { skipped = true }
            try { db[$ "window_get_colour"] = method(undefined, window_get_colour) } catch (ce_) { skipped = true }
            try { db[$ "window_set_color"] = method(undefined, window_set_color) } catch (ce_) { skipped = true }
            try { db[$ "window_get_color"] = method(undefined, window_get_color) } catch (ce_) { skipped = true }
            try { db[$ "window_set_position"] = method(undefined, window_set_position) } catch (ce_) { skipped = true }
            try { db[$ "window_set_size"] = method(undefined, window_set_size) } catch (ce_) { skipped = true }
            try { db[$ "window_set_rectangle"] = method(undefined, window_set_rectangle) } catch (ce_) { skipped = true }
            try { db[$ "window_center"] = method(undefined, window_center) } catch (ce_) { skipped = true }
            try { db[$ "window_get_x"] = method(undefined, window_get_x) } catch (ce_) { skipped = true }
            try { db[$ "window_get_y"] = method(undefined, window_get_y) } catch (ce_) { skipped = true }
            try { db[$ "window_get_width"] = method(undefined, window_get_width) } catch (ce_) { skipped = true }
            try { db[$ "window_get_height"] = method(undefined, window_get_height) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_get_x"] = method(undefined, window_mouse_get_x) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_get_y"] = method(undefined, window_mouse_get_y) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_set"] = method(undefined, window_mouse_set) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_set_locked"] = method(undefined, window_mouse_set_locked) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_get_locked"] = method(undefined, window_mouse_get_locked) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_get_delta_x"] = method(undefined, window_mouse_get_delta_x) } catch (ce_) { skipped = true }
            try { db[$ "window_mouse_get_delta_y"] = method(undefined, window_mouse_get_delta_y) } catch (ce_) { skipped = true }
            try { db[$ "window_view_mouse_get_x"] = method(undefined, window_view_mouse_get_x) } catch (ce_) { skipped = true }
            try { db[$ "window_view_mouse_get_y"] = method(undefined, window_view_mouse_get_y) } catch (ce_) { skipped = true }
            try { db[$ "window_views_mouse_get_x"] = method(undefined, window_views_mouse_get_x) } catch (ce_) { skipped = true }
            try { db[$ "window_views_mouse_get_y"] = method(undefined, window_views_mouse_get_y) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_position"] = method(undefined, audio_listener_position) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_velocity"] = method(undefined, audio_listener_velocity) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_orientation"] = method(undefined, audio_listener_orientation) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_position"] = method(undefined, audio_emitter_position) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_create"] = method(undefined, audio_emitter_create) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_free"] = method(undefined, audio_emitter_free) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_exists"] = method(undefined, audio_emitter_exists) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_pitch"] = method(undefined, audio_emitter_pitch) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_velocity"] = method(undefined, audio_emitter_velocity) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_falloff"] = method(undefined, audio_emitter_falloff) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_gain"] = method(undefined, audio_emitter_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_play_sound"] = method(undefined, audio_play_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_play_sound_on"] = method(undefined, audio_play_sound_on) } catch (ce_) { skipped = true }
            try { db[$ "audio_play_sound_at"] = method(undefined, audio_play_sound_at) } catch (ce_) { skipped = true }
            try { db[$ "audio_play_sound_ext"] = method(undefined, audio_play_sound_ext) } catch (ce_) { skipped = true }
            try { db[$ "audio_stop_sound"] = method(undefined, audio_stop_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_resume_sound"] = method(undefined, audio_resume_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_pause_sound"] = method(undefined, audio_pause_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_channel_num"] = method(undefined, audio_channel_num) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_length"] = method(undefined, audio_sound_length) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_type"] = method(undefined, audio_get_type) } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_set_model"] = method(undefined, audio_falloff_set_model) } catch (ce_) { skipped = true }
            try { db[$ "audio_master_gain"] = method(undefined, audio_master_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_gain"] = method(undefined, audio_sound_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_pitch"] = method(undefined, audio_sound_pitch) } catch (ce_) { skipped = true }
            try { db[$ "audio_stop_all"] = method(undefined, audio_stop_all) } catch (ce_) { skipped = true }
            try { db[$ "audio_resume_all"] = method(undefined, audio_resume_all) } catch (ce_) { skipped = true }
            try { db[$ "audio_pause_all"] = method(undefined, audio_pause_all) } catch (ce_) { skipped = true }
            try { db[$ "audio_is_playing"] = method(undefined, audio_is_playing) } catch (ce_) { skipped = true }
            try { db[$ "audio_is_paused"] = method(undefined, audio_is_paused) } catch (ce_) { skipped = true }
            try { db[$ "audio_exists"] = method(undefined, audio_exists) } catch (ce_) { skipped = true }
            try { db[$ "audio_system_is_available"] = method(undefined, audio_system_is_available) } catch (ce_) { skipped = true }
            try { db[$ "audio_system_is_initialised"] = method(undefined, audio_system_is_initialised) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_is_playable"] = method(undefined, audio_sound_is_playable) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_gain"] = method(undefined, audio_emitter_get_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_pitch"] = method(undefined, audio_emitter_get_pitch) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_x"] = method(undefined, audio_emitter_get_x) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_y"] = method(undefined, audio_emitter_get_y) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_z"] = method(undefined, audio_emitter_get_z) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_vx"] = method(undefined, audio_emitter_get_vx) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_vy"] = method(undefined, audio_emitter_get_vy) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_vz"] = method(undefined, audio_emitter_get_vz) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_set_position"] = method(undefined, audio_listener_set_position) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_set_velocity"] = method(undefined, audio_listener_set_velocity) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_set_orientation"] = method(undefined, audio_listener_set_orientation) } catch (ce_) { skipped = true }
            try { db[$ "audio_listener_get_data"] = method(undefined, audio_listener_get_data) } catch (ce_) { skipped = true }
            try { db[$ "audio_set_master_gain"] = method(undefined, audio_set_master_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_master_gain"] = method(undefined, audio_get_master_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_gain"] = method(undefined, audio_sound_get_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_pitch"] = method(undefined, audio_sound_get_pitch) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_name"] = method(undefined, audio_get_name) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_set_track_position"] = method(undefined, audio_sound_set_track_position) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_track_position"] = method(undefined, audio_sound_get_track_position) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_loop"] = method(undefined, audio_sound_loop) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_loop"] = method(undefined, audio_sound_get_loop) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_loop_start"] = method(undefined, audio_sound_loop_start) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_loop_start"] = method(undefined, audio_sound_get_loop_start) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_loop_end"] = method(undefined, audio_sound_loop_end) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_loop_end"] = method(undefined, audio_sound_get_loop_end) } catch (ce_) { skipped = true }
            try { db[$ "audio_create_stream"] = method(undefined, audio_create_stream) } catch (ce_) { skipped = true }
            try { db[$ "audio_destroy_stream"] = method(undefined, audio_destroy_stream) } catch (ce_) { skipped = true }
            try { db[$ "audio_create_sync_group"] = method(undefined, audio_create_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_destroy_sync_group"] = method(undefined, audio_destroy_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_play_in_sync_group"] = method(undefined, audio_play_in_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_start_sync_group"] = method(undefined, audio_start_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_stop_sync_group"] = method(undefined, audio_stop_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_pause_sync_group"] = method(undefined, audio_pause_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_resume_sync_group"] = method(undefined, audio_resume_sync_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_sync_group_get_track_pos"] = method(undefined, audio_sync_group_get_track_pos) } catch (ce_) { skipped = true }
            try { db[$ "audio_sync_group_debug"] = method(undefined, audio_sync_group_debug) } catch (ce_) { skipped = true }
            try { db[$ "audio_sync_group_is_playing"] = method(undefined, audio_sync_group_is_playing) } catch (ce_) { skipped = true }
            try { db[$ "audio_sync_group_is_paused"] = method(undefined, audio_sync_group_is_paused) } catch (ce_) { skipped = true }
            try { db[$ "audio_debug"] = method(undefined, audio_debug) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_load"] = method(undefined, audio_group_load) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_unload"] = method(undefined, audio_group_unload) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_is_loaded"] = method(undefined, audio_group_is_loaded) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_load_progress"] = method(undefined, audio_group_load_progress) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_name"] = method(undefined, audio_group_name) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_stop_all"] = method(undefined, audio_group_stop_all) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_set_gain"] = method(undefined, audio_group_set_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_get_gain"] = method(undefined, audio_group_get_gain) } catch (ce_) { skipped = true }
            try { db[$ "audio_group_get_assets"] = method(undefined, audio_group_get_assets) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_audio_group"] = method(undefined, audio_sound_get_audio_group) } catch (ce_) { skipped = true }
            try { db[$ "audio_create_buffer_sound"] = method(undefined, audio_create_buffer_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_free_buffer_sound"] = method(undefined, audio_free_buffer_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_create_play_queue"] = method(undefined, audio_create_play_queue) } catch (ce_) { skipped = true }
            try { db[$ "audio_free_play_queue"] = method(undefined, audio_free_play_queue) } catch (ce_) { skipped = true }
            try { db[$ "audio_queue_sound"] = method(undefined, audio_queue_sound) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_recorder_count"] = method(undefined, audio_get_recorder_count) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_recorder_info"] = method(undefined, audio_get_recorder_info) } catch (ce_) { skipped = true }
            try { db[$ "audio_start_recording"] = method(undefined, audio_start_recording) } catch (ce_) { skipped = true }
            try { db[$ "audio_stop_recording"] = method(undefined, audio_stop_recording) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_get_listener_mask"] = method(undefined, audio_sound_get_listener_mask) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_listener_mask"] = method(undefined, audio_emitter_get_listener_mask) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_listener_mask"] = method(undefined, audio_get_listener_mask) } catch (ce_) { skipped = true }
            try { db[$ "audio_sound_set_listener_mask"] = method(undefined, audio_sound_set_listener_mask) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_set_listener_mask"] = method(undefined, audio_emitter_set_listener_mask) } catch (ce_) { skipped = true }
            try { db[$ "audio_set_listener_mask"] = method(undefined, audio_set_listener_mask) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_listener_count"] = method(undefined, audio_get_listener_count) } catch (ce_) { skipped = true }
            try { db[$ "audio_get_listener_info"] = method(undefined, audio_get_listener_info) } catch (ce_) { skipped = true }
            try { db[$ "show_message"] = method(undefined, show_message) } catch (ce_) { skipped = true }
            try { db[$ "show_message_async"] = method(undefined, show_message_async) } catch (ce_) { skipped = true }
            try { db[$ "clickable_add"] = method(undefined, clickable_add) } catch (ce_) { skipped = true }
            try { db[$ "clickable_add_ext"] = method(undefined, clickable_add_ext) } catch (ce_) { skipped = true }
            try { db[$ "clickable_change"] = method(undefined, clickable_change) } catch (ce_) { skipped = true }
            try { db[$ "clickable_change_ext"] = method(undefined, clickable_change_ext) } catch (ce_) { skipped = true }
            try { db[$ "clickable_delete"] = method(undefined, clickable_delete) } catch (ce_) { skipped = true }
            try { db[$ "clickable_exists"] = method(undefined, clickable_exists) } catch (ce_) { skipped = true }
            try { db[$ "clickable_set_style"] = method(undefined, clickable_set_style) } catch (ce_) { skipped = true }
            try { db[$ "show_question"] = method(undefined, show_question) } catch (ce_) { skipped = true }
            try { db[$ "show_question_async"] = method(undefined, show_question_async) } catch (ce_) { skipped = true }
            try { db[$ "get_integer_async"] = method(undefined, get_integer_async) } catch (ce_) { skipped = true }
            try { db[$ "get_string_async"] = method(undefined, get_string_async) } catch (ce_) { skipped = true }
            try { db[$ "get_login_async"] = method(undefined, get_login_async) } catch (ce_) { skipped = true }
            try { db[$ "get_open_filename"] = method(undefined, get_open_filename) } catch (ce_) { skipped = true }
            try { db[$ "get_save_filename"] = method(undefined, get_save_filename) } catch (ce_) { skipped = true }
            try { db[$ "get_open_filename_ext"] = method(undefined, get_open_filename_ext) } catch (ce_) { skipped = true }
            try { db[$ "get_save_filename_ext"] = method(undefined, get_save_filename_ext) } catch (ce_) { skipped = true }
            try { db[$ "show_error"] = method(undefined, show_error) } catch (ce_) { skipped = true }
            try { db[$ "highscore_clear"] = method(undefined, highscore_clear) } catch (ce_) { skipped = true }
            try { db[$ "highscore_add"] = method(undefined, highscore_add) } catch (ce_) { skipped = true }
            try { db[$ "highscore_value"] = method(undefined, highscore_value) } catch (ce_) { skipped = true }
            try { db[$ "highscore_name"] = method(undefined, highscore_name) } catch (ce_) { skipped = true }
            try { db[$ "draw_highscore"] = method(undefined, draw_highscore) } catch (ce_) { skipped = true }
            try { db[$ "sprite_exists"] = method(undefined, sprite_exists) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_name"] = method(undefined, sprite_get_name) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_number"] = method(undefined, sprite_get_number) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_width"] = method(undefined, sprite_get_width) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_height"] = method(undefined, sprite_get_height) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_xoffset"] = method(undefined, sprite_get_xoffset) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_yoffset"] = method(undefined, sprite_get_yoffset) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_bbox_mode"] = method(undefined, sprite_get_bbox_mode) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_bbox_left"] = method(undefined, sprite_get_bbox_left) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_bbox_right"] = method(undefined, sprite_get_bbox_right) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_bbox_top"] = method(undefined, sprite_get_bbox_top) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_bbox_bottom"] = method(undefined, sprite_get_bbox_bottom) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_bbox_mode"] = method(undefined, sprite_set_bbox_mode) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_bbox"] = method(undefined, sprite_set_bbox) } catch (ce_) { skipped = true }
            try { db[$ "sprite_save"] = method(undefined, sprite_save) } catch (ce_) { skipped = true }
            try { db[$ "sprite_save_strip"] = method(undefined, sprite_save_strip) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_cache_size"] = method(undefined, sprite_set_cache_size) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_cache_size_ext"] = method(undefined, sprite_set_cache_size_ext) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_tpe"] = method(undefined, sprite_get_tpe) } catch (ce_) { skipped = true }
            try { db[$ "sprite_prefetch"] = method(undefined, sprite_prefetch) } catch (ce_) { skipped = true }
            try { db[$ "sprite_prefetch_multi"] = method(undefined, sprite_prefetch_multi) } catch (ce_) { skipped = true }
            try { db[$ "sprite_flush"] = method(undefined, sprite_flush) } catch (ce_) { skipped = true }
            try { db[$ "sprite_flush_multi"] = method(undefined, sprite_flush_multi) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_speed"] = method(undefined, sprite_set_speed) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_speed_type"] = method(undefined, sprite_get_speed_type) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_speed"] = method(undefined, sprite_get_speed) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_info"] = method(undefined, sprite_get_info) } catch (ce_) { skipped = true }
            try { db[$ "sprite_get_nineslice"] = method(undefined, sprite_get_nineslice) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_nineslice"] = method(undefined, sprite_set_nineslice) } catch (ce_) { skipped = true }
            try { db[$ "sprite_nineslice_create"] = method(undefined, sprite_nineslice_create) } catch (ce_) { skipped = true }
            try { db[$ "texture_is_ready"] = method(undefined, texture_is_ready) } catch (ce_) { skipped = true }
            try { db[$ "texture_prefetch"] = method(undefined, texture_prefetch) } catch (ce_) { skipped = true }
            try { db[$ "texture_flush"] = method(undefined, texture_flush) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_get_textures"] = method(undefined, texturegroup_get_textures) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_get_sprites"] = method(undefined, texturegroup_get_sprites) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_get_fonts"] = method(undefined, texturegroup_get_fonts) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_get_tilesets"] = method(undefined, texturegroup_get_tilesets) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_get_names"] = method(undefined, texturegroup_get_names) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_load"] = method(undefined, texturegroup_load) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_unload"] = method(undefined, texturegroup_unload) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_get_status"] = method(undefined, texturegroup_get_status) } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_set_mode"] = method(undefined, texturegroup_set_mode) } catch (ce_) { skipped = true }
            try { db[$ "texture_debug_messages"] = method(undefined, texture_debug_messages) } catch (ce_) { skipped = true }
            try { db[$ "font_exists"] = method(undefined, font_exists) } catch (ce_) { skipped = true }
            try { db[$ "font_get_name"] = method(undefined, font_get_name) } catch (ce_) { skipped = true }
            try { db[$ "font_get_fontname"] = method(undefined, font_get_fontname) } catch (ce_) { skipped = true }
            try { db[$ "font_get_bold"] = method(undefined, font_get_bold) } catch (ce_) { skipped = true }
            try { db[$ "font_get_italic"] = method(undefined, font_get_italic) } catch (ce_) { skipped = true }
            try { db[$ "font_get_first"] = method(undefined, font_get_first) } catch (ce_) { skipped = true }
            try { db[$ "font_get_last"] = method(undefined, font_get_last) } catch (ce_) { skipped = true }
            try { db[$ "font_get_size"] = method(undefined, font_get_size) } catch (ce_) { skipped = true }
            try { db[$ "font_set_cache_size"] = method(undefined, font_set_cache_size) } catch (ce_) { skipped = true }
            try { db[$ "path_exists"] = method(undefined, path_exists) } catch (ce_) { skipped = true }
            try { db[$ "path_get_name"] = method(undefined, path_get_name) } catch (ce_) { skipped = true }
            try { db[$ "path_get_length"] = method(undefined, path_get_length) } catch (ce_) { skipped = true }
            try { db[$ "path_get_kind"] = method(undefined, path_get_kind) } catch (ce_) { skipped = true }
            try { db[$ "path_get_closed"] = method(undefined, path_get_closed) } catch (ce_) { skipped = true }
            try { db[$ "path_get_precision"] = method(undefined, path_get_precision) } catch (ce_) { skipped = true }
            try { db[$ "path_get_number"] = method(undefined, path_get_number) } catch (ce_) { skipped = true }
            try { db[$ "path_get_point_x"] = method(undefined, path_get_point_x) } catch (ce_) { skipped = true }
            try { db[$ "path_get_point_y"] = method(undefined, path_get_point_y) } catch (ce_) { skipped = true }
            try { db[$ "path_get_point_speed"] = method(undefined, path_get_point_speed) } catch (ce_) { skipped = true }
            try { db[$ "path_get_x"] = method(undefined, path_get_x) } catch (ce_) { skipped = true }
            try { db[$ "path_get_y"] = method(undefined, path_get_y) } catch (ce_) { skipped = true }
            try { db[$ "path_get_speed"] = method(undefined, path_get_speed) } catch (ce_) { skipped = true }
            try { db[$ "script_exists"] = method(undefined, script_exists) } catch (ce_) { skipped = true }
            try { db[$ "script_get_name"] = method(undefined, script_get_name) } catch (ce_) { skipped = true }
            try { db[$ "timeline_add"] = method(undefined, timeline_add) } catch (ce_) { skipped = true }
            try { db[$ "timeline_delete"] = method(undefined, timeline_delete) } catch (ce_) { skipped = true }
            try { db[$ "timeline_clear"] = method(undefined, timeline_clear) } catch (ce_) { skipped = true }
            try { db[$ "timeline_exists"] = method(undefined, timeline_exists) } catch (ce_) { skipped = true }
            try { db[$ "timeline_get_name"] = method(undefined, timeline_get_name) } catch (ce_) { skipped = true }
            try { db[$ "timeline_moment_clear"] = method(undefined, timeline_moment_clear) } catch (ce_) { skipped = true }
            try { db[$ "timeline_moment_add_script"] = method(undefined, timeline_moment_add_script) } catch (ce_) { skipped = true }
            try { db[$ "timeline_size"] = method(undefined, timeline_size) } catch (ce_) { skipped = true }
            try { db[$ "timeline_max_moment"] = method(undefined, timeline_max_moment) } catch (ce_) { skipped = true }
            try { db[$ "object_exists"] = method(undefined, object_exists) } catch (ce_) { skipped = true }
            try { db[$ "object_get_name"] = method(undefined, object_get_name) } catch (ce_) { skipped = true }
            try { db[$ "object_get_sprite"] = method(undefined, object_get_sprite) } catch (ce_) { skipped = true }
            try { db[$ "object_get_solid"] = method(undefined, object_get_solid) } catch (ce_) { skipped = true }
            try { db[$ "object_get_visible"] = method(undefined, object_get_visible) } catch (ce_) { skipped = true }
            try { db[$ "object_get_persistent"] = method(undefined, object_get_persistent) } catch (ce_) { skipped = true }
            try { db[$ "object_get_mask"] = method(undefined, object_get_mask) } catch (ce_) { skipped = true }
            try { db[$ "object_get_parent"] = method(undefined, object_get_parent) } catch (ce_) { skipped = true }
            try { db[$ "object_get_physics"] = method(undefined, object_get_physics) } catch (ce_) { skipped = true }
            try { db[$ "object_is_ancestor"] = method(undefined, object_is_ancestor) } catch (ce_) { skipped = true }
            try { db[$ "room_exists"] = method(undefined, room_exists) } catch (ce_) { skipped = true }
            try { db[$ "room_get_name"] = method(undefined, room_get_name) } catch (ce_) { skipped = true }
            try { db[$ "room_get_info"] = method(undefined, room_get_info) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_offset"] = method(undefined, sprite_set_offset) } catch (ce_) { skipped = true }
            try { db[$ "sprite_duplicate"] = method(undefined, sprite_duplicate) } catch (ce_) { skipped = true }
            try { db[$ "sprite_assign"] = method(undefined, sprite_assign) } catch (ce_) { skipped = true }
            try { db[$ "sprite_merge"] = method(undefined, sprite_merge) } catch (ce_) { skipped = true }
            try { db[$ "sprite_add"] = method(undefined, sprite_add) } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext"] = method(undefined, sprite_add_ext) } catch (ce_) { skipped = true }
            try { db[$ "sprite_replace"] = method(undefined, sprite_replace) } catch (ce_) { skipped = true }
            try { db[$ "sprite_create_from_surface"] = method(undefined, sprite_create_from_surface) } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_from_surface"] = method(undefined, sprite_add_from_surface) } catch (ce_) { skipped = true }
            try { db[$ "sprite_delete"] = method(undefined, sprite_delete) } catch (ce_) { skipped = true }
            try { db[$ "sprite_set_alpha_from_sprite"] = method(undefined, sprite_set_alpha_from_sprite) } catch (ce_) { skipped = true }
            try { db[$ "sprite_collision_mask"] = method(undefined, sprite_collision_mask) } catch (ce_) { skipped = true }
            try { db[$ "font_add_enable_aa"] = method(undefined, font_add_enable_aa) } catch (ce_) { skipped = true }
            try { db[$ "font_add_get_enable_aa"] = method(undefined, font_add_get_enable_aa) } catch (ce_) { skipped = true }
            try { db[$ "font_add"] = method(undefined, font_add) } catch (ce_) { skipped = true }
            try { db[$ "font_add_sprite"] = method(undefined, font_add_sprite) } catch (ce_) { skipped = true }
            try { db[$ "font_add_sprite_ext"] = method(undefined, font_add_sprite_ext) } catch (ce_) { skipped = true }
            try { db[$ "font_replace_sprite"] = method(undefined, font_replace_sprite) } catch (ce_) { skipped = true }
            try { db[$ "font_replace_sprite_ext"] = method(undefined, font_replace_sprite_ext) } catch (ce_) { skipped = true }
            try { db[$ "font_delete"] = method(undefined, font_delete) } catch (ce_) { skipped = true }
            try { db[$ "font_enable_sdf"] = method(undefined, font_enable_sdf) } catch (ce_) { skipped = true }
            try { db[$ "font_get_sdf_enabled"] = method(undefined, font_get_sdf_enabled) } catch (ce_) { skipped = true }
            try { db[$ "font_sdf_spread"] = method(undefined, font_sdf_spread) } catch (ce_) { skipped = true }
            try { db[$ "font_get_sdf_spread"] = method(undefined, font_get_sdf_spread) } catch (ce_) { skipped = true }
            try { db[$ "font_enable_effects"] = method(undefined, font_enable_effects) } catch (ce_) { skipped = true }
            try { db[$ "path_set_kind"] = method(undefined, path_set_kind) } catch (ce_) { skipped = true }
            try { db[$ "path_set_closed"] = method(undefined, path_set_closed) } catch (ce_) { skipped = true }
            try { db[$ "path_set_precision"] = method(undefined, path_set_precision) } catch (ce_) { skipped = true }
            try { db[$ "path_add"] = method(undefined, path_add) } catch (ce_) { skipped = true }
            try { db[$ "path_assign"] = method(undefined, path_assign) } catch (ce_) { skipped = true }
            try { db[$ "path_duplicate"] = method(undefined, path_duplicate) } catch (ce_) { skipped = true }
            try { db[$ "path_append"] = method(undefined, path_append) } catch (ce_) { skipped = true }
            try { db[$ "path_delete"] = method(undefined, path_delete) } catch (ce_) { skipped = true }
            try { db[$ "path_add_point"] = method(undefined, path_add_point) } catch (ce_) { skipped = true }
            try { db[$ "path_insert_point"] = method(undefined, path_insert_point) } catch (ce_) { skipped = true }
            try { db[$ "path_change_point"] = method(undefined, path_change_point) } catch (ce_) { skipped = true }
            try { db[$ "path_delete_point"] = method(undefined, path_delete_point) } catch (ce_) { skipped = true }
            try { db[$ "path_clear_points"] = method(undefined, path_clear_points) } catch (ce_) { skipped = true }
            try { db[$ "path_reverse"] = method(undefined, path_reverse) } catch (ce_) { skipped = true }
            try { db[$ "path_mirror"] = method(undefined, path_mirror) } catch (ce_) { skipped = true }
            try { db[$ "path_flip"] = method(undefined, path_flip) } catch (ce_) { skipped = true }
            try { db[$ "path_rotate"] = method(undefined, path_rotate) } catch (ce_) { skipped = true }
            try { db[$ "path_rescale"] = method(undefined, path_rescale) } catch (ce_) { skipped = true }
            try { db[$ "path_shift"] = method(undefined, path_shift) } catch (ce_) { skipped = true }
            try { db[$ "script_execute"] = method(undefined, script_execute) } catch (ce_) { skipped = true }
            try { db[$ "script_execute_ext"] = method(undefined, script_execute_ext) } catch (ce_) { skipped = true }
            try { db[$ "method_call"] = method(undefined, method_call) } catch (ce_) { skipped = true }
            try { db[$ "object_set_sprite"] = method(undefined, object_set_sprite) } catch (ce_) { skipped = true }
            try { db[$ "object_set_solid"] = method(undefined, object_set_solid) } catch (ce_) { skipped = true }
            try { db[$ "object_set_visible"] = method(undefined, object_set_visible) } catch (ce_) { skipped = true }
            try { db[$ "object_set_persistent"] = method(undefined, object_set_persistent) } catch (ce_) { skipped = true }
            try { db[$ "object_set_mask"] = method(undefined, object_set_mask) } catch (ce_) { skipped = true }
            try { db[$ "room_set_width"] = method(undefined, room_set_width) } catch (ce_) { skipped = true }
            try { db[$ "room_set_height"] = method(undefined, room_set_height) } catch (ce_) { skipped = true }
            try { db[$ "room_set_persistent"] = method(undefined, room_set_persistent) } catch (ce_) { skipped = true }
            try { db[$ "room_set_viewport"] = method(undefined, room_set_viewport) } catch (ce_) { skipped = true }
            try { db[$ "room_get_viewport"] = method(undefined, room_get_viewport) } catch (ce_) { skipped = true }
            try { db[$ "room_set_view_enabled"] = method(undefined, room_set_view_enabled) } catch (ce_) { skipped = true }
            try { db[$ "room_add"] = method(undefined, room_add) } catch (ce_) { skipped = true }
            try { db[$ "room_duplicate"] = method(undefined, room_duplicate) } catch (ce_) { skipped = true }
            try { db[$ "room_assign"] = method(undefined, room_assign) } catch (ce_) { skipped = true }
            try { db[$ "room_instance_add"] = method(undefined, room_instance_add) } catch (ce_) { skipped = true }
            try { db[$ "room_instance_clear"] = method(undefined, room_instance_clear) } catch (ce_) { skipped = true }
            try { db[$ "room_get_camera"] = method(undefined, room_get_camera) } catch (ce_) { skipped = true }
            try { db[$ "room_set_camera"] = method(undefined, room_set_camera) } catch (ce_) { skipped = true }
            try { db[$ "asset_get_index"] = method(undefined, asset_get_index) } catch (ce_) { skipped = true }
            try { db[$ "asset_get_type"] = method(undefined, asset_get_type) } catch (ce_) { skipped = true }
            try { db[$ "asset_get_ids"] = method(undefined, asset_get_ids) } catch (ce_) { skipped = true }
            try { db[$ "file_text_open_from_string"] = method(undefined, file_text_open_from_string) } catch (ce_) { skipped = true }
            try { db[$ "file_text_open_read"] = method(undefined, file_text_open_read) } catch (ce_) { skipped = true }
            try { db[$ "file_text_open_write"] = method(undefined, file_text_open_write) } catch (ce_) { skipped = true }
            try { db[$ "file_text_open_append"] = method(undefined, file_text_open_append) } catch (ce_) { skipped = true }
            try { db[$ "file_text_close"] = method(undefined, file_text_close) } catch (ce_) { skipped = true }
            try { db[$ "file_text_write_string"] = method(undefined, file_text_write_string) } catch (ce_) { skipped = true }
            try { db[$ "file_text_write_real"] = method(undefined, file_text_write_real) } catch (ce_) { skipped = true }
            try { db[$ "file_text_writeln"] = method(undefined, file_text_writeln) } catch (ce_) { skipped = true }
            try { db[$ "file_text_read_string"] = method(undefined, file_text_read_string) } catch (ce_) { skipped = true }
            try { db[$ "file_text_read_real"] = method(undefined, file_text_read_real) } catch (ce_) { skipped = true }
            try { db[$ "file_text_readln"] = method(undefined, file_text_readln) } catch (ce_) { skipped = true }
            try { db[$ "file_text_eof"] = method(undefined, file_text_eof) } catch (ce_) { skipped = true }
            try { db[$ "file_text_eoln"] = method(undefined, file_text_eoln) } catch (ce_) { skipped = true }
            try { db[$ "file_exists"] = method(undefined, file_exists) } catch (ce_) { skipped = true }
            try { db[$ "file_delete"] = method(undefined, file_delete) } catch (ce_) { skipped = true }
            try { db[$ "file_rename"] = method(undefined, file_rename) } catch (ce_) { skipped = true }
            try { db[$ "file_copy"] = method(undefined, file_copy) } catch (ce_) { skipped = true }
            try { db[$ "directory_exists"] = method(undefined, directory_exists) } catch (ce_) { skipped = true }
            try { db[$ "directory_create"] = method(undefined, directory_create) } catch (ce_) { skipped = true }
            try { db[$ "directory_destroy"] = method(undefined, directory_destroy) } catch (ce_) { skipped = true }
            try { db[$ "file_find_first"] = method(undefined, file_find_first) } catch (ce_) { skipped = true }
            try { db[$ "file_find_next"] = method(undefined, file_find_next) } catch (ce_) { skipped = true }
            try { db[$ "file_find_close"] = method(undefined, file_find_close) } catch (ce_) { skipped = true }
            try { db[$ "file_attributes"] = method(undefined, file_attributes) } catch (ce_) { skipped = true }
            try { db[$ "filename_name"] = method(undefined, filename_name) } catch (ce_) { skipped = true }
            try { db[$ "filename_path"] = method(undefined, filename_path) } catch (ce_) { skipped = true }
            try { db[$ "filename_dir"] = method(undefined, filename_dir) } catch (ce_) { skipped = true }
            try { db[$ "filename_drive"] = method(undefined, filename_drive) } catch (ce_) { skipped = true }
            try { db[$ "filename_ext"] = method(undefined, filename_ext) } catch (ce_) { skipped = true }
            try { db[$ "filename_change_ext"] = method(undefined, filename_change_ext) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_open"] = method(undefined, file_bin_open) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_rewrite"] = method(undefined, file_bin_rewrite) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_close"] = method(undefined, file_bin_close) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_position"] = method(undefined, file_bin_position) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_size"] = method(undefined, file_bin_size) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_seek"] = method(undefined, file_bin_seek) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_write_byte"] = method(undefined, file_bin_write_byte) } catch (ce_) { skipped = true }
            try { db[$ "file_bin_read_byte"] = method(undefined, file_bin_read_byte) } catch (ce_) { skipped = true }
            try { db[$ "parameter_count"] = method(undefined, parameter_count) } catch (ce_) { skipped = true }
            try { db[$ "parameter_string"] = method(undefined, parameter_string) } catch (ce_) { skipped = true }
            try { db[$ "environment_get_variable"] = method(undefined, environment_get_variable) } catch (ce_) { skipped = true }
            try { db[$ "ini_open_from_string"] = method(undefined, ini_open_from_string) } catch (ce_) { skipped = true }
            try { db[$ "ini_open"] = method(undefined, ini_open) } catch (ce_) { skipped = true }
            try { db[$ "ini_close"] = method(undefined, ini_close) } catch (ce_) { skipped = true }
            try { db[$ "ini_read_string"] = method(undefined, ini_read_string) } catch (ce_) { skipped = true }
            try { db[$ "ini_read_real"] = method(undefined, ini_read_real) } catch (ce_) { skipped = true }
            try { db[$ "ini_write_string"] = method(undefined, ini_write_string) } catch (ce_) { skipped = true }
            try { db[$ "ini_write_real"] = method(undefined, ini_write_real) } catch (ce_) { skipped = true }
            try { db[$ "ini_key_exists"] = method(undefined, ini_key_exists) } catch (ce_) { skipped = true }
            try { db[$ "ini_section_exists"] = method(undefined, ini_section_exists) } catch (ce_) { skipped = true }
            try { db[$ "ini_key_delete"] = method(undefined, ini_key_delete) } catch (ce_) { skipped = true }
            try { db[$ "ini_section_delete"] = method(undefined, ini_section_delete) } catch (ce_) { skipped = true }
            try { db[$ "ds_set_precision"] = method(undefined, ds_set_precision) } catch (ce_) { skipped = true }
            try { db[$ "ds_exists"] = method(undefined, ds_exists) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_create"] = method(undefined, ds_stack_create) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_destroy"] = method(undefined, ds_stack_destroy) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_clear"] = method(undefined, ds_stack_clear) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_copy"] = method(undefined, ds_stack_copy) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_size"] = method(undefined, ds_stack_size) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_empty"] = method(undefined, ds_stack_empty) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_push"] = method(undefined, ds_stack_push) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_pop"] = method(undefined, ds_stack_pop) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_top"] = method(undefined, ds_stack_top) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_write"] = method(undefined, ds_stack_write) } catch (ce_) { skipped = true }
            try { db[$ "ds_stack_read"] = method(undefined, ds_stack_read) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_create"] = method(undefined, ds_queue_create) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_destroy"] = method(undefined, ds_queue_destroy) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_clear"] = method(undefined, ds_queue_clear) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_copy"] = method(undefined, ds_queue_copy) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_size"] = method(undefined, ds_queue_size) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_empty"] = method(undefined, ds_queue_empty) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_enqueue"] = method(undefined, ds_queue_enqueue) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_dequeue"] = method(undefined, ds_queue_dequeue) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_head"] = method(undefined, ds_queue_head) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_tail"] = method(undefined, ds_queue_tail) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_write"] = method(undefined, ds_queue_write) } catch (ce_) { skipped = true }
            try { db[$ "ds_queue_read"] = method(undefined, ds_queue_read) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_create"] = method(undefined, ds_list_create) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_destroy"] = method(undefined, ds_list_destroy) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_clear"] = method(undefined, ds_list_clear) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_copy"] = method(undefined, ds_list_copy) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_size"] = method(undefined, ds_list_size) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_empty"] = method(undefined, ds_list_empty) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_add"] = method(undefined, ds_list_add) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_insert"] = method(undefined, ds_list_insert) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_replace"] = method(undefined, ds_list_replace) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_delete"] = method(undefined, ds_list_delete) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_find_index"] = method(undefined, ds_list_find_index) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_find_value"] = method(undefined, ds_list_find_value) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_is_map"] = method(undefined, ds_list_is_map) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_is_list"] = method(undefined, ds_list_is_list) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_mark_as_list"] = method(undefined, ds_list_mark_as_list) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_mark_as_map"] = method(undefined, ds_list_mark_as_map) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_sort"] = method(undefined, ds_list_sort) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_shuffle"] = method(undefined, ds_list_shuffle) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_write"] = method(undefined, ds_list_write) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_read"] = method(undefined, ds_list_read) } catch (ce_) { skipped = true }
            try { db[$ "ds_list_set"] = method(undefined, ds_list_set) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_create"] = method(undefined, ds_map_create) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_destroy"] = method(undefined, ds_map_destroy) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_clear"] = method(undefined, ds_map_clear) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_copy"] = method(undefined, ds_map_copy) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_size"] = method(undefined, ds_map_size) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_empty"] = method(undefined, ds_map_empty) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_add"] = method(undefined, ds_map_add) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_add_list"] = method(undefined, ds_map_add_list) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_add_map"] = method(undefined, ds_map_add_map) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_replace"] = method(undefined, ds_map_replace) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_replace_map"] = method(undefined, ds_map_replace_map) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_replace_list"] = method(undefined, ds_map_replace_list) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_delete"] = method(undefined, ds_map_delete) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_exists"] = method(undefined, ds_map_exists) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_values_to_array"] = method(undefined, ds_map_values_to_array) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_keys_to_array"] = method(undefined, ds_map_keys_to_array) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_find_value"] = method(undefined, ds_map_find_value) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_is_map"] = method(undefined, ds_map_is_map) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_is_list"] = method(undefined, ds_map_is_list) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_find_previous"] = method(undefined, ds_map_find_previous) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_find_next"] = method(undefined, ds_map_find_next) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_find_first"] = method(undefined, ds_map_find_first) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_find_last"] = method(undefined, ds_map_find_last) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_write"] = method(undefined, ds_map_write) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_read"] = method(undefined, ds_map_read) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_secure_save"] = method(undefined, ds_map_secure_save) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_secure_load"] = method(undefined, ds_map_secure_load) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_secure_load_buffer"] = method(undefined, ds_map_secure_load_buffer) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_secure_save_buffer"] = method(undefined, ds_map_secure_save_buffer) } catch (ce_) { skipped = true }
            try { db[$ "ds_map_set"] = method(undefined, ds_map_set) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_create"] = method(undefined, ds_priority_create) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_destroy"] = method(undefined, ds_priority_destroy) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_clear"] = method(undefined, ds_priority_clear) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_copy"] = method(undefined, ds_priority_copy) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_size"] = method(undefined, ds_priority_size) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_empty"] = method(undefined, ds_priority_empty) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_add"] = method(undefined, ds_priority_add) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_change_priority"] = method(undefined, ds_priority_change_priority) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_find_priority"] = method(undefined, ds_priority_find_priority) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_delete_value"] = method(undefined, ds_priority_delete_value) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_delete_min"] = method(undefined, ds_priority_delete_min) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_find_min"] = method(undefined, ds_priority_find_min) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_delete_max"] = method(undefined, ds_priority_delete_max) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_find_max"] = method(undefined, ds_priority_find_max) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_write"] = method(undefined, ds_priority_write) } catch (ce_) { skipped = true }
            try { db[$ "ds_priority_read"] = method(undefined, ds_priority_read) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_create"] = method(undefined, ds_grid_create) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_destroy"] = method(undefined, ds_grid_destroy) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_copy"] = method(undefined, ds_grid_copy) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_resize"] = method(undefined, ds_grid_resize) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_width"] = method(undefined, ds_grid_width) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_height"] = method(undefined, ds_grid_height) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_clear"] = method(undefined, ds_grid_clear) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_add"] = method(undefined, ds_grid_add) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_multiply"] = method(undefined, ds_grid_multiply) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_set_region"] = method(undefined, ds_grid_set_region) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_add_region"] = method(undefined, ds_grid_add_region) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_multiply_region"] = method(undefined, ds_grid_multiply_region) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_set_disk"] = method(undefined, ds_grid_set_disk) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_add_disk"] = method(undefined, ds_grid_add_disk) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_multiply_disk"] = method(undefined, ds_grid_multiply_disk) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_set_grid_region"] = method(undefined, ds_grid_set_grid_region) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_add_grid_region"] = method(undefined, ds_grid_add_grid_region) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_multiply_grid_region"] = method(undefined, ds_grid_multiply_grid_region) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_sum"] = method(undefined, ds_grid_get_sum) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_max"] = method(undefined, ds_grid_get_max) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_min"] = method(undefined, ds_grid_get_min) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_mean"] = method(undefined, ds_grid_get_mean) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_disk_sum"] = method(undefined, ds_grid_get_disk_sum) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_disk_min"] = method(undefined, ds_grid_get_disk_min) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_disk_max"] = method(undefined, ds_grid_get_disk_max) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get_disk_mean"] = method(undefined, ds_grid_get_disk_mean) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_value_exists"] = method(undefined, ds_grid_value_exists) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_value_x"] = method(undefined, ds_grid_value_x) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_value_y"] = method(undefined, ds_grid_value_y) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_value_disk_exists"] = method(undefined, ds_grid_value_disk_exists) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_value_disk_x"] = method(undefined, ds_grid_value_disk_x) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_value_disk_y"] = method(undefined, ds_grid_value_disk_y) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_shuffle"] = method(undefined, ds_grid_shuffle) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_write"] = method(undefined, ds_grid_write) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_read"] = method(undefined, ds_grid_read) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_sort"] = method(undefined, ds_grid_sort) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_set"] = method(undefined, ds_grid_set) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_get"] = method(undefined, ds_grid_get) } catch (ce_) { skipped = true }
            try { db[$ "ds_grid_to_mp_grid"] = method(undefined, ds_grid_to_mp_grid) } catch (ce_) { skipped = true }
            try { db[$ "effect_create_below"] = method(undefined, effect_create_below) } catch (ce_) { skipped = true }
            try { db[$ "effect_create_above"] = method(undefined, effect_create_above) } catch (ce_) { skipped = true }
            try { db[$ "effect_create_layer"] = method(undefined, effect_create_layer) } catch (ce_) { skipped = true }
            try { db[$ "effect_create_depth"] = method(undefined, effect_create_depth) } catch (ce_) { skipped = true }
            try { db[$ "effect_clear"] = method(undefined, effect_clear) } catch (ce_) { skipped = true }
            try { db[$ "part_type_create"] = method(undefined, part_type_create) } catch (ce_) { skipped = true }
            try { db[$ "part_type_destroy"] = method(undefined, part_type_destroy) } catch (ce_) { skipped = true }
            try { db[$ "part_type_exists"] = method(undefined, part_type_exists) } catch (ce_) { skipped = true }
            try { db[$ "part_type_clear"] = method(undefined, part_type_clear) } catch (ce_) { skipped = true }
            try { db[$ "part_type_shape"] = method(undefined, part_type_shape) } catch (ce_) { skipped = true }
            try { db[$ "part_type_sprite"] = method(undefined, part_type_sprite) } catch (ce_) { skipped = true }
            try { db[$ "part_type_subimage"] = method(undefined, part_type_subimage) } catch (ce_) { skipped = true }
            try { db[$ "part_type_size"] = method(undefined, part_type_size) } catch (ce_) { skipped = true }
            try { db[$ "part_type_size_x"] = method(undefined, part_type_size_x) } catch (ce_) { skipped = true }
            try { db[$ "part_type_size_y"] = method(undefined, part_type_size_y) } catch (ce_) { skipped = true }
            try { db[$ "part_type_scale"] = method(undefined, part_type_scale) } catch (ce_) { skipped = true }
            try { db[$ "part_type_orientation"] = method(undefined, part_type_orientation) } catch (ce_) { skipped = true }
            try { db[$ "part_type_life"] = method(undefined, part_type_life) } catch (ce_) { skipped = true }
            try { db[$ "part_type_step"] = method(undefined, part_type_step) } catch (ce_) { skipped = true }
            try { db[$ "part_type_death"] = method(undefined, part_type_death) } catch (ce_) { skipped = true }
            try { db[$ "part_type_speed"] = method(undefined, part_type_speed) } catch (ce_) { skipped = true }
            try { db[$ "part_type_direction"] = method(undefined, part_type_direction) } catch (ce_) { skipped = true }
            try { db[$ "part_type_gravity"] = method(undefined, part_type_gravity) } catch (ce_) { skipped = true }
            try { db[$ "part_type_colour1"] = method(undefined, part_type_colour1) } catch (ce_) { skipped = true }
            try { db[$ "part_type_colour2"] = method(undefined, part_type_colour2) } catch (ce_) { skipped = true }
            try { db[$ "part_type_colour3"] = method(undefined, part_type_colour3) } catch (ce_) { skipped = true }
            try { db[$ "part_type_colour_mix"] = method(undefined, part_type_colour_mix) } catch (ce_) { skipped = true }
            try { db[$ "part_type_colour_rgb"] = method(undefined, part_type_colour_rgb) } catch (ce_) { skipped = true }
            try { db[$ "part_type_colour_hsv"] = method(undefined, part_type_colour_hsv) } catch (ce_) { skipped = true }
            try { db[$ "part_type_color1"] = method(undefined, part_type_color1) } catch (ce_) { skipped = true }
            try { db[$ "part_type_color2"] = method(undefined, part_type_color2) } catch (ce_) { skipped = true }
            try { db[$ "part_type_color3"] = method(undefined, part_type_color3) } catch (ce_) { skipped = true }
            try { db[$ "part_type_color_mix"] = method(undefined, part_type_color_mix) } catch (ce_) { skipped = true }
            try { db[$ "part_type_color_rgb"] = method(undefined, part_type_color_rgb) } catch (ce_) { skipped = true }
            try { db[$ "part_type_color_hsv"] = method(undefined, part_type_color_hsv) } catch (ce_) { skipped = true }
            try { db[$ "part_type_alpha1"] = method(undefined, part_type_alpha1) } catch (ce_) { skipped = true }
            try { db[$ "part_type_alpha2"] = method(undefined, part_type_alpha2) } catch (ce_) { skipped = true }
            try { db[$ "part_type_alpha3"] = method(undefined, part_type_alpha3) } catch (ce_) { skipped = true }
            try { db[$ "part_type_blend"] = method(undefined, part_type_blend) } catch (ce_) { skipped = true }
            try { db[$ "particle_get_info"] = method(undefined, particle_get_info) } catch (ce_) { skipped = true }
            try { db[$ "particle_exists"] = method(undefined, particle_exists) } catch (ce_) { skipped = true }
            try { db[$ "part_system_create"] = method(undefined, part_system_create) } catch (ce_) { skipped = true }
            try { db[$ "part_system_create_layer"] = method(undefined, part_system_create_layer) } catch (ce_) { skipped = true }
            try { db[$ "part_system_destroy"] = method(undefined, part_system_destroy) } catch (ce_) { skipped = true }
            try { db[$ "part_system_exists"] = method(undefined, part_system_exists) } catch (ce_) { skipped = true }
            try { db[$ "part_system_clear"] = method(undefined, part_system_clear) } catch (ce_) { skipped = true }
            try { db[$ "part_system_draw_order"] = method(undefined, part_system_draw_order) } catch (ce_) { skipped = true }
            try { db[$ "part_system_depth"] = method(undefined, part_system_depth) } catch (ce_) { skipped = true }
            try { db[$ "part_system_color"] = method(undefined, part_system_color) } catch (ce_) { skipped = true }
            try { db[$ "part_system_colour"] = method(undefined, part_system_colour) } catch (ce_) { skipped = true }
            try { db[$ "part_system_position"] = method(undefined, part_system_position) } catch (ce_) { skipped = true }
            try { db[$ "part_system_angle"] = method(undefined, part_system_angle) } catch (ce_) { skipped = true }
            try { db[$ "part_system_automatic_update"] = method(undefined, part_system_automatic_update) } catch (ce_) { skipped = true }
            try { db[$ "part_system_automatic_draw"] = method(undefined, part_system_automatic_draw) } catch (ce_) { skipped = true }
            try { db[$ "part_system_update"] = method(undefined, part_system_update) } catch (ce_) { skipped = true }
            try { db[$ "part_system_drawit"] = method(undefined, part_system_drawit) } catch (ce_) { skipped = true }
            try { db[$ "part_system_get_layer"] = method(undefined, part_system_get_layer) } catch (ce_) { skipped = true }
            try { db[$ "part_system_layer"] = method(undefined, part_system_layer) } catch (ce_) { skipped = true }
            try { db[$ "part_system_global_space"] = method(undefined, part_system_global_space) } catch (ce_) { skipped = true }
            try { db[$ "part_system_get_info"] = method(undefined, part_system_get_info) } catch (ce_) { skipped = true }
            try { db[$ "part_particles_create"] = method(undefined, part_particles_create) } catch (ce_) { skipped = true }
            try { db[$ "part_particles_create_colour"] = method(undefined, part_particles_create_colour) } catch (ce_) { skipped = true }
            try { db[$ "part_particles_create_color"] = method(undefined, part_particles_create_color) } catch (ce_) { skipped = true }
            try { db[$ "part_particles_burst"] = method(undefined, part_particles_burst) } catch (ce_) { skipped = true }
            try { db[$ "part_particles_clear"] = method(undefined, part_particles_clear) } catch (ce_) { skipped = true }
            try { db[$ "part_particles_count"] = method(undefined, part_particles_count) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_create"] = method(undefined, part_emitter_create) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_destroy"] = method(undefined, part_emitter_destroy) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_destroy_all"] = method(undefined, part_emitter_destroy_all) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_enable"] = method(undefined, part_emitter_enable) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_exists"] = method(undefined, part_emitter_exists) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_clear"] = method(undefined, part_emitter_clear) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_region"] = method(undefined, part_emitter_region) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_burst"] = method(undefined, part_emitter_burst) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_stream"] = method(undefined, part_emitter_stream) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_delay"] = method(undefined, part_emitter_delay) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_interval"] = method(undefined, part_emitter_interval) } catch (ce_) { skipped = true }
            try { db[$ "part_emitter_relative"] = method(undefined, part_emitter_relative) } catch (ce_) { skipped = true }
            try { db[$ "external_call"] = method(undefined, external_call) } catch (ce_) { skipped = true }
            try { db[$ "external_define"] = method(undefined, external_define) } catch (ce_) { skipped = true }
            try { db[$ "external_free"] = method(undefined, external_free) } catch (ce_) { skipped = true }
            try { db[$ "window_handle"] = method(undefined, window_handle) } catch (ce_) { skipped = true }
            try { db[$ "window_device"] = method(undefined, window_device) } catch (ce_) { skipped = true }
            try { db[$ "matrix_get"] = method(undefined, matrix_get) } catch (ce_) { skipped = true }
            try { db[$ "matrix_set"] = method(undefined, matrix_set) } catch (ce_) { skipped = true }
            try { db[$ "matrix_build_identity"] = method(undefined, matrix_build_identity) } catch (ce_) { skipped = true }
            try { db[$ "matrix_build"] = method(undefined, matrix_build) } catch (ce_) { skipped = true }
            try { db[$ "matrix_build_lookat"] = method(undefined, matrix_build_lookat) } catch (ce_) { skipped = true }
            try { db[$ "matrix_build_projection_ortho"] = method(undefined, matrix_build_projection_ortho) } catch (ce_) { skipped = true }
            try { db[$ "matrix_build_projection_perspective"] = method(undefined, matrix_build_projection_perspective) } catch (ce_) { skipped = true }
            try { db[$ "matrix_build_projection_perspective_fov"] = method(undefined, matrix_build_projection_perspective_fov) } catch (ce_) { skipped = true }
            try { db[$ "matrix_multiply"] = method(undefined, matrix_multiply) } catch (ce_) { skipped = true }
            try { db[$ "matrix_transform_vertex"] = method(undefined, matrix_transform_vertex) } catch (ce_) { skipped = true }
            try { db[$ "matrix_stack_push"] = method(undefined, matrix_stack_push) } catch (ce_) { skipped = true }
            try { db[$ "matrix_stack_pop"] = method(undefined, matrix_stack_pop) } catch (ce_) { skipped = true }
            try { db[$ "matrix_stack_set"] = method(undefined, matrix_stack_set) } catch (ce_) { skipped = true }
            try { db[$ "matrix_stack_clear"] = method(undefined, matrix_stack_clear) } catch (ce_) { skipped = true }
            try { db[$ "matrix_stack_top"] = method(undefined, matrix_stack_top) } catch (ce_) { skipped = true }
            try { db[$ "matrix_stack_is_empty"] = method(undefined, matrix_stack_is_empty) } catch (ce_) { skipped = true }
            try { db[$ "browser_input_capture"] = method(undefined, browser_input_capture) } catch (ce_) { skipped = true }
            try { db[$ "os_get_config"] = method(undefined, os_get_config) } catch (ce_) { skipped = true }
            try { db[$ "os_get_info"] = method(undefined, os_get_info) } catch (ce_) { skipped = true }
            try { db[$ "os_get_language"] = method(undefined, os_get_language) } catch (ce_) { skipped = true }
            try { db[$ "os_get_region"] = method(undefined, os_get_region) } catch (ce_) { skipped = true }
            try { db[$ "os_check_permission"] = method(undefined, os_check_permission) } catch (ce_) { skipped = true }
            try { db[$ "os_request_permission"] = method(undefined, os_request_permission) } catch (ce_) { skipped = true }
            try { db[$ "os_lock_orientation"] = method(undefined, os_lock_orientation) } catch (ce_) { skipped = true }
            try { db[$ "os_set_orientation_lock"] = method(undefined, os_set_orientation_lock) } catch (ce_) { skipped = true }
            try { db[$ "display_get_dpi_x"] = method(undefined, display_get_dpi_x) } catch (ce_) { skipped = true }
            try { db[$ "display_get_dpi_y"] = method(undefined, display_get_dpi_y) } catch (ce_) { skipped = true }
            try { db[$ "display_set_gui_size"] = method(undefined, display_set_gui_size) } catch (ce_) { skipped = true }
            try { db[$ "display_set_gui_maximise"] = method(undefined, display_set_gui_maximise) } catch (ce_) { skipped = true }
            try { db[$ "display_set_gui_maximize"] = method(undefined, display_set_gui_maximize) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_dbclick_enable"] = method(undefined, device_mouse_dbclick_enable) } catch (ce_) { skipped = true }
            try { db[$ "display_set_timing_method"] = method(undefined, display_set_timing_method) } catch (ce_) { skipped = true }
            try { db[$ "display_get_timing_method"] = method(undefined, display_get_timing_method) } catch (ce_) { skipped = true }
            try { db[$ "display_set_sleep_margin"] = method(undefined, display_set_sleep_margin) } catch (ce_) { skipped = true }
            try { db[$ "display_get_sleep_margin"] = method(undefined, display_get_sleep_margin) } catch (ce_) { skipped = true }
            try { db[$ "virtual_key_add"] = method(undefined, virtual_key_add) } catch (ce_) { skipped = true }
            try { db[$ "virtual_key_hide"] = method(undefined, virtual_key_hide) } catch (ce_) { skipped = true }
            try { db[$ "virtual_key_delete"] = method(undefined, virtual_key_delete) } catch (ce_) { skipped = true }
            try { db[$ "virtual_key_show"] = method(undefined, virtual_key_show) } catch (ce_) { skipped = true }
            try { db[$ "draw_enable_drawevent"] = method(undefined, draw_enable_drawevent) } catch (ce_) { skipped = true }
            try { db[$ "draw_enable_swf_aa"] = method(undefined, draw_enable_swf_aa) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_swf_aa_level"] = method(undefined, draw_set_swf_aa_level) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_swf_aa_level"] = method(undefined, draw_get_swf_aa_level) } catch (ce_) { skipped = true }
            try { db[$ "draw_texture_flush"] = method(undefined, draw_texture_flush) } catch (ce_) { skipped = true }
            try { db[$ "draw_flush"] = method(undefined, draw_flush) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_blendenable"] = method(undefined, gpu_set_blendenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_ztestenable"] = method(undefined, gpu_set_ztestenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_zfunc"] = method(undefined, gpu_set_zfunc) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_zwriteenable"] = method(undefined, gpu_set_zwriteenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_depth"] = method(undefined, gpu_set_depth) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_fog"] = method(undefined, gpu_set_fog) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_cullmode"] = method(undefined, gpu_set_cullmode) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_blendmode"] = method(undefined, gpu_set_blendmode) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_blendmode_ext"] = method(undefined, gpu_set_blendmode_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_blendmode_ext_sepalpha"] = method(undefined, gpu_set_blendmode_ext_sepalpha) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_colorwriteenable"] = method(undefined, gpu_set_colorwriteenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_colourwriteenable"] = method(undefined, gpu_set_colourwriteenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_alphatestenable"] = method(undefined, gpu_set_alphatestenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_alphatestref"] = method(undefined, gpu_set_alphatestref) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_texfilter"] = method(undefined, gpu_set_texfilter) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_texfilter_ext"] = method(undefined, gpu_set_texfilter_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_texrepeat"] = method(undefined, gpu_set_texrepeat) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_texrepeat_ext"] = method(undefined, gpu_set_texrepeat_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_filter"] = method(undefined, gpu_set_tex_filter) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_filter_ext"] = method(undefined, gpu_set_tex_filter_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_repeat"] = method(undefined, gpu_set_tex_repeat) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_repeat_ext"] = method(undefined, gpu_set_tex_repeat_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_mip_filter"] = method(undefined, gpu_set_tex_mip_filter) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_mip_filter_ext"] = method(undefined, gpu_set_tex_mip_filter_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_mip_bias"] = method(undefined, gpu_set_tex_mip_bias) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_mip_bias_ext"] = method(undefined, gpu_set_tex_mip_bias_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_min_mip"] = method(undefined, gpu_set_tex_min_mip) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_min_mip_ext"] = method(undefined, gpu_set_tex_min_mip_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_max_mip"] = method(undefined, gpu_set_tex_max_mip) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_max_mip_ext"] = method(undefined, gpu_set_tex_max_mip_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_max_aniso"] = method(undefined, gpu_set_tex_max_aniso) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_max_aniso_ext"] = method(undefined, gpu_set_tex_max_aniso_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_mip_enable"] = method(undefined, gpu_set_tex_mip_enable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_tex_mip_enable_ext"] = method(undefined, gpu_set_tex_mip_enable_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendenable"] = method(undefined, gpu_get_blendenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_ztestenable"] = method(undefined, gpu_get_ztestenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_zfunc"] = method(undefined, gpu_get_zfunc) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_zwriteenable"] = method(undefined, gpu_get_zwriteenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_depth"] = method(undefined, gpu_get_depth) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_fog"] = method(undefined, gpu_get_fog) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_cullmode"] = method(undefined, gpu_get_cullmode) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode"] = method(undefined, gpu_get_blendmode) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode_ext"] = method(undefined, gpu_get_blendmode_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode_ext_sepalpha"] = method(undefined, gpu_get_blendmode_ext_sepalpha) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode_src"] = method(undefined, gpu_get_blendmode_src) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode_dest"] = method(undefined, gpu_get_blendmode_dest) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode_srcalpha"] = method(undefined, gpu_get_blendmode_srcalpha) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_blendmode_destalpha"] = method(undefined, gpu_get_blendmode_destalpha) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_colorwriteenable"] = method(undefined, gpu_get_colorwriteenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_colourwriteenable"] = method(undefined, gpu_get_colourwriteenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_alphatestenable"] = method(undefined, gpu_get_alphatestenable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_alphatestref"] = method(undefined, gpu_get_alphatestref) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_texfilter"] = method(undefined, gpu_get_texfilter) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_texfilter_ext"] = method(undefined, gpu_get_texfilter_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_texrepeat"] = method(undefined, gpu_get_texrepeat) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_texrepeat_ext"] = method(undefined, gpu_get_texrepeat_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_filter"] = method(undefined, gpu_get_tex_filter) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_filter_ext"] = method(undefined, gpu_get_tex_filter_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_repeat"] = method(undefined, gpu_get_tex_repeat) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_repeat_ext"] = method(undefined, gpu_get_tex_repeat_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_mip_filter"] = method(undefined, gpu_get_tex_mip_filter) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_mip_filter_ext"] = method(undefined, gpu_get_tex_mip_filter_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_mip_bias"] = method(undefined, gpu_get_tex_mip_bias) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_mip_bias_ext"] = method(undefined, gpu_get_tex_mip_bias_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_min_mip"] = method(undefined, gpu_get_tex_min_mip) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_min_mip_ext"] = method(undefined, gpu_get_tex_min_mip_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_max_mip"] = method(undefined, gpu_get_tex_max_mip) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_max_mip_ext"] = method(undefined, gpu_get_tex_max_mip_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_max_aniso"] = method(undefined, gpu_get_tex_max_aniso) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_max_aniso_ext"] = method(undefined, gpu_get_tex_max_aniso_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_mip_enable"] = method(undefined, gpu_get_tex_mip_enable) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_tex_mip_enable_ext"] = method(undefined, gpu_get_tex_mip_enable_ext) } catch (ce_) { skipped = true }
            try { db[$ "gpu_push_state"] = method(undefined, gpu_push_state) } catch (ce_) { skipped = true }
            try { db[$ "gpu_pop_state"] = method(undefined, gpu_pop_state) } catch (ce_) { skipped = true }
            try { db[$ "gpu_get_state"] = method(undefined, gpu_get_state) } catch (ce_) { skipped = true }
            try { db[$ "gpu_set_state"] = method(undefined, gpu_set_state) } catch (ce_) { skipped = true }
            try { db[$ "draw_light_define_ambient"] = method(undefined, draw_light_define_ambient) } catch (ce_) { skipped = true }
            try { db[$ "draw_light_define_direction"] = method(undefined, draw_light_define_direction) } catch (ce_) { skipped = true }
            try { db[$ "draw_light_define_point"] = method(undefined, draw_light_define_point) } catch (ce_) { skipped = true }
            try { db[$ "draw_light_enable"] = method(undefined, draw_light_enable) } catch (ce_) { skipped = true }
            try { db[$ "draw_set_lighting"] = method(undefined, draw_set_lighting) } catch (ce_) { skipped = true }
            try { db[$ "draw_light_get_ambient"] = method(undefined, draw_light_get_ambient) } catch (ce_) { skipped = true }
            try { db[$ "draw_light_get"] = method(undefined, draw_light_get) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_lighting"] = method(undefined, draw_get_lighting) } catch (ce_) { skipped = true }
            try { db[$ "shop_leave_rating"] = method(undefined, shop_leave_rating) } catch (ce_) { skipped = true }
            try { db[$ "url_get_domain"] = method(undefined, url_get_domain) } catch (ce_) { skipped = true }
            try { db[$ "url_open"] = method(undefined, url_open) } catch (ce_) { skipped = true }
            try { db[$ "url_open_ext"] = method(undefined, url_open_ext) } catch (ce_) { skipped = true }
            try { db[$ "url_open_full"] = method(undefined, url_open_full) } catch (ce_) { skipped = true }
            try { db[$ "get_timer"] = method(undefined, get_timer) } catch (ce_) { skipped = true }
            try { db[$ "device_get_tilt_x"] = method(undefined, device_get_tilt_x) } catch (ce_) { skipped = true }
            try { db[$ "device_get_tilt_y"] = method(undefined, device_get_tilt_y) } catch (ce_) { skipped = true }
            try { db[$ "device_get_tilt_z"] = method(undefined, device_get_tilt_z) } catch (ce_) { skipped = true }
            try { db[$ "device_is_keypad_open"] = method(undefined, device_is_keypad_open) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_check_button"] = method(undefined, device_mouse_check_button) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_check_button_pressed"] = method(undefined, device_mouse_check_button_pressed) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_check_button_released"] = method(undefined, device_mouse_check_button_released) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_x"] = method(undefined, device_mouse_x) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_y"] = method(undefined, device_mouse_y) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_raw_x"] = method(undefined, device_mouse_raw_x) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_raw_y"] = method(undefined, device_mouse_raw_y) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_x_to_gui"] = method(undefined, device_mouse_x_to_gui) } catch (ce_) { skipped = true }
            try { db[$ "device_mouse_y_to_gui"] = method(undefined, device_mouse_y_to_gui) } catch (ce_) { skipped = true }
            try { db[$ "iap_activate"] = method(undefined, iap_activate) } catch (ce_) { skipped = true }
            try { db[$ "iap_status"] = method(undefined, iap_status) } catch (ce_) { skipped = true }
            try { db[$ "iap_enumerate_products"] = method(undefined, iap_enumerate_products) } catch (ce_) { skipped = true }
            try { db[$ "iap_restore_all"] = method(undefined, iap_restore_all) } catch (ce_) { skipped = true }
            try { db[$ "iap_acquire"] = method(undefined, iap_acquire) } catch (ce_) { skipped = true }
            try { db[$ "iap_consume"] = method(undefined, iap_consume) } catch (ce_) { skipped = true }
            try { db[$ "iap_product_details"] = method(undefined, iap_product_details) } catch (ce_) { skipped = true }
            try { db[$ "iap_purchase_details"] = method(undefined, iap_purchase_details) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_is_supported"] = method(undefined, gamepad_is_supported) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_device_count"] = method(undefined, gamepad_get_device_count) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_is_connected"] = method(undefined, gamepad_is_connected) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_description"] = method(undefined, gamepad_get_description) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_button_threshold"] = method(undefined, gamepad_get_button_threshold) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_set_button_threshold"] = method(undefined, gamepad_set_button_threshold) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_axis_deadzone"] = method(undefined, gamepad_get_axis_deadzone) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_set_axis_deadzone"] = method(undefined, gamepad_set_axis_deadzone) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_button_count"] = method(undefined, gamepad_button_count) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_button_check"] = method(undefined, gamepad_button_check) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_button_check_pressed"] = method(undefined, gamepad_button_check_pressed) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_button_check_released"] = method(undefined, gamepad_button_check_released) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_button_value"] = method(undefined, gamepad_button_value) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_axis_count"] = method(undefined, gamepad_axis_count) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_axis_value"] = method(undefined, gamepad_axis_value) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_set_vibration"] = method(undefined, gamepad_set_vibration) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_set_colour"] = method(undefined, gamepad_set_colour) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_set_color"] = method(undefined, gamepad_set_color) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_hat_count"] = method(undefined, gamepad_hat_count) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_hat_value"] = method(undefined, gamepad_hat_value) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_remove_mapping"] = method(undefined, gamepad_remove_mapping) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_test_mapping"] = method(undefined, gamepad_test_mapping) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_mapping"] = method(undefined, gamepad_get_mapping) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_guid"] = method(undefined, gamepad_get_guid) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_set_option"] = method(undefined, gamepad_set_option) } catch (ce_) { skipped = true }
            try { db[$ "gamepad_get_option"] = method(undefined, gamepad_get_option) } catch (ce_) { skipped = true }
            try { db[$ "os_is_paused"] = method(undefined, os_is_paused) } catch (ce_) { skipped = true }
            try { db[$ "window_has_focus"] = method(undefined, window_has_focus) } catch (ce_) { skipped = true }
            try { db[$ "code_is_compiled"] = method(undefined, code_is_compiled) } catch (ce_) { skipped = true }
            try { db[$ "http_get"] = method(undefined, http_get) } catch (ce_) { skipped = true }
            try { db[$ "http_get_file"] = method(undefined, http_get_file) } catch (ce_) { skipped = true }
            try { db[$ "http_post_string"] = method(undefined, http_post_string) } catch (ce_) { skipped = true }
            try { db[$ "http_request"] = method(undefined, http_request) } catch (ce_) { skipped = true }
            try { db[$ "http_get_request_crossorigin"] = method(undefined, http_get_request_crossorigin) } catch (ce_) { skipped = true }
            try { db[$ "http_set_request_crossorigin"] = method(undefined, http_set_request_crossorigin) } catch (ce_) { skipped = true }
            try { db[$ "json_encode"] = method(undefined, json_encode) } catch (ce_) { skipped = true }
            try { db[$ "json_decode"] = method(undefined, json_decode) } catch (ce_) { skipped = true }
            try { db[$ "json_stringify"] = method(undefined, json_stringify) } catch (ce_) { skipped = true }
            try { db[$ "json_parse"] = method(undefined, json_parse) } catch (ce_) { skipped = true }
            try { db[$ "zip_unzip"] = method(undefined, zip_unzip) } catch (ce_) { skipped = true }
            try { db[$ "zip_unzip_async"] = method(undefined, zip_unzip_async) } catch (ce_) { skipped = true }
            try { db[$ "zip_create"] = method(undefined, zip_create) } catch (ce_) { skipped = true }
            try { db[$ "zip_add_file"] = method(undefined, zip_add_file) } catch (ce_) { skipped = true }
            try { db[$ "zip_save"] = method(undefined, zip_save) } catch (ce_) { skipped = true }
            try { db[$ "load_csv"] = method(undefined, load_csv) } catch (ce_) { skipped = true }
            try { db[$ "base64_encode"] = method(undefined, base64_encode) } catch (ce_) { skipped = true }
            try { db[$ "base64_decode"] = method(undefined, base64_decode) } catch (ce_) { skipped = true }
            try { db[$ "md5_string_unicode"] = method(undefined, md5_string_unicode) } catch (ce_) { skipped = true }
            try { db[$ "md5_string_utf8"] = method(undefined, md5_string_utf8) } catch (ce_) { skipped = true }
            try { db[$ "md5_file"] = method(undefined, md5_file) } catch (ce_) { skipped = true }
            try { db[$ "os_is_network_connected"] = method(undefined, os_is_network_connected) } catch (ce_) { skipped = true }
            try { db[$ "sha1_string_unicode"] = method(undefined, sha1_string_unicode) } catch (ce_) { skipped = true }
            try { db[$ "sha1_string_utf8"] = method(undefined, sha1_string_utf8) } catch (ce_) { skipped = true }
            try { db[$ "sha1_file"] = method(undefined, sha1_file) } catch (ce_) { skipped = true }
            try { db[$ "os_powersave_enable"] = method(undefined, os_powersave_enable) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_tile_clear"] = method(undefined, uwp_livetile_tile_clear) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_badge_notification"] = method(undefined, uwp_livetile_badge_notification) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_badge_clear"] = method(undefined, uwp_livetile_badge_clear) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_queue_enable"] = method(undefined, uwp_livetile_queue_enable) } catch (ce_) { skipped = true }
            try { db[$ "uwp_secondarytile_pin"] = method(undefined, uwp_secondarytile_pin) } catch (ce_) { skipped = true }
            try { db[$ "uwp_secondarytile_badge_notification"] = method(undefined, uwp_secondarytile_badge_notification) } catch (ce_) { skipped = true }
            try { db[$ "uwp_secondarytile_delete"] = method(undefined, uwp_secondarytile_delete) } catch (ce_) { skipped = true }
            try { db[$ "uwp_secondarytile_badge_clear"] = method(undefined, uwp_secondarytile_badge_clear) } catch (ce_) { skipped = true }
            try { db[$ "uwp_secondarytile_tile_clear"] = method(undefined, uwp_secondarytile_tile_clear) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_begin"] = method(undefined, uwp_livetile_notification_begin) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_secondary_begin"] = method(undefined, uwp_livetile_notification_secondary_begin) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_expiry"] = method(undefined, uwp_livetile_notification_expiry) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_tag"] = method(undefined, uwp_livetile_notification_tag) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_text_add"] = method(undefined, uwp_livetile_notification_text_add) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_image_add"] = method(undefined, uwp_livetile_notification_image_add) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_end"] = method(undefined, uwp_livetile_notification_end) } catch (ce_) { skipped = true }
            try { db[$ "uwp_livetile_notification_template_add"] = method(undefined, uwp_livetile_notification_template_add) } catch (ce_) { skipped = true }
            try { db[$ "uwp_device_touchscreen_available"] = method(undefined, uwp_device_touchscreen_available) } catch (ce_) { skipped = true }
            try { db[$ "winphone_tile_background_colour"] = method(undefined, winphone_tile_background_colour) } catch (ce_) { skipped = true }
            try { db[$ "winphone_tile_background_color"] = method(undefined, winphone_tile_background_color) } catch (ce_) { skipped = true }
            try { db[$ "network_create_socket"] = method(undefined, network_create_socket) } catch (ce_) { skipped = true }
            try { db[$ "network_create_socket_ext"] = method(undefined, network_create_socket_ext) } catch (ce_) { skipped = true }
            try { db[$ "network_create_server"] = method(undefined, network_create_server) } catch (ce_) { skipped = true }
            try { db[$ "network_create_server_raw"] = method(undefined, network_create_server_raw) } catch (ce_) { skipped = true }
            try { db[$ "network_connect"] = method(undefined, network_connect) } catch (ce_) { skipped = true }
            try { db[$ "network_connect_raw"] = method(undefined, network_connect_raw) } catch (ce_) { skipped = true }
            try { db[$ "network_connect_async"] = method(undefined, network_connect_async) } catch (ce_) { skipped = true }
            try { db[$ "network_connect_raw_async"] = method(undefined, network_connect_raw_async) } catch (ce_) { skipped = true }
            try { db[$ "network_send_packet"] = method(undefined, network_send_packet) } catch (ce_) { skipped = true }
            try { db[$ "network_send_raw"] = method(undefined, network_send_raw) } catch (ce_) { skipped = true }
            try { db[$ "network_send_broadcast"] = method(undefined, network_send_broadcast) } catch (ce_) { skipped = true }
            try { db[$ "network_send_udp"] = method(undefined, network_send_udp) } catch (ce_) { skipped = true }
            try { db[$ "network_send_udp_raw"] = method(undefined, network_send_udp_raw) } catch (ce_) { skipped = true }
            try { db[$ "network_set_timeout"] = method(undefined, network_set_timeout) } catch (ce_) { skipped = true }
            try { db[$ "network_set_config"] = method(undefined, network_set_config) } catch (ce_) { skipped = true }
            try { db[$ "network_resolve"] = method(undefined, network_resolve) } catch (ce_) { skipped = true }
            try { db[$ "network_destroy"] = method(undefined, network_destroy) } catch (ce_) { skipped = true }
            try { db[$ "buffer_create"] = method(undefined, buffer_create) } catch (ce_) { skipped = true }
            try { db[$ "buffer_write"] = method(undefined, buffer_write) } catch (ce_) { skipped = true }
            try { db[$ "buffer_read"] = method(undefined, buffer_read) } catch (ce_) { skipped = true }
            try { db[$ "buffer_seek"] = method(undefined, buffer_seek) } catch (ce_) { skipped = true }
            try { db[$ "buffer_get_surface"] = method(undefined, buffer_get_surface) } catch (ce_) { skipped = true }
            try { db[$ "buffer_set_surface"] = method(undefined, buffer_set_surface) } catch (ce_) { skipped = true }
            try { db[$ "buffer_set_used_size"] = method(undefined, buffer_set_used_size) } catch (ce_) { skipped = true }
            try { db[$ "buffer_delete"] = method(undefined, buffer_delete) } catch (ce_) { skipped = true }
            try { db[$ "buffer_exists"] = method(undefined, buffer_exists) } catch (ce_) { skipped = true }
            try { db[$ "buffer_get_type"] = method(undefined, buffer_get_type) } catch (ce_) { skipped = true }
            try { db[$ "buffer_get_alignment"] = method(undefined, buffer_get_alignment) } catch (ce_) { skipped = true }
            try { db[$ "buffer_poke"] = method(undefined, buffer_poke) } catch (ce_) { skipped = true }
            try { db[$ "buffer_peek"] = method(undefined, buffer_peek) } catch (ce_) { skipped = true }
            try { db[$ "buffer_save"] = method(undefined, buffer_save) } catch (ce_) { skipped = true }
            try { db[$ "buffer_save_ext"] = method(undefined, buffer_save_ext) } catch (ce_) { skipped = true }
            try { db[$ "buffer_load"] = method(undefined, buffer_load) } catch (ce_) { skipped = true }
            try { db[$ "buffer_load_ext"] = method(undefined, buffer_load_ext) } catch (ce_) { skipped = true }
            try { db[$ "buffer_load_partial"] = method(undefined, buffer_load_partial) } catch (ce_) { skipped = true }
            try { db[$ "buffer_copy"] = method(undefined, buffer_copy) } catch (ce_) { skipped = true }
            try { db[$ "buffer_copy_stride"] = method(undefined, buffer_copy_stride) } catch (ce_) { skipped = true }
            try { db[$ "buffer_fill"] = method(undefined, buffer_fill) } catch (ce_) { skipped = true }
            try { db[$ "buffer_get_size"] = method(undefined, buffer_get_size) } catch (ce_) { skipped = true }
            try { db[$ "buffer_tell"] = method(undefined, buffer_tell) } catch (ce_) { skipped = true }
            try { db[$ "buffer_resize"] = method(undefined, buffer_resize) } catch (ce_) { skipped = true }
            try { db[$ "buffer_md5"] = method(undefined, buffer_md5) } catch (ce_) { skipped = true }
            try { db[$ "buffer_sha1"] = method(undefined, buffer_sha1) } catch (ce_) { skipped = true }
            try { db[$ "buffer_crc32"] = method(undefined, buffer_crc32) } catch (ce_) { skipped = true }
            try { db[$ "buffer_base64_encode"] = method(undefined, buffer_base64_encode) } catch (ce_) { skipped = true }
            try { db[$ "buffer_base64_decode"] = method(undefined, buffer_base64_decode) } catch (ce_) { skipped = true }
            try { db[$ "buffer_base64_decode_ext"] = method(undefined, buffer_base64_decode_ext) } catch (ce_) { skipped = true }
            try { db[$ "buffer_sizeof"] = method(undefined, buffer_sizeof) } catch (ce_) { skipped = true }
            try { db[$ "buffer_get_address"] = method(undefined, buffer_get_address) } catch (ce_) { skipped = true }
            try { db[$ "buffer_create_from_vertex_buffer"] = method(undefined, buffer_create_from_vertex_buffer) } catch (ce_) { skipped = true }
            try { db[$ "buffer_create_from_vertex_buffer_ext"] = method(undefined, buffer_create_from_vertex_buffer_ext) } catch (ce_) { skipped = true }
            try { db[$ "buffer_copy_from_vertex_buffer"] = method(undefined, buffer_copy_from_vertex_buffer) } catch (ce_) { skipped = true }
            try { db[$ "buffer_async_group_begin"] = method(undefined, buffer_async_group_begin) } catch (ce_) { skipped = true }
            try { db[$ "buffer_async_group_option"] = method(undefined, buffer_async_group_option) } catch (ce_) { skipped = true }
            try { db[$ "buffer_async_group_end"] = method(undefined, buffer_async_group_end) } catch (ce_) { skipped = true }
            try { db[$ "buffer_load_async"] = method(undefined, buffer_load_async) } catch (ce_) { skipped = true }
            try { db[$ "buffer_save_async"] = method(undefined, buffer_save_async) } catch (ce_) { skipped = true }
            try { db[$ "buffer_compress"] = method(undefined, buffer_compress) } catch (ce_) { skipped = true }
            try { db[$ "buffer_decompress"] = method(undefined, buffer_decompress) } catch (ce_) { skipped = true }
            try { db[$ "shader_set"] = method(undefined, shader_set) } catch (ce_) { skipped = true }
            try { db[$ "shader_get_name"] = method(undefined, shader_get_name) } catch (ce_) { skipped = true }
            try { db[$ "shader_reset"] = method(undefined, shader_reset) } catch (ce_) { skipped = true }
            try { db[$ "shader_current"] = method(undefined, shader_current) } catch (ce_) { skipped = true }
            try { db[$ "shader_is_compiled"] = method(undefined, shader_is_compiled) } catch (ce_) { skipped = true }
            try { db[$ "shader_get_sampler_index"] = method(undefined, shader_get_sampler_index) } catch (ce_) { skipped = true }
            try { db[$ "shader_get_uniform"] = method(undefined, shader_get_uniform) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_i"] = method(undefined, shader_set_uniform_i) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_i_array"] = method(undefined, shader_set_uniform_i_array) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_f"] = method(undefined, shader_set_uniform_f) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_f_array"] = method(undefined, shader_set_uniform_f_array) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_f_buffer"] = method(undefined, shader_set_uniform_f_buffer) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_matrix"] = method(undefined, shader_set_uniform_matrix) } catch (ce_) { skipped = true }
            try { db[$ "shader_set_uniform_matrix_array"] = method(undefined, shader_set_uniform_matrix_array) } catch (ce_) { skipped = true }
            try { db[$ "shader_enable_corner_id"] = method(undefined, shader_enable_corner_id) } catch (ce_) { skipped = true }
            try { db[$ "texture_set_stage"] = method(undefined, texture_set_stage) } catch (ce_) { skipped = true }
            try { db[$ "texture_get_texel_width"] = method(undefined, texture_get_texel_width) } catch (ce_) { skipped = true }
            try { db[$ "texture_get_texel_height"] = method(undefined, texture_get_texel_height) } catch (ce_) { skipped = true }
            try { db[$ "shaders_are_supported"] = method(undefined, shaders_are_supported) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_begin"] = method(undefined, vertex_format_begin) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_end"] = method(undefined, vertex_format_end) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_delete"] = method(undefined, vertex_format_delete) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_position"] = method(undefined, vertex_format_add_position) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_position_3d"] = method(undefined, vertex_format_add_position_3d) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_colour"] = method(undefined, vertex_format_add_colour) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_color"] = method(undefined, vertex_format_add_color) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_normal"] = method(undefined, vertex_format_add_normal) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_texcoord"] = method(undefined, vertex_format_add_texcoord) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_add_custom"] = method(undefined, vertex_format_add_custom) } catch (ce_) { skipped = true }
            try { db[$ "vertex_format_get_info"] = method(undefined, vertex_format_get_info) } catch (ce_) { skipped = true }
            try { db[$ "vertex_create_buffer"] = method(undefined, vertex_create_buffer) } catch (ce_) { skipped = true }
            try { db[$ "vertex_create_buffer_ext"] = method(undefined, vertex_create_buffer_ext) } catch (ce_) { skipped = true }
            try { db[$ "vertex_delete_buffer"] = method(undefined, vertex_delete_buffer) } catch (ce_) { skipped = true }
            try { db[$ "vertex_begin"] = method(undefined, vertex_begin) } catch (ce_) { skipped = true }
            try { db[$ "vertex_end"] = method(undefined, vertex_end) } catch (ce_) { skipped = true }
            try { db[$ "vertex_position"] = method(undefined, vertex_position) } catch (ce_) { skipped = true }
            try { db[$ "vertex_position_3d"] = method(undefined, vertex_position_3d) } catch (ce_) { skipped = true }
            try { db[$ "vertex_colour"] = method(undefined, vertex_colour) } catch (ce_) { skipped = true }
            try { db[$ "vertex_color"] = method(undefined, vertex_color) } catch (ce_) { skipped = true }
            try { db[$ "vertex_argb"] = method(undefined, vertex_argb) } catch (ce_) { skipped = true }
            try { db[$ "vertex_texcoord"] = method(undefined, vertex_texcoord) } catch (ce_) { skipped = true }
            try { db[$ "vertex_normal"] = method(undefined, vertex_normal) } catch (ce_) { skipped = true }
            try { db[$ "vertex_float1"] = method(undefined, vertex_float1) } catch (ce_) { skipped = true }
            try { db[$ "vertex_float2"] = method(undefined, vertex_float2) } catch (ce_) { skipped = true }
            try { db[$ "vertex_float3"] = method(undefined, vertex_float3) } catch (ce_) { skipped = true }
            try { db[$ "vertex_float4"] = method(undefined, vertex_float4) } catch (ce_) { skipped = true }
            try { db[$ "vertex_ubyte4"] = method(undefined, vertex_ubyte4) } catch (ce_) { skipped = true }
            try { db[$ "vertex_submit"] = method(undefined, vertex_submit) } catch (ce_) { skipped = true }
            try { db[$ "vertex_submit_ext"] = method(undefined, vertex_submit_ext) } catch (ce_) { skipped = true }
            try { db[$ "vertex_freeze"] = method(undefined, vertex_freeze) } catch (ce_) { skipped = true }
            try { db[$ "vertex_get_number"] = method(undefined, vertex_get_number) } catch (ce_) { skipped = true }
            try { db[$ "vertex_get_buffer_size"] = method(undefined, vertex_get_buffer_size) } catch (ce_) { skipped = true }
            try { db[$ "vertex_create_buffer_from_buffer"] = method(undefined, vertex_create_buffer_from_buffer) } catch (ce_) { skipped = true }
            try { db[$ "vertex_create_buffer_from_buffer_ext"] = method(undefined, vertex_create_buffer_from_buffer_ext) } catch (ce_) { skipped = true }
            try { db[$ "vertex_update_buffer_from_buffer"] = method(undefined, vertex_update_buffer_from_buffer) } catch (ce_) { skipped = true }
            try { db[$ "vertex_update_buffer_from_vertex"] = method(undefined, vertex_update_buffer_from_vertex) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_set"] = method(undefined, skeleton_animation_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get"] = method(undefined, skeleton_animation_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_mix"] = method(undefined, skeleton_animation_mix) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_set_ext"] = method(undefined, skeleton_animation_set_ext) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get_ext"] = method(undefined, skeleton_animation_get_ext) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get_duration"] = method(undefined, skeleton_animation_get_duration) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get_frames"] = method(undefined, skeleton_animation_get_frames) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_clear"] = method(undefined, skeleton_animation_clear) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_skin_set"] = method(undefined, skeleton_skin_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_skin_get"] = method(undefined, skeleton_skin_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_skin_create"] = method(undefined, skeleton_skin_create) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_set"] = method(undefined, skeleton_attachment_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_get"] = method(undefined, skeleton_attachment_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_create"] = method(undefined, skeleton_attachment_create) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_create_colour"] = method(undefined, skeleton_attachment_create_colour) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_create_color"] = method(undefined, skeleton_attachment_create_color) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_exists"] = method(undefined, skeleton_attachment_exists) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_replace"] = method(undefined, skeleton_attachment_replace) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_replace_colour"] = method(undefined, skeleton_attachment_replace_colour) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_replace_color"] = method(undefined, skeleton_attachment_replace_color) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_attachment_destroy"] = method(undefined, skeleton_attachment_destroy) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_collision_draw_set"] = method(undefined, skeleton_collision_draw_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_bone_data_get"] = method(undefined, skeleton_bone_data_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_bone_data_set"] = method(undefined, skeleton_bone_data_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_bone_state_get"] = method(undefined, skeleton_bone_state_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_bone_state_set"] = method(undefined, skeleton_bone_state_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_colour_set"] = method(undefined, skeleton_slot_colour_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_color_set"] = method(undefined, skeleton_slot_color_set) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_colour_get"] = method(undefined, skeleton_slot_colour_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_color_get"] = method(undefined, skeleton_slot_color_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_alpha_get"] = method(undefined, skeleton_slot_alpha_get) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_find_slot"] = method(undefined, skeleton_find_slot) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_get_minmax"] = method(undefined, skeleton_get_minmax) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_get_num_bounds"] = method(undefined, skeleton_get_num_bounds) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_get_bounds"] = method(undefined, skeleton_get_bounds) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get_frame"] = method(undefined, skeleton_animation_get_frame) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_set_frame"] = method(undefined, skeleton_animation_set_frame) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get_position"] = method(undefined, skeleton_animation_get_position) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_set_position"] = method(undefined, skeleton_animation_set_position) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_get_event_frames"] = method(undefined, skeleton_animation_get_event_frames) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_is_looping"] = method(undefined, skeleton_animation_is_looping) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_is_finished"] = method(undefined, skeleton_animation_is_finished) } catch (ce_) { skipped = true }
            try { db[$ "draw_skeleton"] = method(undefined, draw_skeleton) } catch (ce_) { skipped = true }
            try { db[$ "draw_skeleton_time"] = method(undefined, draw_skeleton_time) } catch (ce_) { skipped = true }
            try { db[$ "draw_skeleton_instance"] = method(undefined, draw_skeleton_instance) } catch (ce_) { skipped = true }
            try { db[$ "draw_skeleton_collision"] = method(undefined, draw_skeleton_collision) } catch (ce_) { skipped = true }
            try { db[$ "draw_enable_skeleton_blendmodes"] = method(undefined, draw_enable_skeleton_blendmodes) } catch (ce_) { skipped = true }
            try { db[$ "draw_get_enable_skeleton_blendmodes"] = method(undefined, draw_get_enable_skeleton_blendmodes) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_animation_list"] = method(undefined, skeleton_animation_list) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_skin_list"] = method(undefined, skeleton_skin_list) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_bone_list"] = method(undefined, skeleton_bone_list) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_list"] = method(undefined, skeleton_slot_list) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_data"] = method(undefined, skeleton_slot_data) } catch (ce_) { skipped = true }
            try { db[$ "skeleton_slot_data_instance"] = method(undefined, skeleton_slot_data_instance) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_id"] = method(undefined, layer_get_id) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_id_at_depth"] = method(undefined, layer_get_id_at_depth) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_depth"] = method(undefined, layer_get_depth) } catch (ce_) { skipped = true }
            try { db[$ "layer_create"] = method(undefined, layer_create) } catch (ce_) { skipped = true }
            try { db[$ "layer_destroy"] = method(undefined, layer_destroy) } catch (ce_) { skipped = true }
            try { db[$ "layer_destroy_instances"] = method(undefined, layer_destroy_instances) } catch (ce_) { skipped = true }
            try { db[$ "layer_add_instance"] = method(undefined, layer_add_instance) } catch (ce_) { skipped = true }
            try { db[$ "layer_has_instance"] = method(undefined, layer_has_instance) } catch (ce_) { skipped = true }
            try { db[$ "layer_set_visible"] = method(undefined, layer_set_visible) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_visible"] = method(undefined, layer_get_visible) } catch (ce_) { skipped = true }
            try { db[$ "layer_exists"] = method(undefined, layer_exists) } catch (ce_) { skipped = true }
            try { db[$ "layer_x"] = method(undefined, layer_x) } catch (ce_) { skipped = true }
            try { db[$ "layer_y"] = method(undefined, layer_y) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_x"] = method(undefined, layer_get_x) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_y"] = method(undefined, layer_get_y) } catch (ce_) { skipped = true }
            try { db[$ "layer_hspeed"] = method(undefined, layer_hspeed) } catch (ce_) { skipped = true }
            try { db[$ "layer_vspeed"] = method(undefined, layer_vspeed) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_hspeed"] = method(undefined, layer_get_hspeed) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_vspeed"] = method(undefined, layer_get_vspeed) } catch (ce_) { skipped = true }
            try { db[$ "layer_script_begin"] = method(undefined, layer_script_begin) } catch (ce_) { skipped = true }
            try { db[$ "layer_script_end"] = method(undefined, layer_script_end) } catch (ce_) { skipped = true }
            try { db[$ "layer_shader"] = method(undefined, layer_shader) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_script_begin"] = method(undefined, layer_get_script_begin) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_script_end"] = method(undefined, layer_get_script_end) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_shader"] = method(undefined, layer_get_shader) } catch (ce_) { skipped = true }
            try { db[$ "layer_set_target_room"] = method(undefined, layer_set_target_room) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_target_room"] = method(undefined, layer_get_target_room) } catch (ce_) { skipped = true }
            try { db[$ "layer_reset_target_room"] = method(undefined, layer_reset_target_room) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_all"] = method(undefined, layer_get_all) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_all_elements"] = method(undefined, layer_get_all_elements) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_name"] = method(undefined, layer_get_name) } catch (ce_) { skipped = true }
            try { db[$ "layer_depth"] = method(undefined, layer_depth) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_element_layer"] = method(undefined, layer_get_element_layer) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_element_type"] = method(undefined, layer_get_element_type) } catch (ce_) { skipped = true }
            try { db[$ "layer_element_move"] = method(undefined, layer_element_move) } catch (ce_) { skipped = true }
            try { db[$ "layer_force_draw_depth"] = method(undefined, layer_force_draw_depth) } catch (ce_) { skipped = true }
            try { db[$ "layer_is_draw_depth_forced"] = method(undefined, layer_is_draw_depth_forced) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_forced_depth"] = method(undefined, layer_get_forced_depth) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_id"] = method(undefined, layer_background_get_id) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_exists"] = method(undefined, layer_background_exists) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_create"] = method(undefined, layer_background_create) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_destroy"] = method(undefined, layer_background_destroy) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_visible"] = method(undefined, layer_background_visible) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_change"] = method(undefined, layer_background_change) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_sprite"] = method(undefined, layer_background_sprite) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_htiled"] = method(undefined, layer_background_htiled) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_vtiled"] = method(undefined, layer_background_vtiled) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_stretch"] = method(undefined, layer_background_stretch) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_yscale"] = method(undefined, layer_background_yscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_xscale"] = method(undefined, layer_background_xscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_blend"] = method(undefined, layer_background_blend) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_alpha"] = method(undefined, layer_background_alpha) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_index"] = method(undefined, layer_background_index) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_speed"] = method(undefined, layer_background_speed) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_visible"] = method(undefined, layer_background_get_visible) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_sprite"] = method(undefined, layer_background_get_sprite) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_htiled"] = method(undefined, layer_background_get_htiled) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_vtiled"] = method(undefined, layer_background_get_vtiled) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_stretch"] = method(undefined, layer_background_get_stretch) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_yscale"] = method(undefined, layer_background_get_yscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_xscale"] = method(undefined, layer_background_get_xscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_blend"] = method(undefined, layer_background_get_blend) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_alpha"] = method(undefined, layer_background_get_alpha) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_index"] = method(undefined, layer_background_get_index) } catch (ce_) { skipped = true }
            try { db[$ "layer_background_get_speed"] = method(undefined, layer_background_get_speed) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_id"] = method(undefined, layer_sprite_get_id) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_exists"] = method(undefined, layer_sprite_exists) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_create"] = method(undefined, layer_sprite_create) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_destroy"] = method(undefined, layer_sprite_destroy) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_change"] = method(undefined, layer_sprite_change) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_index"] = method(undefined, layer_sprite_index) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_speed"] = method(undefined, layer_sprite_speed) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_xscale"] = method(undefined, layer_sprite_xscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_yscale"] = method(undefined, layer_sprite_yscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_angle"] = method(undefined, layer_sprite_angle) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_blend"] = method(undefined, layer_sprite_blend) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_alpha"] = method(undefined, layer_sprite_alpha) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_x"] = method(undefined, layer_sprite_x) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_y"] = method(undefined, layer_sprite_y) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_sprite"] = method(undefined, layer_sprite_get_sprite) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_index"] = method(undefined, layer_sprite_get_index) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_speed"] = method(undefined, layer_sprite_get_speed) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_xscale"] = method(undefined, layer_sprite_get_xscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_yscale"] = method(undefined, layer_sprite_get_yscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_angle"] = method(undefined, layer_sprite_get_angle) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_blend"] = method(undefined, layer_sprite_get_blend) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_alpha"] = method(undefined, layer_sprite_get_alpha) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_x"] = method(undefined, layer_sprite_get_x) } catch (ce_) { skipped = true }
            try { db[$ "layer_sprite_get_y"] = method(undefined, layer_sprite_get_y) } catch (ce_) { skipped = true }
            try { db[$ "layer_tilemap_get_id"] = method(undefined, layer_tilemap_get_id) } catch (ce_) { skipped = true }
            try { db[$ "layer_tilemap_exists"] = method(undefined, layer_tilemap_exists) } catch (ce_) { skipped = true }
            try { db[$ "layer_tilemap_create"] = method(undefined, layer_tilemap_create) } catch (ce_) { skipped = true }
            try { db[$ "layer_tilemap_destroy"] = method(undefined, layer_tilemap_destroy) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_tileset"] = method(undefined, tilemap_tileset) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_x"] = method(undefined, tilemap_x) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_y"] = method(undefined, tilemap_y) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_set"] = method(undefined, tilemap_set) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_set_at_pixel"] = method(undefined, tilemap_set_at_pixel) } catch (ce_) { skipped = true }
            try { db[$ "tileset_get_texture"] = method(undefined, tileset_get_texture) } catch (ce_) { skipped = true }
            try { db[$ "tileset_get_uvs"] = method(undefined, tileset_get_uvs) } catch (ce_) { skipped = true }
            try { db[$ "tileset_get_name"] = method(undefined, tileset_get_name) } catch (ce_) { skipped = true }
            try { db[$ "tileset_get_info"] = method(undefined, tileset_get_info) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_tileset"] = method(undefined, tilemap_get_tileset) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_tile_width"] = method(undefined, tilemap_get_tile_width) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_tile_height"] = method(undefined, tilemap_get_tile_height) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_width"] = method(undefined, tilemap_get_width) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_height"] = method(undefined, tilemap_get_height) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_set_width"] = method(undefined, tilemap_set_width) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_set_height"] = method(undefined, tilemap_set_height) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_x"] = method(undefined, tilemap_get_x) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_y"] = method(undefined, tilemap_get_y) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get"] = method(undefined, tilemap_get) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_at_pixel"] = method(undefined, tilemap_get_at_pixel) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_cell_x_at_pixel"] = method(undefined, tilemap_get_cell_x_at_pixel) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_cell_y_at_pixel"] = method(undefined, tilemap_get_cell_y_at_pixel) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_clear"] = method(undefined, tilemap_clear) } catch (ce_) { skipped = true }
            try { db[$ "draw_tilemap"] = method(undefined, draw_tilemap) } catch (ce_) { skipped = true }
            try { db[$ "draw_tile"] = method(undefined, draw_tile) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_set_global_mask"] = method(undefined, tilemap_set_global_mask) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_global_mask"] = method(undefined, tilemap_get_global_mask) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_set_mask"] = method(undefined, tilemap_set_mask) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_mask"] = method(undefined, tilemap_get_mask) } catch (ce_) { skipped = true }
            try { db[$ "tilemap_get_frame"] = method(undefined, tilemap_get_frame) } catch (ce_) { skipped = true }
            try { db[$ "tile_set_empty"] = method(undefined, tile_set_empty) } catch (ce_) { skipped = true }
            try { db[$ "tile_set_index"] = method(undefined, tile_set_index) } catch (ce_) { skipped = true }
            try { db[$ "tile_set_flip"] = method(undefined, tile_set_flip) } catch (ce_) { skipped = true }
            try { db[$ "tile_set_mirror"] = method(undefined, tile_set_mirror) } catch (ce_) { skipped = true }
            try { db[$ "tile_set_rotate"] = method(undefined, tile_set_rotate) } catch (ce_) { skipped = true }
            try { db[$ "tile_get_empty"] = method(undefined, tile_get_empty) } catch (ce_) { skipped = true }
            try { db[$ "tile_get_index"] = method(undefined, tile_get_index) } catch (ce_) { skipped = true }
            try { db[$ "tile_get_flip"] = method(undefined, tile_get_flip) } catch (ce_) { skipped = true }
            try { db[$ "tile_get_mirror"] = method(undefined, tile_get_mirror) } catch (ce_) { skipped = true }
            try { db[$ "tile_get_rotate"] = method(undefined, tile_get_rotate) } catch (ce_) { skipped = true }
            try { db[$ "layer_instance_get_instance"] = method(undefined, layer_instance_get_instance) } catch (ce_) { skipped = true }
            try { db[$ "instance_activate_layer"] = method(undefined, instance_activate_layer) } catch (ce_) { skipped = true }
            try { db[$ "instance_deactivate_layer"] = method(undefined, instance_deactivate_layer) } catch (ce_) { skipped = true }
            try { db[$ "camera_create"] = method(undefined, camera_create) } catch (ce_) { skipped = true }
            try { db[$ "camera_create_view"] = method(undefined, camera_create_view) } catch (ce_) { skipped = true }
            try { db[$ "camera_destroy"] = method(undefined, camera_destroy) } catch (ce_) { skipped = true }
            try { db[$ "camera_apply"] = method(undefined, camera_apply) } catch (ce_) { skipped = true }
            try { db[$ "camera_copy_transforms"] = method(undefined, camera_copy_transforms) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_active"] = method(undefined, camera_get_active) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_default"] = method(undefined, camera_get_default) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_default"] = method(undefined, camera_set_default) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_mat"] = method(undefined, camera_set_view_mat) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_proj_mat"] = method(undefined, camera_set_proj_mat) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_update_script"] = method(undefined, camera_set_update_script) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_begin_script"] = method(undefined, camera_set_begin_script) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_end_script"] = method(undefined, camera_set_end_script) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_pos"] = method(undefined, camera_set_view_pos) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_size"] = method(undefined, camera_set_view_size) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_speed"] = method(undefined, camera_set_view_speed) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_border"] = method(undefined, camera_set_view_border) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_angle"] = method(undefined, camera_set_view_angle) } catch (ce_) { skipped = true }
            try { db[$ "camera_set_view_target"] = method(undefined, camera_set_view_target) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_mat"] = method(undefined, camera_get_view_mat) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_proj_mat"] = method(undefined, camera_get_proj_mat) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_update_script"] = method(undefined, camera_get_update_script) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_begin_script"] = method(undefined, camera_get_begin_script) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_end_script"] = method(undefined, camera_get_end_script) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_x"] = method(undefined, camera_get_view_x) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_y"] = method(undefined, camera_get_view_y) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_width"] = method(undefined, camera_get_view_width) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_height"] = method(undefined, camera_get_view_height) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_speed_x"] = method(undefined, camera_get_view_speed_x) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_speed_y"] = method(undefined, camera_get_view_speed_y) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_border_x"] = method(undefined, camera_get_view_border_x) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_border_y"] = method(undefined, camera_get_view_border_y) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_angle"] = method(undefined, camera_get_view_angle) } catch (ce_) { skipped = true }
            try { db[$ "camera_get_view_target"] = method(undefined, camera_get_view_target) } catch (ce_) { skipped = true }
            try { db[$ "view_get_camera"] = method(undefined, view_get_camera) } catch (ce_) { skipped = true }
            try { db[$ "view_get_visible"] = method(undefined, view_get_visible) } catch (ce_) { skipped = true }
            try { db[$ "view_get_xport"] = method(undefined, view_get_xport) } catch (ce_) { skipped = true }
            try { db[$ "view_get_yport"] = method(undefined, view_get_yport) } catch (ce_) { skipped = true }
            try { db[$ "view_get_wport"] = method(undefined, view_get_wport) } catch (ce_) { skipped = true }
            try { db[$ "view_get_hport"] = method(undefined, view_get_hport) } catch (ce_) { skipped = true }
            try { db[$ "view_get_surface_id"] = method(undefined, view_get_surface_id) } catch (ce_) { skipped = true }
            try { db[$ "view_set_camera"] = method(undefined, view_set_camera) } catch (ce_) { skipped = true }
            try { db[$ "view_set_visible"] = method(undefined, view_set_visible) } catch (ce_) { skipped = true }
            try { db[$ "view_set_xport"] = method(undefined, view_set_xport) } catch (ce_) { skipped = true }
            try { db[$ "view_set_yport"] = method(undefined, view_set_yport) } catch (ce_) { skipped = true }
            try { db[$ "view_set_wport"] = method(undefined, view_set_wport) } catch (ce_) { skipped = true }
            try { db[$ "view_set_hport"] = method(undefined, view_set_hport) } catch (ce_) { skipped = true }
            try { db[$ "view_set_surface_id"] = method(undefined, view_set_surface_id) } catch (ce_) { skipped = true }
            try { db[$ "gesture_drag_time"] = method(undefined, gesture_drag_time) } catch (ce_) { skipped = true }
            try { db[$ "gesture_drag_distance"] = method(undefined, gesture_drag_distance) } catch (ce_) { skipped = true }
            try { db[$ "gesture_flick_speed"] = method(undefined, gesture_flick_speed) } catch (ce_) { skipped = true }
            try { db[$ "gesture_double_tap_time"] = method(undefined, gesture_double_tap_time) } catch (ce_) { skipped = true }
            try { db[$ "gesture_double_tap_distance"] = method(undefined, gesture_double_tap_distance) } catch (ce_) { skipped = true }
            try { db[$ "gesture_pinch_distance"] = method(undefined, gesture_pinch_distance) } catch (ce_) { skipped = true }
            try { db[$ "gesture_pinch_angle_towards"] = method(undefined, gesture_pinch_angle_towards) } catch (ce_) { skipped = true }
            try { db[$ "gesture_pinch_angle_away"] = method(undefined, gesture_pinch_angle_away) } catch (ce_) { skipped = true }
            try { db[$ "gesture_rotate_time"] = method(undefined, gesture_rotate_time) } catch (ce_) { skipped = true }
            try { db[$ "gesture_rotate_angle"] = method(undefined, gesture_rotate_angle) } catch (ce_) { skipped = true }
            try { db[$ "gesture_tap_count"] = method(undefined, gesture_tap_count) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_drag_time"] = method(undefined, gesture_get_drag_time) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_drag_distance"] = method(undefined, gesture_get_drag_distance) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_flick_speed"] = method(undefined, gesture_get_flick_speed) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_double_tap_time"] = method(undefined, gesture_get_double_tap_time) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_double_tap_distance"] = method(undefined, gesture_get_double_tap_distance) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_pinch_distance"] = method(undefined, gesture_get_pinch_distance) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_pinch_angle_towards"] = method(undefined, gesture_get_pinch_angle_towards) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_pinch_angle_away"] = method(undefined, gesture_get_pinch_angle_away) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_rotate_time"] = method(undefined, gesture_get_rotate_time) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_rotate_angle"] = method(undefined, gesture_get_rotate_angle) } catch (ce_) { skipped = true }
            try { db[$ "gesture_get_tap_count"] = method(undefined, gesture_get_tap_count) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_virtual_show"] = method(undefined, keyboard_virtual_show) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_virtual_hide"] = method(undefined, keyboard_virtual_hide) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_virtual_status"] = method(undefined, keyboard_virtual_status) } catch (ce_) { skipped = true }
            try { db[$ "keyboard_virtual_height"] = method(undefined, keyboard_virtual_height) } catch (ce_) { skipped = true }
            try { db[$ "tag_get_asset_ids"] = method(undefined, tag_get_asset_ids) } catch (ce_) { skipped = true }
            try { db[$ "tag_get_assets"] = method(undefined, tag_get_assets) } catch (ce_) { skipped = true }
            try { db[$ "asset_get_tags"] = method(undefined, asset_get_tags) } catch (ce_) { skipped = true }
            try { db[$ "asset_add_tags"] = method(undefined, asset_add_tags) } catch (ce_) { skipped = true }
            try { db[$ "asset_remove_tags"] = method(undefined, asset_remove_tags) } catch (ce_) { skipped = true }
            try { db[$ "asset_has_tags"] = method(undefined, asset_has_tags) } catch (ce_) { skipped = true }
            try { db[$ "asset_has_any_tag"] = method(undefined, asset_has_any_tag) } catch (ce_) { skipped = true }
            try { db[$ "asset_clear_tags"] = method(undefined, asset_clear_tags) } catch (ce_) { skipped = true }
            try { db[$ "extension_exists"] = method(undefined, extension_exists) } catch (ce_) { skipped = true }
            try { db[$ "extension_get_version"] = method(undefined, extension_get_version) } catch (ce_) { skipped = true }
            try { db[$ "extension_get_option_count"] = method(undefined, extension_get_option_count) } catch (ce_) { skipped = true }
            try { db[$ "extension_get_option_names"] = method(undefined, extension_get_option_names) } catch (ce_) { skipped = true }
            try { db[$ "extension_get_option_value"] = method(undefined, extension_get_option_value) } catch (ce_) { skipped = true }
            try { db[$ "extension_get_options"] = method(undefined, extension_get_options) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_instance"] = method(undefined, layer_sequence_get_instance) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_create"] = method(undefined, layer_sequence_create) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_destroy"] = method(undefined, layer_sequence_destroy) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_exists"] = method(undefined, layer_sequence_exists) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_x"] = method(undefined, layer_sequence_x) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_y"] = method(undefined, layer_sequence_y) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_angle"] = method(undefined, layer_sequence_angle) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_xscale"] = method(undefined, layer_sequence_xscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_yscale"] = method(undefined, layer_sequence_yscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_headpos"] = method(undefined, layer_sequence_headpos) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_headdir"] = method(undefined, layer_sequence_headdir) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_pause"] = method(undefined, layer_sequence_pause) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_play"] = method(undefined, layer_sequence_play) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_speedscale"] = method(undefined, layer_sequence_speedscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_x"] = method(undefined, layer_sequence_get_x) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_y"] = method(undefined, layer_sequence_get_y) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_angle"] = method(undefined, layer_sequence_get_angle) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_xscale"] = method(undefined, layer_sequence_get_xscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_yscale"] = method(undefined, layer_sequence_get_yscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_headpos"] = method(undefined, layer_sequence_get_headpos) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_headdir"] = method(undefined, layer_sequence_get_headdir) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_sequence"] = method(undefined, layer_sequence_get_sequence) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_is_paused"] = method(undefined, layer_sequence_is_paused) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_is_finished"] = method(undefined, layer_sequence_is_finished) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_speedscale"] = method(undefined, layer_sequence_get_speedscale) } catch (ce_) { skipped = true }
            try { db[$ "layer_sequence_get_length"] = method(undefined, layer_sequence_get_length) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_get"] = method(undefined, animcurve_get) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_get_channel"] = method(undefined, animcurve_get_channel) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_get_channel_index"] = method(undefined, animcurve_get_channel_index) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_channel_evaluate"] = method(undefined, animcurve_channel_evaluate) } catch (ce_) { skipped = true }
            try { db[$ "sequence_create"] = method(undefined, sequence_create) } catch (ce_) { skipped = true }
            try { db[$ "sequence_destroy"] = method(undefined, sequence_destroy) } catch (ce_) { skipped = true }
            try { db[$ "sequence_exists"] = method(undefined, sequence_exists) } catch (ce_) { skipped = true }
            try { db[$ "sequence_get"] = method(undefined, sequence_get) } catch (ce_) { skipped = true }
            try { db[$ "sequence_keyframe_new"] = method(undefined, sequence_keyframe_new) } catch (ce_) { skipped = true }
            try { db[$ "sequence_keyframedata_new"] = method(undefined, sequence_keyframedata_new) } catch (ce_) { skipped = true }
            try { db[$ "sequence_track_new"] = method(undefined, sequence_track_new) } catch (ce_) { skipped = true }
            try { db[$ "sequence_get_objects"] = method(undefined, sequence_get_objects) } catch (ce_) { skipped = true }
            try { db[$ "sequence_instance_override_object"] = method(undefined, sequence_instance_override_object) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_create"] = method(undefined, animcurve_create) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_destroy"] = method(undefined, animcurve_destroy) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_exists"] = method(undefined, animcurve_exists) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_channel_new"] = method(undefined, animcurve_channel_new) } catch (ce_) { skipped = true }
            try { db[$ "animcurve_point_new"] = method(undefined, animcurve_point_new) } catch (ce_) { skipped = true }
            try { db[$ "fx_create"] = method(undefined, fx_create) } catch (ce_) { skipped = true }
            try { db[$ "fx_get_name"] = method(undefined, fx_get_name) } catch (ce_) { skipped = true }
            try { db[$ "fx_get_parameter_names"] = method(undefined, fx_get_parameter_names) } catch (ce_) { skipped = true }
            try { db[$ "fx_get_parameter"] = method(undefined, fx_get_parameter) } catch (ce_) { skipped = true }
            try { db[$ "fx_get_parameters"] = method(undefined, fx_get_parameters) } catch (ce_) { skipped = true }
            try { db[$ "fx_get_single_layer"] = method(undefined, fx_get_single_layer) } catch (ce_) { skipped = true }
            try { db[$ "fx_set_parameter"] = method(undefined, fx_set_parameter) } catch (ce_) { skipped = true }
            try { db[$ "fx_set_parameters"] = method(undefined, fx_set_parameters) } catch (ce_) { skipped = true }
            try { db[$ "fx_set_single_layer"] = method(undefined, fx_set_single_layer) } catch (ce_) { skipped = true }
            try { db[$ "layer_set_fx"] = method(undefined, layer_set_fx) } catch (ce_) { skipped = true }
            try { db[$ "layer_get_fx"] = method(undefined, layer_get_fx) } catch (ce_) { skipped = true }
            try { db[$ "layer_clear_fx"] = method(undefined, layer_clear_fx) } catch (ce_) { skipped = true }
            try { db[$ "layer_enable_fx"] = method(undefined, layer_enable_fx) } catch (ce_) { skipped = true }
            try { db[$ "layer_fx_is_enabled"] = method(undefined, layer_fx_is_enabled) } catch (ce_) { skipped = true }
            try { db[$ "gc_collect"] = method(undefined, gc_collect) } catch (ce_) { skipped = true }
            try { db[$ "gc_enable"] = method(undefined, gc_enable) } catch (ce_) { skipped = true }
            try { db[$ "gc_is_enabled"] = method(undefined, gc_is_enabled) } catch (ce_) { skipped = true }
            try { db[$ "gc_get_stats"] = method(undefined, gc_get_stats) } catch (ce_) { skipped = true }
            try { db[$ "gc_target_frame_time"] = method(undefined, gc_target_frame_time) } catch (ce_) { skipped = true }
            try { db[$ "gc_get_target_frame_time"] = method(undefined, gc_get_target_frame_time) } catch (ce_) { skipped = true }
            try { db[$ "weak_ref_create"] = method(undefined, weak_ref_create) } catch (ce_) { skipped = true }
            try { db[$ "weak_ref_alive"] = method(undefined, weak_ref_alive) } catch (ce_) { skipped = true }
            try { db[$ "weak_ref_any_alive"] = method(undefined, weak_ref_any_alive) } catch (ce_) { skipped = true }
            try { db[$ "time_source_create"] = method(undefined, time_source_create) } catch (ce_) { skipped = true }
            try { db[$ "time_source_destroy"] = method(undefined, time_source_destroy) } catch (ce_) { skipped = true }
            try { db[$ "time_source_start"] = method(undefined, time_source_start) } catch (ce_) { skipped = true }
            try { db[$ "time_source_stop"] = method(undefined, time_source_stop) } catch (ce_) { skipped = true }
            try { db[$ "time_source_pause"] = method(undefined, time_source_pause) } catch (ce_) { skipped = true }
            try { db[$ "time_source_resume"] = method(undefined, time_source_resume) } catch (ce_) { skipped = true }
            try { db[$ "time_source_reset"] = method(undefined, time_source_reset) } catch (ce_) { skipped = true }
            try { db[$ "time_source_reconfigure"] = method(undefined, time_source_reconfigure) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_period"] = method(undefined, time_source_get_period) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_reps_completed"] = method(undefined, time_source_get_reps_completed) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_reps_remaining"] = method(undefined, time_source_get_reps_remaining) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_units"] = method(undefined, time_source_get_units) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_time_remaining"] = method(undefined, time_source_get_time_remaining) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_state"] = method(undefined, time_source_get_state) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_parent"] = method(undefined, time_source_get_parent) } catch (ce_) { skipped = true }
            try { db[$ "time_source_get_children"] = method(undefined, time_source_get_children) } catch (ce_) { skipped = true }
            try { db[$ "time_source_exists"] = method(undefined, time_source_exists) } catch (ce_) { skipped = true }
            try { db[$ "time_seconds_to_bpm"] = method(undefined, time_seconds_to_bpm) } catch (ce_) { skipped = true }
            try { db[$ "time_bpm_to_seconds"] = method(undefined, time_bpm_to_seconds) } catch (ce_) { skipped = true }
            try { db[$ "call_later"] = method(undefined, call_later) } catch (ce_) { skipped = true }
            try { db[$ "call_cancel"] = method(undefined, call_cancel) } catch (ce_) { skipped = true }
            try { db[$ "audio_bus_create"] = method(undefined, audio_bus_create) } catch (ce_) { skipped = true }
            try { db[$ "audio_effect_create"] = method(undefined, audio_effect_create) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_bus"] = method(undefined, audio_emitter_bus) } catch (ce_) { skipped = true }
            try { db[$ "audio_emitter_get_bus"] = method(undefined, audio_emitter_get_bus) } catch (ce_) { skipped = true }
            try { db[$ "audio_bus_get_emitters"] = method(undefined, audio_bus_get_emitters) } catch (ce_) { skipped = true }
            try { db[$ "audio_bus_clear_emitters"] = method(undefined, audio_bus_clear_emitters) } catch (ce_) { skipped = true }
            try { db[$ "lin_to_db"] = method(undefined, lin_to_db) } catch (ce_) { skipped = true }
            try { db[$ "db_to_lin"] = method(undefined, db_to_lin) } catch (ce_) { skipped = true }
            try { db[$ "all"] = all } catch (ce_) { skipped = true }
            try { db[$ "noone"] = noone } catch (ce_) { skipped = true }
            try { db[$ "global"] = catspeak_special_to_struct(global) } catch (ce_) { skipped = true }
            try { db[$ "undefined"] = undefined } catch (ce_) { skipped = true }
            try { db[$ "pointer_invalid"] = pointer_invalid } catch (ce_) { skipped = true }
            try { db[$ "pointer_null"] = pointer_null } catch (ce_) { skipped = true }
            try { db[$ "path_action_stop"] = path_action_stop } catch (ce_) { skipped = true }
            try { db[$ "path_action_restart"] = path_action_restart } catch (ce_) { skipped = true }
            try { db[$ "path_action_continue"] = path_action_continue } catch (ce_) { skipped = true }
            try { db[$ "path_action_reverse"] = path_action_reverse } catch (ce_) { skipped = true }
            try { db[$ "true"] = true } catch (ce_) { skipped = true }
            try { db[$ "false"] = false } catch (ce_) { skipped = true }
            try { db[$ "pi"] = pi } catch (ce_) { skipped = true }
            try { db[$ "NaN"] = NaN } catch (ce_) { skipped = true }
            try { db[$ "infinity"] = infinity } catch (ce_) { skipped = true }
            try { db[$ "GM_build_date"] = GM_build_date } catch (ce_) { skipped = true }
            try { db[$ "GM_version"] = GM_version } catch (ce_) { skipped = true }
            try { db[$ "GM_runtime_version"] = GM_runtime_version } catch (ce_) { skipped = true }
            try { db[$ "GM_project_filename"] = GM_project_filename } catch (ce_) { skipped = true }
            try { db[$ "GM_build_type"] = GM_build_type } catch (ce_) { skipped = true }
            try { db[$ "GM_is_sandboxed"] = GM_is_sandboxed } catch (ce_) { skipped = true }
            try { db[$ "_GMLINE_"] = _GMLINE_ } catch (ce_) { skipped = true }
            try { db[$ "_GMFILE_"] = _GMFILE_ } catch (ce_) { skipped = true }
            try { db[$ "_GMFUNCTION_"] = _GMFUNCTION_ } catch (ce_) { skipped = true }
            try { db[$ "timezone_local"] = timezone_local } catch (ce_) { skipped = true }
            try { db[$ "timezone_utc"] = timezone_utc } catch (ce_) { skipped = true }
            try { db[$ "gamespeed_fps"] = gamespeed_fps } catch (ce_) { skipped = true }
            try { db[$ "gamespeed_microseconds"] = gamespeed_microseconds } catch (ce_) { skipped = true }
            try { db[$ "ev_create"] = ev_create } catch (ce_) { skipped = true }
            try { db[$ "ev_pre_create"] = ev_pre_create } catch (ce_) { skipped = true }
            try { db[$ "ev_destroy"] = ev_destroy } catch (ce_) { skipped = true }
            try { db[$ "ev_step"] = ev_step } catch (ce_) { skipped = true }
            try { db[$ "ev_alarm"] = ev_alarm } catch (ce_) { skipped = true }
            try { db[$ "ev_keyboard"] = ev_keyboard } catch (ce_) { skipped = true }
            try { db[$ "ev_mouse"] = ev_mouse } catch (ce_) { skipped = true }
            try { db[$ "ev_collision"] = ev_collision } catch (ce_) { skipped = true }
            try { db[$ "ev_other"] = ev_other } catch (ce_) { skipped = true }
            try { db[$ "ev_draw"] = ev_draw } catch (ce_) { skipped = true }
            try { db[$ "ev_draw_begin"] = ev_draw_begin } catch (ce_) { skipped = true }
            try { db[$ "ev_draw_end"] = ev_draw_end } catch (ce_) { skipped = true }
            try { db[$ "ev_draw_pre"] = ev_draw_pre } catch (ce_) { skipped = true }
            try { db[$ "ev_draw_post"] = ev_draw_post } catch (ce_) { skipped = true }
            try { db[$ "ev_draw_normal"] = ev_draw_normal } catch (ce_) { skipped = true }
            try { db[$ "ev_keypress"] = ev_keypress } catch (ce_) { skipped = true }
            try { db[$ "ev_keyrelease"] = ev_keyrelease } catch (ce_) { skipped = true }
            try { db[$ "ev_trigger"] = ev_trigger } catch (ce_) { skipped = true }
            try { db[$ "ev_left_button"] = ev_left_button } catch (ce_) { skipped = true }
            try { db[$ "ev_right_button"] = ev_right_button } catch (ce_) { skipped = true }
            try { db[$ "ev_middle_button"] = ev_middle_button } catch (ce_) { skipped = true }
            try { db[$ "ev_no_button"] = ev_no_button } catch (ce_) { skipped = true }
            try { db[$ "ev_left_press"] = ev_left_press } catch (ce_) { skipped = true }
            try { db[$ "ev_right_press"] = ev_right_press } catch (ce_) { skipped = true }
            try { db[$ "ev_middle_press"] = ev_middle_press } catch (ce_) { skipped = true }
            try { db[$ "ev_left_release"] = ev_left_release } catch (ce_) { skipped = true }
            try { db[$ "ev_right_release"] = ev_right_release } catch (ce_) { skipped = true }
            try { db[$ "ev_middle_release"] = ev_middle_release } catch (ce_) { skipped = true }
            try { db[$ "ev_mouse_enter"] = ev_mouse_enter } catch (ce_) { skipped = true }
            try { db[$ "ev_mouse_leave"] = ev_mouse_leave } catch (ce_) { skipped = true }
            try { db[$ "ev_mouse_wheel_up"] = ev_mouse_wheel_up } catch (ce_) { skipped = true }
            try { db[$ "ev_mouse_wheel_down"] = ev_mouse_wheel_down } catch (ce_) { skipped = true }
            try { db[$ "ev_global_left_button"] = ev_global_left_button } catch (ce_) { skipped = true }
            try { db[$ "ev_global_right_button"] = ev_global_right_button } catch (ce_) { skipped = true }
            try { db[$ "ev_global_middle_button"] = ev_global_middle_button } catch (ce_) { skipped = true }
            try { db[$ "ev_global_left_press"] = ev_global_left_press } catch (ce_) { skipped = true }
            try { db[$ "ev_global_right_press"] = ev_global_right_press } catch (ce_) { skipped = true }
            try { db[$ "ev_global_middle_press"] = ev_global_middle_press } catch (ce_) { skipped = true }
            try { db[$ "ev_global_left_release"] = ev_global_left_release } catch (ce_) { skipped = true }
            try { db[$ "ev_global_right_release"] = ev_global_right_release } catch (ce_) { skipped = true }
            try { db[$ "ev_global_middle_release"] = ev_global_middle_release } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_left"] = ev_joystick1_left } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_right"] = ev_joystick1_right } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_up"] = ev_joystick1_up } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_down"] = ev_joystick1_down } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button1"] = ev_joystick1_button1 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button2"] = ev_joystick1_button2 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button3"] = ev_joystick1_button3 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button4"] = ev_joystick1_button4 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button5"] = ev_joystick1_button5 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button6"] = ev_joystick1_button6 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button7"] = ev_joystick1_button7 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick1_button8"] = ev_joystick1_button8 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_left"] = ev_joystick2_left } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_right"] = ev_joystick2_right } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_up"] = ev_joystick2_up } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_down"] = ev_joystick2_down } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button1"] = ev_joystick2_button1 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button2"] = ev_joystick2_button2 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button3"] = ev_joystick2_button3 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button4"] = ev_joystick2_button4 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button5"] = ev_joystick2_button5 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button6"] = ev_joystick2_button6 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button7"] = ev_joystick2_button7 } catch (ce_) { skipped = true }
            try { db[$ "ev_joystick2_button8"] = ev_joystick2_button8 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside"] = ev_outside } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary"] = ev_boundary } catch (ce_) { skipped = true }
            try { db[$ "ev_game_start"] = ev_game_start } catch (ce_) { skipped = true }
            try { db[$ "ev_game_end"] = ev_game_end } catch (ce_) { skipped = true }
            try { db[$ "ev_room_start"] = ev_room_start } catch (ce_) { skipped = true }
            try { db[$ "ev_room_end"] = ev_room_end } catch (ce_) { skipped = true }
            try { db[$ "ev_no_more_lives"] = ev_no_more_lives } catch (ce_) { skipped = true }
            try { db[$ "ev_animation_end"] = ev_animation_end } catch (ce_) { skipped = true }
            try { db[$ "ev_end_of_path"] = ev_end_of_path } catch (ce_) { skipped = true }
            try { db[$ "ev_no_more_health"] = ev_no_more_health } catch (ce_) { skipped = true }
            try { db[$ "ev_user0"] = ev_user0 } catch (ce_) { skipped = true }
            try { db[$ "ev_user1"] = ev_user1 } catch (ce_) { skipped = true }
            try { db[$ "ev_user2"] = ev_user2 } catch (ce_) { skipped = true }
            try { db[$ "ev_user3"] = ev_user3 } catch (ce_) { skipped = true }
            try { db[$ "ev_user4"] = ev_user4 } catch (ce_) { skipped = true }
            try { db[$ "ev_user5"] = ev_user5 } catch (ce_) { skipped = true }
            try { db[$ "ev_user6"] = ev_user6 } catch (ce_) { skipped = true }
            try { db[$ "ev_user7"] = ev_user7 } catch (ce_) { skipped = true }
            try { db[$ "ev_user8"] = ev_user8 } catch (ce_) { skipped = true }
            try { db[$ "ev_user9"] = ev_user9 } catch (ce_) { skipped = true }
            try { db[$ "ev_user10"] = ev_user10 } catch (ce_) { skipped = true }
            try { db[$ "ev_user11"] = ev_user11 } catch (ce_) { skipped = true }
            try { db[$ "ev_user12"] = ev_user12 } catch (ce_) { skipped = true }
            try { db[$ "ev_user13"] = ev_user13 } catch (ce_) { skipped = true }
            try { db[$ "ev_user14"] = ev_user14 } catch (ce_) { skipped = true }
            try { db[$ "ev_user15"] = ev_user15 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view0"] = ev_outside_view0 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view1"] = ev_outside_view1 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view2"] = ev_outside_view2 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view3"] = ev_outside_view3 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view4"] = ev_outside_view4 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view5"] = ev_outside_view5 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view6"] = ev_outside_view6 } catch (ce_) { skipped = true }
            try { db[$ "ev_outside_view7"] = ev_outside_view7 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view0"] = ev_boundary_view0 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view1"] = ev_boundary_view1 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view2"] = ev_boundary_view2 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view3"] = ev_boundary_view3 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view4"] = ev_boundary_view4 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view5"] = ev_boundary_view5 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view6"] = ev_boundary_view6 } catch (ce_) { skipped = true }
            try { db[$ "ev_boundary_view7"] = ev_boundary_view7 } catch (ce_) { skipped = true }
            try { db[$ "ev_animation_update"] = ev_animation_update } catch (ce_) { skipped = true }
            try { db[$ "ev_animation_event"] = ev_animation_event } catch (ce_) { skipped = true }
            try { db[$ "ev_web_image_load"] = ev_web_image_load } catch (ce_) { skipped = true }
            try { db[$ "ev_web_sound_load"] = ev_web_sound_load } catch (ce_) { skipped = true }
            try { db[$ "ev_web_async"] = ev_web_async } catch (ce_) { skipped = true }
            try { db[$ "ev_dialog_async"] = ev_dialog_async } catch (ce_) { skipped = true }
            try { db[$ "ev_web_iap"] = ev_web_iap } catch (ce_) { skipped = true }
            try { db[$ "ev_web_cloud"] = ev_web_cloud } catch (ce_) { skipped = true }
            try { db[$ "ev_web_networking"] = ev_web_networking } catch (ce_) { skipped = true }
            try { db[$ "ev_web_steam"] = ev_web_steam } catch (ce_) { skipped = true }
            try { db[$ "ev_social"] = ev_social } catch (ce_) { skipped = true }
            try { db[$ "ev_push_notification"] = ev_push_notification } catch (ce_) { skipped = true }
            try { db[$ "ev_async_save_load"] = ev_async_save_load } catch (ce_) { skipped = true }
            try { db[$ "ev_audio_recording"] = ev_audio_recording } catch (ce_) { skipped = true }
            try { db[$ "ev_audio_playback"] = ev_audio_playback } catch (ce_) { skipped = true }
            try { db[$ "ev_audio_playback_ended"] = ev_audio_playback_ended } catch (ce_) { skipped = true }
            try { db[$ "ev_system_event"] = ev_system_event } catch (ce_) { skipped = true }
            try { db[$ "ev_broadcast_message"] = ev_broadcast_message } catch (ce_) { skipped = true }
            try { db[$ "ev_step_normal"] = ev_step_normal } catch (ce_) { skipped = true }
            try { db[$ "ev_step_begin"] = ev_step_begin } catch (ce_) { skipped = true }
            try { db[$ "ev_step_end"] = ev_step_end } catch (ce_) { skipped = true }
            try { db[$ "ev_gui"] = ev_gui } catch (ce_) { skipped = true }
            try { db[$ "ev_gui_begin"] = ev_gui_begin } catch (ce_) { skipped = true }
            try { db[$ "ev_gui_end"] = ev_gui_end } catch (ce_) { skipped = true }
            try { db[$ "ev_cleanup"] = ev_cleanup } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture"] = ev_gesture } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_tap"] = ev_gesture_tap } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_double_tap"] = ev_gesture_double_tap } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_drag_start"] = ev_gesture_drag_start } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_dragging"] = ev_gesture_dragging } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_drag_end"] = ev_gesture_drag_end } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_flick"] = ev_gesture_flick } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_pinch_start"] = ev_gesture_pinch_start } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_pinch_in"] = ev_gesture_pinch_in } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_pinch_out"] = ev_gesture_pinch_out } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_pinch_end"] = ev_gesture_pinch_end } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_rotate_start"] = ev_gesture_rotate_start } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_rotating"] = ev_gesture_rotating } catch (ce_) { skipped = true }
            try { db[$ "ev_gesture_rotate_end"] = ev_gesture_rotate_end } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_tap"] = ev_global_gesture_tap } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_double_tap"] = ev_global_gesture_double_tap } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_drag_start"] = ev_global_gesture_drag_start } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_dragging"] = ev_global_gesture_dragging } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_drag_end"] = ev_global_gesture_drag_end } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_flick"] = ev_global_gesture_flick } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_pinch_start"] = ev_global_gesture_pinch_start } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_pinch_in"] = ev_global_gesture_pinch_in } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_pinch_out"] = ev_global_gesture_pinch_out } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_pinch_end"] = ev_global_gesture_pinch_end } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_rotate_start"] = ev_global_gesture_rotate_start } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_rotating"] = ev_global_gesture_rotating } catch (ce_) { skipped = true }
            try { db[$ "ev_global_gesture_rotate_end"] = ev_global_gesture_rotate_end } catch (ce_) { skipped = true }
            try { db[$ "ev_async_web_image_load"] = ev_async_web_image_load } catch (ce_) { skipped = true }
            try { db[$ "ev_async_web"] = ev_async_web } catch (ce_) { skipped = true }
            try { db[$ "ev_async_dialog"] = ev_async_dialog } catch (ce_) { skipped = true }
            try { db[$ "ev_async_web_iap"] = ev_async_web_iap } catch (ce_) { skipped = true }
            try { db[$ "ev_async_web_cloud"] = ev_async_web_cloud } catch (ce_) { skipped = true }
            try { db[$ "ev_async_web_networking"] = ev_async_web_networking } catch (ce_) { skipped = true }
            try { db[$ "ev_async_web_steam"] = ev_async_web_steam } catch (ce_) { skipped = true }
            try { db[$ "ev_async_social"] = ev_async_social } catch (ce_) { skipped = true }
            try { db[$ "ev_async_push_notification"] = ev_async_push_notification } catch (ce_) { skipped = true }
            try { db[$ "ev_async_save_load"] = ev_async_save_load } catch (ce_) { skipped = true }
            try { db[$ "ev_async_audio_recording"] = ev_async_audio_recording } catch (ce_) { skipped = true }
            try { db[$ "ev_async_audio_playback"] = ev_async_audio_playback } catch (ce_) { skipped = true }
            try { db[$ "ev_async_audio_playback_ended"] = ev_async_audio_playback_ended } catch (ce_) { skipped = true }
            try { db[$ "ev_async_system_event"] = ev_async_system_event } catch (ce_) { skipped = true }
            try { db[$ "vk_nokey"] = vk_nokey } catch (ce_) { skipped = true }
            try { db[$ "vk_anykey"] = vk_anykey } catch (ce_) { skipped = true }
            try { db[$ "vk_enter"] = vk_enter } catch (ce_) { skipped = true }
            try { db[$ "vk_return"] = vk_return } catch (ce_) { skipped = true }
            try { db[$ "vk_shift"] = vk_shift } catch (ce_) { skipped = true }
            try { db[$ "vk_control"] = vk_control } catch (ce_) { skipped = true }
            try { db[$ "vk_alt"] = vk_alt } catch (ce_) { skipped = true }
            try { db[$ "vk_escape"] = vk_escape } catch (ce_) { skipped = true }
            try { db[$ "vk_space"] = vk_space } catch (ce_) { skipped = true }
            try { db[$ "vk_backspace"] = vk_backspace } catch (ce_) { skipped = true }
            try { db[$ "vk_tab"] = vk_tab } catch (ce_) { skipped = true }
            try { db[$ "vk_pause"] = vk_pause } catch (ce_) { skipped = true }
            try { db[$ "vk_printscreen"] = vk_printscreen } catch (ce_) { skipped = true }
            try { db[$ "vk_left"] = vk_left } catch (ce_) { skipped = true }
            try { db[$ "vk_right"] = vk_right } catch (ce_) { skipped = true }
            try { db[$ "vk_up"] = vk_up } catch (ce_) { skipped = true }
            try { db[$ "vk_down"] = vk_down } catch (ce_) { skipped = true }
            try { db[$ "vk_home"] = vk_home } catch (ce_) { skipped = true }
            try { db[$ "vk_end"] = vk_end } catch (ce_) { skipped = true }
            try { db[$ "vk_delete"] = vk_delete } catch (ce_) { skipped = true }
            try { db[$ "vk_insert"] = vk_insert } catch (ce_) { skipped = true }
            try { db[$ "vk_pageup"] = vk_pageup } catch (ce_) { skipped = true }
            try { db[$ "vk_pagedown"] = vk_pagedown } catch (ce_) { skipped = true }
            try { db[$ "vk_f1"] = vk_f1 } catch (ce_) { skipped = true }
            try { db[$ "vk_f2"] = vk_f2 } catch (ce_) { skipped = true }
            try { db[$ "vk_f3"] = vk_f3 } catch (ce_) { skipped = true }
            try { db[$ "vk_f4"] = vk_f4 } catch (ce_) { skipped = true }
            try { db[$ "vk_f5"] = vk_f5 } catch (ce_) { skipped = true }
            try { db[$ "vk_f6"] = vk_f6 } catch (ce_) { skipped = true }
            try { db[$ "vk_f7"] = vk_f7 } catch (ce_) { skipped = true }
            try { db[$ "vk_f8"] = vk_f8 } catch (ce_) { skipped = true }
            try { db[$ "vk_f9"] = vk_f9 } catch (ce_) { skipped = true }
            try { db[$ "vk_f10"] = vk_f10 } catch (ce_) { skipped = true }
            try { db[$ "vk_f11"] = vk_f11 } catch (ce_) { skipped = true }
            try { db[$ "vk_f12"] = vk_f12 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad0"] = vk_numpad0 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad1"] = vk_numpad1 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad2"] = vk_numpad2 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad3"] = vk_numpad3 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad4"] = vk_numpad4 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad5"] = vk_numpad5 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad6"] = vk_numpad6 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad7"] = vk_numpad7 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad8"] = vk_numpad8 } catch (ce_) { skipped = true }
            try { db[$ "vk_numpad9"] = vk_numpad9 } catch (ce_) { skipped = true }
            try { db[$ "vk_divide"] = vk_divide } catch (ce_) { skipped = true }
            try { db[$ "vk_multiply"] = vk_multiply } catch (ce_) { skipped = true }
            try { db[$ "vk_subtract"] = vk_subtract } catch (ce_) { skipped = true }
            try { db[$ "vk_add"] = vk_add } catch (ce_) { skipped = true }
            try { db[$ "vk_decimal"] = vk_decimal } catch (ce_) { skipped = true }
            try { db[$ "vk_lshift"] = vk_lshift } catch (ce_) { skipped = true }
            try { db[$ "vk_lcontrol"] = vk_lcontrol } catch (ce_) { skipped = true }
            try { db[$ "vk_lalt"] = vk_lalt } catch (ce_) { skipped = true }
            try { db[$ "vk_rshift"] = vk_rshift } catch (ce_) { skipped = true }
            try { db[$ "vk_rcontrol"] = vk_rcontrol } catch (ce_) { skipped = true }
            try { db[$ "vk_ralt"] = vk_ralt } catch (ce_) { skipped = true }
            try { db[$ "mb_any"] = mb_any } catch (ce_) { skipped = true }
            try { db[$ "mb_none"] = mb_none } catch (ce_) { skipped = true }
            try { db[$ "mb_left"] = mb_left } catch (ce_) { skipped = true }
            try { db[$ "mb_right"] = mb_right } catch (ce_) { skipped = true }
            try { db[$ "mb_middle"] = mb_middle } catch (ce_) { skipped = true }
            try { db[$ "mb_side1"] = mb_side1 } catch (ce_) { skipped = true }
            try { db[$ "mb_side2"] = mb_side2 } catch (ce_) { skipped = true }
            try { db[$ "m_axisx"] = m_axisx } catch (ce_) { skipped = true }
            try { db[$ "m_axisy"] = m_axisy } catch (ce_) { skipped = true }
            try { db[$ "m_axisx_gui"] = m_axisx_gui } catch (ce_) { skipped = true }
            try { db[$ "m_axisy_gui"] = m_axisy_gui } catch (ce_) { skipped = true }
            try { db[$ "m_scroll_up"] = m_scroll_up } catch (ce_) { skipped = true }
            try { db[$ "m_scroll_down"] = m_scroll_down } catch (ce_) { skipped = true }
            try { db[$ "bboxmode_automatic"] = bboxmode_automatic } catch (ce_) { skipped = true }
            try { db[$ "bboxmode_fullimage"] = bboxmode_fullimage } catch (ce_) { skipped = true }
            try { db[$ "bboxmode_manual"] = bboxmode_manual } catch (ce_) { skipped = true }
            try { db[$ "bboxkind_precise"] = bboxkind_precise } catch (ce_) { skipped = true }
            try { db[$ "bboxkind_rectangular"] = bboxkind_rectangular } catch (ce_) { skipped = true }
            try { db[$ "bboxkind_ellipse"] = bboxkind_ellipse } catch (ce_) { skipped = true }
            try { db[$ "bboxkind_diamond"] = bboxkind_diamond } catch (ce_) { skipped = true }
            try { db[$ "c_aqua"] = c_aqua } catch (ce_) { skipped = true }
            try { db[$ "c_black"] = c_black } catch (ce_) { skipped = true }
            try { db[$ "c_blue"] = c_blue } catch (ce_) { skipped = true }
            try { db[$ "c_dkgray"] = c_dkgray } catch (ce_) { skipped = true }
            try { db[$ "c_dkgrey"] = c_dkgrey } catch (ce_) { skipped = true }
            try { db[$ "c_fuchsia"] = c_fuchsia } catch (ce_) { skipped = true }
            try { db[$ "c_gray"] = c_gray } catch (ce_) { skipped = true }
            try { db[$ "c_grey"] = c_grey } catch (ce_) { skipped = true }
            try { db[$ "c_green"] = c_green } catch (ce_) { skipped = true }
            try { db[$ "c_lime"] = c_lime } catch (ce_) { skipped = true }
            try { db[$ "c_ltgray"] = c_ltgray } catch (ce_) { skipped = true }
            try { db[$ "c_ltgrey"] = c_ltgrey } catch (ce_) { skipped = true }
            try { db[$ "c_maroon"] = c_maroon } catch (ce_) { skipped = true }
            try { db[$ "c_navy"] = c_navy } catch (ce_) { skipped = true }
            try { db[$ "c_olive"] = c_olive } catch (ce_) { skipped = true }
            try { db[$ "c_purple"] = c_purple } catch (ce_) { skipped = true }
            try { db[$ "c_red"] = c_red } catch (ce_) { skipped = true }
            try { db[$ "c_silver"] = c_silver } catch (ce_) { skipped = true }
            try { db[$ "c_teal"] = c_teal } catch (ce_) { skipped = true }
            try { db[$ "c_white"] = c_white } catch (ce_) { skipped = true }
            try { db[$ "c_yellow"] = c_yellow } catch (ce_) { skipped = true }
            try { db[$ "c_orange"] = c_orange } catch (ce_) { skipped = true }
            try { db[$ "fa_left"] = fa_left } catch (ce_) { skipped = true }
            try { db[$ "fa_center"] = fa_center } catch (ce_) { skipped = true }
            try { db[$ "fa_right"] = fa_right } catch (ce_) { skipped = true }
            try { db[$ "fa_top"] = fa_top } catch (ce_) { skipped = true }
            try { db[$ "fa_middle"] = fa_middle } catch (ce_) { skipped = true }
            try { db[$ "fa_bottom"] = fa_bottom } catch (ce_) { skipped = true }
            try { db[$ "pr_pointlist"] = pr_pointlist } catch (ce_) { skipped = true }
            try { db[$ "pr_linelist"] = pr_linelist } catch (ce_) { skipped = true }
            try { db[$ "pr_linestrip"] = pr_linestrip } catch (ce_) { skipped = true }
            try { db[$ "pr_trianglelist"] = pr_trianglelist } catch (ce_) { skipped = true }
            try { db[$ "pr_trianglestrip"] = pr_trianglestrip } catch (ce_) { skipped = true }
            try { db[$ "pr_trianglefan"] = pr_trianglefan } catch (ce_) { skipped = true }
            try { db[$ "bm_normal"] = bm_normal } catch (ce_) { skipped = true }
            try { db[$ "bm_add"] = bm_add } catch (ce_) { skipped = true }
            try { db[$ "bm_max"] = bm_max } catch (ce_) { skipped = true }
            try { db[$ "bm_subtract"] = bm_subtract } catch (ce_) { skipped = true }
            try { db[$ "bm_zero"] = bm_zero } catch (ce_) { skipped = true }
            try { db[$ "bm_one"] = bm_one } catch (ce_) { skipped = true }
            try { db[$ "bm_src_colour"] = bm_src_colour } catch (ce_) { skipped = true }
            try { db[$ "bm_inv_src_colour"] = bm_inv_src_colour } catch (ce_) { skipped = true }
            try { db[$ "bm_src_color"] = bm_src_color } catch (ce_) { skipped = true }
            try { db[$ "bm_inv_src_color"] = bm_inv_src_color } catch (ce_) { skipped = true }
            try { db[$ "bm_src_alpha"] = bm_src_alpha } catch (ce_) { skipped = true }
            try { db[$ "bm_inv_src_alpha"] = bm_inv_src_alpha } catch (ce_) { skipped = true }
            try { db[$ "bm_dest_alpha"] = bm_dest_alpha } catch (ce_) { skipped = true }
            try { db[$ "bm_inv_dest_alpha"] = bm_inv_dest_alpha } catch (ce_) { skipped = true }
            try { db[$ "bm_dest_colour"] = bm_dest_colour } catch (ce_) { skipped = true }
            try { db[$ "bm_inv_dest_colour"] = bm_inv_dest_colour } catch (ce_) { skipped = true }
            try { db[$ "bm_dest_color"] = bm_dest_color } catch (ce_) { skipped = true }
            try { db[$ "bm_inv_dest_color"] = bm_inv_dest_color } catch (ce_) { skipped = true }
            try { db[$ "bm_src_alpha_sat"] = bm_src_alpha_sat } catch (ce_) { skipped = true }
            try { db[$ "tf_point"] = tf_point } catch (ce_) { skipped = true }
            try { db[$ "tf_linear"] = tf_linear } catch (ce_) { skipped = true }
            try { db[$ "tf_anisotropic"] = tf_anisotropic } catch (ce_) { skipped = true }
            try { db[$ "mip_off"] = mip_off } catch (ce_) { skipped = true }
            try { db[$ "mip_on"] = mip_on } catch (ce_) { skipped = true }
            try { db[$ "mip_markedonly"] = mip_markedonly } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_none"] = audio_falloff_none } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_inverse_distance"] = audio_falloff_inverse_distance } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_inverse_distance_clamped"] = audio_falloff_inverse_distance_clamped } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_inverse_distance_scaled"] = audio_falloff_inverse_distance_scaled } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_linear_distance"] = audio_falloff_linear_distance } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_linear_distance_clamped"] = audio_falloff_linear_distance_clamped } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_exponent_distance"] = audio_falloff_exponent_distance } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_exponent_distance_clamped"] = audio_falloff_exponent_distance_clamped } catch (ce_) { skipped = true }
            try { db[$ "audio_falloff_exponent_distance_scaled"] = audio_falloff_exponent_distance_scaled } catch (ce_) { skipped = true }
            try { db[$ "audio_mono"] = audio_mono } catch (ce_) { skipped = true }
            try { db[$ "audio_stereo"] = audio_stereo } catch (ce_) { skipped = true }
            try { db[$ "audio_3D"] = audio_3D } catch (ce_) { skipped = true }
            try { db[$ "surface_rgba8unorm"] = surface_rgba8unorm } catch (ce_) { skipped = true }
            try { db[$ "surface_r16float"] = surface_r16float } catch (ce_) { skipped = true }
            try { db[$ "surface_r32float"] = surface_r32float } catch (ce_) { skipped = true }
            try { db[$ "surface_rgba4unorm"] = surface_rgba4unorm } catch (ce_) { skipped = true }
            try { db[$ "surface_r8unorm"] = surface_r8unorm } catch (ce_) { skipped = true }
            try { db[$ "surface_rg8unorm"] = surface_rg8unorm } catch (ce_) { skipped = true }
            try { db[$ "surface_rgba16float"] = surface_rgba16float } catch (ce_) { skipped = true }
            try { db[$ "surface_rgba32float"] = surface_rgba32float } catch (ce_) { skipped = true }
            try { db[$ "video_format_rgba"] = video_format_rgba } catch (ce_) { skipped = true }
            try { db[$ "video_format_yuv"] = video_format_yuv } catch (ce_) { skipped = true }
            try { db[$ "video_status_closed"] = video_status_closed } catch (ce_) { skipped = true }
            try { db[$ "video_status_preparing"] = video_status_preparing } catch (ce_) { skipped = true }
            try { db[$ "video_status_playing"] = video_status_playing } catch (ce_) { skipped = true }
            try { db[$ "video_status_paused"] = video_status_paused } catch (ce_) { skipped = true }
            try { db[$ "cr_default"] = cr_default } catch (ce_) { skipped = true }
            try { db[$ "cr_none"] = cr_none } catch (ce_) { skipped = true }
            try { db[$ "cr_arrow"] = cr_arrow } catch (ce_) { skipped = true }
            try { db[$ "cr_cross"] = cr_cross } catch (ce_) { skipped = true }
            try { db[$ "cr_beam"] = cr_beam } catch (ce_) { skipped = true }
            try { db[$ "cr_size_nesw"] = cr_size_nesw } catch (ce_) { skipped = true }
            try { db[$ "cr_size_ns"] = cr_size_ns } catch (ce_) { skipped = true }
            try { db[$ "cr_size_nwse"] = cr_size_nwse } catch (ce_) { skipped = true }
            try { db[$ "cr_size_we"] = cr_size_we } catch (ce_) { skipped = true }
            try { db[$ "cr_uparrow"] = cr_uparrow } catch (ce_) { skipped = true }
            try { db[$ "cr_hourglass"] = cr_hourglass } catch (ce_) { skipped = true }
            try { db[$ "cr_drag"] = cr_drag } catch (ce_) { skipped = true }
            try { db[$ "cr_appstart"] = cr_appstart } catch (ce_) { skipped = true }
            try { db[$ "cr_handpoint"] = cr_handpoint } catch (ce_) { skipped = true }
            try { db[$ "cr_size_all"] = cr_size_all } catch (ce_) { skipped = true }
            try { db[$ "spritespeed_framespersecond"] = spritespeed_framespersecond } catch (ce_) { skipped = true }
            try { db[$ "spritespeed_framespergameframe"] = spritespeed_framespergameframe } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext_error_unknown"] = sprite_add_ext_error_unknown } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext_error_cancelled"] = sprite_add_ext_error_cancelled } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext_error_spritenotfound"] = sprite_add_ext_error_spritenotfound } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext_error_loadfailed"] = sprite_add_ext_error_loadfailed } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext_error_decompressfailed"] = sprite_add_ext_error_decompressfailed } catch (ce_) { skipped = true }
            try { db[$ "sprite_add_ext_error_setupfailed"] = sprite_add_ext_error_setupfailed } catch (ce_) { skipped = true }
            try { db[$ "asset_object"] = asset_object } catch (ce_) { skipped = true }
            try { db[$ "asset_unknown"] = asset_unknown } catch (ce_) { skipped = true }
            try { db[$ "asset_sprite"] = asset_sprite } catch (ce_) { skipped = true }
            try { db[$ "asset_sound"] = asset_sound } catch (ce_) { skipped = true }
            try { db[$ "asset_room"] = asset_room } catch (ce_) { skipped = true }
            try { db[$ "asset_path"] = asset_path } catch (ce_) { skipped = true }
            try { db[$ "asset_script"] = asset_script } catch (ce_) { skipped = true }
            try { db[$ "asset_font"] = asset_font } catch (ce_) { skipped = true }
            try { db[$ "asset_timeline"] = asset_timeline } catch (ce_) { skipped = true }
            try { db[$ "asset_tiles"] = asset_tiles } catch (ce_) { skipped = true }
            try { db[$ "asset_shader"] = asset_shader } catch (ce_) { skipped = true }
            try { db[$ "asset_sequence"] = asset_sequence } catch (ce_) { skipped = true }
            try { db[$ "asset_animationcurve"] = asset_animationcurve } catch (ce_) { skipped = true }
            try { db[$ "fa_none"] = fa_none } catch (ce_) { skipped = true }
            try { db[$ "fa_readonly"] = fa_readonly } catch (ce_) { skipped = true }
            try { db[$ "fa_hidden"] = fa_hidden } catch (ce_) { skipped = true }
            try { db[$ "fa_sysfile"] = fa_sysfile } catch (ce_) { skipped = true }
            try { db[$ "fa_volumeid"] = fa_volumeid } catch (ce_) { skipped = true }
            try { db[$ "fa_directory"] = fa_directory } catch (ce_) { skipped = true }
            try { db[$ "fa_archive"] = fa_archive } catch (ce_) { skipped = true }
            try { db[$ "ds_type_map"] = ds_type_map } catch (ce_) { skipped = true }
            try { db[$ "ds_type_list"] = ds_type_list } catch (ce_) { skipped = true }
            try { db[$ "ds_type_stack"] = ds_type_stack } catch (ce_) { skipped = true }
            try { db[$ "ds_type_queue"] = ds_type_queue } catch (ce_) { skipped = true }
            try { db[$ "ds_type_grid"] = ds_type_grid } catch (ce_) { skipped = true }
            try { db[$ "ds_type_priority"] = ds_type_priority } catch (ce_) { skipped = true }
            try { db[$ "ef_explosion"] = ef_explosion } catch (ce_) { skipped = true }
            try { db[$ "ef_ring"] = ef_ring } catch (ce_) { skipped = true }
            try { db[$ "ef_ellipse"] = ef_ellipse } catch (ce_) { skipped = true }
            try { db[$ "ef_firework"] = ef_firework } catch (ce_) { skipped = true }
            try { db[$ "ef_smoke"] = ef_smoke } catch (ce_) { skipped = true }
            try { db[$ "ef_smokeup"] = ef_smokeup } catch (ce_) { skipped = true }
            try { db[$ "ef_star"] = ef_star } catch (ce_) { skipped = true }
            try { db[$ "ef_spark"] = ef_spark } catch (ce_) { skipped = true }
            try { db[$ "ef_flare"] = ef_flare } catch (ce_) { skipped = true }
            try { db[$ "ef_cloud"] = ef_cloud } catch (ce_) { skipped = true }
            try { db[$ "ef_rain"] = ef_rain } catch (ce_) { skipped = true }
            try { db[$ "ef_snow"] = ef_snow } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_pixel"] = pt_shape_pixel } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_disk"] = pt_shape_disk } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_square"] = pt_shape_square } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_line"] = pt_shape_line } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_star"] = pt_shape_star } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_circle"] = pt_shape_circle } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_ring"] = pt_shape_ring } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_sphere"] = pt_shape_sphere } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_flare"] = pt_shape_flare } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_spark"] = pt_shape_spark } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_explosion"] = pt_shape_explosion } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_cloud"] = pt_shape_cloud } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_smoke"] = pt_shape_smoke } catch (ce_) { skipped = true }
            try { db[$ "pt_shape_snow"] = pt_shape_snow } catch (ce_) { skipped = true }
            try { db[$ "ps_distr_linear"] = ps_distr_linear } catch (ce_) { skipped = true }
            try { db[$ "ps_distr_gaussian"] = ps_distr_gaussian } catch (ce_) { skipped = true }
            try { db[$ "ps_distr_invgaussian"] = ps_distr_invgaussian } catch (ce_) { skipped = true }
            try { db[$ "ps_shape_rectangle"] = ps_shape_rectangle } catch (ce_) { skipped = true }
            try { db[$ "ps_shape_ellipse"] = ps_shape_ellipse } catch (ce_) { skipped = true }
            try { db[$ "ps_shape_diamond"] = ps_shape_diamond } catch (ce_) { skipped = true }
            try { db[$ "ps_shape_line"] = ps_shape_line } catch (ce_) { skipped = true }
            try { db[$ "ps_mode_stream"] = ps_mode_stream } catch (ce_) { skipped = true }
            try { db[$ "ps_mode_burst"] = ps_mode_burst } catch (ce_) { skipped = true }
            try { db[$ "ty_real"] = ty_real } catch (ce_) { skipped = true }
            try { db[$ "ty_string"] = ty_string } catch (ce_) { skipped = true }
            try { db[$ "dll_cdecl"] = dll_cdecl } catch (ce_) { skipped = true }
            try { db[$ "dll_stdcall"] = dll_stdcall } catch (ce_) { skipped = true }
            try { db[$ "matrix_view"] = matrix_view } catch (ce_) { skipped = true }
            try { db[$ "matrix_projection"] = matrix_projection } catch (ce_) { skipped = true }
            try { db[$ "matrix_world"] = matrix_world } catch (ce_) { skipped = true }
            try { db[$ "os_windows"] = os_windows } catch (ce_) { skipped = true }
            try { db[$ "os_macosx"] = os_macosx } catch (ce_) { skipped = true }
            try { db[$ "os_ios"] = os_ios } catch (ce_) { skipped = true }
            try { db[$ "os_android"] = os_android } catch (ce_) { skipped = true }
            try { db[$ "os_linux"] = os_linux } catch (ce_) { skipped = true }
            try { db[$ "os_unknown"] = os_unknown } catch (ce_) { skipped = true }
            try { db[$ "os_winphone"] = os_winphone } catch (ce_) { skipped = true }
            try { db[$ "os_win8native"] = os_win8native } catch (ce_) { skipped = true }
            try { db[$ "os_psvita"] = os_psvita } catch (ce_) { skipped = true }
            try { db[$ "os_ps4"] = os_ps4 } catch (ce_) { skipped = true }
            try { db[$ "os_xboxone"] = os_xboxone } catch (ce_) { skipped = true }
            try { db[$ "os_ps3"] = os_ps3 } catch (ce_) { skipped = true }
            try { db[$ "os_uwp"] = os_uwp } catch (ce_) { skipped = true }
            try { db[$ "os_tvos"] = os_tvos } catch (ce_) { skipped = true }
            try { db[$ "os_switch"] = os_switch } catch (ce_) { skipped = true }
            try { db[$ "os_ps5"] = os_ps5 } catch (ce_) { skipped = true }
            try { db[$ "os_xboxseriesxs"] = os_xboxseriesxs } catch (ce_) { skipped = true }
            try { db[$ "os_gdk"] = os_gdk } catch (ce_) { skipped = true }
            try { db[$ "os_operagx"] = os_operagx } catch (ce_) { skipped = true }
            try { db[$ "os_gxgames"] = os_gxgames } catch (ce_) { skipped = true }
            try { db[$ "browser_not_a_browser"] = browser_not_a_browser } catch (ce_) { skipped = true }
            try { db[$ "browser_unknown"] = browser_unknown } catch (ce_) { skipped = true }
            try { db[$ "browser_ie"] = browser_ie } catch (ce_) { skipped = true }
            try { db[$ "browser_firefox"] = browser_firefox } catch (ce_) { skipped = true }
            try { db[$ "browser_chrome"] = browser_chrome } catch (ce_) { skipped = true }
            try { db[$ "browser_safari"] = browser_safari } catch (ce_) { skipped = true }
            try { db[$ "browser_safari_mobile"] = browser_safari_mobile } catch (ce_) { skipped = true }
            try { db[$ "browser_opera"] = browser_opera } catch (ce_) { skipped = true }
            try { db[$ "browser_tizen"] = browser_tizen } catch (ce_) { skipped = true }
            try { db[$ "browser_edge"] = browser_edge } catch (ce_) { skipped = true }
            try { db[$ "browser_windows_store"] = browser_windows_store } catch (ce_) { skipped = true }
            try { db[$ "browser_ie_mobile"] = browser_ie_mobile } catch (ce_) { skipped = true }
            try { db[$ "device_ios_unknown"] = device_ios_unknown } catch (ce_) { skipped = true }
            try { db[$ "device_ios_iphone"] = device_ios_iphone } catch (ce_) { skipped = true }
            try { db[$ "device_ios_iphone_retina"] = device_ios_iphone_retina } catch (ce_) { skipped = true }
            try { db[$ "device_ios_ipad"] = device_ios_ipad } catch (ce_) { skipped = true }
            try { db[$ "device_ios_ipad_retina"] = device_ios_ipad_retina } catch (ce_) { skipped = true }
            try { db[$ "device_ios_iphone5"] = device_ios_iphone5 } catch (ce_) { skipped = true }
            try { db[$ "device_ios_iphone6"] = device_ios_iphone6 } catch (ce_) { skipped = true }
            try { db[$ "device_ios_iphone6plus"] = device_ios_iphone6plus } catch (ce_) { skipped = true }
            try { db[$ "device_emulator"] = device_emulator } catch (ce_) { skipped = true }
            try { db[$ "device_tablet"] = device_tablet } catch (ce_) { skipped = true }
            try { db[$ "display_landscape"] = display_landscape } catch (ce_) { skipped = true }
            try { db[$ "display_landscape_flipped"] = display_landscape_flipped } catch (ce_) { skipped = true }
            try { db[$ "display_portrait"] = display_portrait } catch (ce_) { skipped = true }
            try { db[$ "display_portrait_flipped"] = display_portrait_flipped } catch (ce_) { skipped = true }
            try { db[$ "tm_sleep"] = tm_sleep } catch (ce_) { skipped = true }
            try { db[$ "tm_countvsyncs"] = tm_countvsyncs } catch (ce_) { skipped = true }
            try { db[$ "tm_systemtiming"] = tm_systemtiming } catch (ce_) { skipped = true }
            try { db[$ "of_challenge_win"] = of_challenge_win } catch (ce_) { skipped = true }
            try { db[$ "of_challenge_lose"] = of_challenge_lose } catch (ce_) { skipped = true }
            try { db[$ "of_challenge_tie"] = of_challenge_tie } catch (ce_) { skipped = true }
            try { db[$ "leaderboard_type_number"] = leaderboard_type_number } catch (ce_) { skipped = true }
            try { db[$ "leaderboard_type_time_mins_secs"] = leaderboard_type_time_mins_secs } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_never"] = cmpfunc_never } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_less"] = cmpfunc_less } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_equal"] = cmpfunc_equal } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_lessequal"] = cmpfunc_lessequal } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_greater"] = cmpfunc_greater } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_notequal"] = cmpfunc_notequal } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_greaterequal"] = cmpfunc_greaterequal } catch (ce_) { skipped = true }
            try { db[$ "cmpfunc_always"] = cmpfunc_always } catch (ce_) { skipped = true }
            try { db[$ "cull_noculling"] = cull_noculling } catch (ce_) { skipped = true }
            try { db[$ "cull_clockwise"] = cull_clockwise } catch (ce_) { skipped = true }
            try { db[$ "cull_counterclockwise"] = cull_counterclockwise } catch (ce_) { skipped = true }
            try { db[$ "lighttype_dir"] = lighttype_dir } catch (ce_) { skipped = true }
            try { db[$ "lighttype_point"] = lighttype_point } catch (ce_) { skipped = true }
            try { db[$ "iap_ev_storeload"] = iap_ev_storeload } catch (ce_) { skipped = true }
            try { db[$ "iap_ev_product"] = iap_ev_product } catch (ce_) { skipped = true }
            try { db[$ "iap_ev_purchase"] = iap_ev_purchase } catch (ce_) { skipped = true }
            try { db[$ "iap_ev_consume"] = iap_ev_consume } catch (ce_) { skipped = true }
            try { db[$ "iap_ev_restore"] = iap_ev_restore } catch (ce_) { skipped = true }
            try { db[$ "iap_storeload_ok"] = iap_storeload_ok } catch (ce_) { skipped = true }
            try { db[$ "iap_storeload_failed"] = iap_storeload_failed } catch (ce_) { skipped = true }
            try { db[$ "iap_status_uninitialised"] = iap_status_uninitialised } catch (ce_) { skipped = true }
            try { db[$ "iap_status_unavailable"] = iap_status_unavailable } catch (ce_) { skipped = true }
            try { db[$ "iap_status_loading"] = iap_status_loading } catch (ce_) { skipped = true }
            try { db[$ "iap_status_available"] = iap_status_available } catch (ce_) { skipped = true }
            try { db[$ "iap_status_processing"] = iap_status_processing } catch (ce_) { skipped = true }
            try { db[$ "iap_status_restoring"] = iap_status_restoring } catch (ce_) { skipped = true }
            try { db[$ "iap_failed"] = iap_failed } catch (ce_) { skipped = true }
            try { db[$ "iap_unavailable"] = iap_unavailable } catch (ce_) { skipped = true }
            try { db[$ "iap_available"] = iap_available } catch (ce_) { skipped = true }
            try { db[$ "iap_purchased"] = iap_purchased } catch (ce_) { skipped = true }
            try { db[$ "iap_canceled"] = iap_canceled } catch (ce_) { skipped = true }
            try { db[$ "iap_refunded"] = iap_refunded } catch (ce_) { skipped = true }
            try { db[$ "network_socket_tcp"] = network_socket_tcp } catch (ce_) { skipped = true }
            try { db[$ "network_socket_udp"] = network_socket_udp } catch (ce_) { skipped = true }
            try { db[$ "network_socket_ws"] = network_socket_ws } catch (ce_) { skipped = true }
            try { db[$ "network_socket_wss"] = network_socket_wss } catch (ce_) { skipped = true }
            try { db[$ "network_socket_bluetooth"] = network_socket_bluetooth } catch (ce_) { skipped = true }
            try { db[$ "network_type_connect"] = network_type_connect } catch (ce_) { skipped = true }
            try { db[$ "network_type_disconnect"] = network_type_disconnect } catch (ce_) { skipped = true }
            try { db[$ "network_type_data"] = network_type_data } catch (ce_) { skipped = true }
            try { db[$ "network_type_non_blocking_connect"] = network_type_non_blocking_connect } catch (ce_) { skipped = true }
            try { db[$ "network_type_up"] = network_type_up } catch (ce_) { skipped = true }
            try { db[$ "network_type_up_failed"] = network_type_up_failed } catch (ce_) { skipped = true }
            try { db[$ "network_type_down"] = network_type_down } catch (ce_) { skipped = true }
            try { db[$ "network_send_binary"] = network_send_binary } catch (ce_) { skipped = true }
            try { db[$ "network_send_text"] = network_send_text } catch (ce_) { skipped = true }
            try { db[$ "network_config_connect_timeout"] = network_config_connect_timeout } catch (ce_) { skipped = true }
            try { db[$ "network_config_use_non_blocking_socket"] = network_config_use_non_blocking_socket } catch (ce_) { skipped = true }
            try { db[$ "network_config_enable_reliable_udp"] = network_config_enable_reliable_udp } catch (ce_) { skipped = true }
            try { db[$ "network_config_disable_reliable_udp"] = network_config_disable_reliable_udp } catch (ce_) { skipped = true }
            try { db[$ "network_config_avoid_time_wait"] = network_config_avoid_time_wait } catch (ce_) { skipped = true }
            try { db[$ "network_config_websocket_protocol"] = network_config_websocket_protocol } catch (ce_) { skipped = true }
            try { db[$ "network_config_enable_multicast"] = network_config_enable_multicast } catch (ce_) { skipped = true }
            try { db[$ "network_config_disable_multicast"] = network_config_disable_multicast } catch (ce_) { skipped = true }
            try { db[$ "network_connect_none"] = network_connect_none } catch (ce_) { skipped = true }
            try { db[$ "network_connect_blocking"] = network_connect_blocking } catch (ce_) { skipped = true }
            try { db[$ "network_connect_nonblocking"] = network_connect_nonblocking } catch (ce_) { skipped = true }
            try { db[$ "network_connect_active"] = network_connect_active } catch (ce_) { skipped = true }
            try { db[$ "network_connect_passive"] = network_connect_passive } catch (ce_) { skipped = true }
            try { db[$ "buffer_fixed"] = buffer_fixed } catch (ce_) { skipped = true }
            try { db[$ "buffer_grow"] = buffer_grow } catch (ce_) { skipped = true }
            try { db[$ "buffer_wrap"] = buffer_wrap } catch (ce_) { skipped = true }
            try { db[$ "buffer_fast"] = buffer_fast } catch (ce_) { skipped = true }
            try { db[$ "buffer_vbuffer"] = buffer_vbuffer } catch (ce_) { skipped = true }
            try { db[$ "buffer_u8"] = buffer_u8 } catch (ce_) { skipped = true }
            try { db[$ "buffer_s8"] = buffer_s8 } catch (ce_) { skipped = true }
            try { db[$ "buffer_u16"] = buffer_u16 } catch (ce_) { skipped = true }
            try { db[$ "buffer_s16"] = buffer_s16 } catch (ce_) { skipped = true }
            try { db[$ "buffer_u32"] = buffer_u32 } catch (ce_) { skipped = true }
            try { db[$ "buffer_s32"] = buffer_s32 } catch (ce_) { skipped = true }
            try { db[$ "buffer_u64"] = buffer_u64 } catch (ce_) { skipped = true }
            try { db[$ "buffer_f16"] = buffer_f16 } catch (ce_) { skipped = true }
            try { db[$ "buffer_f32"] = buffer_f32 } catch (ce_) { skipped = true }
            try { db[$ "buffer_f64"] = buffer_f64 } catch (ce_) { skipped = true }
            try { db[$ "buffer_bool"] = buffer_bool } catch (ce_) { skipped = true }
            try { db[$ "buffer_text"] = buffer_text } catch (ce_) { skipped = true }
            try { db[$ "buffer_string"] = buffer_string } catch (ce_) { skipped = true }
            try { db[$ "buffer_seek_start"] = buffer_seek_start } catch (ce_) { skipped = true }
            try { db[$ "buffer_seek_relative"] = buffer_seek_relative } catch (ce_) { skipped = true }
            try { db[$ "buffer_seek_end"] = buffer_seek_end } catch (ce_) { skipped = true }
            try { db[$ "gp_face1"] = gp_face1 } catch (ce_) { skipped = true }
            try { db[$ "gp_face2"] = gp_face2 } catch (ce_) { skipped = true }
            try { db[$ "gp_face3"] = gp_face3 } catch (ce_) { skipped = true }
            try { db[$ "gp_face4"] = gp_face4 } catch (ce_) { skipped = true }
            try { db[$ "gp_shoulderl"] = gp_shoulderl } catch (ce_) { skipped = true }
            try { db[$ "gp_shoulderr"] = gp_shoulderr } catch (ce_) { skipped = true }
            try { db[$ "gp_shoulderlb"] = gp_shoulderlb } catch (ce_) { skipped = true }
            try { db[$ "gp_shoulderrb"] = gp_shoulderrb } catch (ce_) { skipped = true }
            try { db[$ "gp_select"] = gp_select } catch (ce_) { skipped = true }
            try { db[$ "gp_start"] = gp_start } catch (ce_) { skipped = true }
            try { db[$ "gp_stickl"] = gp_stickl } catch (ce_) { skipped = true }
            try { db[$ "gp_stickr"] = gp_stickr } catch (ce_) { skipped = true }
            try { db[$ "gp_padu"] = gp_padu } catch (ce_) { skipped = true }
            try { db[$ "gp_padd"] = gp_padd } catch (ce_) { skipped = true }
            try { db[$ "gp_padl"] = gp_padl } catch (ce_) { skipped = true }
            try { db[$ "gp_padr"] = gp_padr } catch (ce_) { skipped = true }
            try { db[$ "gp_axislh"] = gp_axislh } catch (ce_) { skipped = true }
            try { db[$ "gp_axislv"] = gp_axislv } catch (ce_) { skipped = true }
            try { db[$ "gp_axisrh"] = gp_axisrh } catch (ce_) { skipped = true }
            try { db[$ "gp_axisrv"] = gp_axisrv } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_acceleration_x"] = gp_axis_acceleration_x } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_acceleration_y"] = gp_axis_acceleration_y } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_acceleration_z"] = gp_axis_acceleration_z } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_angular_velocity_x"] = gp_axis_angular_velocity_x } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_angular_velocity_y"] = gp_axis_angular_velocity_y } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_angular_velocity_z"] = gp_axis_angular_velocity_z } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_orientation_x"] = gp_axis_orientation_x } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_orientation_y"] = gp_axis_orientation_y } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_orientation_z"] = gp_axis_orientation_z } catch (ce_) { skipped = true }
            try { db[$ "gp_axis_orientation_w"] = gp_axis_orientation_w } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_position"] = vertex_usage_position } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_colour"] = vertex_usage_colour } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_color"] = vertex_usage_color } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_normal"] = vertex_usage_normal } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_texcoord"] = vertex_usage_texcoord } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_blendweight"] = vertex_usage_blendweight } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_blendindices"] = vertex_usage_blendindices } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_psize"] = vertex_usage_psize } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_tangent"] = vertex_usage_tangent } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_binormal"] = vertex_usage_binormal } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_fog"] = vertex_usage_fog } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_depth"] = vertex_usage_depth } catch (ce_) { skipped = true }
            try { db[$ "vertex_usage_sample"] = vertex_usage_sample } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_float1"] = vertex_type_float1 } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_float2"] = vertex_type_float2 } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_float3"] = vertex_type_float3 } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_float4"] = vertex_type_float4 } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_colour"] = vertex_type_colour } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_color"] = vertex_type_color } catch (ce_) { skipped = true }
            try { db[$ "vertex_type_ubyte4"] = vertex_type_ubyte4 } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_undefined"] = layerelementtype_undefined } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_background"] = layerelementtype_background } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_instance"] = layerelementtype_instance } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_oldtilemap"] = layerelementtype_oldtilemap } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_sprite"] = layerelementtype_sprite } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_tilemap"] = layerelementtype_tilemap } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_particlesystem"] = layerelementtype_particlesystem } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_tile"] = layerelementtype_tile } catch (ce_) { skipped = true }
            try { db[$ "layerelementtype_sequence"] = layerelementtype_sequence } catch (ce_) { skipped = true }
            try { db[$ "tile_rotate"] = tile_rotate } catch (ce_) { skipped = true }
            try { db[$ "tile_flip"] = tile_flip } catch (ce_) { skipped = true }
            try { db[$ "tile_mirror"] = tile_mirror } catch (ce_) { skipped = true }
            try { db[$ "tile_index_mask"] = tile_index_mask } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_default"] = kbv_type_default } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_ascii"] = kbv_type_ascii } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_url"] = kbv_type_url } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_email"] = kbv_type_email } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_numbers"] = kbv_type_numbers } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_phone"] = kbv_type_phone } catch (ce_) { skipped = true }
            try { db[$ "kbv_type_phone_name"] = kbv_type_phone_name } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_default"] = kbv_returnkey_default } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_go"] = kbv_returnkey_go } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_google"] = kbv_returnkey_google } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_join"] = kbv_returnkey_join } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_next"] = kbv_returnkey_next } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_route"] = kbv_returnkey_route } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_search"] = kbv_returnkey_search } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_send"] = kbv_returnkey_send } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_yahoo"] = kbv_returnkey_yahoo } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_done"] = kbv_returnkey_done } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_continue"] = kbv_returnkey_continue } catch (ce_) { skipped = true }
            try { db[$ "kbv_returnkey_emergency"] = kbv_returnkey_emergency } catch (ce_) { skipped = true }
            try { db[$ "kbv_autocapitalize_none"] = kbv_autocapitalize_none } catch (ce_) { skipped = true }
            try { db[$ "kbv_autocapitalize_words"] = kbv_autocapitalize_words } catch (ce_) { skipped = true }
            try { db[$ "kbv_autocapitalize_sentences"] = kbv_autocapitalize_sentences } catch (ce_) { skipped = true }
            try { db[$ "kbv_autocapitalize_characters"] = kbv_autocapitalize_characters } catch (ce_) { skipped = true }
            try { db[$ "os_permission_denied_dont_request"] = os_permission_denied_dont_request } catch (ce_) { skipped = true }
            try { db[$ "os_permission_denied"] = os_permission_denied } catch (ce_) { skipped = true }
            try { db[$ "os_permission_granted"] = os_permission_granted } catch (ce_) { skipped = true }
            try { db[$ "nineslice_left"] = nineslice_left } catch (ce_) { skipped = true }
            try { db[$ "nineslice_top"] = nineslice_top } catch (ce_) { skipped = true }
            try { db[$ "nineslice_right"] = nineslice_right } catch (ce_) { skipped = true }
            try { db[$ "nineslice_bottom"] = nineslice_bottom } catch (ce_) { skipped = true }
            try { db[$ "nineslice_centre"] = nineslice_centre } catch (ce_) { skipped = true }
            try { db[$ "nineslice_center"] = nineslice_center } catch (ce_) { skipped = true }
            try { db[$ "nineslice_stretch"] = nineslice_stretch } catch (ce_) { skipped = true }
            try { db[$ "nineslice_repeat"] = nineslice_repeat } catch (ce_) { skipped = true }
            try { db[$ "nineslice_mirror"] = nineslice_mirror } catch (ce_) { skipped = true }
            try { db[$ "nineslice_blank"] = nineslice_blank } catch (ce_) { skipped = true }
            try { db[$ "nineslice_hide"] = nineslice_hide } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_status_unloaded"] = texturegroup_status_unloaded } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_status_loading"] = texturegroup_status_loading } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_status_loaded"] = texturegroup_status_loaded } catch (ce_) { skipped = true }
            try { db[$ "texturegroup_status_fetched"] = texturegroup_status_fetched } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_graphic"] = seqtracktype_graphic } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_audio"] = seqtracktype_audio } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_real"] = seqtracktype_real } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_color"] = seqtracktype_color } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_colour"] = seqtracktype_colour } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_bool"] = seqtracktype_bool } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_string"] = seqtracktype_string } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_sequence"] = seqtracktype_sequence } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_clipmask"] = seqtracktype_clipmask } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_clipmask_mask"] = seqtracktype_clipmask_mask } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_clipmask_subject"] = seqtracktype_clipmask_subject } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_group"] = seqtracktype_group } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_empty"] = seqtracktype_empty } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_spriteframes"] = seqtracktype_spriteframes } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_instance"] = seqtracktype_instance } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_message"] = seqtracktype_message } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_moment"] = seqtracktype_moment } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_text"] = seqtracktype_text } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_particlesystem"] = seqtracktype_particlesystem } catch (ce_) { skipped = true }
            try { db[$ "seqtracktype_audioeffect"] = seqtracktype_audioeffect } catch (ce_) { skipped = true }
            try { db[$ "seqplay_oneshot"] = seqplay_oneshot } catch (ce_) { skipped = true }
            try { db[$ "seqplay_loop"] = seqplay_loop } catch (ce_) { skipped = true }
            try { db[$ "seqplay_pingpong"] = seqplay_pingpong } catch (ce_) { skipped = true }
            try { db[$ "seqdir_right"] = seqdir_right } catch (ce_) { skipped = true }
            try { db[$ "seqdir_left"] = seqdir_left } catch (ce_) { skipped = true }
            try { db[$ "seqinterpolation_assign"] = seqinterpolation_assign } catch (ce_) { skipped = true }
            try { db[$ "seqinterpolation_lerp"] = seqinterpolation_lerp } catch (ce_) { skipped = true }
            try { db[$ "seqaudiokey_loop"] = seqaudiokey_loop } catch (ce_) { skipped = true }
            try { db[$ "seqaudiokey_oneshot"] = seqaudiokey_oneshot } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_left"] = seqtextkey_left } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_center"] = seqtextkey_center } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_right"] = seqtextkey_right } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_justify"] = seqtextkey_justify } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_top"] = seqtextkey_top } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_middle"] = seqtextkey_middle } catch (ce_) { skipped = true }
            try { db[$ "seqtextkey_bottom"] = seqtextkey_bottom } catch (ce_) { skipped = true }
            try { db[$ "animcurvetype_linear"] = animcurvetype_linear } catch (ce_) { skipped = true }
            try { db[$ "animcurvetype_catmullrom"] = animcurvetype_catmullrom } catch (ce_) { skipped = true }
            try { db[$ "animcurvetype_bezier"] = animcurvetype_bezier } catch (ce_) { skipped = true }
            try { db[$ "time_source_global"] = time_source_global } catch (ce_) { skipped = true }
            try { db[$ "time_source_game"] = time_source_game } catch (ce_) { skipped = true }
            try { db[$ "time_source_units_seconds"] = time_source_units_seconds } catch (ce_) { skipped = true }
            try { db[$ "time_source_units_frames"] = time_source_units_frames } catch (ce_) { skipped = true }
            try { db[$ "time_source_expire_nearest"] = time_source_expire_nearest } catch (ce_) { skipped = true }
            try { db[$ "time_source_expire_after"] = time_source_expire_after } catch (ce_) { skipped = true }
            try { db[$ "time_source_state_initial"] = time_source_state_initial } catch (ce_) { skipped = true }
            try { db[$ "time_source_state_active"] = time_source_state_active } catch (ce_) { skipped = true }
            try { db[$ "time_source_state_paused"] = time_source_state_paused } catch (ce_) { skipped = true }
            try { db[$ "time_source_state_stopped"] = time_source_state_stopped } catch (ce_) { skipped = true }
            try { db[$ "audio_bus_main"] = audio_bus_main } catch (ce_) { skipped = true }
            try { db[$ "AudioEffectType"] = AudioEffectType } catch (ce_) { skipped = true }
            try { db[$ "AudioLFOType"] = AudioLFOType } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_speed;
                db[$ "room_speed_get"] = method(undefined, function() { return room_speed });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = fps;
                db[$ "fps_get"] = method(undefined, function() { return fps });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = fps_real;
                db[$ "fps_real_get"] = method(undefined, function() { return fps_real });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_time;
                db[$ "current_time_get"] = method(undefined, function() { return current_time });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_year;
                db[$ "current_year_get"] = method(undefined, function() { return current_year });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_month;
                db[$ "current_month_get"] = method(undefined, function() { return current_month });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_day;
                db[$ "current_day_get"] = method(undefined, function() { return current_day });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_weekday;
                db[$ "current_weekday_get"] = method(undefined, function() { return current_weekday });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_hour;
                db[$ "current_hour_get"] = method(undefined, function() { return current_hour });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_minute;
                db[$ "current_minute_get"] = method(undefined, function() { return current_minute });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = current_second;
                db[$ "current_second_get"] = method(undefined, function() { return current_second });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room;
                db[$ "room_get"] = method(undefined, function() { return room });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_first;
                db[$ "room_first_get"] = method(undefined, function() { return room_first });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_last;
                db[$ "room_last_get"] = method(undefined, function() { return room_last });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_width;
                db[$ "room_width_get"] = method(undefined, function() { return room_width });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_height;
                db[$ "room_height_get"] = method(undefined, function() { return room_height });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_persistent;
                db[$ "room_persistent_get"] = method(undefined, function() { return room_persistent });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = score;
                db[$ "score_get"] = method(undefined, function() { return score });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = lives;
                db[$ "lives_get"] = method(undefined, function() { return lives });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = health;
                db[$ "health_get"] = method(undefined, function() { return health });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = event_type;
                db[$ "event_type_get"] = method(undefined, function() { return event_type });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = event_number;
                db[$ "event_number_get"] = method(undefined, function() { return event_number });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = event_object;
                db[$ "event_object_get"] = method(undefined, function() { return event_object });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = event_action;
                db[$ "event_action_get"] = method(undefined, function() { return event_action });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = application_surface;
                db[$ "application_surface_get"] = method(undefined, function() { return application_surface });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = debug_mode;
                db[$ "debug_mode_get"] = method(undefined, function() { return debug_mode });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = font_texture_page_size;
                db[$ "font_texture_page_size_get"] = method(undefined, function() { return font_texture_page_size });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_key;
                db[$ "keyboard_key_get"] = method(undefined, function() { return keyboard_key });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_lastkey;
                db[$ "keyboard_lastkey_get"] = method(undefined, function() { return keyboard_lastkey });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_lastchar;
                db[$ "keyboard_lastchar_get"] = method(undefined, function() { return keyboard_lastchar });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_string;
                db[$ "keyboard_string_get"] = method(undefined, function() { return keyboard_string });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = mouse_x;
                db[$ "mouse_x_get"] = method(undefined, function() { return mouse_x });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = mouse_y;
                db[$ "mouse_y_get"] = method(undefined, function() { return mouse_y });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = mouse_button;
                db[$ "mouse_button_get"] = method(undefined, function() { return mouse_button });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = mouse_lastbutton;
                db[$ "mouse_lastbutton_get"] = method(undefined, function() { return mouse_lastbutton });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = cursor_sprite;
                db[$ "cursor_sprite_get"] = method(undefined, function() { return cursor_sprite });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_colour;
                db[$ "background_colour_get"] = method(undefined, function() { return background_colour });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_showcolour;
                db[$ "background_showcolour_get"] = method(undefined, function() { return background_showcolour });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_color;
                db[$ "background_color_get"] = method(undefined, function() { return background_color });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_showcolor;
                db[$ "background_showcolor_get"] = method(undefined, function() { return background_showcolor });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_enabled;
                db[$ "view_enabled_get"] = method(undefined, function() { return view_enabled });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_current;
                db[$ "view_current_get"] = method(undefined, function() { return view_current });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = game_id;
                db[$ "game_id_get"] = method(undefined, function() { return game_id });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = game_display_name;
                db[$ "game_display_name_get"] = method(undefined, function() { return game_display_name });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = game_project_name;
                db[$ "game_project_name_get"] = method(undefined, function() { return game_project_name });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = game_save_id;
                db[$ "game_save_id_get"] = method(undefined, function() { return game_save_id });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = working_directory;
                db[$ "working_directory_get"] = method(undefined, function() { return working_directory });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = temp_directory;
                db[$ "temp_directory_get"] = method(undefined, function() { return temp_directory });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = cache_directory;
                db[$ "cache_directory_get"] = method(undefined, function() { return cache_directory });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = program_directory;
                db[$ "program_directory_get"] = method(undefined, function() { return program_directory });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = browser_width;
                db[$ "browser_width_get"] = method(undefined, function() { return browser_width });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = browser_height;
                db[$ "browser_height_get"] = method(undefined, function() { return browser_height });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = os_type;
                db[$ "os_type_get"] = method(undefined, function() { return os_type });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = os_device;
                db[$ "os_device_get"] = method(undefined, function() { return os_device });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = os_browser;
                db[$ "os_browser_get"] = method(undefined, function() { return os_browser });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = os_version;
                db[$ "os_version_get"] = method(undefined, function() { return os_version });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = display_aa;
                db[$ "display_aa_get"] = method(undefined, function() { return display_aa });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = async_load;
                db[$ "async_load_get"] = method(undefined, function() { return async_load });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = delta_time;
                db[$ "delta_time_get"] = method(undefined, function() { return delta_time });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = webgl_enabled;
                db[$ "webgl_enabled_get"] = method(undefined, function() { return webgl_enabled });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = event_data;
                db[$ "event_data_get"] = method(undefined, function() { return event_data });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = iap_data;
                db[$ "iap_data_get"] = method(undefined, function() { return iap_data });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_speed;
                db[$ "room_speed_set"] = method(undefined, function(val) { room_speed = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room;
                db[$ "room_set"] = method(undefined, function(val) { room = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = room_persistent;
                db[$ "room_persistent_set"] = method(undefined, function(val) { room_persistent = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = score;
                db[$ "score_set"] = method(undefined, function(val) { score = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = lives;
                db[$ "lives_set"] = method(undefined, function(val) { lives = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = health;
                db[$ "health_set"] = method(undefined, function(val) { health = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = font_texture_page_size;
                db[$ "font_texture_page_size_set"] = method(undefined, function(val) { font_texture_page_size = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_key;
                db[$ "keyboard_key_set"] = method(undefined, function(val) { keyboard_key = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_lastkey;
                db[$ "keyboard_lastkey_set"] = method(undefined, function(val) { keyboard_lastkey = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_lastchar;
                db[$ "keyboard_lastchar_set"] = method(undefined, function(val) { keyboard_lastchar = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = keyboard_string;
                db[$ "keyboard_string_set"] = method(undefined, function(val) { keyboard_string = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = mouse_button;
                db[$ "mouse_button_set"] = method(undefined, function(val) { mouse_button = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = mouse_lastbutton;
                db[$ "mouse_lastbutton_set"] = method(undefined, function(val) { mouse_lastbutton = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = cursor_sprite;
                db[$ "cursor_sprite_set"] = method(undefined, function(val) { cursor_sprite = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_colour;
                db[$ "background_colour_set"] = method(undefined, function(val) { background_colour = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_showcolour;
                db[$ "background_showcolour_set"] = method(undefined, function(val) { background_showcolour = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_color;
                db[$ "background_color_set"] = method(undefined, function(val) { background_color = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = background_showcolor;
                db[$ "background_showcolor_set"] = method(undefined, function(val) { background_showcolor = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_enabled;
                db[$ "view_enabled_set"] = method(undefined, function(val) { view_enabled = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_visible[0];
                db[$ "view_visible_get"] = method(undefined, function(idx) { return view_visible[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_xport[0];
                db[$ "view_xport_get"] = method(undefined, function(idx) { return view_xport[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_yport[0];
                db[$ "view_yport_get"] = method(undefined, function(idx) { return view_yport[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_wport[0];
                db[$ "view_wport_get"] = method(undefined, function(idx) { return view_wport[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_hport[0];
                db[$ "view_hport_get"] = method(undefined, function(idx) { return view_hport[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_surface_id[0];
                db[$ "view_surface_id_get"] = method(undefined, function(idx) { return view_surface_id[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_camera[0];
                db[$ "view_camera_get"] = method(undefined, function(idx) { return view_camera[idx] });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_visible[0];
                db[$ "view_visible_set"] = method(undefined, function(idx, val) { view_visible[idx] = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_xport[0];
                db[$ "view_xport_set"] = method(undefined, function(idx, val) { view_xport[idx] = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_yport[0];
                db[$ "view_yport_set"] = method(undefined, function(idx, val) { view_yport[idx] = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_wport[0];
                db[$ "view_wport_set"] = method(undefined, function(idx, val) { view_wport[idx] = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_hport[0];
                db[$ "view_hport_set"] = method(undefined, function(idx, val) { view_hport[idx] = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_surface_id[0];
                db[$ "view_surface_id_set"] = method(undefined, function(idx, val) { view_surface_id[idx] = val });
            } catch (ce_) { skipped = true }
            try {
                var gatekeeper = view_camera[0];
                db[$ "view_camera_set"] = method(undefined, function(idx, val) { view_camera[idx] = val });
            } catch (ce_) { skipped = true }
        }
        if (skipped) {
            __catspeak_error_silent(
                "some functions/constants in the GML interface were skipped\n",
                "this may be because your GameMaker version is out of date, or missing them"
            );
        }
    }
    return db;
}
