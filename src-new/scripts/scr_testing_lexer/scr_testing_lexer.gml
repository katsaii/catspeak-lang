
run_test(function() : Test("lexer-tokens-unicode") constructor {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字 abcde1');
    var lexer = new CatspeakLexer(buff);
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("🙀", lexer.getLexeme());
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("會", lexer.getLexeme());
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("意", lexer.getLexeme());
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("字", lexer.getLexeme());
    // whitespace
    assertEq(CatspeakToken.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    // identifier
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("abcde1", lexer.getLexeme());
    buffer_delete(buff);
});

run_test(function() : Test("lexer-whitespace-sensitive-ident") constructor {
    var buff = __catspeak_create_buffer_from_string(@'a bc d');
    var lexer = new CatspeakLexer(buff);
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("a", lexer.getLexeme());
    assertEq(CatspeakToken.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("bc", lexer.getLexeme());
    assertEq(CatspeakToken.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("d", lexer.getLexeme());
    buffer_delete(buff);
});

function TestLexerWhitespace(name, token, src) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var lexer = new CatspeakLexer(buff);
    assertEq(token, lexer.nextWithWhitespace());
    assertEq(src, lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
}

run_test(function() : TestLexerWhitespace("lexer-whitespace-space",
    CatspeakToken.WHITESPACE, " "
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-tab",
    CatspeakToken.WHITESPACE, "\t"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-line-feed",
    CatspeakToken.BREAK_LINE, "\n"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-vtab",
    CatspeakToken.WHITESPACE, "\v"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-form-feed",
    CatspeakToken.WHITESPACE, "\f"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-carriage-return",
    CatspeakToken.BREAK_LINE, "\r"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-next-line",
    CatspeakToken.WHITESPACE, "\u85"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-break-line",
    CatspeakToken.BREAK_LINE, ";"
) constructor { });

run_test(function() : TestLexerWhitespace("lexer-whitespace-continue-line",
    CatspeakToken.CONTINUE_LINE, "..."
) constructor { });