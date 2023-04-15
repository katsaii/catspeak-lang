
//# feather use syntax-errors

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

run_test(function() : TestLexerToken("lexer-whitespace-break-line",
    CatspeakToken.BREAK_LINE, ";", ";"
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-continue-line",
    CatspeakToken.CONTINUE_LINE, "...", "..."
) constructor { });

run_test(function() : TestLexerToken("lexer-whitespace-comment",
    CatspeakToken.COMMENT, "-- hello world", "-- hello world"
) constructor { });

run_test(function() : Test("lexer-whitespace-semicolon-insertion") constructor {
    var buff = __catspeak_create_buffer_from_string(@'...
        let a = (
            1,
            2, ... ;
            3,
        )...
... ...
    ');
    var lexer = new CatspeakLexer(buff);
    var token;
    do {
        token = lexer.next();
        assertNeq(CatspeakToken.BREAK_LINE, token);
    } until (token == CatspeakToken.EOF);
    buffer_delete(buff);
});