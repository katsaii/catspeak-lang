//! A place where experimental tests can be conducted.

//# feather use syntax-errors

if (os_browser != browser_not_a_browser) {
    // ignore HTML5
    exit;
}

catspeak_force_init();

var runExperiment = "catspeak4";
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
    var f = Catspeak.compile(ir);
    show_message([f(), f]);
    show_message([ir]);
}

TEST_EXPERIMENT "compiler-2" {
    var buff = __catspeak_create_buffer_from_string(@'let a = fun () { let b = "hiiiii"; b } ; a ');
    var ir = Catspeak.parse(buff);
    var f = Catspeak.compile(ir);
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
    var f = Catspeak.compile(ir);
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
    var f = Catspeak.compile(ir);
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
    var f = env.compile(ir);
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
    var f = env.compile(ir);
    global.n = 10;
    f();
    show_message([global.hello, global.n]);
}

TEST_EXPERIMENT "env" {
    var env = new CatspeakEnvironment();
    env.getInterface().exposeFunction("print", show_message);
    var f = env.compile(env.parseString(@'
        print(self.id);
    '));
    with ({ something : 1 }) {
        f.setSelf(self);
        f();
    }
}

TEST_EXPERIMENT "moss" {
    var env = new CatspeakEnvironment();
    var startParse = get_timer();
    var ir = env.parseString(@'
        do { let s = { get_self : fun() { self }, "hi" : "hello" };
        s.get_self(); }
    ');
    var endParse = get_timer();
    var startComp = get_timer();
    var f = env.compile(ir);
    var endComp = get_timer();
    //show_message([
    //    (endParse - startParse) / 1000000,
    //    (endComp - startComp) / 1000000,
    //]);
    //show_message(f());
}

TEST_EXPERIMENT "catch" {
    var env = new CatspeakEnvironment();
    env.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
    var ir = env.parseString(@'
        -- GML-style try/catch (instead of `try`, use a `do` block)
        do {
          throw { message : "hi" }
        } catch err {
          show_message("something went wrong!:")
          show_message(err.message)
          throw "propagate error"
        } catch err { -- re-define error val
          show_message(err)
        }
    ');
    var a = 123;
    var f = env.compile(ir);
    f();
}

TEST_EXPERIMENT "err" {
    var env = new CatspeakEnvironment();
    env.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
    var ir = env.parseString(@'
        let n = 1;
        --let n = 2;
        return ("a" - "b")
    ', "testfile.meow");
    var f = env.compile(ir);
    show_message(f());
}

TEST_EXPERIMENT "catspeak4" {
    var buff = buffer_create(1, buffer_grow, 1);
    var writer = new CatspeakCartWriter(buff);
    writer.emitConstBool(false);
    writer.emitConstString("hello |");
    writer.emitConstString(" youtube");
    writer.emitAdd();
    writer.emitConstNumber(5);
    writer.emitConstNumber(8);
    writer.emitSubtract();
    writer.emitIfThenElse();
    writer.emitClosure();
    writer.finalise();
    buffer_seek(buff, buffer_seek_start, 0);
    show_message(catspeak_cart_disassemble(buff));
    buffer_seek(buff, buffer_seek_start, 0);
    var codegen = new CatspeakCodegenGML();
    var reader = new CatspeakCartReader(buff, codegen);
    do {
        var moreRemains = reader.readInstr();
    } until (!moreRemains);
    var program = codegen.getProgram();
    //show_message(program);
    var result = program();
    //show_message(result);
    result()
/*
    __gc_force_init();
    GC_START;
    var runTime = 120;
    var frame = 0;
    var countTotal_ = 0;
    while (frame < runTime) {
    var expectTime = get_timer() + game_get_speed(gamespeed_microseconds);
    while (get_timer() < expectTime) {
        result();
        countTotal_ += 1;
    }
    frame +=1;
    }
    GC_LOG;
    show_message("Catspeak avg. n = " + string(countTotal_ / runTime));
*/
}