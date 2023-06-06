
//# feather use syntax-errors

test_add(function() : TestLexerToken("lexer-string",
    CatspeakToken.VALUE, @'"a"', "a"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-2",
    CatspeakToken.VALUE, @'"A"', "A"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-3",
    CatspeakToken.VALUE, @'"🙀"', "🙀"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-4",
    CatspeakToken.VALUE, @'"\n"', "\n"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw",
    CatspeakToken.VALUE, @'@"a"', "a"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-2",
    CatspeakToken.VALUE, @'@"A"', "A"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-3",
    CatspeakToken.VALUE, @'@"🙀"', "🙀"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-4",
    CatspeakToken.VALUE, @'@"\n"', @"\n"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-malformed-eol",
    CatspeakToken.VALUE, @'"\', "\\"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-malformed-empty",
    CatspeakToken.VALUE, @'"', ""
) constructor { });

test_add(function() : TestLexerToken("lexer-string-malformed",
    CatspeakToken.VALUE, @'"a', "a"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-malformed-2",
    CatspeakToken.VALUE, @'"A', "A"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-malformed-3",
    CatspeakToken.VALUE, @'"🙀', "🙀"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-malformed-4",
    CatspeakToken.VALUE, @'"\n', "\n"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-malformed",
    CatspeakToken.VALUE, @'@"a', "a"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-malformed-2",
    CatspeakToken.VALUE, @'@"A', "A"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-malformed-3",
    CatspeakToken.VALUE, @'@"🙀', "🙀"
) constructor { });

test_add(function() : TestLexerToken("lexer-string-raw-malformed-4",
    CatspeakToken.VALUE, @'@"\n', @"\n"
) constructor { });

