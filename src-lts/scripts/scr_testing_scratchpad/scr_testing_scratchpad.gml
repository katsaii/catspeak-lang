//! A place where experimental tests can be conducted.

//# feather use syntax-errors

if (os_browser != browser_not_a_browser) {
    // ignore HTML5
    exit;
}

catspeak_force_init();

var runExperiment = "unf";
#macro TEST_EXPERIMENT if runExperiment ==

TEST_EXPERIMENT "lexer" {
    var buff = __catspeak_create_buffer_from_string(@'1 2._ 3._4_ 5_6_7__');
    var lexer = new CatspeakLexer(buff);
    lexer.nextWithWhitespace(); // 1
    show_message([lexer.getLexeme(), lexer.getValue()]);
    lexer.nextWithWhitespace(); // whitespace
    lexer.nextWithWhitespace(); // 2._
    show_message([lexer.getLexeme(), lexer.getValue()]);
    lexer.nextWithWhitespace(); // whitespace
    lexer.nextWithWhitespace(); // 3._4_
    show_message([lexer.getLexeme(), lexer.getValue()]);
    lexer.nextWithWhitespace(); // whitespace
    lexer.nextWithWhitespace(); // 5_6_7__
    show_message([lexer.getLexeme(), lexer.getValue()]);
}

TEST_EXPERIMENT "parser" {
    var buff = __catspeak_create_buffer_from_string(@'123_4.5');
    var lexer = new CatspeakLexer(buff);
    var builder = new CatspeakIRBuilder();
    var parser = new CatspeakParser(lexer, builder);
    parser.parseExpression();
    show_message(builder.get());
}

TEST_EXPERIMENT "parser-2" {
    var buff = __catspeak_create_buffer_from_string(@'1 2 3 4');
    var ir = Catspeak.parse(buff);
    show_message(ir);
}

TEST_EXPERIMENT "parser-3" {
    var buff = __catspeak_create_buffer_from_string(@'1 a 2');
    var ir = Catspeak.parse(buff);
    show_message(json_stringify(ir)); //, true));
}

TEST_EXPERIMENT "compiler" {
    var buff = __catspeak_create_buffer_from_string(@'1 2 3 4');
    var ir = Catspeak.parse(buff);
    var f = Catspeak.compileGML(ir);
    show_message([f(), f]);
    show_message([ir]);
}

TEST_EXPERIMENT "compiler-2" {
    var buff = __catspeak_create_buffer_from_string(@'let a = fun () { let b = "hiiiii"; b } ; a ');
    var ir = Catspeak.parse(buff);
    var f = Catspeak.compileGML(ir);
    show_message(json_stringify(ir)); //, true));
    show_message([f(), f()()]);
}

TEST_EXPERIMENT "compiler-3" {
    var buff = __catspeak_create_buffer_from_string(@'
        let a = 0;
        -- if (a) {
        --   "hi"
        -- } else {
        --    "thoust";
        -- }
        while (a) {
        }
    ');
    var ir = Catspeak.parse(buff);
    var f = Catspeak.compileGML(ir);
    show_message(json_stringify(ir)); //, true));
    show_message(f());
}

TEST_EXPERIMENT "compiler-4" {
    var buff = __catspeak_create_buffer_from_string(@'
    
        while true {
            break "hello"
        }
    ');
    var ir = Catspeak.parse(buff);
    show_message(json_stringify(ir)); //, true));
    var f = Catspeak.compileGML(ir);
    show_message(f());
    
}

TEST_EXPERIMENT "compiler-5" {
    var buff = __catspeak_create_buffer_from_string(@'
        let a = [1, 2, 3, "five", false undefined, { "a" : 1, ["be"] : 5, cee : 89  hi }]
        
        let f = fun (yippee) {
            return yippee;
        }
        
        a[6].be = -3
        let b = max(1.3, f(2));
        return [b, typeof(b)]
    ');
    var env = new CatspeakEnvironment();
    env.applyPreset(CatspeakPreset.TYPE, CatspeakPreset.MATH);
    var ir = env.parse(buff);
    //show_message(json_stringify(ir, true));
    var f = env.compileGML(ir);
    show_message(f());
    
}

TEST_EXPERIMENT "compiler-6" {
    var buff = __catspeak_create_buffer_from_string(@'
        global.hello = "hi";
        global.n += 1;
    ');
    var env = new CatspeakEnvironment();
    env.getInterface().exposeConstant(
        "global", catspeak_special_to_struct(global)
    );
    var ir = env.parse(buff);
    var f = env.compileGML(ir);
    global.n = 10;
    f();
    show_message([global.hello, global.n]);
}

TEST_EXPERIMENT "env" {
    var env = new CatspeakEnvironment();
    env.getInterface().exposeFunction("print", show_message);
    var f = env.compileGML(env.parseString(@'
        print(self.id);
    '));
    with ({ something : 1 }) {
        f.setSelf(self);
        f();
    }
}