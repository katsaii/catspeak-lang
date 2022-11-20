
run_test(function() : AsyncTest("empty-string") constructor {
    catspeak_compile_string("").andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("empty-string-raw") constructor {
    catspeak_compile_string(@'').andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("empty-string-whitespace") constructor {
    catspeak_compile_string("	 ").andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("empty-string-whitespace-escape") constructor {
    catspeak_compile_string("\t \n \v \f \r \r\n \n\n").andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("empty-string-whitespace-raw") constructor {
    catspeak_compile_string(@'
        	 
    ').andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : AsyncTest("empty-comment") constructor {
    catspeak_compile_string(@'
        -- nothing
        --also nothing, but with not space
        -- //
    ').andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});