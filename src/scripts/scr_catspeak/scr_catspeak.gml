//! The primary user-facing interface for compiling and executing Catspeak
//! programs.

/// TODO
function catspeak_compile() {
    // TODO
}

/// TODO
function catspeak_execute() {
    // TODO
}

/// TODO
function catspeak_compile_buffer(buff) {
    // TODO
}

/// Compiles a string containing Catspeak code. Will allocate a new buffer
/// to store the string, if that isn't ideal then you will have to create
/// and write to your own buffer, then pass it to `catspeak_compile_buffer`.
///
/// @param {Any} src
///   The value containing the source code to compile.
function catspeak_compile_string(src) {
    var src_ = is_string(src) ? src : string(src);
    var buff = catspeak_create_buffer_from_string(src_);
    return catspeak_compile_buffer(buff);
}

/// A helper function for creating a buffer from a string.
///
/// @param {String} src
///   The source code to convert into a buffer.
///
/// @return {Id.Buffer}
function catspeak_create_buffer_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}