/// @desc Update the Catspeak program once per step.
if (catspeak_session_in_progress(catspeak)) {
    catspeak_session_update(catspeak);
}