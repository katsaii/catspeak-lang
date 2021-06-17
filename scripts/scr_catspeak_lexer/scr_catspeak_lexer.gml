/* Catspeak Lexical Analysis Stage
 * -------------------------------
 * Kat @katsaii
 */

/// @desc Represents a kind of token.
enum CatspeakToken {
	PAREN_LEFT,
	PAREN_RIGHT,
	BOX_LEFT,
	BOX_RIGHT,
	BRACE_LEFT,
	BRACE_RIGHT,
	DOT, // used for accessing members
	COLON, // function application operator, `f (a + b)` is equivalent to `f : a + b`
	SEMICOLON, // statement terminator
	__OPERATORS_BEGIN__,
	DISJUNCTION,
	CONJUNCTION,
	COMPARISON,
	ADDITION,
	MULTIPLICATION,
	DIVISION,
	__OPERATORS_END__,
	SET,
	IF,
	ELSE,
	WHILE,
	PRINT,
	RUN,
	RETURN,
	IDENTIFIER,
	STRING,
	NUMBER,
	WHITESPACE,
	COMMENT,
	EOL,
	BOF,
	EOF,
	OTHER
}

/// @desc Displays the token as a string.
/// @param {CatspeakToken} kind The token kind to display.
function catspeak_token_render(_kind) {
	switch (_kind) {
	case CatspeakToken.PAREN_LEFT: return "PAREN_LEFT";
	case CatspeakToken.PAREN_RIGHT: return "PAREN_RIGHT";
	case CatspeakToken.BOX_LEFT: return "BOX_LEFT";
	case CatspeakToken.BOX_RIGHT: return "BOX_RIGHT";
	case CatspeakToken.BRACE_LEFT: return "BRACE_LEFT";
	case CatspeakToken.BRACE_RIGHT: return "BRACE_RIGHT";
	case CatspeakToken.DOT: return "DOT";
	case CatspeakToken.COLON: return "COLON";
	case CatspeakToken.SEMICOLON: return "SEMICOLON";
	case CatspeakToken.DISJUNCTION: return "DISJUNCTION";
	case CatspeakToken.CONJUNCTION: return "CONJUNCTION";
	case CatspeakToken.COMPARISON: return "COMPARISON";
	case CatspeakToken.ADDITION: return "ADDITION";
	case CatspeakToken.MULTIPLICATION: return "MULTIPLICATION";
	case CatspeakToken.DIVISION: return "DIVISION";
	case CatspeakToken.SET: return "SET";
	case CatspeakToken.IF: return "IF";
	case CatspeakToken.ELSE: return "ELSE";
	case CatspeakToken.WHILE: return "WHILE";
	case CatspeakToken.PRINT: return "PRINT";
	case CatspeakToken.RUN: return "RUN";
	case CatspeakToken.RETURN: return "RETURN";
	case CatspeakToken.IDENTIFIER: return "IDENTIFIER";
	case CatspeakToken.STRING: return "STRING";
	case CatspeakToken.NUMBER: return "NUMBER";
	case CatspeakToken.WHITESPACE: return "WHITESPACE";
	case CatspeakToken.COMMENT: return "COMMENT";
	case CatspeakToken.EOL: return "EOL";
	case CatspeakToken.BOF: return "BOF";
	case CatspeakToken.EOF: return "EOF";
	case CatspeakToken.OTHER: return "OTHER";
	default: return "<unknown>";
	}
}

/// @desc Returns whether a token is a valid operator.
/// @param {CatspeakToken} token The token to check.
function catspeak_token_is_operator(_token) {
	return _token > CatspeakToken.__OPERATORS_BEGIN__
			&& _token < CatspeakToken.__OPERATORS_END__;
}

/// @desc Returns whether a byte is a valid newline character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_newline(_byte) {
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
function __catspeak_byte_is_not_newline(_byte) {
	return !__catspeak_byte_is_newline(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_quote(_byte) {
	return _byte == ord("\"");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_not_quote(_byte) {
	return !__catspeak_byte_is_quote(_byte);
}

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_accent(_byte) {
	return _byte == ord("`");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_not_accent(_byte) {
	return !__catspeak_byte_is_accent(_byte);
}

/// @desc Returns whether a byte is a valid whitespace character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_whitespace(_byte) {
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
function __catspeak_byte_is_alphabetic(_byte) {
	return _byte >= ord("a") && _byte <= ord("z")
			|| _byte >= ord("A") && _byte <= ord("Z")
			|| _byte == ord("_")
			|| _byte == ord("'");
}

/// @desc Returns whether a byte is a valid digit character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_digit(_byte) {
	return _byte >= ord("0") && _byte <= ord("9");
}

/// @desc Returns whether a byte is a valid alphanumeric character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_alphanumeric(_byte) {
	return __catspeak_byte_is_alphabetic(_byte)
			|| __catspeak_byte_is_digit(_byte);
}

/// @desc Returns whether a byte is a valid operator character.
/// @param {real} byte The byte to check.
function __catspeak_byte_is_operator(_byte) {
	return _byte == ord("!")
			|| _byte >= ord("#") && _byte <= ord("&")
			|| _byte == ord("*")
			|| _byte == ord("+")
			|| _byte == ord("-")
			|| _byte == ord("/")
			|| _byte >= ord("<") && _byte <= ord("@")
			|| _byte == ord("^")
			|| _byte == ord("|")
			|| _byte == ord("~");
}

/// @desc Tokenises the buffer contents.
/// @param {real} buffer The id of the buffer to use.
function CatspeakScanner(_buff) constructor {
	buff = _buff;
	alignment = buffer_get_alignment(_buff);
	limit = buffer_get_size(_buff);
	row = 1; // assumes the buffer is always at its starting position, even if it's not
	col = 1;
	rowStart = row;
	colStart = col;
	cr = false;
	lexeme = undefined;
	lexemeLength = 0;
	isCommentLexeme = true;
	skipNextByte = false;
	/// @desc Returns the current buffer lexeme.
	static getLexeme = function() {
		return lexeme;
	}
	/// @desc Returns the current buffer position.
	static getPosition = function() {
		return [rowStart, colStart];
	}
	/// @desc Checks for a new line character and increments the source position.
	/// @param {real} byte The byte to register.
	static registerByte = function(_byte) {
		lexemeLength += 1;
		if (isCommentLexeme && _byte != ord("-")) {
			isCommentLexeme = false;
		}
		if (_byte == ord("\r")) {
			cr = true;
			col = 1;
			row += 1;
		} else if (_byte == ord("\n")) {
			col = 1;
			if (cr) {
				cr = false;
			} else {
				row += 1;
			}
		} else {
			col += 1;
			cr = false;
		}
	}
	/// @desc Registers the current lexeme as a string.
	static registerLexeme = function() {
		if (lexemeLength < 1) {
			// always an empty slice
			lexeme = "";
			return;
		}
		var slice = buffer_create(lexemeLength, buffer_fixed, 1);
		buffer_copy(buff, buffer_tell(buff) - lexemeLength, lexemeLength, slice, 0);
		buffer_seek(slice, buffer_seek_start, 0);
		lexeme = buffer_read(slice, buffer_text);
		buffer_delete(slice);
	}
	/// @desc Resets the current lexeme.
	static clearLexeme = function() {
		isCommentLexeme = true;
		lexemeLength = 0;
		lexeme = undefined;
		rowStart = row;
		colStart = col;
	}
	/// @desc Advances the scanner and returns the current byte.
	static advance = function() {
		var byte = buffer_read(buff, buffer_u8);
		registerByte(byte);
		return byte;
	}
	/// @desc Returns whether the next byte equals this expected byte. And advances the scanner if this is the case.
	/// @param {real} expected The byte to check for.
	static advanceIf = function(_expected) {
		var seek = buffer_tell(buff);
		var actual = buffer_peek(buff, seek, buffer_u8);
		if (actual != _expected) {
			return false;
		}
		buffer_read(buff, buffer_u8);
		registerByte(actual);
		return true;
	}
	/// @desc Advances the scanner whilst a predicate holds, or until the EoF was reached.
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
			registerByte(byte);
			seek += alignment;
		}
		buffer_seek(buff, buffer_seek_start, seek);
		return byte;
	}
	/// @desc Advances the scanner according to this predicate, but escapes newline characters.
	/// @param {script} pred The predicate to check for.
	static advanceWhile = function(_pred) {
		return advanceWhileEscape(_pred, __catspeak_byte_is_newline);
	}
	/// @desc Advances the scanner and returns the next token.
	static next = function() {
		clearLexeme();
		if (buffer_tell(buff) >= limit) {
			return CatspeakToken.EOF;
		}
		if (skipNextByte) {
			advance();
			skipNextByte = false;
			return next();
		}
		var byte = advance();
		switch (byte) {
		case ord("\\"):
			// this is needed for a specific case where `\` is the first character in a line
			advanceWhile(__catspeak_byte_is_newline);
			advanceWhile(__catspeak_byte_is_whitespace);
			return CatspeakToken.WHITESPACE;
		case ord("("):
			return CatspeakToken.PAREN_LEFT;
		case ord(")"):
			return CatspeakToken.PAREN_RIGHT;
		case ord("["):
			return CatspeakToken.BOX_LEFT;
		case ord("]"):
			return CatspeakToken.BOX_RIGHT;
		case ord("{"):
			return CatspeakToken.BRACE_LEFT;
		case ord("}"):
			return CatspeakToken.BRACE_RIGHT;
		case ord(":"):
			return CatspeakToken.COLON;
		case ord(";"):
			return CatspeakToken.SEMICOLON;
		case ord("|"):
		case ord("^"):
		case ord("$"):
			advanceWhile(__catspeak_byte_is_operator);
			registerLexeme();
			return CatspeakToken.DISJUNCTION;
		case ord("&"):
			advanceWhile(__catspeak_byte_is_operator);
			registerLexeme();
			return CatspeakToken.CONJUNCTION;
		case ord("<"):
		case ord(">"):
		case ord("!"):
		case ord("?"):
		case ord("="):
		case ord("~"):
			advanceWhile(__catspeak_byte_is_operator);
			registerLexeme();
			return CatspeakToken.COMPARISON;
		case ord("+"):
		case ord("-"):
			advanceWhile(__catspeak_byte_is_operator);
			if (isCommentLexeme && lexemeLength > 1) {
				advanceWhile(__catspeak_byte_is_not_newline);
				return CatspeakToken.COMMENT;
			}
			registerLexeme();
			return CatspeakToken.ADDITION;
		case ord("*"):
		case ord("/"):
			advanceWhile(__catspeak_byte_is_operator);
			registerLexeme();
			return CatspeakToken.MULTIPLICATION;
		case ord("%"):
		case ord("@"):
		case ord("#"):
			advanceWhile(__catspeak_byte_is_operator);
			registerLexeme();
			return CatspeakToken.DIVISION;
		case ord("\""):
			clearLexeme();
			advanceWhileEscape(__catspeak_byte_is_not_quote, __catspeak_byte_is_quote);
			skipNextByte = true;
			registerLexeme();
			return CatspeakToken.STRING;
		case ord("."):
			return CatspeakToken.DOT;
		case ord("`"):
			clearLexeme();
			advanceWhileEscape(__catspeak_byte_is_not_accent, __catspeak_byte_is_accent);
			skipNextByte = true;
			registerLexeme();
			return CatspeakToken.IDENTIFIER;
		default:
			if (__catspeak_byte_is_newline(byte)) {
				advanceWhile(__catspeak_byte_is_newline);
				return CatspeakToken.EOL;
			} else if (__catspeak_byte_is_whitespace(byte)) {
				advanceWhile(__catspeak_byte_is_whitespace);
				return CatspeakToken.WHITESPACE;
			} else if (__catspeak_byte_is_alphabetic(byte)) {
				advanceWhile(__catspeak_byte_is_alphanumeric);
				registerLexeme();
				var keyword;
				switch (lexeme) {
				case "set":
					keyword = CatspeakToken.SET;
					break;
				case "if":
					keyword = CatspeakToken.IF;
					break;
				case "else":
					keyword = CatspeakToken.ELSE;
					break;
				case "while":
					keyword = CatspeakToken.WHILE;
					break;
				case "print":
					keyword = CatspeakToken.PRINT;
					break;
				case "run":
					keyword = CatspeakToken.RUN;
					break;
				case "return":
					keyword = CatspeakToken.RETURN;
					break;
				default:
					return CatspeakToken.IDENTIFIER;
				}
				lexeme = undefined;
				return keyword;
			} else if (__catspeak_byte_is_digit(byte)) {
				advanceWhile(__catspeak_byte_is_digit);
				registerLexeme();
				return CatspeakToken.NUMBER;
			} else {
				return CatspeakToken.OTHER;
			}
		}
	}
	/// @desc Returns the next token that isn't a whitespace or comment token.
	static nextWithoutSpace = function() {
		var token;
		do {
			token = next();
		} until (token != CatspeakToken.WHITESPACE
				&& token != CatspeakToken.COMMENT);
		return token;
	}
}

/// @desc An iterator that simplifies tokens generated by the scanner and applies automatic semicolon insertion.
/// @param {CatspeakScanner} scanner The Catspeak scanner to iterate over.
function CatspeakLexer(_scanner) constructor {
	scanner = _scanner;
	pred = CatspeakToken.BOF;
	lexeme = scanner.getLexeme();
	pos = scanner.getPosition();
	current = scanner.nextWithoutSpace();
	parenDepth = 0;
	eof = false;
	/// @desc Returns the current buffer lexeme.
	static getLexeme = function() {
		return lexeme;
	}
	/// @desc Returns the current buffer position.
	static getPosition = function() {
		return pos;
	}
	/// @desc Advances the scanner and returns the next token.
	static next = function() {
		while (true) {
			lexeme = scanner.getLexeme();
			pos = scanner.getPosition();
			var succ = scanner.nextWithoutSpace();
			switch (current) {
			case CatspeakToken.PAREN_LEFT:
				parenDepth += 1;
				break;
			case CatspeakToken.PAREN_RIGHT:
				if (parenDepth > 0) {
					parenDepth -= 1;
				}
				break;
			case CatspeakToken.EOL:
				var implicit_semicolon = parenDepth <= 0;
				switch (pred) {
				case CatspeakToken.BOX_LEFT:
				case CatspeakToken.BRACE_LEFT:
				case CatspeakToken.DOT:
				case CatspeakToken.COLON:
				case CatspeakToken.SEMICOLON:
				case CatspeakToken.ADDITION:
					implicit_semicolon = false;
					break;
				default:
					if (catspeak_token_is_operator(pred)) {
						implicit_semicolon = false;
					}
				}
				switch (succ) {
				case CatspeakToken.DOT:
				case CatspeakToken.COLON:
				case CatspeakToken.ELSE:
				case CatspeakToken.SEMICOLON:
				case CatspeakToken.ADDITION:
					implicit_semicolon = false;
					break;
				default:
					if (catspeak_token_is_operator(succ)) {
						implicit_semicolon = false;
					}
				}
				if (implicit_semicolon) {
					current = CatspeakToken.SEMICOLON;
				} else {
					// ignore this EOL character and try again
					current = succ;
					continue;
				}
				break;
			case CatspeakToken.EOF:
				if not (eof) {
					current = CatspeakToken.SEMICOLON;
					eof = true;
				}
				break;
			}
			pred = current;
			current = succ;
			return pred;
		}
	}
}