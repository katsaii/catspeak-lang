
//# feather use syntax-errors

run_test(function() : AsyncTest("prim-int") constructor {
    catspeak_compile_string("88888888").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(88888888, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("prim-float") constructor {
    catspeak_compile_string("1.5").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(1.5, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("prim-nan") constructor {
    catspeak_compile_string("NaN").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assert(is_nan(result)).withMessage("should be NaN");
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("prim-infinity") constructor {
    catspeak_compile_string("[infinity, -infinity]").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assert(is_infinity(result[0])).withMessage("should be infinity");
        assert(is_infinity(result[1])).withMessage("should be -infinity");
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("prim-bool") constructor {
    catspeak_compile_string("[true, false]").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(true, result[0]);
        assertEq(false, result[1]);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("prim-undefined") constructor {
    catspeak_compile_string("undefined").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(undefined, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("prim-null") constructor {
    catspeak_compile_string("null").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(pointer_null, result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});