
//# feather use syntax-errors

function TestCodegenGML(name, src) : Test(name) constructor {
    var strBuff = catspeak_buffer_create_from_string(src);
    var writer = new CatspeakCartWriter();
    var parser = new CatspeakParser(writer, new CatspeakLexer(strBuff));
    do {
        var keepParsing = parser.parseOnce() == undefined;
    } until (!keepParsing);
    writer.path = name;
    var cart = writer.finalise();
    buffer_delete(strBuff);
    buffer_seek(cart, buffer_seek_start, 0);
    var codegen = new CatspeakGenGML();
    var reader = new CatspeakCartReader(cart, codegen);
    do {
        var keepReading = reader.readInstr();
    } until (!keepReading);
    gmlFunc = codegen.finalise();
}

function TestCodegenGMLResult(name, src, result) : TestCodegenGML(
    name, src
) constructor {
    assertEq(result, self.gmlFunc());
}