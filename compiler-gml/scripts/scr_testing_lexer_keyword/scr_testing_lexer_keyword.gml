
//# feather use syntax-errors

test_add(function () : TestLexerToken("lexer-keyword-comment",
    CatspeakToken.COMMENT, "--", "--"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-assign",
    CatspeakToken.ASSIGN, "=", "="
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-colon",
    CatspeakToken.COLON, ":", ":"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-break-line",
    CatspeakToken.SEMICOLON, ";", ";"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-dot",
    CatspeakToken.DOT, ".", "."
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-do",
    CatspeakToken.DO, "do", "do"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-if",
    CatspeakToken.IF, "if", "if"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-else",
    CatspeakToken.ELSE, "else", "else"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-catch",
    CatspeakToken.CATCH, "catch", "catch"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-while",
    CatspeakToken.WHILE, "while", "while"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-for",
    CatspeakToken.FOR, "for", "for"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-loop",
    CatspeakToken.LOOP, "loop", "loop"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-match",
    CatspeakToken.MATCH, "match", "match"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-let",
    CatspeakToken.LET, "let", "let"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-fun",
    CatspeakToken.FUN, "fun", "fun"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-break",
    CatspeakToken.BREAK, "break", "break"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-continue",
    CatspeakToken.CONTINUE, "continue", "continue"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-return",
    CatspeakToken.RETURN, "return", "return"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-throw",
    CatspeakToken.THROW, "throw", "throw"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-and",
    CatspeakToken.AND, "and", "and"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-or",
    CatspeakToken.OR, "or", "or"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-xor",
    CatspeakToken.XOR, "xor", "xor"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-new",
    CatspeakToken.NEW, "new", "new"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-impl",
    CatspeakToken.IMPL, "impl", "impl"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-self",
    CatspeakToken.SELF, "self", "self"
) constructor { });

test_add(function () : TestLexerToken("lexer-keyword-other",
    CatspeakToken.OTHER, "other", "other"
) constructor { });