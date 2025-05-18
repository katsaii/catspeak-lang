
//# feather use syntax-errors

function TestParserASG(name, src) : Test(name) constructor {
    self.src = src;

    static checkASG = function (ir) {
        var buff = __catspeak_create_buffer_from_string(src);
        var lexer = new CatspeakLexerV3(buff);
        var builder = new CatspeakIRBuilder();
        var parser = new CatspeakParser(lexer, builder);
        var moreToParse;
        do {
            moreToParse = parser.update();
        } until (!moreToParse);
        buffer_delete(buff);
        assertEq(builder.get(), ir, false);
    };
}

function TestParserASGValue(name, src, expect) : TestParserASG(
    name, src
) constructor {
    checkASG({
        root : {
            type : CatspeakTerm.VALUE,
            value : expect
        }
    });
};