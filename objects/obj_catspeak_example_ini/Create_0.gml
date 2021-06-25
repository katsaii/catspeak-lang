/// @desc Initialise Catspeak.
catspeak = catspeak_session_id_create();
sections = { };
catspeak_session_id_add_expression_statement_handler(catspeak, function(_value) {
    if (is_array(_value) && array_length(_value) == 1) {
        var key = string(_value[0]);
        if not (variable_struct_exists(sections, key)) {
            sections[$ key] = { };
        }
        catspeak_session_id_set_workspace(catspeak, sections[$ key]);
    }
});
catspeak_session_id_add_source(catspeak, @'
["player"]
set x 12
set y 43

["score"]
set highscore 4000
');
catspeak_session_id_update_eager(catspeak);
show_message(sections);