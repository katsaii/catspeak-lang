/* Catspeak JSON Interface
 * -----------------------
 * Kat @katsaii
 */

/// @desc Creates a new Catspeak session for parsing JSON objects.
function catspeak_ext_json_session_create() {
    var session_id = catspeak_session_create();
    catspeak_session_enable_implicit_return(session_id, true);
    catspeak_session_add_constant(session_id, "true", true);
    catspeak_session_add_constant(session_id, "false", false);
    catspeak_session_add_constant(session_id, "null", undefined);
    catspeak_session_add_function(session_id, "+", function(_x) { return +_x; });
    catspeak_session_add_function(session_id, "-", function(_x) { return -_x; });
    return session_id;
}

/// @desc Eagerly parses a JSON string and returns its contents.
/// @param {string} src The source code to compile and evaluate.
function catspeak_ext_json_parse(_src) {
    var session_id = catspeak_ext_json_session_create();
    catspeak_session_set_source(session_id, _src);
    var result = catspeak_session_create_process_eager(session_id);
    catspeak_session_destroy(session_id);
    return result;
}