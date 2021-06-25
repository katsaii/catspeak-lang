/// @desc Initialise Catspeak.
catspeak = catspeak_session_id_create();
playerData = undefined;
worldData = undefined;
catspeak_ext_session_id_add_gml_operators(catspeak);
catspeak_session_id_add_function(catspeak, "player", function(_value) {
    playerData = _value;
});
catspeak_session_id_add_function(catspeak, "world", function(_value) {
    worldData = _value;
});
catspeak_session_id_add_source(catspeak, @'
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
catspeak_session_id_update_eager(catspeak);
show_message(playerData);
show_message(worldData);