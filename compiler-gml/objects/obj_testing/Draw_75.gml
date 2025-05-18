
//# feather use syntax-errors

var width = display_get_gui_width();
var height = display_get_gui_height();
var stats = test_stats();
var pad = 10;
var headerHeight = 15;

draw_set_font(fnt_testing);

// update the example region so it doesn't overlap with the outside UI
exampleLeft = pad;
exampleTop = headerHeight + pad + 4 * lineHeight;
exampleRight = width - pad;
exampleBottom = height - pad - 5 * lineHeight;
lineHeight = string_height("@C");

// draw example region
//draw_set_colour(TESTING_COL_DARK_GREY);
//draw_rectangle(exampleLeft, exampleTop, exampleRight, exampleBottom, true);

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
if (stats.totalFatal > 0) {
    draw_set_colour(TESTING_COL_FATAL);
} else if (stats.totalFailed > 0) {
    draw_set_colour(TESTING_COL_FAIL);
} else if (stats.totalActive > 0) {
    draw_set_colour(TESTING_COL_WORKING);
} else {
    draw_set_colour(TESTING_COL_PASS);
}
draw_text(width - pad, height - pad,
        (stats.totalFatal > 0 ? "FATAL! " : "") +
        string(stats.total - stats.totalFailed - stats.totalActive) + " of " +
        string(stats.total) + " tests passed");
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
        "example " + string(exampleCurrent + 1) + " of " + 
        string(array_length(examples)) + "\n" + exampleName);
if (exampleIsValid(exampleCurrent - 1)) {
    draw_text(width * 0.15, headerHeight + pad + lineHeight, 
            "previous example\n<left arrow key>");
}
if (exampleIsValid(exampleCurrent + 1)) {
    draw_text(width * 0.85, headerHeight + pad + lineHeight, 
            "next example\n<right arrow key>");
}

draw_set_valign(fa_top);
draw_set_halign(fa_left);