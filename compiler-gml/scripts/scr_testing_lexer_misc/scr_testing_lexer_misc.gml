
//# feather use syntax-errors

test_add(function () : Test("lexer-misc-unicode") constructor {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字 abcde1');
    var lexer = new CatspeakLexerV3(buff);
    // other
    assertEq(CatspeakTokenV3.OTHER, lexer.nextWithWhitespace());
    assertEq("🙀", lexer.getLexeme());
    // other
    assertEq(CatspeakTokenV3.OTHER, lexer.nextWithWhitespace());
    assertEq("會", lexer.getLexeme());
    // other
    assertEq(CatspeakTokenV3.OTHER, lexer.nextWithWhitespace());
    assertEq("意", lexer.getLexeme());
    // other
    assertEq(CatspeakTokenV3.OTHER, lexer.nextWithWhitespace());
    assertEq("字", lexer.getLexeme());
    // whitespace
    assertEq(CatspeakTokenV3.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    // identifier
    assertEq(CatspeakTokenV3.IDENT, lexer.nextWithWhitespace());
    assertEq("abcde1", lexer.getLexeme());
    buffer_delete(buff);
}, IgnorePlatform.HTML5);

test_add(function () : TestLexerTokenStream("lexer-misc-example",
    "return (fun (a, b) { a + b })"
) constructor {
    checkTokens(
        CatspeakTokenV3.RETURN,
        CatspeakTokenV3.PAREN_LEFT,
        CatspeakTokenV3.FUN,
        CatspeakTokenV3.PAREN_LEFT,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.COMMA,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.PAREN_RIGHT,
        CatspeakTokenV3.BRACE_LEFT,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.PLUS,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.BRACE_RIGHT,
        CatspeakTokenV3.PAREN_RIGHT
    )
});

test_add(function () : TestLexerTokenStream("lexer-misc-example-2",
    @'
        count = 0
        limit = 10
        while (count < limit) {
            inc_count()
            count = count + 1
        }
        return count
    '
) constructor {
    checkTokens(
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.ASSIGN,
        CatspeakTokenV3.VALUE,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.ASSIGN,
        CatspeakTokenV3.VALUE,
        CatspeakTokenV3.WHILE,
        CatspeakTokenV3.PAREN_LEFT,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.LESS,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.PAREN_RIGHT,
        CatspeakTokenV3.BRACE_LEFT,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.PAREN_LEFT,
        CatspeakTokenV3.PAREN_RIGHT,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.ASSIGN,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.PLUS,
        CatspeakTokenV3.VALUE,
        CatspeakTokenV3.BRACE_RIGHT,
        CatspeakTokenV3.RETURN,
        CatspeakTokenV3.IDENT,
    )
});

test_add(function () : TestLexerTokenStream("lexer-misc-example-3",
    @'
        
        
        ; ;
        
         ; ;
        ;
        
 ; hi ; 
 ; ; ; ;
 
                                                        
    '
) constructor {
    checkTokens(
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.IDENT,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON,
        CatspeakTokenV3.SEMICOLON
    )
});