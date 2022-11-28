
//# feather use syntax-errors

run_test(function() : AsyncTest("stress-100") constructor {
    catspeak_compile_string(@'
        count = 0
        while (count < 100) {
            count = count + 1
        }
        count
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(100, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("stress-1000") constructor {
    catspeak_compile_string(@'
        count = 0
        while (count < 1000) {
            count = count + 1
        }
        count
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(1000, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("stress-10000") constructor {
    catspeak_compile_string(@'
        count = 0
        while (count < 10000) {
            count = count + 1
        }
        count
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(10000, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("stress-100000") constructor {
    catspeak_compile_string(@'
        count = 0
        while (count < 100000) {
            count = count + 1
        }
        count
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(100000, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});