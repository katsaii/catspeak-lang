
//# feather use syntax-errors

var left = obj_testing.exampleLeft;
var top = obj_testing.exampleTop;
var right = obj_testing.exampleRight;
var bottom = obj_testing.exampleBottom;
var lineHeight = obj_testing.lineHeight;

var midX = mean(left, right);
var midY = mean(top, bottom);
var pad = 10;
var offset;

offset = top + pad;

// draw code
draw_set_colour(TESTING_COL_WHITE);
draw_set_halign(fa_center);
draw_text(mean(left, midX), offset, "Code");
offset += 2 * lineHeight;

draw_set_colour(TESTING_COL_GREY);
draw_set_halign(fa_left);
draw_text_ext(left, offset, code, lineHeight, midX - left - pad);

offset = top + pad;

// draw log
draw_set_colour(TESTING_COL_WHITE);
draw_set_halign(fa_center);
draw_text(mean(right, midX), offset, "Output");
draw_set_colour(TESTING_COL_GREY);
draw_set_halign(fa_left);
offset += 2 * lineHeight;
var finalOffset = offset + logLength * lineHeight;
for (var i = 0; i < logLength; i += 1) {
    var idx = (logTail + i) % logLength;
    draw_set_colour(severities[$ logSeverity[idx]]);
    draw_text_ext(midX + pad, offset, log[idx], lineHeight, right - midX - pad);
    offset += lineHeight;
}
offset = finalOffset;

// draw dividers
var vdivider = "|";
repeat (20) {
    vdivider += "\n|";
}
var hdivider = "";
repeat (32) {
    hdivider += "-";
}
draw_set_colour(TESTING_COL_DARK_GREY);
draw_set_halign(fa_center);
draw_text(midX, top + pad, vdivider);
draw_set_halign(fa_center);
draw_text(mean(right, midX), offset, hdivider);

// draw description
draw_set_colour(TESTING_COL_WHITE);
draw_set_halign(fa_center);
offset += 2 * lineHeight;
draw_text(mean(right, midX), offset, "Description");
draw_set_colour(TESTING_COL_GREY);
draw_set_halign(fa_left);
offset += 2 * lineHeight;
draw_text(midX + pad, offset, "Press <enter> to run the example");
offset += 2 * lineHeight;
draw_text_ext(midX + pad, offset, desc, lineHeight, right - midX - pad);

draw_set_valign(fa_top);
draw_set_halign(fa_left);