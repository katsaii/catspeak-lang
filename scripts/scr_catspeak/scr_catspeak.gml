/* Catspeak Core Compiler
 * ----------------------
 * Kat @katsaii
 */

/// @desc Creates a compiler session from this string.
/// @param {string} str The string that contains the source code.
function catspeak_session_create(_str) {
	var size = string_byte_length(_str);
	var buff = buffer_create(size, buffer_fixed, 1);
	buffer_write(buff, buffer_text, _str);
	buffer_seek(buff, buffer_seek_start, 0);
	return buff;
}

/// @desc Destroys this compiler session.
/// @param {struct} sess The session to kill.
function catspeak_session_destroy(_sess) {
	buffer_delete(_sess);
}

/// @desc Represents a span of bytes of some buffer.
/// @param {real} begin The start of the span.
/// @param {real} end The end of the span.
function CatspeakSpan(_begin, _end) constructor {
	start = min(_begin, _end);
	limit = max(_begin, _end) - start;
	/// @desc Creates a clone of this span.
	static clone = function() {
		return new CatspeakSpan(start, start + limit);
	}
	/// @desc Renders this span with the content of this buffer.
	/// @param {real} buffer The buffer to pull string data from.
	static render = function(_buff) {
		if (limit < 1) {
			// always an empty slice
			return "";
		}
		var slice = buffer_create(limit, buffer_fixed, 1);
		buffer_copy(_buff, start, limit, slice, 0);
		buffer_seek(slice, buffer_seek_start, 0);
		var str = buffer_read(slice, buffer_text);
		buffer_delete(slice);
		return str;
	}
}

/// @desc Represents a kind of token.
enum CatspeakTokenKind {
	LEFT_PAREN,
	RIGHT_PAREN,
	LEFT_BOX,
	RIGHT_BOX,
	LEFT_BRACE,
	RIGHT_BRACE,
	// member access
	DOT,
	// thunk argument
	BAR,
	// function application operator `f (a + b)` is equivalent to `f : a + b`
	COLON,
	// statement terminator
	SEMICOLON,
	PLUS,
	MINUS,
	STRING,
	NUMBER,
	WHITESPACE,
	COMMENT,
	EOL,
	EOF,
	UNKNOWN
}

/// @desc Displays the token as a string.
/// @param {CatspeakTokenKind} kidn The token kind to display.
function catspeak_render_token(_kind) {
	switch (_kind) {
	case CatspeakTokenKind.LEFT_PAREN: return "LEFT_PAREN";
	case CatspeakTokenKind.RIGHT_PAREN: return "RIGHT_PAREN";
	case CatspeakTokenKind.LEFT_BOX: return "LEFT_BOX";
	case CatspeakTokenKind.RIGHT_BOX: return "RIGHT_BOX";
	case CatspeakTokenKind.LEFT_BRACE: return "LEFT_BRACE";
	case CatspeakTokenKind.RIGHT_BRACE: return "RIGHT_BRACE";
	case CatspeakTokenKind.DOT: return "DOT";
	case CatspeakTokenKind.BAR: return "BAR";
	case CatspeakTokenKind.COLON: return "COLON";
	case CatspeakTokenKind.SEMICOLON: return "SEMICOLON";
	case CatspeakTokenKind.PLUS: return "PLUS";
	case CatspeakTokenKind.MINUS: return "MINUS";
	case CatspeakTokenKind.STRING: return "STRING";
	case CatspeakTokenKind.NUMBER: return "NUMBER";
	case CatspeakTokenKind.WHITESPACE: return "WHITESPACE";
	case CatspeakTokenKind.COMMENT: return "COMMENT";
	case CatspeakTokenKind.EOL: return "EOL";
	case CatspeakTokenKind.EOF: return "EOF";
	case CatspeakTokenKind.UNKNOWN: return "UNKNOWN";
	}
}

/// @desc Returns whether a byte is a valid newline character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_newline(_byte) {
	switch (_byte) {
	case ord("\n"):
	case ord("\r"):
		return true;
	default:
		return false;
	}
}

/// @desc Returns whether a byte is a valid whitespace character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_whitespace(_byte) {
	switch (_byte) {
	case ord(" "):
	case ord("\t"):
		return true;
	default:
		return false;
	}
}

/// @desc Returns whether a byte is a valid alphabetic character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_alphabetic(_byte) {
	return _byte >= ord("a") && _byte <= ord("z")
			|| _byte >= ord("A") && _byte <= ord("Z");
}

/// @desc Returns whether a byte is a valid digit character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_digit(_byte) {
	return _byte >= ord("0") && _byte <= ord("9");
}

/// @desc Returns whether a byte is a valid alphanumeric character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_alphanumeric(_byte) {
	return catspeak_byte_is_alphabetic(_byte)
			|| catspeak_byte_is_digit(_byte);
}

/// @desc Tokenises the buffer contents.
/// @param {real} buffer The id of the buffer to use.
function CatspeakLexer(_buff) constructor {
	buff = _buff;
	offset = buffer_tell(_buff);
	alignment = buffer_get_alignment(_buff);
	limit = buffer_get_size(_buff);
	spanBegin = offset;
	/// @desc Resets the current span.
	static resetSpan = function() {
		spanBegin = buffer_tell(buff);
	}
	/// @desc Returns the current buffer span.
	static getSpan = function() {
		return new CatspeakSpan(spanBegin, buffer_tell(buff));
	}
	/// @desc Advances the lexer whilst a predicate holds, or until the EoF was reached.
	/// @param {script} pred The predicate to check for.
	/// @param {script} escape The escape character.
	static advanceWhileEscape = function(_pred, _escape) {
		var seek = buffer_tell(buff);
		var skip_next = false;
		while (seek < limit) {
			var byte = buffer_peek(buff, seek, buffer_u8);
			if (skip_next) {
				skip_next = false;
			} else if (byte == _escape) {
				skip_next = true;
			} else if not (_pred(byte)) {
				break;
			}
			seek += alignment;
		}
		buffer_seek(buff, buffer_seek_start, seek);
	}
	/// @desc Advances the lexer whilst a predicate holds, or until the EoF was reached.
	/// @param {script} pred The predicate to check for.
	static advanceWhile = function(_pred) {
		advanceWhileEscape(_pred, undefined);
	}
	/// @desc Advances the lexer and returns the next token. 
	static next = function() {
		resetSpan();
		if (buffer_tell(buff) >= limit) {
			return CatspeakTokenKind.EOF;
		}
		var byte = buffer_read(buff, buffer_u8);
		switch (byte) {
		case ord("\\"):
			advanceWhile(catspeak_byte_is_newline);
			return CatspeakTokenKind.WHITESPACE;
		case ord("("):
			return CatspeakTokenKind.LEFT_PAREN;
		case ord(")"):
			return CatspeakTokenKind.RIGHT_PAREN;
		case ord("["):
			return CatspeakTokenKind.LEFT_BOX;
		case ord("]"):
			return CatspeakTokenKind.RIGHT_BOX;
		case ord("{"):
			return CatspeakTokenKind.LEFT_BRACE;
		case ord("}"):
			return CatspeakTokenKind.RIGHT_BRACE;
		case ord("."):
			return CatspeakTokenKind.DOT;
		case ord(":"):
			return CatspeakTokenKind.COLON;
		case ord(";"):
			return CatspeakTokenKind.SEMICOLON;
		case ord("+"):
			return CatspeakTokenKind.PLUS;
		case ord("-"):
			return CatspeakTokenKind.MINUS;
		default:
			if (catspeak_byte_is_newline(byte)) {
				advanceWhile(catspeak_byte_is_newline);
				return CatspeakTokenKind.EOL;
			} else if (catspeak_byte_is_whitespace(byte)) {
				advanceWhile(catspeak_byte_is_whitespace);
				return CatspeakTokenKind.WHITESPACE;
			} else if (catspeak_byte_is_alphabetic(byte)) {
				advanceWhile(catspeak_byte_is_alphanumeric);
				return CatspeakTokenKind.STRING;
			} else if (catspeak_byte_is_digit(byte)) {
				advanceWhile(catspeak_byte_is_digit);
				return CatspeakTokenKind.NUMBER;
			} else {
				return CatspeakTokenKind.UNKNOWN;
			}
		}
	}
}

var sess = catspeak_session_create(@'\
def add |x y| {\
  ret x + y\
}');
var lex = new CatspeakLexer(sess);
do {
	var token = lex.next();
	var slice = lex.getSpan().render(sess);
	show_debug_message([catspeak_render_token(token), slice]);
} until (token == CatspeakTokenKind.EOF);
catspeak_session_destroy(sess);