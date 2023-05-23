
//# feather use syntax-errors

if (gmlFunc == undefined) {
    exit;
}

if (frame < 120) {
    var countTotal_ = countTotal;

    var expectTime = get_timer() + game_get_speed(gamespeed_microseconds);
    while (get_timer() < expectTime) {
        gmlFunc();
        countTotal_ += 1;
    }

    countTotal = countTotal_;
    frame += 1;

    if (frame >= 120) {
        addLog("Catspeak avg. = " + string(countTotal / 120));
        countTotal = 0;

        addLog("running GML...", "boring");
    }
} else if (frame < 120 + 120) {
    var countTotal_ = countTotal;

    var expectTime = get_timer() + game_get_speed(gamespeed_microseconds);
    while (get_timer() < expectTime) {
        nativeFunc();
        countTotal_ += 1;
    }

    countTotal = countTotal_;
    frame += 1;

    if (frame >= 120 + 120) {
        addLog("GML avg. = " + string(countTotal / 120));
        countTotal = 0;
        gmlFunc = undefined;
    }
}