
//# feather use syntax-errors

test_add(function () : TestLexerToken("lexer-numbers",
    CatspeakTokenV3.VALUE, "1", 1
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-2",
    CatspeakTokenV3.VALUE, "2._", 2
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-3",
    CatspeakTokenV3.VALUE, "3._4_", 3.4
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-4",
    CatspeakTokenV3.VALUE, "7_._", 7
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-5",
    CatspeakTokenV3.VALUE, "5_6_7__", 567
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char",
    CatspeakTokenV3.VALUE, "'a'", ord("a")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-2",
    CatspeakTokenV3.VALUE, "'A'", ord("A")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-3",
    CatspeakTokenV3.VALUE, "'🙀'", ord("🙀")
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-numbers-char-malformed-eof",
    CatspeakTokenV3.VALUE, "'", 0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-malformed",
    CatspeakTokenV3.VALUE, "'a'", ord("a")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-malformed-2",
    CatspeakTokenV3.VALUE, "'A'", ord("A")
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-char-malformed-3",
    CatspeakTokenV3.VALUE, "'🙀'", ord("🙀")
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-numbers-binary",
    CatspeakTokenV3.VALUE, "0b0110", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscore",
    CatspeakTokenV3.VALUE, "0b01_10", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscores",
    CatspeakTokenV3.VALUE, "0b__0110", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscores-2",
    CatspeakTokenV3.VALUE, "0b0110__", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-underscores-3",
    CatspeakTokenV3.VALUE, "0b__01_1_0__", 6
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-32-1",
    CatspeakTokenV3.VALUE,
    "0b01001001001010111101010111010100",
    1227609556
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-32-2",
    CatspeakTokenV3.VALUE,
    "0b01001001011010101010010010010101",
    1231725717
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-64-none",
    CatspeakTokenV3.VALUE,
    "0b0000000000000000000000000000000000000000000000000000000000000000",
    0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-64-some",
    CatspeakTokenV3.VALUE,
    "0b0000000000000000000000000000000001001001011010101010010010010101",
    1231725717
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-binary-128-none",
    CatspeakTokenV3.VALUE,
    "0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
    0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex",
    CatspeakTokenV3.VALUE, "0xDEADBEEF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-mixed-case",
    CatspeakTokenV3.VALUE, "0xdEaDbEeF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-mixed-case",
    CatspeakTokenV3.VALUE, "0xDeAdBeEf", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscore",
    CatspeakTokenV3.VALUE, "0xDEAD_BEEF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscores",
    CatspeakTokenV3.VALUE, "0x__DEADBEEF", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscores-2",
    CatspeakTokenV3.VALUE, "0xDEADBEEF__", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-underscores-3",
    CatspeakTokenV3.VALUE, "0x__DEAD_BEEF__", 3735928559
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-64-none",
    CatspeakTokenV3.VALUE, "0x0000000000000000", 0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-64-some",
    CatspeakTokenV3.VALUE, "0x00000000EEEEAAAA", 4008618666
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-hex-128-none",
    CatspeakTokenV3.VALUE, "0x00000000000000000000000000000000", 0
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-red",
    CatspeakTokenV3.VALUE, "#FF0000", #FF0000
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-green",
    CatspeakTokenV3.VALUE, "#00FF00", #00FF00
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-blue",
    CatspeakTokenV3.VALUE, "#0000FF", #0000FF
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-alpha",
    CatspeakTokenV3.VALUE, "#000000FF", 0xFF000000
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-red-short",
    CatspeakTokenV3.VALUE, "#F00", #FF0000
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-green-short",
    CatspeakTokenV3.VALUE, "#0F0", #00FF00
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-blue-short",
    CatspeakTokenV3.VALUE, "#00F", #0000FF
) constructor { });

test_add(function () : TestLexerToken("lexer-numbers-colour-alpha-short",
    CatspeakTokenV3.VALUE, "#000F", 0xFF000000
) constructor { });