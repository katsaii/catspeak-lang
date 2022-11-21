
run_test(function() : AsyncTest("struct-literal") constructor {
    catspeak_compile_string(@'
        { x : "ecks", y : "why?" }
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("ecks", result[$ "x"]);
        assertEq("why?", result[$ "y"]);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("struct-literal-access") constructor {
    catspeak_compile_string(@'
        let s = { ["meow"] : ":33" }
        [s.["meow"], s.meow, s.`meow`, s."meow"]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(":33", result[0]);
        assertEq(":33", result[1]);
        assertEq(":33", result[2]);
        assertEq(":33", result[3]);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});