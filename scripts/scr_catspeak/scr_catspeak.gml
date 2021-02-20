/* Catspeak Core Compiler
 * ----------------------
 * Kat @katsaii
 */

/// @desc Represents a span of bytes of some buffer.
/// @param {real} begin The start of the span.
/// @param {real} end The end of the span.
function CatspeakSpan(_begin, _end) {
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
	// used to escape newlines
	ESCAPE,
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
	case CatspeakTokenKind.ESCAPE: return "ESCAPE";
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
	
}