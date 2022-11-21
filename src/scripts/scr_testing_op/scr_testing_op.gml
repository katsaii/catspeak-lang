
run_test(function() : AsyncTest("op-arithmetic") constructor {
    catspeak_compile_string("1+2+4+8^1+2+4+8*4").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq((1 + 2 + 4 + 8) ^ (1 + 2 + 4 + (8 * 4)), result);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});