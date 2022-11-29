
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
        assertEq("?:B", self[$ "karkat"]);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("self-call") constructor {
    func = function() {
        return self;
    };
    catspeak_compile_string(@'
        let gamzee = {
            `:o)` : fun() { self }
        };
        gamzee.`:o)`()
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assert(result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("self-counter") constructor {
    func = function() {
        return self;
    };
    catspeak_compile_string(@'
        let counter = {
            n: 0, inc : fun() { self.n = it + 1},
        };

        counter.inc(); counter.inc(); counter.inc();
        counter.inc(); counter.inc(); counter.inc();
        counter.inc(); counter.inc(); counter.inc();

        counter.n
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(9, result);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("self-shared") constructor {
    func = function() {
        return self;
    };
    catspeak_compile_string(@'
        let s = {
            a: 1
        }

        let t = {
            a: 3
        }

        function = fun() {
            self.a = it + 1
        }

        s.function = function
        t.function = function

        s.function()
        t.function()

        [s.a, t.a]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq(2, result[0]);
        assertEq(4, result[1]);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("self-side-effect") constructor {
    func = function() {
        return self;
    };
    catspeak_compile_string(@'
        let bunny = {
            n : 0,
            speak : fun() {
                self.n = it + 1
                "purr"
            },
        }
        bunny.speak()
        [bunny.speak(), bunny.n]
    ').andThen(function(ir) {
        return catspeak_execute(ir);
    }).andThen(function(result) {
        assertEq("purr", result[0]);
        assertEq(2, result[1]);
    }).andCatch(function(e) {
        fail().withMessage(e);
    }).andFinally(function() {
        complete();
    });
});