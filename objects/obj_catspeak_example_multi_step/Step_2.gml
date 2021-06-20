/// @desc Compute the amount of time left to run Catspeak code.
if (catspeak_session_in_progress(catspeak)) {
    var time_limit = timeStart + game_get_speed(gamespeed_microseconds);
    while (get_timer() < time_limit) {
        catspeak_session_update(catspeak);
    }
}