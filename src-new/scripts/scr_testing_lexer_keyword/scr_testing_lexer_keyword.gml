
//# feather use syntax-errors

run_test(function() : TestLexerToken("lexer-keyword-comment",
    CatspeakToken.COMMENT, "--", "--"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-assign",
    CatspeakToken.ASSIGN, "=", "="
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-colon",
    CatspeakToken.COLON, ":", ":"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-break-line",
    CatspeakToken.BREAK_LINE, ";", ";"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-dot",
    CatspeakToken.DOT, ".", "."
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-continue-line",
    CatspeakToken.CONTINUE_LINE, "...", "..."
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-do",
    CatspeakToken.DO, "do", "do"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-it",
    CatspeakToken.IT, "it", "it"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-if",
    CatspeakToken.IF, "if", "if"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-else",
    CatspeakToken.ELSE, "else", "else"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-while",
    CatspeakToken.WHILE, "while", "while"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-for",
    CatspeakToken.FOR, "for", "for"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-loop",
    CatspeakToken.LOOP, "loop", "loop"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-let",
    CatspeakToken.LET, "let", "let"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-fun",
    CatspeakToken.FUN, "fun", "fun"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-break",
    CatspeakToken.BREAK, "break", "break"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-continue",
    CatspeakToken.CONTINUE, "continue", "continue"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-return",
    CatspeakToken.RETURN, "return", "return"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-and",
    CatspeakToken.AND, "and", "and"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-or",
    CatspeakToken.OR, "or", "or"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-new",
    CatspeakToken.NEW, "new", "new"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-impl",
    CatspeakToken.IMPL, "impl", "impl"
) constructor { });

run_test(function() : TestLexerToken("lexer-keyword-self",
    CatspeakToken.SELF, "self", "self"
) constructor { });