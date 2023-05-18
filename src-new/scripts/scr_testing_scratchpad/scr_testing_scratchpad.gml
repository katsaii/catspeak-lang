//! A place where experimental tests can be conducted.

//# feather use syntax-errors

catspeak_force_init();

var runExperiment = "parser-2";
#macro TEST_EXPERIMENT if runExperiment ==

TEST_EXPERIMENT "lexer" {
    var buff = __catspeak_create_buffer_from_string(@'1 2._ 3._4_ 5_6_7__');
    var lexer = new CatspeakLexer(buff);
    lexer.nextWithWhitespace(); // 1
    show_message([lexer.getLexeme(), lexer.getValue()]);
    lexer.nextWithWhitespace(); // whitespace
    lexer.nextWithWhitespace(); // 2._
    show_message([lexer.getLexeme(), lexer.getValue()]);
    lexer.nextWithWhitespace(); // whitespace
    lexer.nextWithWhitespace(); // 3._4_
    show_message([lexer.getLexeme(), lexer.getValue()]);
    lexer.nextWithWhitespace(); // whitespace
    lexer.nextWithWhitespace(); // 5_6_7__
    show_message([lexer.getLexeme(), lexer.getValue()]);
}

TEST_EXPERIMENT "parser" {
    var buff = __catspeak_create_buffer_from_string(@'123_4.5');
    var lexer = new CatspeakLexer(buff);
    var builder = new CatspeakASGBuilder();
    var parser = new CatspeakParser(lexer, builder);
    parser.parseExpression();
    show_message(builder.get());
}

TEST_EXPERIMENT "parser-2" {
    var buff = __catspeak_create_buffer_from_string(@'1 2 3 4');
    var asg = Catspeak.parse(buff);
    show_message(asg);
}