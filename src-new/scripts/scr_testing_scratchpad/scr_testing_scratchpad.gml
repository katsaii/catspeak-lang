//! A place where experimental tests can be conducted.

//# feather use syntax-errors

catspeak_force_init();

var runExperiment = "lexer";
#macro TEST_EXPERIMENT if runExperiment ==

TEST_EXPERIMENT "lexer" {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字');
    var lexer = new CatspeakLexer(buff);
    lexer.__advance(); // 🙀
    lexer.__advance(); // 會
    lexer.__advance(); // 意
    show_message("'" + string(lexer.getLexeme()) + "'");
    lexer.__clearLexeme();
    lexer.__advance(); // 字
    show_message("'" + string(lexer.getLexeme()) + "'");
}