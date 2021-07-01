/// @desc Include a persistent version of `obj_catspeak` in the first room.
gml_pragma("global", @'
    object_set_persistent(obj_catspeak, true);
    room_instance_add(room_first, 0, 0, obj_catspeak);
');
if (instance_number(obj_catspeak) > 1) {
    // don't create more than one Catspeak instance
    instance_destroy();
}