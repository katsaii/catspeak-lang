
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

run_test(function() : AsyncTest("struct-access") constructor {
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

run_test(function() : AsyncTest("struct-access-2") constructor {
    catspeak_compile_string(@'
        let s = { ["meow"] : ":33" }
        [s.["meow"], s.meow]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(":33", result[0]);
        assertEq(":33", result[1]);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("struct-access-3") constructor {
    catspeak_compile_string(@'
        let s = { meow : ":33" }
        s.["meow"]
        s.meow
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(":33", result);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("struct-access-literal") constructor {
    catspeak_compile_string(@'
        { huh : "???" }."huh"
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("???", result);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("struct-json") constructor {
    jsonStr = @'
    {
        "Arrs": [1, 2, 3],
        "Objs": {
            "x": "hello",
            "y": "world"
        },
        "Lits": [null, true, false]
    }
    ';
    catspeak_compile_string(jsonStr).andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        var json = json_parse(jsonStr);
        assertEq(json[$ "Arrs"][0], result[$ "Arrs"][0]);
        assertEq(json[$ "Arrs"][1], result[$ "Arrs"][1]);
        assertEq(json[$ "Arrs"][2], result[$ "Arrs"][2]);
        assertEq(json[$ "Objs"][$ "x"], result[$ "Objs"][$ "x"]);
        assertEq(json[$ "Objs"][$ "y"], result[$ "Objs"][$ "y"]);
        assertEq(json[$ "Lits"][0], result[$ "Lits"][0]);
        assertEq(json[$ "Lits"][1], result[$ "Lits"][1]);
        assertEq(json[$ "Lits"][2], result[$ "Lits"][2]);
    }).andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});