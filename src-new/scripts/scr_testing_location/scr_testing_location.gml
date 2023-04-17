
//# feather use syntax-errors

run_test(function() : Test("location") constructor {
    var pos = catspeak_location_create(0, 0);
    assertEq(0, catspeak_location_get_row(pos));
    assertEq(0, catspeak_location_get_column(pos));
});

run_test(function() : Test("location-2") constructor {
    var pos = catspeak_location_create(123456, 1000);
    assertEq(123456, catspeak_location_get_row(pos));
    assertEq(1000, catspeak_location_get_column(pos));
});

run_test(function() : Test("location-3") constructor {
    var pos = catspeak_location_create(1048576 - 1, 4096 - 1);
    assertEq(1048576 - 1, catspeak_location_get_row(pos));
    assertEq(4096 - 1, catspeak_location_get_column(pos));
});

run_test(function() : Test("location-negative-row") constructor {
    try {
        catspeak_location_create(1048576, 0);
    } catch (e) {
        return;
    }
    fail("expected to error when the row number is >= 1048576");
});

run_test(function() : Test("location-negative-row-2") constructor {
    try {
        catspeak_location_create(-1, 0);
    } catch (e) {
        return;
    }
    fail("expected to error when the row number is < 0");
});

run_test(function() : Test("location-negative-column") constructor {
    try {
        catspeak_location_create(0, 4096);
    } catch (e) {
        return;
    }
    fail("expected to error when the column number is >= 4096");
});

run_test(function() : Test("location-negative-column-2") constructor {
    try {
        catspeak_location_create(0, -1);
    } catch (e) {
        return;
    }
    fail("expected to error when the column number is < 0");
});