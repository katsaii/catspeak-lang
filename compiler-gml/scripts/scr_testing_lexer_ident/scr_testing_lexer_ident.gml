
//# feather use syntax-errors

test_add(function () : TestLexerToken("lexer-ident",
    CatspeakTokenV3.IDENT, "cool", "cool"
) constructor { });

test_add(function () : TestLexerToken("lexer-ident-2",
    CatspeakTokenV3.IDENT, "abc_2", "abc_2"
) constructor { });

test_add(function () : TestLexerToken("lexer-ident-3",
    CatspeakTokenV3.IDENT, "__karkitty", "__karkitty"
) constructor { });

test_add(function () : TestLexerToken("lexer-tokens-ident-literal",
    CatspeakTokenV3.IDENT, "`🙀abc`", "🙀abc"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerToken("lexer-tokens-ident-literal-2",
    CatspeakTokenV3.IDENT, "`>>=`", ">>="
) constructor { });

test_add(function () : TestLexerToken("lexer-tokens-ident-literal-3",
    CatspeakTokenV3.IDENT, "`1_+_2_=_?`", "1_+_2_=_?"
) constructor { });

test_add(function () : TestLexerTokenNegative("lexer-tokens-ident-literal-malformed",
    CatspeakTokenV3.IDENT, "`🙀abc", "🙀abc"
) constructor { }, IgnorePlatform.HTML5);

test_add(function () : TestLexerTokenNegative("lexer-tokens-ident-literal-malformed-2",
    CatspeakTokenV3.IDENT, "`>>=", ">>="
) constructor { });

test_add(function () : TestLexerTokenNegative("lexer-tokens-ident-literal-malformed-3",
    CatspeakTokenV3.IDENT, "`1_+_2_=_?", "1_+_2_=_?"
) constructor { });

test_add(function () : TestLexerToken("lexer-tokens-ident-op",
    CatspeakTokenV3.PLUS, "+", "+"
) constructor { });

test_add(function () : TestLexerToken("lexer-tokens-ident-op-2",
    CatspeakTokenV3.LESS_EQUAL, "<=", "<="
) constructor { });