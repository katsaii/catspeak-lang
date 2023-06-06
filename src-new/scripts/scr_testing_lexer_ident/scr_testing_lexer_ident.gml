
//# feather use syntax-errors

test_add(function() : TestLexerToken("lexer-ident",
    CatspeakToken.IDENT, "cool", "cool"
) constructor { });

test_add(function() : TestLexerToken("lexer-ident-2",
    CatspeakToken.IDENT, "abc_2", "abc_2"
) constructor { });

test_add(function() : TestLexerToken("lexer-ident-3",
    CatspeakToken.IDENT, "__karkitty", "__karkitty"
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-literal",
    CatspeakToken.IDENT, "`🙀abc`", "🙀abc"
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-literal-2",
    CatspeakToken.IDENT, "`>>=`", ">>="
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-literal-3",
    CatspeakToken.IDENT, "`1_+_2_=_?`", "1_+_2_=_?"
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-literal-malformed",
    CatspeakToken.IDENT, "`🙀abc", "🙀abc"
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-literal-malformed-2",
    CatspeakToken.IDENT, "`>>=", ">>="
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-literal-malformed-3",
    CatspeakToken.IDENT, "`1_+_2_=_?", "1_+_2_=_?"
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-op",
    CatspeakToken.PLUS, "+", "+"
) constructor { });

test_add(function() : TestLexerToken("lexer-tokens-ident-op-2",
    CatspeakToken.LESS_EQUAL, "<=", "<="
) constructor { });