
//# feather use syntax-errors

function TestLexerTokenStream(name, src) : Test(name) constructor {
    self.src = src;

    static checkTokens = function () {
        var buff = __catspeak_create_buffer_from_string(src);
        var lexer = new CatspeakLexer(buff);
        for (var i = 0; i < argument_count; i += 1) {
            var peeked = lexer.peek();
            var nexted = lexer.next();
            assertEq(argument[i], peeked);
            assertEq(argument[i], nexted);
            assertEq(peeked, nexted);
        }
        assertEq(CatspeakToken.EOF, lexer.next());
        buffer_delete(buff);
    };
}

function TestLexerToken(name, token, src, value) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var lexer = new CatspeakLexer(buff);
    assertEq(token, lexer.nextWithWhitespace());
    assertEq(src, lexer.getLexeme());
    assertEq(value, lexer.getValue());
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
}

function TestLexerUTF8(name, src) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var lexer = new CatspeakLexer(buff);
    var pos = 1;
    repeat (string_length(src)) {
        lexer.__advance();
        assertEq(string_char_at(src, pos), lexer.getLexeme());
        lexer.__clearLexeme();
        pos += 1;
    }
    buffer_delete(buff);
}

run_test(function() : Test("lexer-unicode") constructor {
    var buff = __catspeak_create_buffer_from_string(@'🙀會意字 abcde1');
    var lexer = new CatspeakLexer(buff);
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("🙀", lexer.getLexeme());
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("會", lexer.getLexeme());
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("意", lexer.getLexeme());
    // other
    assertEq(CatspeakToken.OTHER, lexer.nextWithWhitespace());
    assertEq("字", lexer.getLexeme());
    // whitespace
    assertEq(CatspeakToken.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    // identifier
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("abcde1", lexer.getLexeme());
    buffer_delete(buff);
});





run_test(function() : TestLexerTokenStream("lexer-stream",
    "return (fun (a, b) { a + b })"
) constructor {
    checkTokens(
        CatspeakToken.RETURN,
        CatspeakToken.PAREN_LEFT,
        CatspeakToken.FUN,
        CatspeakToken.PAREN_LEFT,
        CatspeakToken.IDENT,
        CatspeakToken.COMMA,
        CatspeakToken.IDENT,
        CatspeakToken.PAREN_RIGHT,
        CatspeakToken.BRACE_LEFT,
        CatspeakToken.IDENT,
        CatspeakToken.OP_ADD,
        CatspeakToken.IDENT,
        CatspeakToken.BRACE_RIGHT,
        CatspeakToken.PAREN_RIGHT
    )
});