//! A place where experimental tests can be conducted.

//# feather use syntax-errors

catspeak_force_init();

var runExperiment = "none";
#macro TEST_EXPERIMENT if runExperiment ==

TEST_EXPERIMENT "lexer" {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字 abcde1');
    var lexer = new CatspeakLexer(buff);
    show_message([CatspeakToken.OTHER, CatspeakToken.WHITESPACE, CatspeakToken.IDENT]);
    // other
    show_message(
        "'" + string(lexer.nextWithWhitespace()) + "' " +
        "'" + string(lexer.getLexeme()) + "'"
    );
    // other
    show_message(
        "'" + string(lexer.nextWithWhitespace()) + "' " +
        "'" + string(lexer.getLexeme()) + "'"
    );
    // other
    show_message(
        "'" + string(lexer.nextWithWhitespace()) + "' " +
        "'" + string(lexer.getLexeme()) + "'"
    );
    // other
    show_message(
        "'" + string(lexer.nextWithWhitespace()) + "' " +
        "'" + string(lexer.getLexeme()) + "'"
    );
    // whitespace
    show_message(
        "'" + string(lexer.nextWithWhitespace()) + "' " +
        "'" + string(lexer.getLexeme()) + "'"
    );
    // identifier
    show_message(
        "'" + string(lexer.nextWithWhitespace()) + "' " +
        "'" + string(lexer.getLexeme()) + "'"
    );
}