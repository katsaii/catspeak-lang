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
	/// @desc Converts this span into a string.
	static toString = function() {
		return "[" + string(start) + ".." + string(start + limit) + "]";
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
	IDENTIFIER,
	STRING,
	NUMBER,
	WHITESPACE,
	COMMENT,
	EOL,
	BOF,
	EOF,
	UNKNOWN
}

/// @desc Displays the token as a string.
/// @param {CatspeakTokenKind} kidn The token kind to display.
function catspeak_token_render(_kind) {
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
	case CatspeakTokenKind.IDENTIFIER: return "IDENTIFIER";
	case CatspeakTokenKind.STRING: return "STRING";
	case CatspeakTokenKind.NUMBER: return "NUMBER";
	case CatspeakTokenKind.WHITESPACE: return "WHITESPACE";
	case CatspeakTokenKind.COMMENT: return "COMMENT";
	case CatspeakTokenKind.EOL: return "EOL";
	case CatspeakTokenKind.BOF: return "BOF";
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

/// @desc Returns whether a byte is NOT a valid newline character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_not_newline(_byte) {
	return !catspeak_byte_is_newline(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_quote(_byte) {
	return _byte == ord("\"");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_not_quote(_byte) {
	return !catspeak_byte_is_quote(_byte);
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
			|| _byte >= ord("A") && _byte <= ord("Z")
			|| _byte == ord("_")
			|| _byte == ord("'");
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
	skipNextByte = false;
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
	/// @param {script} escape The predicate to check for escapes.
	static advanceWhileEscape = function(_pred, _escape) {
		var do_escape = false;
		var byte = undefined;
		var seek = buffer_tell(buff);
		while (seek < limit) {
			byte = buffer_peek(buff, seek, buffer_u8);
			if (do_escape) {
				do_escape = _escape(byte);
			}
			if not (do_escape) {
				if not (_pred(byte)) {
					break;
				} else if (byte == ord("\\")) {
					do_escape = true;
				}
			}
			seek += alignment;
		}
		buffer_seek(buff, buffer_seek_start, seek);
		return byte;
	}
	/// @desc Advances the lexer according to this predicate, but escapes newline characters.
	/// @param {script} pred The predicate to check for.
	static advanceWhile = function(_pred) {
		return advanceWhileEscape(_pred, catspeak_byte_is_newline);
	}
	/// @desc Advances the lexer and returns the next token. 
	static next = function() {
		if (buffer_tell(buff) >= limit) {
			spanBegin = limit;
			return CatspeakTokenKind.EOF;
		}
		if (skipNextByte) {
			buffer_read(buff, buffer_u8);
			skipNextByte = false;
			return next();
		}
		resetSpan();
		var byte = buffer_read(buff, buffer_u8);
		switch (byte) {
		case ord("\\"):
			// this is needed for a specific case where `\` is the first character in a line
			advanceWhile(catspeak_byte_is_newline);
			advanceWhile(catspeak_byte_is_whitespace);
			return CatspeakTokenKind.WHITESPACE;
		case ord("#"):
			advanceWhile(catspeak_byte_is_not_newline);
			return CatspeakTokenKind.COMMENT;
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
		case ord("|"):
			return CatspeakTokenKind.BAR;
		case ord(":"):
			return CatspeakTokenKind.COLON;
		case ord(";"):
			return CatspeakTokenKind.SEMICOLON;
		case ord("+"):
			return CatspeakTokenKind.PLUS;
		case ord("-"):
			return CatspeakTokenKind.MINUS;
		case ord("\""):
			resetSpan();
			advanceWhileEscape(catspeak_byte_is_not_quote, catspeak_byte_is_quote);
			skipNextByte = true;
			return CatspeakTokenKind.STRING;
		default:
			if (catspeak_byte_is_newline(byte)) {
				advanceWhile(catspeak_byte_is_newline);
				return CatspeakTokenKind.EOL;
			} else if (catspeak_byte_is_whitespace(byte)) {
				advanceWhile(catspeak_byte_is_whitespace);
				return CatspeakTokenKind.WHITESPACE;
			} else if (catspeak_byte_is_alphabetic(byte)) {
				advanceWhile(catspeak_byte_is_alphanumeric);
				return CatspeakTokenKind.IDENTIFIER;
			} else if (catspeak_byte_is_digit(byte)) {
				advanceWhile(catspeak_byte_is_digit);
				return CatspeakTokenKind.NUMBER;
			} else {
				return CatspeakTokenKind.UNKNOWN;
			}
		}
	}
}

/// @desc An iterator that simplifies tokens generated by the lexer and applies automatic semicolon insertion.
/// @param {CatspeakLexer} lexer The id of the lexer to iterate over.
function CatspeakParserLexer(_lexer) constructor {
	lexer = _lexer;
	pred = CatspeakTokenKind.BOF;
	span = lexer.getSpan();
	current = lexer.next();
	parenDepth = 0;
	seenBar = false;
	/// @desc Returns the current buffer span.
	static getSpan = function() {
		return span;
	}
	/// @desc Peeks at the next token.
	static peek = function() {
		return current;
	}
	/// @desc Advances the lexer and returns the next token.
	static next = function() {
		while (true) {
			span = lexer.getSpan();
			var succ;
			do {
				succ = lexer.next();
			} until (succ != CatspeakTokenKind.WHITESPACE
					&& succ != CatspeakTokenKind.COMMENT);
			switch (current) {
			case CatspeakTokenKind.BAR:
				seenBar = !seenBar;
			case CatspeakTokenKind.LEFT_PAREN:
			case CatspeakTokenKind.LEFT_BOX:
				parenDepth += 1;
				break;
			case CatspeakTokenKind.RIGHT_PAREN:
			case CatspeakTokenKind.RIGHT_BOX:
				if (parenDepth > 0) {
					parenDepth -= 1;
				}
				break;
			case CatspeakTokenKind.EOL:
				var implicit_semicolon = !seenBar && parenDepth <= 0;
				switch (pred) {
				case CatspeakTokenKind.LEFT_BRACE:
				case CatspeakTokenKind.DOT:
				case CatspeakTokenKind.BAR:
				case CatspeakTokenKind.COLON:
				case CatspeakTokenKind.SEMICOLON:
				case CatspeakTokenKind.PLUS:
				case CatspeakTokenKind.MINUS:
					implicit_semicolon = false;
					break;
				}
				switch (succ) {
				case CatspeakTokenKind.LEFT_BRACE:
				case CatspeakTokenKind.DOT:
				case CatspeakTokenKind.BAR:
				case CatspeakTokenKind.COLON:
				case CatspeakTokenKind.SEMICOLON:
				case CatspeakTokenKind.PLUS:
				case CatspeakTokenKind.MINUS:
					implicit_semicolon = false;
					break;
				}
				if (implicit_semicolon) {
					current = CatspeakTokenKind.SEMICOLON;
				} else {
					// ignore this EOL character and try again
					current = succ;
					continue;
				}
				break;
			}
			pred = current;
			current = succ;
			return pred;
		}
	}
}

/// @desc Represents a compiler error.
/// @param {string} msg The error message.
/// @param {CatspeakSpan} span The span where the error occurred at.
function CatspeakCompilerError(_msg, _span) constructor {
	msg = is_string(_msg) ? _msg : string(_msg);
	span = _span;
	/// @desc Displays the content of this error.
	toString = function() {
		return string(span) + " " + msg;
	}
}

/// @desc Represents a kind of IR node.
enum CatspeakIRKind {
	VALUE,
	
}

/// @desc Represents an IR node.
/// @param {CatspeakIRKind} kind The kind of ir node.
/// @param {CatspeakIRKind} value The value held by the ir node.
function CatspeakIRNode(_kind, _value) constructor {
	kind = _kind;
	value = _value;
}

/// @desc Creates a new parser from this string.
/// @param {real} buffer The id of the buffer to use.
function CatspeakParser(_buff) constructor {
	lexer = new CatspeakParserLexer(new CatspeakLexer(_buff));
	buff = _buff;
	token = CatspeakTokenKind.BOF;
	/// @desc Advances the parser and returns the token.
	static advance = function() {
		token = lexer.next();
		return token;
	}
	/// @desc Renders the current span of the parser.
	static renderContent = function() {
		return lexer.getSpan().render(buff);
	}
	/// @desc Throws a `CatspeakCompilerError` for the current token.
	/// @param {string} on_error The error message.
	static error = function(_msg) {
		advance();
		var span = lexer.getSpan();
		throw new CatspeakCompilerError(_msg, span);
	}
	/// @desc Returns true if the current token matches this token kind.
	/// @param {CatspeakTokenKind} kind The token kind to match.
	static matches = function(_kind) {
		return lexer.peek() == _kind;
	}
	/// @desc Attempts to match against a token and advances the parser if this was successful.
	/// @param {CatspeakTokenKind} kind The token kind to consume.
	static consume = function(_kind) {
		if (matches(_kind)) {
			advance();
			return true;
		} else {
			return false;
		}
	}
	/// @desc Throws a `CatspeakCompilerError` if the current token is not the expected value. Advances the parser otherwise.
	/// @param {CatspeakTokenKind} kind The token kind to expect.
	/// @param {string} on_error The error message.
	static expects = function(_kind, _msg) {
		if (consume(_kind)) {
			return token;
		} else {
			error(_msg);
		}
	}
	/// @desc Entry point for parsing terms.
	static parse = function() {
		try {
			var term = parseValue();
			return term;
		} catch (_e) {
			if (instanceof(_e) == "CatspeakCompilerError") {
				return _e;
			}
			// propogate other errors
			throw _e;
		}
	}
	/// @desc Parses a terminal value or expression.
	static parseValue = function() {
		var kind = CatspeakIRKind.VALUE;
		var value;
		if (consume(CatspeakTokenKind.STRING)) {
			value = renderContent();
		} else if (consume(CatspeakTokenKind.NUMBER)) {
			value = real(renderContent());
		} else {
			return parseGrouping();
		}
		return new CatspeakIRNode(kind, value);
	}
	/// @desc Parses groupings of expressions.
	static parseGrouping = function() {
		if (consume(CatspeakTokenKind.LEFT_PAREN)) {
			var value = parseValue();
			expects(CatspeakTokenKind.RIGHT_PAREN, "expected closing `)` in grouping");
			return value;
		} else {
			error("unexpected symbol in expression");
		}
	}
}

/// @desc Parses a data string and returns the top-level structure.
/// @param {string} str The string to parse.
function catspeak_parse(_str) {
	var sess = catspeak_session_create(_str);
	var ir = new CatspeakParser(sess).parse();
	catspeak_session_destroy(sess);
	return ir;
}

var program = @'
# adds to numbers together
fun add |arr| {
  var acc 0
  for arr |x| {
    inc acc x
  }
  ret acc
}
';
var ast = catspeak_parse("(\"hi hello\")");
show_debug_message(ast);