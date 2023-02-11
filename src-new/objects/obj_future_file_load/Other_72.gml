/// @desc Call events.

//# feather use syntax-errors

if (async_load[? "id"] == idx) {
    if (async_load[? "status"]) {
        // it is the users responsibility to delete the buffer
        future.accept(buffer);
    } else {
        deleteBuffer = true;
    }
    instance_destroy();
}