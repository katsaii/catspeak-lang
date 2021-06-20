/// @desc Initialise Catspeak.
catspeak = catspeak_session_create();
workspace = catspeak_session_get_workspace(catspeak);
catspeak_ext_session_add_gml_operators(catspeak);
catspeak_session_add_result_handler(catspeak, function(_result) {
    show_message(_result);
});
catspeak_session_add_source(catspeak, @'
set n 0
set factorial_n 1
while (n < 100) {
    set wait 10000
    while (wait > 0) {
        -- artificial delay
        set wait : wait - 1
    }
    set n : n + 1
    set factorial_n : factorial_n * n
}
return factorial_n
');
show_debug_overlay(true);
timeStart = 0;