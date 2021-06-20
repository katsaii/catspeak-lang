/// @desc Initialise Catspeak.
catspeak = catspeak_session_create();
player_data = undefined;
world_data = undefined;
catspeak_ext_session_add_gml_operators(catspeak);
catspeak_session_add_function(catspeak, "player", function(_value) {
    player_data = _value;
});
catspeak_session_add_function(catspeak, "world", function(_value) {
    world_data = _value;
});
catspeak_session_add_source(catspeak, @'
player {
    .name : "Angie"
    .x : -12
    .y : 8
}

world {
    .height : 1000
    .width : 500
    .background_colour : 0x00FF00
}
');
catspeak_session_update_eager(catspeak);
show_message(player_data);
show_message(world_data);