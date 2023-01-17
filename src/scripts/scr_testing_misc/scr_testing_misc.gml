
//# feather use syntax-errors

run_test(function() : AsyncTest("misc-catspeak-to-gml") constructor {
    catspeak_compile_string(@'
        return (fun (a, b) { a + b })
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        var f = catspeak_into_gml_function(result);
        assertEq(-9 + 10, f(-9, 10));
        assertEq(8 + 10, f(8, 10));
        assertEq(12 + -2.5, f(12, -2.5));
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});
