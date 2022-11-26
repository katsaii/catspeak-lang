
run_test(function() : AsyncTest("op-arithmetic") constructor {
    catspeak_compile_string("1+2+4+8^1+2+4+8*4").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq((1 + 2 + 4 + 8) ^ (1 + 2 + 4 + (8 * 4)), result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("op-and") constructor {
    catspeak_compile_string(@'
        false and failure()
        true and 5000
    ').andThen(function(ir) {
        ir.setGlobal("failure", function() {
            fail().withMessage("failed to short-circuit 'and'");
        });
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(5000, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("op-and-chain") constructor {
    catspeak_compile_string(@'
        true and 1 and "wah"
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("wah", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("op-or") constructor {
    catspeak_compile_string(@'
        true or failure()
        false or "wtf"
    ').andThen(function(ir) {
        ir.setGlobal("failure", function() {
            fail().withMessage("failed to short-circuit 'or'");
        });
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("wtf", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("op-or-chain") constructor {
    catspeak_compile_string(@'
        false or 0 or "hi"
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("hi", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("op-and-or-chain") constructor {
    catspeak_compile_string(@'
        let even = true
        let odd = false
        even and odd or "schmeven"
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("schmeven", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});