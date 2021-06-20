/// @desc Initialise Catspeak.
catspeak = catspeak_session_create();
workspace = catspeak_session_get_workspace(catspeak);
player_data = undefined;
world_data = undefined;
catspeak_ext_session_add_gml_operators(catspeak);
catspeak_session_add_result_handler(catspeak, function(_result) {
    show_message(_result);
});
catspeak_session_add_source(catspeak, @'
set n 0
set factorial_n 1
while (n < 100) {
    set n : n + 1
    set factorial_n : factorial_n * n
}
return factorial_n
');