
//# feather use syntax-errors

var dir = keyboard_check_pressed(vk_right) - keyboard_check_pressed(vk_left);
if (dir != 0 && exampleIsValid(exampleCurrent + dir)) {
    exampleChange(exampleCurrent + dir);
}

repeat (10) {
    test_run();
}

fpsRealTimer -= 1;
if (fpsRealTimer < 0) {
    fpsRealCache = fps_real;
    fpsRealTimer = 30;
}