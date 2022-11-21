
run_test(function() : AsyncTest("if-elseif-else") constructor {
    catspeak_compile_string(@'
        a = 3
        b = 5
        let c;
        if (a > b) {
            c = "greater"
        } else if (a < b) {
            c = "less"
        } else {
            c = "equal"
        }
        return c
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("less", result);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});