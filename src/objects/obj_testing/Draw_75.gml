var width = display_get_gui_width();
var height = display_get_gui_height();
var stats = test_stats();
var lineHeight = string_height("@C");
var pad = 10;
var headerHeight = 15;

draw_set_font(fnt_testing_mono);

// draw watermark
draw_set_colour(TESTING_COL_WHITE);
draw_set_valign(fa_bottom);
draw_text(pad, height - pad,
        "Catspeak v" + CATSPEAK_VERSION + " by @katsaii");
draw_text(pad, height - pad - lineHeight, @'
 |\ /|
>(OwO)<
   \(
');

// draw test results
draw_set_halign(fa_right);
if (stats.totalFailed > 0) {
    draw_set_colour(TESTING_COL_FAIL);
    draw_text(width - pad, height - pad,
            string(stats.totalFailed) + " of " +
            string(stats.total) + " tests failed");
} else {
    draw_set_colour(TESTING_COL_PASS);
    draw_text(width - pad, height - pad, "no tests failed");
}
var goodFPS = 60;
draw_set_colour(fps_real < goodFPS ? TESTING_COL_FAIL : TESTING_COL_PASS);
draw_text(width - pad, height - pad - lineHeight,
        string_format(fpsRealCache, 1, 3) + " fps_real");
draw_set_colour(fps < goodFPS ? TESTING_COL_FAIL : TESTING_COL_PASS);
draw_text(width - pad, height - pad - 2 * lineHeight,
        string_format(fps, 1, 3) + " fps");

// draw example selector
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_colour(TESTING_COL_WHITE);
var exampleName = "unknown";
if (exampleIsValid(exampleCurrent)) {
    exampleName = examples[exampleCurrent].title;
}
draw_text(width * 0.5, headerHeight + pad + lineHeight, 
        "example\n" + exampleName);
if (exampleIsValid(exampleCurrent - 1)) {
    draw_text(width * 0.25, headerHeight + pad + lineHeight, 
            "previous example\n(left arrow)");
}
if (exampleIsValid(exampleCurrent + 1)) {
    draw_text(width * 0.75, headerHeight + pad + lineHeight, 
            "next example\n(right arrow)");
}

draw_set_valign(fa_top);
draw_set_halign(fa_left);