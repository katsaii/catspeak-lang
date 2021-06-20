/* Catspeak JSON Interface
 * -----------------------
 * Kat @katsaii
 */

/// @desc Creates a new Catspeak session for parsing JSON-like syntax.
function catspeak_ext_json_session_create() {
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    workspace.json_objects = [];
    catspeak_session_set_expression_statement_handler(session, method(workspace, function(_value) {
        if (is_array(_value) || is_struct(_value) && instanceof(_value) == "struct") {
            array_push(json_objects, _value);
        }
    }));
    return session;
}

/// @desc Returns an array of json objects, or a single object if there is only one.
/// @param {struct} session The Catspeak session to check.
function catspeak_ext_json_session_get_objects(_session) {
    var objects = catspeak_session_get_workspace(_session).json_objects;
    return array_length(objects) == 1 ? objects[0] : objects;
}

/// @desc Eagerly parses a JSON-like string and returns its contents.
/// @param {string} src The source to parse.
function catspeak_ext_json_parse(_src) {
    var session = catspeak_ext_json_session_create();
    catspeak_session_add_source(session, _src);
    catspeak_session_update_eager(session);
    var objects = catspeak_ext_json_session_get_objects(session);
    catspeak_session_destroy(session);
    return objects;
}