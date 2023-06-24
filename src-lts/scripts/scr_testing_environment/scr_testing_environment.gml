
//# feather use syntax-errors

test_add(function () : Test("engine-tokenise") constructor {
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

test_add(function () : Test("engine-tokenise-2") constructor {
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

test_add(function () : Test("engine-tokenise-keywords") constructor {
    var engine = new CatspeakEnvironment();
    engine.renameKeyword("while", "world");
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

test_add(function () : Test("engine-self-inst") constructor {
    var engine = new CatspeakEnvironment();
    var asg = engine.parseString(@'self');
    var gmlFunc = engine.compileGML(asg);
    var inst = instance_create_depth(0, 0, 0, obj_unit_test_inst);
    gmlFunc.setSelf(inst);
    assertEq(inst, gmlFunc());
    instance_destroy(inst);
});

test_add(function () : Test("engine-global-shared") constructor {
    var engine = new CatspeakEnvironment();
    var fA = engine.compileGML(engine.parseString(@'globalvar = 1;'));
    var fB = engine.compileGML(engine.parseString(@'globalvar'));
    var s = { };
    fA.setGlobals(s);
    fB.setGlobals(s);
    fA();
    assertEq(1, fB());
});

test_add(function () : Test("engine-global-shared-2") constructor {
    var engine = new CatspeakEnvironment();
    engine.enableSharedGlobal(true);
    var fA = engine.compileGML(engine.parseString(@'globalvar = 1;'));
    var fB = engine.compileGML(engine.parseString(@'globalvar'));
    fA();
    assertEq(1, fB());
});

test_add(function () : Test("engine-delete-keyword") constructor {
    var engine = new CatspeakEnvironment();
    engine.removeKeyword("fun");
    var buff = __catspeak_create_buffer_from_string("fun");
    var lexer = engine.tokenise(buff);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("fun", lexer.getLexeme());
    assertEq("fun", lexer.getValue());
    buffer_delete(buff);
});

test_add(function () : Test("engine-struct-not-terminated") constructor {
    var engine = new CatspeakEnvironment();
    var asg = engine.parseString(@'
        return {
            foo: "bar",
            a_number: 0,
            a_string: "Hello World!"
        }
    ');
    var func = engine.compileGML(asg);
    var result = func();
    assertEq(result, { foo : "bar", a_number : 0, a_string : "Hello World!" });
});

test_add(function () : Test("engine-function-brace-style") constructor {
    var engine = new CatspeakEnvironment();
    var fA = engine.compileGML(engine.parseString(@'
        main = fun()
        {
            return "hi"
        }
    '));
    var fB = engine.compileGML(engine.parseString(@'
        main = fun() {
            return "hi"
        }
    '));
    fA();
    fB();
    assertEq(fA.getGlobals().main(), fB.getGlobals().main());
    assertEq("hi", fA.getGlobals().main());
    assertEq("hi", fB.getGlobals().main());
});