var width = display_get_gui_width();
var height = display_get_gui_height();
var stats = test_stats();

draw_set_font(fnt_testing_mono);
draw_set_colour(TESTING_COL_WHITE);
draw_set_valign(fa_bottom);
draw_text(10, height - 10,
        "Catspeak v" + CATSPEAK_VERSION + " by @katsaii");
draw_text(10, height - 30, @'
 |\ /|
>(OwO)<
   \(
');
draw_set_halign(fa_right);
if (stats.totalFailed > 0) {
    draw_set_colour(TESTING_COL_FAIL);
    draw_text(width - 10, height - 10,
            string(stats.totalFailed) + " of " +
            string(stats.total) + " tests failed");
} else {
    draw_set_colour(TESTING_COL_PASS);
    draw_text(width - 10, height - 10, "no tests failed");
}
draw_set_valign(fa_top);
draw_set_halign(fa_left);