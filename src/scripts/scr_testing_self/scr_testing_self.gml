
//# feather use syntax-errors

run_test(function() : AsyncTest("self-get") constructor {
    catspeak_compile_string(@'
        return self
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(self, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("self-set") constructor {
    catspeak_compile_string(@'
        self.["karkat"] = "?:B";
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assert(variable_struct_exists(self, "karkat"))
                .withMessage("failed to assign variable");
        assertEq(karkat, "?:B");
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});