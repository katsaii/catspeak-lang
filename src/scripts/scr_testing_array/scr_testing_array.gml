
//# feather use syntax-errors

run_test(function() : AsyncTest("array-literal") constructor {
    catspeak_compile_string(@'
        ["hello world", true, false]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("hello world", result[0]);
        assertEq(true, result[1]);
        assertEq(false, result[2]);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("array-literal-access") constructor {
    catspeak_compile_string(@'
        ["?:B"].[0]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("?:B", result);
    }).andCatch(function() {
        fail();
    }).andFinally(function() {
        complete();
    });
});