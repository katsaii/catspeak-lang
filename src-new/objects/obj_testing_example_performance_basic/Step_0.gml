
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
} else if (frame < 120 * 2) {
    var countTotal_ = countTotal;

    var expectTime = get_timer() + game_get_speed(gamespeed_microseconds);
    while (get_timer() < expectTime) {
        nativeFunc();
        countTotal_ += 1;
    }

    countTotal = countTotal_;
    frame += 1;

    if (frame >= 120 * 2) {
        addLog("GML avg. = " + string(countTotal / 120));
        countTotal = 0;

        addLog("running compiler...", "boring");
    }
} else if (frame < 120 * 3) {
    var countTotal_ = countTotal;

    var expectTime = get_timer() + game_get_speed(gamespeed_microseconds);
    while (get_timer() < expectTime) {
        Catspeak.parseString(code);

        countTotal_ += 1;
    }

    countTotal = countTotal_;
    frame += 1;

    if (frame >= 120 * 3) {
        addLog("Parse avg. = " + string(countTotal / 120));
        countTotal = 0;
    }
} else if (frame < 120 * 4) {
    var countTotal_ = countTotal;

    var asg = Catspeak.parseString(code);
    var expectTime = get_timer() + game_get_speed(gamespeed_microseconds);
    while (get_timer() < expectTime) {
        Catspeak.compileGML(asg);

        countTotal_ += 1;
    }

    countTotal = countTotal_;
    frame += 1;

    if (frame >= 120 * 4) {
        addLog("Compile avg. = " + string(countTotal / 120));
        countTotal = 0;
        gmlFunc = undefined;
    }
}