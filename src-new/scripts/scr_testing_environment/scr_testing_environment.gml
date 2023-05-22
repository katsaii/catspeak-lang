
//# feather use syntax-errors

test_add(function() : Test("engine-tokenise") constructor {
    var engine = new CatspeakEnvironment();
    var buff = __catspeak_create_buffer_from_string(@'hello.world');
    var lexer = engine.tokenise(buff);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("hello", lexer.getLexeme());
    assertEq(CatspeakToken.DOT, lexer.next());
    assertEq(".", lexer.getLexeme());
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("world", lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.next());
    buffer_delete(buff);
});

test_add(function() : Test("engine-tokenise-2") constructor {
    var engine = new CatspeakEnvironment();
    var buff = __catspeak_create_buffer_from_string(@'hello.world');
    var lexer = engine.tokenise(buff, 3, 5);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("lo", lexer.getLexeme());
    assertEq(CatspeakToken.DOT, lexer.next());
    assertEq(".", lexer.getLexeme());
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("wo", lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.next());
    buffer_delete(buff);
});

test_add(function() : Test("engine-tokenise-keywords") constructor {
    var engine = new CatspeakEnvironment();
    catspeak_keywords_rename(
        engine.getKeywords(),
        "while", "world"
    );
    var buff = __catspeak_create_buffer_from_string(@'hello.world');
    var lexer = engine.tokenise(buff);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("hello", lexer.getLexeme());
    assertEq(CatspeakToken.DOT, lexer.next());
    assertEq(".", lexer.getLexeme());
    assertEq(CatspeakToken.WHILE, lexer.next());
    assertEq("world", lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.next());
    buffer_delete(buff);
});