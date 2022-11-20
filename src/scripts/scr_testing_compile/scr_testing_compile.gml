
{
    global.testCompEmpty1 = new TestCase("compile-empty-1");
    catspeak_compile_string(@'');
    test.assertAsset("scr_future", asset_script, "depends on Future");
    test.complete();
}