
//# feather use syntax-errors

run_test(function() : AsyncTest("function-define") constructor {
    catspeak_compile_string("fun() { failure() }").andThen(function(ir) {
        ir.setGlobal("failure", function() {
            fail().withMessage("failed to contain function");
        });
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertInstanceof(result, "CatspeakFunction");
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("function-call") constructor {
    catspeak_compile_string(@'
        get_name = fun() { "Kat" }
        return get_name() ++ " " ++ get_name()
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("Kat Kat", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("function-call-side-effect") constructor {
    catspeak_compile_string(@'
        n = 0
        inc = fun() { n = it + 1 }
        inc(); inc(); inc()
        return n
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(3, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("function-args") constructor {
    catspeak_compile_string(@'
        add = fun(a, b) {
            return a + b
        }
        add 1, 3
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(1 + 3, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("function-recursion") constructor {
    catspeak_compile_string(@'
        factorial = fun n {
            if (n <= 1) {
                return 1;
            }
            return factorial(n - 1) * n
        }

        factorial 10
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(1 * 2 * 3 * 4 * 5 * 6 * 7 * 8 * 9 * 10, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("function-scope") constructor {
    catspeak_compile_string(@'
        a = 1;
        let b = 2;
        (fun() {
            c = 3
            let d = 4
        })()

        return [a, b, c, d]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(1, result[0]);
        assertEq(2, result[1]);
        assertEq(3, result[2]);
        assertEq(undefined, result[3]);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});