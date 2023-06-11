
//# feather use syntax-errors

function TestCodegenGML(name, src) : Test(name) constructor {
    var buff = __catspeak_create_buffer_from_string(src);
    var lexer = new CatspeakLexer(buff);
    var builder = new CatspeakASGBuilder();
    var parser = new CatspeakParser(lexer, builder);
    var moreToParse;
    do {
        moreToParse = parser.update();
    } until (!moreToParse);
    buffer_delete(buff);
    var compiler = new CatspeakGMLCompiler(builder.get());
    do {
        self.gmlFunc = compiler.update();
    } until (self.gmlFunc != undefined);
}

function TestCodegenGMLResult(name, src, result) : TestCodegenGML(
    name, src
) constructor {
    assertEq(result, self.gmlFunc());
}