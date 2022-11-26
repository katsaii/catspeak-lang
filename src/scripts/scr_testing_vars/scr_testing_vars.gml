
//# feather use syntax-errors

run_test(function() : AsyncTest("vars-let") constructor {
    catspeak_compile_string(@'
        let a = "uwu"
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("uwu", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-let-default") constructor {
    catspeak_compile_string(@'
        let a
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(undefined, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-let-assign") constructor {
    catspeak_compile_string(@'
        let a = "uwu"
        a = "o_o"
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("o_o", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-let-it") constructor {
    catspeak_compile_string(@'
        let a = 10
        let b = 100
        a = it + b
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(110, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-let-it-twice") constructor {
    catspeak_compile_string(@'
        let a = 10
        a = it + it
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(20, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-global-read") constructor {
    f = function() { return "hi!! /(.0 x 0)\\"; };
    catspeak_compile_string("[const, func]").andThen(function(ir) {
        ir.setGlobal("const", -12);
        ir.setGlobalFunction("func", f);
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(-12, result[0]);
        assertEq(f, result[1]);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-global-read-2") constructor {
    catspeak_compile_string(@'
        a = -3
        b = 12
        c = a * b + -a
        d = max a, b, c
        return [a, b, c, d]
    ').andThen(function(ir) {
        ir.setGlobalFunction("max", max);
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(-3, result[0]);
        assertEq(12, result[1]);
        assertEq(-33, result[2]);
        assertEq(12, result[3]);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-global-write") constructor {
    catsFunc = undefined;
    catspeak_compile_string(@'
        zero = null
        snail = "<@_"
    ').andThen(function(ir) {
        catsFunc = ir;
        return catspeak_execute(ir);
    }).andThen(function() {
        assertEq(pointer_null, catsFunc.getGlobal("zero"));
        assertEq("<@_", catsFunc.getGlobal("snail"));
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-global-it") constructor {
    catspeak_compile_string(@'
        a = 10
        b = 100
        a = it + b
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(110, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("vars-global-it-twice") constructor {
    catspeak_compile_string(@'
        a = 10
        a = it + it
        return a
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(20, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});