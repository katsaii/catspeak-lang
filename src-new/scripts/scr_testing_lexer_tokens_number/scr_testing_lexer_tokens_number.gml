
//# feather use syntax-errors

run_test(function() : TestLexerToken("lexer-numbers",
    CatspeakToken.NUMBER, "1", 1
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-2",
    CatspeakToken.NUMBER, "2._", 2
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-3",
    CatspeakToken.NUMBER, "3._4_", 3.4
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-4",
    CatspeakToken.NUMBER, "7_._", 7
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-5",
    CatspeakToken.NUMBER, "5_6_7__", 567
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-char",
    CatspeakToken.NUMBER, "'a'", ord("a")
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-char-2",
    CatspeakToken.NUMBER, "'A'", ord("A")
) constructor { });

run_test(function() : TestLexerToken("lexer-numbers-char-3",
    CatspeakToken.NUMBER, "'🙀'", ord("🙀")
) constructor { });