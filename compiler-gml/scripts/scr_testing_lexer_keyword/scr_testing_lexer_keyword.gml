
//# feather use syntax-errors

test_add(function () : TestLexerToken("lexer-keyword-comment",
    CatspeakTokenV3.COMMENT, "--", "--"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-assign",
    CatspeakTokenV3.ASSIGN, "=", "="
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-colon",
    CatspeakTokenV3.COLON, ":", ":"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-break-line",
    CatspeakTokenV3.SEMICOLON, ";", ";"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-dot",
    CatspeakTokenV3.DOT, ".", "."
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-do",
    CatspeakTokenV3.DO, "do", "do"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-if",
    CatspeakTokenV3.IF, "if", "if"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-else",
    CatspeakTokenV3.ELSE, "else", "else"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-catch",
    CatspeakTokenV3.CATCH, "catch", "catch"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-while",
    CatspeakTokenV3.WHILE, "while", "while"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-for",
    CatspeakTokenV3.FOR, "for", "for"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-loop",
    CatspeakTokenV3.LOOP, "loop", "loop"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-match",
    CatspeakTokenV3.MATCH, "match", "match"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-let",
    CatspeakTokenV3.LET, "let", "let"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-fun",
    CatspeakTokenV3.FUN, "fun", "fun"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-break",
    CatspeakTokenV3.BREAK, "break", "break"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-continue",
    CatspeakTokenV3.CONTINUE, "continue", "continue"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-return",
    CatspeakTokenV3.RETURN, "return", "return"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-throw",
    CatspeakTokenV3.THROW, "throw", "throw"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-and",
    CatspeakTokenV3.AND, "and", "and"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-or",
    CatspeakTokenV3.OR, "or", "or"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-xor",
    CatspeakTokenV3.XOR, "xor", "xor"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-new",
    CatspeakTokenV3.NEW, "new", "new"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-impl",
    CatspeakTokenV3.IMPL, "impl", "impl"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-self",
    CatspeakTokenV3.SELF, "self", "self"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-other",
    CatspeakTokenV3.OTHER, "other", "other"
) constructor { });