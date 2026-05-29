
//# feather use syntax-errors

test_add(function () : Test("lexer-internals-empty") constructor {
    var buff = catspeak_buffer_create_from_string(@'');
    var lexer = new CatspeakLexerV3(buff);
    assertEq("", lexer.getLexeme());
    buffer_delete(buff);
});

test_add(function () : Test("lexer-internals-ascii") constructor {
    var buff = catspeak_buffer_create_from_string(@'let a = 1;');
    var lexer = new CatspeakLexerV3(buff);
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

test_add(function () : Test("lexer-internals-unicode") constructor {
    var buff = catspeak_buffer_create_from_string(@'🙀會意字');
    var lexer = new CatspeakLexerV3(buff);
    lexer.__advance(); // 🙀
    lexer.__advance(); // 會
    lexer.__advance(); // 意
    assertEq("🙀會意", lexer.getLexeme());
    lexer.__clearLexeme();
    lexer.__advance(); // 字
    assertEq("字", lexer.getLexeme());
    buffer_delete(buff);
}, IgnorePlatform.HTML5);
