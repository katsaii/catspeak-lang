
//# feather use syntax-errors

test_add(function () : Test("lexer-config-offset") constructor {
    var buff = __catspeak_create_buffer_from_string(@'hello world :3');
    var lexer = new CatspeakLexerV3(buff, 6);
    // identifier
    assertEq(CatspeakTokenV3.IDENT, lexer.nextWithWhitespace());
    assertEq("world", lexer.getLexeme());
    // whitespace
    assertEq(CatspeakTokenV3.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    // colon
    assertEq(CatspeakTokenV3.COLON, lexer.nextWithWhitespace());
    assertEq(":", lexer.getLexeme());
    // number
    assertEq(CatspeakTokenV3.VALUE_NUMBER, lexer.nextWithWhitespace());
    assertEq("3", lexer.getLexeme());
    // eof
    assertEq(CatspeakTokenV3.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
});

test_add(function () : Test("lexer-config-offset-2") constructor {
    var buff = __catspeak_create_buffer_from_string(@'hello world :3');
    var lexer = new CatspeakLexerV3(buff, 6, 5);
    // identifier
    assertEq(CatspeakTokenV3.IDENT, lexer.nextWithWhitespace());
    assertEq("world", lexer.getLexeme());
    // eof
    assertEq(CatspeakTokenV3.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
});

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-2",
    CatspeakTokenV3.FUN, @'f'
) constructor { });

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-3",
    CatspeakTokenV3.FUN, @'fn'
) constructor { });

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-4",
    CatspeakTokenV3.FUN, @'fun'
) constructor { });

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-5",
    CatspeakTokenV3.FUN, @'func'
) constructor { });

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-6",
    CatspeakTokenV3.FUN, @'fnc'
) constructor { });

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-7",
    CatspeakTokenV3.FUN, @'funct'
) constructor { });

test_add(function () : TestLexerKeyword("lexer-config-custom-keyword-8",
    CatspeakTokenV3.FUN, @'function'
) constructor { });