
//# feather use syntax-errors

run_test(function() : AsyncTest("while-count-up") constructor {
    count = 0;
    catspeak_compile_string(@'
        count = 0
        limit = 10
        while (count < limit) {
            inc_count()
            count = count + 1
        }
        return count
    ').andThen(function(ir) {
        ir.setGlobal("inc_count", function() {
            count += 1;
        });
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(10, result);
        assertEq(count, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("while-break") constructor {
    catspeak_compile_string(@'
        while (true) {
            break
            failure()
        }
    ').andThen(function(ir) {
        ir.setGlobal("failure", function() {
            fail().withMessage("failed to break out of loop");
        });
        return catspeak_execute(ir);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("while-continue") constructor {
    catspeak_compile_string(@'
        count = 10
        while (count > 0) {
            count = count - 1

            continue
            failure()
        }
    ').andThen(function(ir) {
        ir.setGlobal("failure", function() {
            fail().withMessage("failed to continue loop");
        });
        return catspeak_execute(ir);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});