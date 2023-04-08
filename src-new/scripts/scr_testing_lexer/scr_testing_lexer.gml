
function TestLexerToken(name, token, src, value) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var lexer = new CatspeakLexer(buff);
    assertEq(token, lexer.nextWithWhitespace());
    assertEq(src, lexer.getLexeme());
    assertEq(value, lexer.getValue());
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
}

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

run_test(function() : TestLexerToken("lexer-tokens-numbers",
    CatspeakToken.NUMBER, "1", 1
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-numbers-2",
    CatspeakToken.NUMBER, "2._", 2
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-numbers-3",
    CatspeakToken.NUMBER, "3._4_", 3.4
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-numbers-4",
    CatspeakToken.NUMBER, "7_._", 7
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-numbers-5",
    CatspeakToken.NUMBER, "5_6_7__", 567
) constructor { });

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

run_test(function() : TestLexerToken("lexer-whitespace-space",
    CatspeakToken.WHITESPACE, " ", " "
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-tab",
    CatspeakToken.WHITESPACE, "\t", "\t"
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-line-feed",
    CatspeakToken.BREAK_LINE, "\n", "\n"
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-vtab",
    CatspeakToken.WHITESPACE, "\v", "\v"
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-form-feed",
    CatspeakToken.WHITESPACE, "\f", "\f"
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-carriage-return",
    CatspeakToken.BREAK_LINE, "\r", "\r"
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-next-line",
    CatspeakToken.WHITESPACE, "\u85", "\u85"
) constructor { });

//run_test(function() : TestLexerToken("lexer-whitespace-break-line",
//    CatspeakToken.BREAK_LINE, ";"
//) constructor { });
//
//run_test(function() : TestLexerToken("lexer-whitespace-continue-line",
//    CatspeakToken.CONTINUE_LINE, "..."
//) constructor { });