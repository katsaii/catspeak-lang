
//# feather use syntax-errors

test_add(function () : Test("lexer-whitespace-sensitive-ident") constructor {
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

test_add(function () : TestLexerToken("lexer-whitespace-space",
    CatspeakToken.WHITESPACE, " ", " "
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-tab",
    CatspeakToken.WHITESPACE, "\t", "\t"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-line-feed",
    CatspeakToken.WHITESPACE, "\n", "\n"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-vtab",
    CatspeakToken.WHITESPACE, "\v", "\v"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-form-feed",
    CatspeakToken.WHITESPACE, "\f", "\f"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-carriage-return",
    CatspeakToken.WHITESPACE, "\r", "\r"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-next-line",
    CatspeakToken.WHITESPACE, "\u85", "\u85"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-break-line",
    CatspeakToken.SEMICOLON, ";", ";"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-continue-line",
    CatspeakToken.WHITESPACE, "...", "..."
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-comment",
    CatspeakToken.COMMENT, "-- hello world", "-- hello world"
) constructor { });

test_add(function () : Test("lexer-whitespace-legacy-line-continue") constructor {
    var buff = __catspeak_create_buffer_from_string(@'...
        let a = (
            1,
            2, ...
            3,
        )...
... ...
    ');
    var lexer = new CatspeakLexer(buff);
    var token;
    do {
        token = lexer.next();
        assertNeq(CatspeakToken.SEMICOLON, token);
    } until (token == CatspeakToken.EOF);
    buffer_delete(buff);
});