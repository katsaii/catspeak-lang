
//# feather use syntax-errors

run_test(function() : Test("init-entrypoint") constructor {
    assertAsset("scr_catspeak_init", asset_script)
            .withMessage("missing entrypoint");
});

run_test(function() : Test("init-version") constructor {
    assertEq(CATSPEAK_VERSION, CATSPEAK_VERSION)
            .withMessage("not constant");
    assertTypeof(CATSPEAK_VERSION, "string")
            .withMessage("not a string");
});

run_test(function() : Test("init-dependency") constructor {
    assertAsset("scr_future", asset_script)
            .withMessage("depends on Future");
});