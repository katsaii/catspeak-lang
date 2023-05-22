
//# feather use syntax-errors

test_add(function() : Test("lexer-config-offset") constructor {
    var buff = __catspeak_create_buffer_from_string(@'hello world :3');
    var lexer = new CatspeakLexer(buff, 6);
    // identifier
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("world", lexer.getLexeme());
    // whitespace
    assertEq(CatspeakToken.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    // colon
    assertEq(CatspeakToken.COLON, lexer.nextWithWhitespace());
    assertEq(":", lexer.getLexeme());
    // number
    assertEq(CatspeakToken.NUMBER, lexer.nextWithWhitespace());
    assertEq("3", lexer.getLexeme());
    // eof
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
});

test_add(function() : Test("lexer-config-offset-2") constructor {
    var buff = __catspeak_create_buffer_from_string(@'hello world :3');
    var lexer = new CatspeakLexer(buff, 6, 5);
    // identifier
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("world", lexer.getLexeme());
    // eof
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
});

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword",
    CatspeakToken.FUN, @'\'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-2",
    CatspeakToken.FUN, @'f'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-3",
    CatspeakToken.FUN, @'fn'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-4",
    CatspeakToken.FUN, @'fun'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-5",
    CatspeakToken.FUN, @'func'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-6",
    CatspeakToken.FUN, @'fnc'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-7",
    CatspeakToken.FUN, @'funct'
) constructor { });

test_add(function() : TestLexerKeyword("lexer-config-custom-keyword-8",
    CatspeakToken.FUN, @'function'
) constructor { });