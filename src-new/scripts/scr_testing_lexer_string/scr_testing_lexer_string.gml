
//# feather use syntax-errors

run_test(function() : TestLexerToken("lexer-string",
    CatspeakToken.STRING, @'"a"', "a"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-2",
    CatspeakToken.STRING, @'"A"', "A"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-3",
    CatspeakToken.STRING, @'"🙀"', "🙀"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-4",
    CatspeakToken.STRING, @'"\n"', "\n"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw",
    CatspeakToken.STRING, @'@"a"', "a"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-2",
    CatspeakToken.STRING, @'@"A"', "A"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-3",
    CatspeakToken.STRING, @'@"🙀"', "🙀"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-4",
    CatspeakToken.STRING, @'@"\n"', @"\n"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-malformed-eol",
    CatspeakToken.STRING, @'"\', "\\"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-malformed-empty",
    CatspeakToken.STRING, @'"', ""
) constructor { });

run_test(function() : TestLexerToken("lexer-string-malformed",
    CatspeakToken.STRING, @'"a', "a"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-malformed-2",
    CatspeakToken.STRING, @'"A', "A"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-malformed-3",
    CatspeakToken.STRING, @'"🙀', "🙀"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-malformed-4",
    CatspeakToken.STRING, @'"\n', "\n"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-malformed",
    CatspeakToken.STRING, @'@"a', "a"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-malformed-2",
    CatspeakToken.STRING, @'@"A', "A"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-malformed-3",
    CatspeakToken.STRING, @'@"🙀', "🙀"
) constructor { });

run_test(function() : TestLexerToken("lexer-string-raw-malformed-4",
    CatspeakToken.STRING, @'@"\n', @"\n"
) constructor { });

