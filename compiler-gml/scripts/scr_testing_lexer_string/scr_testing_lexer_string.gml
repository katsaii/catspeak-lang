
//# feather use syntax-errors

test_add(function () : TestLexerToken("lexer-string",
    CatspeakTokenV3.VALUE, @'"a"', "a"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-2",
    CatspeakTokenV3.VALUE, @'"A"', "A"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-3",
    CatspeakTokenV3.VALUE, @'"🙀"', "🙀"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-string-4",
    CatspeakTokenV3.VALUE, @'"\n"', "\n"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-raw",
    CatspeakTokenV3.VALUE, @'@"a"', "a"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-raw-2",
    CatspeakTokenV3.VALUE, @'@"A"', "A"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-raw-3",
    CatspeakTokenV3.VALUE, @'@"🙀"', "🙀"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-string-raw-4",
    CatspeakTokenV3.VALUE, @'@"\n"', @"\n"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-malformed-eol",
    CatspeakTokenV3.VALUE, @'"\', "\\"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-malformed-empty",
    CatspeakTokenV3.VALUE, @'"', ""
) constructor { });

test_add(function () : TestLexerToken("lexer-string-malformed",
    CatspeakTokenV3.VALUE, @'"a', "a"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-malformed-2",
    CatspeakTokenV3.VALUE, @'"A', "A"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-malformed-3",
    CatspeakTokenV3.VALUE, @'"🙀', "🙀"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-string-malformed-4",
    CatspeakTokenV3.VALUE, @'"\n', "\n"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-raw-malformed",
    CatspeakTokenV3.VALUE, @'@"a', "a"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-raw-malformed-2",
    CatspeakTokenV3.VALUE, @'@"A', "A"
) constructor { });

test_add(function () : TestLexerToken("lexer-string-raw-malformed-3",
    CatspeakTokenV3.VALUE, @'@"🙀', "🙀"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-string-raw-malformed-4",
    CatspeakTokenV3.VALUE, @'@"\n', @"\n"
) constructor { });

