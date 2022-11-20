
{
    var test = new TestCase("init-exists");
    test.assertAsset("scr_catspeak_init", asset_script, "missing script");
    test.complete();
}

{
    var test = new TestCase("init-version");
    test.assertEq(CATSPEAK_VERSION, CATSPEAK_VERSION, "not constant");
    test.assertTypeof(CATSPEAK_VERSION, "string", "not a string");
    test.complete();
}

{
    var test = new TestCase("init-dependencies");
    test.assertAsset("scr_future", asset_script, "depends on Future");
    test.complete();
}