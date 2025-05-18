
//# feather use syntax-errors

test_add(function () : Test("lexer-whitespace-sensitive-ident") constructor {
    var buff = __catspeak_create_buffer_from_string(@'a bc d');
    var lexer = new CatspeakLexerV3(buff);
    assertEq(CatspeakTokenV3.IDENT, lexer.nextWithWhitespace());
    assertEq("a", lexer.getLexeme());
    assertEq(CatspeakTokenV3.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    assertEq(CatspeakTokenV3.IDENT, lexer.nextWithWhitespace());
    assertEq("bc", lexer.getLexeme());
    assertEq(CatspeakTokenV3.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    assertEq(CatspeakTokenV3.IDENT, lexer.nextWithWhitespace());
    assertEq("d", lexer.getLexeme());
    buffer_delete(buff);
});

test_add(function () : TestLexerToken("lexer-whitespace-space",
    CatspeakTokenV3.WHITESPACE, " ", " "
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-tab",
    CatspeakTokenV3.WHITESPACE, "\t", "\t"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-line-feed",
    CatspeakTokenV3.WHITESPACE, "\n", "\n"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-vtab",
    CatspeakTokenV3.WHITESPACE, "\v", "\v"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-form-feed",
    CatspeakTokenV3.WHITESPACE, "\f", "\f"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-carriage-return",
    CatspeakTokenV3.WHITESPACE, "\r", "\r"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-next-line",
    CatspeakTokenV3.WHITESPACE, "\u85", "\u85"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-break-line",
    CatspeakTokenV3.SEMICOLON, ";", ";"
) constructor { });

test_add(function () : TestLexerToken("lexer-whitespace-comment",
    CatspeakTokenV3.COMMENT, "-- hello world", "-- hello world"
) constructor { });

test_add(function () : Test("lexer-whitespace-legacy-line-continue") constructor {
    var buff = __catspeak_create_buffer_from_string(@' -- ...
        let a = (
            1,
            2, -- ...
            3,
        ) --...
--... ...
    ');
    var lexer = new CatspeakLexerV3(buff);
    var token;
    do {
        token = lexer.next();
        assertNeq(CatspeakTokenV3.SEMICOLON, token);
    } until (token == CatspeakTokenV3.EOF);
    buffer_delete(buff);
});