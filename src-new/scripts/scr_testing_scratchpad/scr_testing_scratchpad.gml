//! A place where experimental tests can be conducted.

//# feather use syntax-errors

catspeak_force_init();

var runExperiment = "lexer";
#macro TEST_EXPERIMENT if runExperiment ==

TEST_EXPERIMENT "lexer" {
    var buff = __catspeak_create_buffer_from_string(@'let a = 1;');
    var lexer = new CatspeakLexer(buff);
    show_message("'" + string(lexer.getLexeme()) + "'");
    lexer.__clearLexeme();
    lexer.__advance(); // l
    lexer.__advance(); // e
    lexer.__advance(); // t
    lexer.__advance(); //
    lexer.__advance(); // a
    show_message("'" + string(lexer.getLexeme()) + "'");
    lexer.__clearLexeme();
    lexer.__advance(); //
    lexer.__advance(); // =
    show_message("'" + string(lexer.getLexeme()) + "'");
    lexer.__clearLexeme();
    lexer.__advance(); //
    lexer.__advance(); // 1
    lexer.__advance(); // ;
    lexer.__advance(); // EOF
    lexer.__advance(); // EOF
    show_message("'" + string(lexer.getLexeme()) + "'");
}