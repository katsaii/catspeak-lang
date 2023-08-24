/// @desc Initialise GML code

event_inherited();

environment = new CatspeakEnvironment();
environment.applyPreset(CatspeakPreset.MATH, CatspeakPreset.DRAW);
environment.getInterface().exposeMethod(
    "get_timer", get_timer,
    "room_width", function () { return room_width },
    "room_height", function () { return room_height },
);

code = @'
-- draw a simple pendulum

let t = get_timer() / 5000;
let angle = 270 + 30 * dsin(t);

let w = :room_width;
let h = :room_height;

let ox = w / 2;
let oy = 0;

let x = lengthdir_x(h * 0.75, angle);
let y = lengthdir_y(h * 0.75, angle);
draw_circle(ox + x, oy + y, 100, false);
draw_line_width(ox, oy, ox + x, oy + y, 10);
';