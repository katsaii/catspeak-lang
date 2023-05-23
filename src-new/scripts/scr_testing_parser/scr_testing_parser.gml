
//# feather use syntax-errors

function TestParserASG(name, src) : Test(name) constructor {
    self.src = src;

    static checkASG = function (asg) {
        var buff = __catspeak_create_buffer_from_string(src);
        var lexer = new CatspeakLexer(buff);
        var builder = new CatspeakASGBuilder();
        var parser = new CatspeakParser(lexer, builder);
        var moreToParse;
        do {
            moreToParse = parser.update();
        } until (!moreToParse);
        buffer_delete(buff);
        assertEq(builder.get(), asg, false);
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