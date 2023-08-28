
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

test_add(function () : TestLexerToken("lexer-numbers-binary",
    CatspeakToken.VALUE, "0b0110", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscore",
    CatspeakToken.VALUE, "0b01_10", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscores",
    CatspeakToken.VALUE, "0b__0110", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscores-2",
    CatspeakToken.VALUE, "0b0110__", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscores-3",
    CatspeakToken.VALUE, "0b__01_1_0__", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-32-1",
    CatspeakToken.VALUE,
    "0b01001001001010111101010111010100",
    1227609556
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-32-2",
    CatspeakToken.VALUE,
    "0b01001001011010101010010010010101",
    1231725717
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-64-none",
    CatspeakToken.VALUE,
    "0b0000000000000000000000000000000000000000000000000000000000000000",
    0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-64-some",
    CatspeakToken.VALUE,
    "0b0000000000000000000000000000000001001001011010101010010010010101",
    1231725717
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-128-none",
    CatspeakToken.VALUE,
    "0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex",
    CatspeakToken.VALUE, "0xDEADBEEF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-mixed-case",
    CatspeakToken.VALUE, "0xdEaDbEeF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-mixed-case",
    CatspeakToken.VALUE, "0xDeAdBeEf", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscore",
    CatspeakToken.VALUE, "0xDEAD_BEEF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscores",
    CatspeakToken.VALUE, "0x__DEADBEEF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscores-2",
    CatspeakToken.VALUE, "0xDEADBEEF__", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscores-3",
    CatspeakToken.VALUE, "0x__DEAD_BEEF__", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-64-none",
    CatspeakToken.VALUE, "0x0000000000000000", 0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-64-some",
    CatspeakToken.VALUE, "0x00000000EEEEAAAA", 4008618666
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-128-none",
    CatspeakToken.VALUE, "0x00000000000000000000000000000000", 0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-red",
    CatspeakToken.VALUE, "#FF0000", #FF0000
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-green",
    CatspeakToken.VALUE, "#00FF00", #00FF00
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-blue",
    CatspeakToken.VALUE, "#0000FF", #0000FF
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-alpha",
    CatspeakToken.VALUE, "#000000FF", 0xFF000000
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-red-short",
    CatspeakToken.VALUE, "#F00", #FF0000
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-green-short",
    CatspeakToken.VALUE, "#0F0", #00FF00
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-blue-short",
    CatspeakToken.VALUE, "#00F", #0000FF
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-alpha-short",
    CatspeakToken.VALUE, "#000F", 0xFF000000
) constructor { });