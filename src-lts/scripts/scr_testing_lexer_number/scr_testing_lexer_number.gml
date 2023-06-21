
//# feather use syntax-errors

test_add(function () : TestLexerToken("lexer-numbers",
    CatspeakToken.VALUE, "1", 1
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-2",
    CatspeakToken.VALUE, "2._", 2
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-3",
    CatspeakToken.VALUE, "3._4_", 3.4
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-4",
    CatspeakToken.VALUE, "7_._", 7
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-5",
    CatspeakToken.VALUE, "5_6_7__", 567
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char",
    CatspeakToken.VALUE, "'a'", ord("a")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-2",
    CatspeakToken.VALUE, "'A'", ord("A")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-3",
    CatspeakToken.VALUE, "'🙀'", ord("🙀")
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-numbers-char-malformed-eof",
    CatspeakToken.VALUE, "'", 0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-malformed",
    CatspeakToken.VALUE, "'a'", ord("a")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-malformed-2",
    CatspeakToken.VALUE, "'A'", ord("A")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-malformed-3",
    CatspeakToken.VALUE, "'🙀'", ord("🙀")
) constructor { }, IgnorePlatform.HTML5);