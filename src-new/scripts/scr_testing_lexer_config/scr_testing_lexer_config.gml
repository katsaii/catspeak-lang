
//# feather use syntax-errors

run_test(function() : Test("lexer-config-offset") constructor {
    var buff = __catspeak_create_buffer_from_string(@'hello world :3');
    var lexer = new CatspeakLexer(buff, 6);
    // identifier
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("world", lexer.getLexeme());
    // whitespace
    assertEq(CatspeakToken.WHITESPACE, lexer.nextWithWhitespace());
    assertEq(" ", lexer.getLexeme());
    // colon
    assertEq(CatspeakToken.COLON, lexer.nextWithWhitespace());
    assertEq(":", lexer.getLexeme());
    // number
    assertEq(CatspeakToken.NUMBER, lexer.nextWithWhitespace());
    assertEq("3", lexer.getLexeme());
    // eof
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
});

run_test(function() : Test("lexer-config-offset-2") constructor {
    var buff = __catspeak_create_buffer_from_string(@'hello world :3');
    var lexer = new CatspeakLexer(buff, 6, 5);
    // identifier
    assertEq(CatspeakToken.IDENT, lexer.nextWithWhitespace());
    assertEq("world", lexer.getLexeme());
    // eof
    assertEq(CatspeakToken.EOF, lexer.nextWithWhitespace());
    buffer_delete(buff);
});