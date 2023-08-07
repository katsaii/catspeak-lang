/// @desc Initialise GML code

event_inherited();

environment = new CatspeakEnvironment();
environment.applyPreset(CatspeakPreset.MATH);
environment.addFunction(
    "draw_circle", draw_circle,
    "draw_line_width", draw_line_width,
    "get_timer", get_timer,
    "get_room_width", function () { return room_width },
    "get_room_height", function () { return room_height },
);

code = @'
-- draw a simple pendulum

let t = get_timer() / 5000;
let angle = 270 + 30 * dsin(t);

let w = get_room_width();
let h = get_room_height();

let ox = w / 2;
let oy = 0;

let x = lengthdir_x(h * 0.75, angle);
let y = lengthdir_y(h * 0.75, angle);
draw_circle(ox + x, oy + y, 100, false);
draw_line_width(ox, oy, ox + x, oy + y, 10);
';