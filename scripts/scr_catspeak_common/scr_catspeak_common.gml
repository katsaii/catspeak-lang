/* Catspeak Common Functions
 * -------------------------
 * Kat @katsaii
 */

/// @desc Represents a Catspeak error.
/// @param {vector} pos The vector holding the row and column numbers.
/// @param {string} msg The error message.
function CatspeakError(_pos, _msg) constructor {
	pos = _pos;
	reason = is_string(_msg) ? _msg : string(_msg);
	/// @desc Displays the content of this error.
	static toString = function() {
		return instanceof(self) + " at " + string(pos) + ": " + reason;
	}
}

/// @desc A helper function for converting strings into a preferred format by Catspeak.
/// @param {string} str The string to convert into a buffer.
function catspeak_string_to_buffer(_str) {
	var size = string_byte_length(_str);
	var buff = buffer_create(size, buffer_fixed, 1);
	buffer_write(buff, buffer_text, _str);
	buffer_seek(buff, buffer_seek_start, 0);
	return buff;
}