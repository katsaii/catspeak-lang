
//# feather use syntax-errors

test_add(function () : Test("env-tokenise") constructor {
    var env = new CatspeakEnvironment();
    var buff = __catspeak_create_buffer_from_string(@'hello.world');
    var lexer = env.tokenise(buff);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("hello", lexer.getLexeme());
    assertEq(CatspeakToken.DOT, lexer.next());
    assertEq(".", lexer.getLexeme());
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("world", lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.next());
    buffer_delete(buff);
});

test_add(function () : Test("env-tokenise-2") constructor {
    var env = new CatspeakEnvironment();
    var buff = __catspeak_create_buffer_from_string(@'hello.world');
    var lexer = env.tokenise(buff, 3, 5);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("lo", lexer.getLexeme());
    assertEq(CatspeakToken.DOT, lexer.next());
    assertEq(".", lexer.getLexeme());
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("wo", lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.next());
    buffer_delete(buff);
});

test_add(function () : Test("env-tokenise-keywords") constructor {
    var env = new CatspeakEnvironment();
    env.renameKeyword("while", "world");
    var buff = __catspeak_create_buffer_from_string(@'hello.world');
    var lexer = env.tokenise(buff);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("hello", lexer.getLexeme());
    assertEq(CatspeakToken.DOT, lexer.next());
    assertEq(".", lexer.getLexeme());
    assertEq(CatspeakToken.WHILE, lexer.next());
    assertEq("world", lexer.getLexeme());
    assertEq(CatspeakToken.EOF, lexer.next());
    buffer_delete(buff);
});

test_add(function () : Test("env-self-inst") constructor {
    var env = new CatspeakEnvironment();
    var asg = env.parseString(@'self');
    var gmlFunc = env.compileGML(asg);
    var inst = instance_create_depth(0, 0, 0, obj_unit_test_inst);
    gmlFunc.setSelf(inst);
    assertEq(catspeak_special_to_struct(inst), gmlFunc());
    instance_destroy(inst);
});

test_add(function () : Test("env-global-shared") constructor {
    var env = new CatspeakEnvironment();
    var fA = env.compileGML(env.parseString(@'globalvar = 1;'));
    var fB = env.compileGML(env.parseString(@'globalvar'));
    var s = { };
    fA.setGlobals(s);
    fB.setGlobals(s);
    fA();
    assertEq(1, fB());
});

test_add(function () : Test("env-global-shared-2") constructor {
    var env = new CatspeakEnvironment();
    env.enableSharedGlobal(true);
    var fA = env.compileGML(env.parseString(@'globalvar = 1;'));
    var fB = env.compileGML(env.parseString(@'globalvar'));
    fA();
    assertEq(1, fB());
});

test_add(function () : Test("env-delete-keyword") constructor {
    var env = new CatspeakEnvironment();
    env.removeKeyword("fun");
    var buff = __catspeak_create_buffer_from_string("fun");
    var lexer = env.tokenise(buff);
    assertEq(CatspeakToken.IDENT, lexer.next());
    assertEq("fun", lexer.getLexeme());
    assertEq("fun", lexer.getValue());
    buffer_delete(buff);
});

test_add(function () : Test("env-struct-not-terminated") constructor {
    var env = new CatspeakEnvironment();
    var asg = env.parseString(@'
        return {
            foo: "bar",
            a_number: 0,
            a_string: "Hello World!"
        }
    ');
    var func = env.compileGML(asg);
    var result = func();
    assertEq(result, { foo : "bar", a_number : 0, a_string : "Hello World!" });
});

test_add(function () : Test("env-function-brace-style") constructor {
    var env = new CatspeakEnvironment();
    var fA = env.compileGML(env.parseString(@'
        main = fun()
        {
            return "hi"
        }
    '));
    var fB = env.compileGML(env.parseString(@'
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

test_add(function () : Test("env-use-test") constructor {
    msg = "start";
    var env = new CatspeakEnvironment();
    env.addMethod("thing", function () {
        msg = "inside";
        return function () { msg = "end" };
    });
    env.addMethod("get_msg", function () {
        return msg;
    });
    var fA = env.compileGML(env.parseString(@'
        let a = get_msg();
        let b;
        use thing {
            b = get_msg();
        }
        let c = get_msg();
        [a, b, c]
    '));
    assertEq(["start", "inside", "end"], fA());
});

test_add(function () : Test("env-function-set-self") constructor {
    var env = new CatspeakEnvironment();
    var f = env.compileGML(env.parseString(@'
        return fun { self };
    '));
    var fun = f();
    fun.setSelf({ hi : "hi" });
    assertEq("hi", fun().hi);
});

function EngineFunctionMethodCallTest__Construct() constructor {
    // this is part of the below test, but needs to live in global scope
    // otherwise the name will be mangled
    str = "";
    static add = function(_str) {
        str += string(_str);
    }
}
test_add(function () : Test("env-function-method-call") constructor {
    var env = new CatspeakEnvironment();
    env.getInterface().exposeFunction("Construct", function() {
        return new EngineFunctionMethodCallTest__Construct();
    });
    var f = env.compileGML(env.parseString(@'
        let _inst = Construct();
        _inst.add("Woo!");
        _inst.add("Yeehaw!");
        _inst
    '));
    var inst = f();
    assertEq("EngineFunctionMethodCallTest__Construct", instanceof(inst));
    assertEq("Woo!Yeehaw!", inst.str);
});

test_add(function () : Test("global-custom-presets") constructor {
    catspeak_preset_add("test-preset", function (env) {
        env.getInterface().exposeFunction("double", function (n) { return 2 * n });
    });
    var env = new CatspeakEnvironment();
    env.applyPreset("test-preset");
    var f = env.compileGML(env.parseString(@'
        return double(103);
    '));
    assertEq(2 * 103, f());
});

test_add(function () : Test("env-properties") constructor {
    var env = new CatspeakEnvironment();
    var f = env.compileGML(env.parseString(@'
        let some_property = fun { 620 }

        return :some_property + 2 * :some_property
    '));
    assertEq(620 + 2 * 620, f());
});

test_add(function () : Test("env-properties-2") constructor {
    var env = new CatspeakEnvironment();
    var f = env.compileGML(env.parseString(@'
        count = 1
        let counter = fun {
            let res = count
            count *= 2
            return res
        }

        let a = :counter
        let b = :counter
        let c = :counter
        return { a, b, c }
    '));
    var result = f();
    assertEq(1, result.a);
    assertEq(2, result.b);
    assertEq(4, result.c);
});

test_add(function () : Test("env-properties-get-set") constructor {
    var env = new CatspeakEnvironment();
    var f = env.compileGML(env.parseString(@'
        value = 0
        let double = fun (x) {
            if x == undefined { value } else { value = 2 * x }
        }

        :double = 8
        let a = :double

        :double += 6
        let b = :double + :double

        return [a, b]
    '));
    var result = f();
    assertEq(2 * 8, result[0]);
    assertEq(2 * (2 * 8 + 6) + 2 * (2 * 8 + 6), result[1]);
});

test_add(function () : Test("env-pipe-left") constructor {
    var env = new CatspeakEnvironment();
    var f = env.compileGML(env.parseString(@'
        let f = fun (x) { return x * 2 }
        f <| 7
    '));
    assertEq(7 * 2, f());
});

test_add(function () : Test("env-pipe-right") constructor {
    var env = new CatspeakEnvironment();
    var f = env.compileGML(env.parseString(@'
        let f = fun (x) { return x + "world" }
        "hello" |> f
    '));
    assertEq("helloworld", f());
});

test_add(function () : Test("env-gm-asset") constructor {
    var env = new CatspeakEnvironment();
    var ffi = env.getInterface();
    ffi.exposeFunction("font_exists", font_exists);
    ffi.exposeAsset("fnt_testing");
    var asg = env.parseString(@'
        return font_exists(fnt_testing);
    ');
    var func = env.compileGML(asg);
    var result = func();
    assertEq(true, result);
});

test_add(function () : Test("env-gml-function") constructor {
    var env = new CatspeakEnvironment();
    var ffi = env.getInterface();
    ffi.exposeFunctionByName(is_string);
    var asg = env.parseString(@'
        return is_string("Hello World!");
    ');
    var func = env.compileGML(asg);
    var result = func();
    assertEq(true, result);
});

test_add(function () : Test("env-gml-function-by-substring") constructor {
    var env = new CatspeakEnvironment();
    var ffi = env.getInterface();
    ffi.exposeFunctionByPrefix("test_array");
    var asg = env.parseString(@'
        let array = [2, 2, 4];
        return test_array_sum(array);
    ');
    var func = env.compileGML(asg);
    var result = func();
    assertEq(8, result);
});

test_add(function () : Test("env-gml-function-by-substring-exist") constructor {
    var env = new CatspeakEnvironment();
    var ffi = env.getInterface();
    ffi.exposeFunctionByPrefix("test_array");
    var asg = env.parseString(@'
        return [
            test_array_sum,
            test_array_min,
            test_array_max,
            test_array_mean,
            test_array_median,
        ];
    ');
    var func = env.compileGML(asg);
    var result = func();
    assertNeq(undefined, result[0]);
    assertNeq(undefined, result[1]);
    assertNeq(undefined, result[2]);
    assertNeq(undefined, result[3]);
    assertNeq(undefined, result[4]);
    assert(is_method(result[0]));
    assert(is_method(result[1]));
    assert(is_method(result[2]));
    assert(is_method(result[3]));
    assert(is_method(result[4]));
});

test_add(function () : Test("env-gml-function-by-substring-not-exist") constructor {
    var env = new CatspeakEnvironment();
    var ffi = env.getInterface();
    ffi.exposeFunctionByPrefix("test_array");
    var asg = env.parseString(@'
        return test_struct_create;
    ');
    var func = env.compileGML(asg);
    var result = func();
    assertEq(undefined, result);
    assert(!is_method(result));
});

test_add(function () : Test("env-object-index") constructor {
    try {
        instance_create_depth(0, 0, 0, obj_unit_test_obj);
    } catch (e) {
        fail(e.message);
    }
});

test_add(function () : Test("env-else-if") constructor {
    var env = new CatspeakEnvironment();
    try {
        var asg = env.parseString(@'
            a = 1
            if (a == 1) {

            } else if (a == 2) {

            }
        ');
        env.compileGML(asg);
    } catch (e) {
        fail(e.message);
    }
});