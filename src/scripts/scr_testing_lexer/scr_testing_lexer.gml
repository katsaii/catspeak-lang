
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

function TestLexerKeyword(name, token, src) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var customKeywords = { };
    customKeywords[$ src] = token;
    var lexer = new CatspeakLexer(buff, , , customKeywords);
    assertEq(token, lexer.next());
    assertEq(src, lexer.getLexeme());
    // part 2
    var customKeywords2 = __catspeak_keywords_create();
    var tokenName = __catspeak_keywords_find_name(customKeywords2, token);
    __catspeak_keywords_rename(customKeywords2, tokenName, src);
    var lexer2 = new CatspeakLexer(buff, , , customKeywords2);
    assertEq(token, lexer2.next());
    assertEq(src, lexer2.getLexeme());
    buffer_delete(buff);
}