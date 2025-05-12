function __catspeak_assert(expect, message_="assertion failed") {
    if !expect {
        __catspeak_error(message_);
    }
}

function __catspeak_assert_eq(expect, got, message_="assertion failed") {
    if expect != got {
        __catspeak_error(message_);
    }
}