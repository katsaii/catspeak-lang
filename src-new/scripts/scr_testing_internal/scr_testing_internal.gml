
//# feather use syntax-errors

run_test(function() : Test("internal-location-1") constructor {
    var pos = __catspeak_location_create(0, 0);
    assertEq(0, __catspeak_location_get_row(pos));
    assertEq(0, __catspeak_location_get_column(pos));
});

run_test(function() : Test("internal-location-2") constructor {
    var pos = __catspeak_location_create(123456, 1000);
    assertEq(123456, __catspeak_location_get_row(pos));
    assertEq(1000, __catspeak_location_get_column(pos));
});

run_test(function() : Test("internal-location-3") constructor {
    var pos = __catspeak_location_create(1048576 - 1, 4096 - 1);
    assertEq(1048576 - 1, __catspeak_location_get_row(pos));
    assertEq(4096 - 1, __catspeak_location_get_column(pos));
});

run_test(function() : Test("internal-location-negative-row-1") constructor {
    try {
        __catspeak_location_create(1048576, 0);
    } catch (e) {
        return;
    }
    fail("expected to error when the row number is >= 1048576");
});

run_test(function() : Test("internal-location-negative-row-2") constructor {
    try {
        __catspeak_location_create(-1, 0);
    } catch (e) {
        return;
    }
    fail("expected to error when the row number is < 0");
});

run_test(function() : Test("internal-location-negative-column-1") constructor {
    try {
        __catspeak_location_create(0, 4096);
    } catch (e) {
        return;
    }
    fail("expected to error when the column number is >= 4096");
});

run_test(function() : Test("internal-location-negative-column-2") constructor {
    try {
        __catspeak_location_create(0, -1);
    } catch (e) {
        return;
    }
    fail("expected to error when the column number is < 0");
});