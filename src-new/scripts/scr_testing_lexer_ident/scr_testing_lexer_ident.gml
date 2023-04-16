
//# feather use syntax-errors

run_test(function() : TestLexerToken("lexer-ident",
    CatspeakToken.IDENT, "cool", "cool"
) constructor { });

run_test(function() : TestLexerToken("lexer-ident-2",
    CatspeakToken.IDENT, "abc_2", "abc_2"
) constructor { });

run_test(function() : TestLexerToken("lexer-ident-3",
    CatspeakToken.IDENT, "__karkitty", "__karkitty"
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-literal",
    CatspeakToken.IDENT, "`🙀abc`", "🙀abc"
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-literal-2",
    CatspeakToken.IDENT, "`>>=`", ">>="
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-literal-3",
    CatspeakToken.IDENT, "`1_+_2_=_?`", "1_+_2_=_?"
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-literal-malformed",
    CatspeakToken.IDENT, "`🙀abc", "🙀abc"
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-literal-malformed-2",
    CatspeakToken.IDENT, "`>>=", ">>="
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-literal-malformed-3",
    CatspeakToken.IDENT, "`1_+_2_=_?", "1_+_2_=_?"
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-op",
    CatspeakToken.OP_ADD, "++", "++"
) constructor { });

run_test(function() : TestLexerToken("lexer-tokens-ident-op-2",
    CatspeakToken.OP_COMP, "<=>", "<=>"
) constructor { });