
run_test(function() : AsyncTest("grouping-paren") constructor {
    catspeak_compile_string("(1 + (1 + 1))").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(3, result);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("grouping-box") constructor {
    catspeak_compile_string("[([([])])]").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        if (assertTypeof(result, "array").failed) {
            return;
        }
        if (assertTypeof(result[0], "array").failed) {
            return;
        }
        if (assertTypeof(result[0][0], "array").failed) {
            return;
        }
        assertEq(0, array_length(result[0][0]));
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("grouping-brace") constructor {
    catspeak_compile_string("{ [(1)] : { } }").andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        if (assertTypeof(result, "struct").failed) {
            return;
        }
        if (assertTypeof(result[$ "1"], "struct").failed) {
            return;
        }
        assertEq(1, variable_struct_names_count(result));
        assertEq(0, variable_struct_names_count(result[$ "1"]));
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});