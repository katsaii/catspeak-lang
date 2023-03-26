
//# feather use syntax-errors

run_test(function() : Test("lexer-internal-1") constructor {
    var buff = __catspeak_create_buffer_from_string(@'let a = 1;');
    var lexer = new CatspeakLexer(buff);
    assertEq("", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); // l
    lexer.__advance(); // e
    lexer.__advance(); // t
    lexer.__advance(); //
    lexer.__advance(); // a
    assertEq("let a", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); //
    lexer.__advance(); // =
    assertEq(" =", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); //
    lexer.__advance(); // 1
    lexer.__advance(); // ;
    lexer.__advance(); // EOF
    lexer.__advance(); // EOF
    assertEq(" 1;", lexer.getLexeme());
    buffer_delete(buff);
});