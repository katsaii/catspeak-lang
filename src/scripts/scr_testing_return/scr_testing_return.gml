
//# feather use syntax-errors

run_test(function() : AsyncTest("return") constructor {
    catspeak_compile_string("return 1").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(1, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("return-implicit") constructor {
    catspeak_compile_string("2").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(2, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});