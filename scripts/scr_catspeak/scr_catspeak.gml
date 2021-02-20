/* Catspeak Core Compiler
 * ----------------------
 * Kat @katsaii
 */

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

/// @desc Tokenises the buffer contents.
/// @param {real} buffer The id of the buffer to use.
function CatspeakLexer(_buffer) constructor {
	buff = _buffer;
	offset = buffer_tell(_buffer);
	alignment = buffer_get_alignment(_buffer);
	limit = buffer_get_size(_buffer);
	spanBegin = offset;
	/// @desc Resets the current span.
	static resetSpan = function() {
		spanBegin = buffer_tell(buff);
	}
	/// @desc Returns the current buffer span.
	static getSpan = function() {
		return new CatspeakSpan(spanBegin, buffer_tell(buff));
	}
	/// @desc Advances the lexer until a specific byte is reached, or until the EoF was reached.
	/// @param {real} byte The byte to check for.
	static advanceUntil = function(_byte) {
		var seek = buffer_tell(buff);
		while (seek < limit) {
			var byte = buffer_peek(buff, seek, buffer_u8);
			if (byte == _byte) {
				break;
			}
			seek += alignment;
		}
		buffer_seek(buff, buffer_seek_start, seek);
	}
	/// @desc Advances the lexer and returns the next token. 
	static next = function() {
		resetSpan();
		advanceUntil(0x20);
		return CatspeakTokenKind.UNKNOWN;
	}
}

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

var sess = catspeak_session_create("hello world");
var lex = new CatspeakLexer(sess);
lex.next()
show_debug_message(lex.getSpan());
catspeak_session_destroy(sess);