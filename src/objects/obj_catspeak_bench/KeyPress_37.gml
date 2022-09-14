
repeat (1) {
    catspeak_execute(ir)
            .withTimeLimit(4)
            .andThen(function(result) {
        show_debug_message([current_time, result]);
    });
}