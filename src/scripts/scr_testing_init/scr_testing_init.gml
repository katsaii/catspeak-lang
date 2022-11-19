
test_begin("init-exists");
test_assert_asset("scr_catspeak_init", asset_script, "missing script");
test_end();

test_begin("init-version");
test_assert_eq(CATSPEAK_VERSION, CATSPEAK_VERSION, "not constant");
test_assert_typeof(CATSPEAK_VERSION, "string", "not a string");
test_end();

test_begin("init-dependency");
test_assert_asset("scr_future", asset_script, "depends on Future");
test_end();