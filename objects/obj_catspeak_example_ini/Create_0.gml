/// @desc Initialise Catspeak.
catspeak = catspeak_session_create();
sections = { };
sections[$ "default"] = catspeak_session_get_workspace(catspeak);
catspeak_session_add_expression_statement_handler(catspeak, function(_value) {
    if (is_array(_value) && array_length(_value) == 1) {
        var key = string(_value[0]);
        if not (variable_struct_exists(sections, key)) {
            sections[$ key] = { };
        }
        catspeak_session_set_workspace(catspeak, sections[$ key]);
    }
});
catspeak_session_add_source(catspeak, @'
["player"]
set x 12
set y 43

["score"]
set highscore 4000
');
catspeak_session_update_eager(catspeak);
show_message(sections);