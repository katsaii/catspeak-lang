
repeat (1000) {
catspeak_execute(ir).andThen(function(result) {
    show_debug_message([current_time, result]);
});
}