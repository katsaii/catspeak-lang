
run_test(function() : Test("empty-string") constructor {
    completeAutomatically(false);
    catspeak_compile_string("").andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : Test("empty-string-raw") constructor {
    completeAutomatically(false);
    catspeak_compile_string(@'').andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : Test("empty-string-whitespace") constructor {
    completeAutomatically(false);
    catspeak_compile_string("	       ").andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : Test("empty-string-whitespace-escape") constructor {
    completeAutomatically(false);
    catspeak_compile_string("\t \n \v \f \r \r\n \n\n").andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : Test("empty-string-whitespace-raw") constructor {
    completeAutomatically(false);
    catspeak_compile_string(@'
        	       
    ').andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});

run_test(function() : Test("empty-comment") constructor {
    completeAutomatically(false);
    catspeak_compile_string(@'
        -- nothing
    ').andCatch(function() {
        fail()
    }).andFinally(function() {
        complete();
    });
});