
//# feather use syntax-errors

run_test(function() : Test("lexer-internal-empty") constructor {
    var buff = __catspeak_create_buffer_from_string(@'');
    var lexer = new CatspeakLexer(buff);
    assertEq("", lexer.getLexeme());
    buffer_delete(buff);
});

run_test(function() : Test("lexer-internal-ascii") constructor {
    var buff = __catspeak_create_buffer_from_string(@'let a = 1;');
    var lexer = new CatspeakLexer(buff);
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

run_test(function() : Test("lexer-internal-unicode") constructor {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字');
    var lexer = new CatspeakLexer(buff);
    lexer.__advance(); // 🙀
    lexer.__advance(); // 會
    lexer.__advance(); // 意
    assertEq("🙀會意", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); // 字
    assertEq("字", lexer.getLexeme());
    buffer_delete(buff);
});