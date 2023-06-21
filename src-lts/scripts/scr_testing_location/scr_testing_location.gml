
//# feather use syntax-errors

test_add(function () : Test("location") constructor {
    var pos = catspeak_location_create(0, 0);
    assertEq(0, catspeak_location_get_row(pos));
    assertEq(0, catspeak_location_get_column(pos));
});

test_add(function () : Test("location-2") constructor {
    var pos = catspeak_location_create(123456, 1000);
    assertEq(123456, catspeak_location_get_row(pos));
    assertEq(1000, catspeak_location_get_column(pos));
});

test_add(function () : Test("location-3") constructor {
    var pos = catspeak_location_create(1048576 - 1, 4096 - 1);
    assertEq(1048576 - 1, catspeak_location_get_row(pos));
    assertEq(4096 - 1, catspeak_location_get_column(pos));
});

test_add(function () : Test("location-negative-row") constructor {
    if (!CATSPEAK_DEBUG_MODE) {
        return;
    }
    try {
        catspeak_location_create(1048576, 0);
    } catch (e) {
        return;
    }
    fail("expected to error when the row number is >= 1048576");
}, IgnorePlatform.HTML5);

test_add(function () : Test("location-negative-row-2") constructor {
    if (!CATSPEAK_DEBUG_MODE) {
        return;
    }
    try {
        catspeak_location_create(-1, 0);
    } catch (e) {
        return;
    }
    fail("expected to error when the row number is < 0");
}, IgnorePlatform.HTML5);

test_add(function () : Test("location-negative-column") constructor {
    if (!CATSPEAK_DEBUG_MODE) {
        return;
    }
    try {
        catspeak_location_create(0, 4096);
    } catch (e) {
        return;
    }
    fail("expected to error when the column number is >= 4096");
}, IgnorePlatform.HTML5);

test_add(function () : Test("location-negative-column-2") constructor {
    if (!CATSPEAK_DEBUG_MODE) {
        return;
    }
    try {
        catspeak_location_create(0, -1);
    } catch (e) {
        return;
    }
    fail("expected to error when the column number is < 0");
}, IgnorePlatform.HTML5);