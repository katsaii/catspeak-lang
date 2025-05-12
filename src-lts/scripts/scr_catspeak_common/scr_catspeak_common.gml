function __catspeak_assert(expect, message_="assertion failed") {
    gml_pragma("forceinline");
    if (!expect) {
        __catspeak_error(message_);
    }
}

function __catspeak_assert_eq(expect, got, message_="assertion failed") {
    gml_pragma("forceinline");
    if (expect != got) {
        __catspeak_error(message_);
    }
}