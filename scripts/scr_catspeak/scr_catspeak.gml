/* Catspeak Core Compiler
 * ----------------------
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

/// @desc Represents a kind of token.
enum CatspeakToken {
	PAREN_LEFT,
	PAREN_RIGHT,
	BOX_LEFT,
	BOX_RIGHT,
	BRACE_LEFT,
	BRACE_RIGHT,
	COLON, // function application operator, `f (a + b)` is equivalent to `f : a + b`
	SEMICOLON, // statement terminator
	__OPERATORS_BEGIN__,
	ADDITION,
	__OPERATORS_END__,
	SET,
	IF,
	ELSE,
	WHILE,
	PRINT,
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
	case CatspeakToken.COLON: return "COLON";
	case CatspeakToken.SEMICOLON: return "SEMICOLON";
	case CatspeakToken.ADDITION: return "ADDITION";
	case CatspeakToken.SET: return "SET";
	case CatspeakToken.IF: return "IF";
	case CatspeakToken.ELSE: return "ELSE";
	case CatspeakToken.WHILE: return "WHILE";
	case CatspeakToken.PRINT: return "PRINT";
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

/// @desc Returns whether a byte is a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_accent(_byte) {
	return _byte == ord("`");
}

/// @desc Returns whether a byte is NOT a valid quote character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_not_accent(_byte) {
	return !catspeak_byte_is_accent(_byte);
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

/// @desc Returns whether a byte is a valid operator character.
/// @param {real} byte The byte to check.
function catspeak_byte_is_operator(_byte) {
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
function CatspeakLexer(_buff) constructor {
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
	/// @desc Advances the lexer and returns the current byte.
	static advance = function() {
		var byte = buffer_read(buff, buffer_u8);
		registerByte(byte);
		return byte;
	}
	/// @desc Returns whether the next byte equals this expected byte. And advances the lexer if this is the case.
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
			registerByte(byte);
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
			advanceWhile(catspeak_byte_is_newline);
			advanceWhile(catspeak_byte_is_whitespace);
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
		case ord("+"):
		case ord("-"):
			advanceWhile(catspeak_byte_is_operator);
			if (isCommentLexeme && lexemeLength > 1) {
				advanceWhile(catspeak_byte_is_not_newline);
				return CatspeakToken.COMMENT;
			}
			registerLexeme();
			return CatspeakToken.ADDITION;
		case ord("\""):
			clearLexeme();
			advanceWhileEscape(catspeak_byte_is_not_quote, catspeak_byte_is_quote);
			skipNextByte = true;
			registerLexeme();
			return CatspeakToken.STRING;
		case ord("."):
			clearLexeme();
			advanceWhileEscape(catspeak_byte_is_alphanumeric);
			registerLexeme();
			return CatspeakToken.STRING;
		case ord("`"):
			clearLexeme();
			advanceWhileEscape(catspeak_byte_is_not_accent, catspeak_byte_is_accent);
			skipNextByte = true;
			registerLexeme();
			return CatspeakToken.IDENTIFIER;
		default:
			if (catspeak_byte_is_newline(byte)) {
				advanceWhile(catspeak_byte_is_newline);
				return CatspeakToken.EOL;
			} else if (catspeak_byte_is_whitespace(byte)) {
				advanceWhile(catspeak_byte_is_whitespace);
				return CatspeakToken.WHITESPACE;
			} else if (catspeak_byte_is_alphabetic(byte)) {
				advanceWhile(catspeak_byte_is_alphanumeric);
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
				default:
					return CatspeakToken.IDENTIFIER;
				}
				lexeme = undefined;
				return keyword;
			} else if (catspeak_byte_is_digit(byte)) {
				advanceWhile(catspeak_byte_is_digit);
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

/// @desc An iterator that simplifies tokens generated by the lexer and applies automatic semicolon insertion.
/// @param {real} buffer The id of the buffer to use.
function CatspeakParserLexer(_buff) constructor {
	lexer = new CatspeakLexer(_buff);
	pred = CatspeakToken.BOF;
	lexeme = lexer.getLexeme();
	pos = lexer.getPosition();
	current = lexer.nextWithoutSpace();
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
	/// @desc Advances the lexer and returns the next token.
	static next = function() {
		while (true) {
			lexeme = lexer.getLexeme();
			pos = lexer.getPosition();
			var succ = lexer.nextWithoutSpace();
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

/// @desc Represents a kind of IR node.
enum CatspeakIRKind {
	NOTHING,
	EXPRESSION_STATEMENT,
	SET,
	CONDITIONAL,
	LOOP,
	PRINT,
	CALL,
	CONSTANT,
	ARRAY,
	OBJECT,
	IDENTIFIER,
	GROUPING
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function catspeak_ir_render(_kind) {
	switch (_kind) {
	case CatspeakIRKind.NOTHING: return "NOTHING";
	case CatspeakIRKind.EXPRESSION_STATEMENT: return "EXPRESSION_STATEMENT";
	case CatspeakIRKind.SET: return "SET";
	case CatspeakIRKind.CONDITIONAL: return "CONDITIONAL";
	case CatspeakIRKind.LOOP: return "LOOP";
	case CatspeakIRKind.PRINT: return "PRINT";
	case CatspeakIRKind.CALL: return "CALL";
	case CatspeakIRKind.CONSTANT: return "CONSTANT";
	case CatspeakIRKind.ARRAY: return "ARRAY";
	case CatspeakIRKind.OBJECT: return "OBJECT";
	case CatspeakIRKind.IDENTIFIER: return "IDENTIFIER";
	case CatspeakIRKind.GROUPING: return "GROUPING";
	default: return "<unknown>";
	}
}

/// @desc Represents an IR node.
/// @param {vector} pos The vector holding the row and column numbers.
/// @param {CatspeakIRKind} kind The kind of ir node.
/// @param {value} [inner] The inner value (if required) held by the ir node.
function CatspeakIRNode(_pos, _kind) constructor {
	pos = _pos;
	kind = _kind;
	inner = argument_count > 2 ? argument[2] : undefined;
}

/// @desc Creates a new parser from this string.
/// @param {real} buffer The id of the buffer to use.
function CatspeakParser(_buff) constructor {
	lexer = new CatspeakParserLexer(_buff);
	token = CatspeakToken.BOF;
	pos = lexer.getPosition();
	lexeme = lexer.getLexeme();
	peeked = lexer.next();
	/// @desc Returns the current buffer position.
	static getPosition = function() {
		return pos;
	}
	/// @desc Creates a call node.
	/// @param {CatspeakIRNode} callsite The callsite.
	/// @param {array} params The paramter array.
	static genCallIR = function(_callsite, _params) {
		return new CatspeakIRNode(_callsite.pos, CatspeakIRKind.CALL, {
			callsite : _callsite,
			params : _params
		});
	}
	/// @desc Creates an identifier node.
	static genIdentIR = function() {
		return new CatspeakIRNode(
				pos, CatspeakIRKind.IDENTIFIER, lexeme);
	}
	/// @desc Advances the parser and returns the token.
	static advance = function() {
		token = peeked;
		pos = lexer.getPosition();
		lexeme = lexer.getLexeme();
		peeked = lexer.next();
		return token;
	}
	/// @desc Throws a `CatspeakCompilerError` for the current token.
	/// @param {string} on_error The error message.
	static error = function(_msg) {
		throw new CatspeakError(pos, _msg + " -- got `" + string(lexeme) + "` (" + catspeak_token_render(token) + ")");
	}
	/// @desc Advances the parser and throws a `CatspeakCompilerError` for the current token.
	/// @param {string} on_error The error message.
	static errorAndAdvance = function(_msg) {
		advance();
		error(_msg);
	}
	/// @desc Returns true if the current token matches this token kind.
	/// @param {CatspeakToken} kind The token kind to match.
	static matches = function(_kind) {
		return peeked == _kind;
	}
	/// @desc Returns true if the current token infers an expression.
	static matchesExpression = function() {
		return matches(CatspeakToken.PAREN_LEFT)
				|| matches(CatspeakToken.BOX_LEFT)
				|| matches(CatspeakToken.BRACE_LEFT)
				|| matches(CatspeakToken.COLON)
				|| matches(CatspeakToken.IDENTIFIER)
				|| matches(CatspeakToken.STRING)
				|| matches(CatspeakToken.NUMBER);
	}
	/// @desc Returns true if the current token matches any kind of operator.
	static matchesOperator = function() {
		return catspeak_token_is_operator(peeked);
	}
	/// @desc Attempts to match against a token and advances the parser if this was successful.
	/// @param {CatspeakToken} kind The token kind to consume.
	static consume = function(_kind) {
		if (matches(_kind)) {
			advance();
			return true;
		} else {
			return false;
		}
	}
	/// @desc Throws a `CatspeakCompilerError` if the current token is not the expected value. Advances the parser otherwise.
	/// @param {CatspeakToken} kind The token kind to expect.
	/// @param {string} on_error The error message.
	static expects = function(_kind, _msg) {
		if (consume(_kind)) {
			return token;
		} else {
			errorAndAdvance(_msg);
		}
	}
	/// @desc Throws a `CatspeakCompilerError` if the current token is not a semicolon. Advances the parser otherwise.
	/// @param {string} on_error The error message.
	static expectsSemicolon = function(_msg) {
		return expects(CatspeakToken.SEMICOLON, "expected `;` or new line " + _msg);
	}
	/// @desc Entry point for parsing statements.
	static parseStmt = function() {
		if (consume(CatspeakToken.SEMICOLON)) {
			return new CatspeakIRNode(
					pos, CatspeakIRKind.NOTHING, undefined);
		} else if (consume(CatspeakToken.SET)) {
			var start = pos;
			expects(CatspeakToken.IDENTIFIER, "expected identifier after `set` keyword");
			var ident = lexeme;
			var params = [];
			while (matchesExpression()) {
				var param = parseValue();
				array_push(params, param);
			}
			expectsSemicolon("after `set` statements");
			return new CatspeakIRNode(start, CatspeakIRKind.SET, {
				ident : ident,
				params : params
			});
		} else if (consume(CatspeakToken.IF)) {
			errorAndAdvance("if statements not implemented");
		} else if (consume(CatspeakToken.WHILE)) {
			errorAndAdvance("while loops not implemented");
		} else if (consume(CatspeakToken.PRINT)) {
			var start = pos;
			var values = [];
			while (matchesExpression()) {
				array_push(values, parseValue());
			}
			expectsSemicolon("after `print` statements");
			return new CatspeakIRNode(start, CatspeakIRKind.PRINT, values);
		} else {
			var value = parseExpr();
			expectsSemicolon("after expression statements");
			return new CatspeakIRNode(value.pos, CatspeakIRKind.EXPRESSION_STATEMENT, value);
		}
	}
	/// @desc Entry point for parsing expressions.
	static parseExpr = function() {
		return parseBinary(CatspeakToken.__OPERATORS_BEGIN__ + 1);
	}
	/// @desc Parses binary operators.
	/// @param {CatspeakToken} token The kind of operator token to check for.
	static parseBinary = function(_kind) {
		if (_kind >= CatspeakToken.__OPERATORS_END__) {
			return parseCall();
		}
		var next_kind = _kind + 1;
		var expr = parseBinary(next_kind);
		while (consume(_kind)) {
			var callsite = genIdentIR();
			expr = genCallIR(callsite, [expr, parseBinary(next_kind)]);
		}
		return expr;
	}
	/// @desc Parses a function call.
	static parseCall = function() {
		var callsite = parseValue();
		var params = [];
		while (matchesExpression()) {
			var param = parseValue();
			array_push(params, param);
		}
		var arg_count = array_length(params);
		if (arg_count == 0) {
			return callsite;
		} else {
			return genCallIR(callsite, params);
		}
	}
	/// @desc Parses a terminal value or expression.
	static parseValue = function() {
		if (consume(CatspeakToken.IDENTIFIER)) {
			return genIdentIR();
		} else if (matchesOperator()) {
			advance();
			return genIdentIR();
		} else if (consume(CatspeakToken.STRING)) {
			return new CatspeakIRNode(
					pos, CatspeakIRKind.CONSTANT, lexeme);
		} else if (consume(CatspeakToken.NUMBER)) {
			return new CatspeakIRNode(
					pos, CatspeakIRKind.CONSTANT, real(lexeme));
		} else {
			return parseGrouping();
		}
	}
	/// @desc Parses groupings of expressions.
	static parseGrouping = function() {
		if (consume(CatspeakToken.COLON)) {
			var start = pos;
			var value = parseExpr();
			return new CatspeakIRNode(
					start, CatspeakIRKind.GROUPING, value);
		} else if (consume(CatspeakToken.PAREN_LEFT)) {
			var start = pos;
			var value = parseExpr();
			expects(CatspeakToken.PAREN_RIGHT, "expected closing `)` in grouping");
			return new CatspeakIRNode(
					start, CatspeakIRKind.GROUPING, value);
		} else if (consume(CatspeakToken.BOX_LEFT)) {
			var start = pos;
			var params = [];
			while (matchesExpression()) {
				var param = parseExpr();
				array_push(params, param);
				if not (matches(CatspeakToken.BOX_RIGHT)) {
					expectsSemicolon("between array elements");
				}
			}
			expects(CatspeakToken.BOX_RIGHT, "expected closing `]` in array literal");
			return new CatspeakIRNode(start, CatspeakIRKind.ARRAY, params);
		} else if (consume(CatspeakToken.BRACE_LEFT)) {
			var start = pos;
			var params = [];
			while (matchesExpression()) {
				var key = parseValue();
				var value = parseValue();
				array_push(params, key);
				array_push(params, value);
				if not (matches(CatspeakToken.BOX_RIGHT)) {
					expectsSemicolon("between object elements");
				}
			}
			expects(CatspeakToken.BRACE_RIGHT, "expected closing `}` in object literal");
			return new CatspeakIRNode(start, CatspeakIRKind.OBJECT, params);
		} else {
			errorAndAdvance("unexpected symbol in expression");
		}
	}
}

/// @desc Represents a kind of intcode.
enum CatspeakOpCode {
	PUSH,
	POP,
	VAR_GET,
	VAR_SET,
	MAKE_ARRAY,
	MAKE_OBJECT,
	PRINT,
	CALL,
	JUMP,
	JUMP_FALSE,
	RETURN
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function catspeak_code_render(_kind) {
	switch (_kind) {
	case CatspeakOpCode.PUSH: return "PUSH";
	case CatspeakOpCode.POP: return "POP";
	case CatspeakOpCode.VAR_GET: return "VAR_GET";
	case CatspeakOpCode.VAR_SET: return "VAR_SET";
	case CatspeakOpCode.MAKE_ARRAY: return "MAKE_ARRAY";
	case CatspeakOpCode.MAKE_OBJECT: return "MAKE_OBJECT";
	case CatspeakOpCode.PRINT: return "PRINT";
	case CatspeakOpCode.CALL: return "CALL";
	case CatspeakOpCode.JUMP: return "JUMP";
	case CatspeakOpCode.JUMP_FALSE: return "JUMP_FALSE";
	case CatspeakOpCode.RETURN: return "RETURN";
	default: return "<unknown>";
	}
}

/// @desc Represents a Catspeak intcode program with associated debug information.
function CatspeakChunk() constructor {
	intcode = [];
	diagnostic = [];
	/// @desc Adds a code and its positional information to the program.
	/// @param {vector} pos The position of this piece of code.
	/// @param {value} code The piece of code to write.
	static addCode = function(_pos, _code) {
		var i = array_length(intcode);
		array_push(diagnostic, _pos);
		array_push(intcode, _code);
		return i;
	}
	/// @desc Patches an existing code at this program counter.
	/// @param {vector} pc The program counter the code to patch.
	/// @param {value} code The piece of code to write.
	static patchCode = function(_pc, _code) {
		intcode[_pc] = _code;
		return _pc;
	}
}

/// @desc Handles the generation of intcode from Catspeak IR.
/// @param {real} buffer The id of the buffer to use.
/// @param {CatspeakProgram} out The program to populate code with.
function CatspeakCodegen(_buff, _out) constructor {
	parser = new CatspeakParser(_buff);
	out = _out;
	/// @desc Throws a `CatspeakCompilerError` for this IR term.
	/// @param {CatspeakIRKind} term The IR term to consider.
	/// @param {string} on_error The error message.
	static error = function(_term, _msg) {
		throw new CatspeakError(_term.pos, _msg);
	}
	/// @desc Generates the code for the next IR term.
	/// @param {CatspeakIRTerm} term The term to generate code for.
	static visitTerm = function(_term) {
		var pos = _term.pos;
		var kind = _term.kind;
		var inner = _term.inner;
		switch (kind) {
		case CatspeakIRKind.NOTHING:
			break;
		case CatspeakIRKind.EXPRESSION_STATEMENT:
			visitTerm(inner);
			out.addCode(pos, CatspeakOpCode.POP);
			break;
		case CatspeakIRKind.SET:
			var ident = inner.ident;
			var args = inner.params;
			var arg_count = array_length(args);
			for (var i = arg_count - 1; i >= 0; i -= 1) {
				visitTerm(args[i]);
			}
			out.addCode(pos, CatspeakOpCode.VAR_SET);
			out.addCode(pos, ident);
			out.addCode(pos, arg_count - 1);
			break;
		case CatspeakIRKind.CONDITIONAL:
			error(_term, "conditional unimplemented");
			break;
		case CatspeakIRKind.LOOP:
			error(_term, "loop unimplemented");
			break;
		case CatspeakIRKind.PRINT:
			var arg_count = array_length(inner);
			for (var i = 0; i < arg_count; i += 1) {
				visitTerm(inner[i]);
				out.addCode(pos, CatspeakOpCode.PRINT);
			}
			break;
		case CatspeakIRKind.CALL:
			var callsite = inner.callsite;
			var params = inner.params;
			var arg_count = array_length(params);
			for (var i = arg_count - 1; i >= 0; i -= 1) {
				visitTerm(params[i]);
			}
			visitTerm(callsite);
			out.addCode(pos, CatspeakOpCode.CALL);
			out.addCode(pos, arg_count);
			break;
		case CatspeakIRKind.CONSTANT:
			out.addCode(pos, CatspeakOpCode.PUSH);
			out.addCode(pos, inner);
			break;
		case CatspeakIRKind.ARRAY:
			var arg_count = array_length(inner);
			for (var i = arg_count - 1; i >= 0; i -= 1) {
				visitTerm(inner[i]);
			}
			out.addCode(pos, CatspeakOpCode.MAKE_ARRAY);
			out.addCode(pos, arg_count);
			break;
		case CatspeakIRKind.OBJECT:
			var arg_count = array_length(inner);
			for (var i = arg_count - 1; i >= 0; i -= 1) {
				visitTerm(inner[i]);
			}
			out.addCode(pos, CatspeakOpCode.MAKE_OBJECT);
			out.addCode(pos, arg_count div 2);
			break;
		case CatspeakIRKind.IDENTIFIER:
			out.addCode(pos, CatspeakOpCode.VAR_GET);
			out.addCode(pos, inner);
			break;
		case CatspeakIRKind.GROUPING:
			visitTerm(inner);
			break;
		}
	}
	/// @desc Generates the code for a single term and returns whether more terms need to be parsed.
	static generateCode = function() {
		if (parser.matches(CatspeakToken.EOF)) {
			var pos = parser.getPosition();
			out.addCode(pos, CatspeakOpCode.PUSH);
			out.addCode(pos, undefined);
			out.addCode(pos, CatspeakOpCode.RETURN);
			return false;
		}
		var ir = parser.parseStmt();
		visitTerm(ir);
		return true;
	}
}

/// @desc Compiles this string and returns the resulting intcode program.
/// @param {string} str The string that contains the source code.
function catspeak_compile(_str) {
	var size = string_byte_length(_str);
	var buff = buffer_create(size, buffer_fixed, 1);
	buffer_write(buff, buffer_text, _str);
	buffer_seek(buff, buffer_seek_start, 0);
	var out = new CatspeakChunk();
	var codegen = new CatspeakCodegen(buff, out);
	while (codegen.generateCode()) { }
	buffer_delete(buff);
	return out;
}

/// @desc Handles the execution of a single Catspeak chunk.
function CatspeakVM() constructor {
	interface = { };
	binding = { };
	resultHandler = undefined;
	chunks = [];
	chunk = undefined;
	pc = 0;
	stackLimit = 8;
	stackSize = 0;
	stack = array_create(stackLimit);
	/// @desc Throws a `CatspeakError` with the current program counter.
	/// @param {string} msg The error message.
	static error = function(_msg) {
		throw new CatspeakError(chunk.diagnostic[pc], _msg);
	}
	/// @desc Pushes a value onto the stack.
	/// @param {value} value The value to push.
	static push = function(_value) {
		stack[stackSize] = _value;
		stackSize += 1;
		if (stackSize >= stackLimit) {
			stackLimit *= 2;
			array_resize(stack, stackLimit);
		}
	}
	/// @desc Pops the top value from the stack.
	static pop = function() {
		if (stackSize < 1) {
			error("VM stack underflow");
		}
		stackSize -= 1;
		return stack[stackSize];
	}
	/// @desc Returns the top value of the stack.
	static top = function() {
		if (stackSize < 1) {
			error("cannot peek into empty VM stack");
		}
		return stack[stackSize - 1];
	}
	/// @desc Attemps to set a variable in the current context and returns whether it was successful.
	/// @param {string} name The name of the variable to add.
	/// @param {value} value The value to assign.
	static setVariable = function(_name, _value) {
		binding[$ _name] = _value;
	}
	/// @desc Gets a variable in the current context.
	/// @param {string} name The name of the variable to add.
	static getVariable = function(_name) {
		if (variable_struct_exists(binding, _name)) {
			return binding[$ _name];
		} else if (variable_struct_exists(interface, _name)) {
			return interface[$ _name];
		} else {
			return undefined;
		}
	}
	/// @desc Adds a new chunk to the VM to execute.
	/// @param {CatspeakChunk} chunk The chunk to execute code of.
	static addChunk = function(_chunk) {
		if (chunk == undefined) {
			chunk = _chunk;
		} else {
			array_insert(chunks, 0, _chunk);
		}
	}
	/// @desc Removes the chunk currently being executed.
	static terminateChunk = function() {
		if (chunk == undefined) {
			return;
		}
		pc = 0;
		if (array_length(chunks) >= 1) {
			chunk = array_pop(chunks);
		} else {
			chunk = undefined;
		}
	}
	/// @desc Returns whether the VM is in progress.
	static inProgress = function() {
		return chunk != undefined;
	}
	/// @desc Gets the variable workspace for this context.
	static getWorkspace = function() {
		return binding;
	}
	/// @desc Adds an interface to this VM.
	/// @param {struct} vars The context to assign.
	static addInterface = function(_vars) {
		var names = variable_struct_get_names(_vars);
		var name_count = array_length(names);
		for (var i = name_count - 1; i >= 0; i -= 1) {
			var name = names[i];
			interface[$ name] = _vars[$ name];
		}
		return self;
	}
	/// @desc Sets the function to call after program execution is complete.
	/// @param {function} f The function to call.
	static setResultHandler = function(_f) {
		resultHandler = _f;
		return self;
	}
	/// @desc Executes a single instruction and updates the program counter.
	static computeProgram = function() {
		var code = chunk.intcode;
		var inst = code[pc];
		switch (inst) {
		case CatspeakOpCode.PUSH:
			pc += 1;
			var value = code[pc];
			push(value);
			break;
		case CatspeakOpCode.POP:
			pop();
			break;
		case CatspeakOpCode.VAR_GET:
			pc += 1;
			var name = code[pc];
			var value = getVariable(name);
			push(value);
			break;
		case CatspeakOpCode.VAR_SET:
			pc += 1;
			var name = code[pc];
			pc += 1;
			var subscript_count = code[pc];
			if (subscript_count < 1) {
				var value = pop();
				setVariable(name, value);
			} else {
				var container = getVariable(name);
				for (; subscript_count >= 1; subscript_count -= 1) {
					var subscript = pop();
					var ty = typeof(container);
					switch (ty) {
					case "array":
						if (subscript_count <= 1) {
							var value = pop();
							container[@ subscript] = value;
						} else {
							container = container[subscript];
						}
						break;
					case "struct":
						if (subscript_count <= 1) {
							var value = pop();
							container[$ subscript] = value;
						} else {
							container = container[$ string(subscript)];
						}
						break;
					default:
						error("cannot index value of type `" + ty + "`");
						break;
					}
				}
			}
			break;
		case CatspeakOpCode.MAKE_ARRAY:
			pc += 1;
			var size = code[pc];
			var container = array_create(size);
			for (var i = 0; i < size; i += 1) {
				var value = pop();
				container[@ i] = value;
			}
			push(container);
			break;
		case CatspeakOpCode.MAKE_OBJECT:
			pc += 1;
			var size = code[pc];
			var container = { };
			repeat (size) {
				var key = pop();
				var value = pop();
				container[$ string(key)] = value;
			}
			push(container);
			break;
		case CatspeakOpCode.PRINT:
			var value = pop();
			show_debug_message(value);
			break;
		case CatspeakOpCode.JUMP:
			pc += 1;
			var new_pc = code[pc];
			pc = new_pc;
			return;
		case CatspeakOpCode.JUMP_FALSE:
			pc += 1;
			var new_pc = code[pc];
			var value = pop();
			if not (is_numeric(value) && value) {
				pc = new_pc;
				return;
			}
			break;
		case CatspeakOpCode.CALL:
			pc += 1;
			var arg_count = code[pc];
			var callsite = pop();
			var ty = typeof(callsite);
			switch (ty) {
			case "array":
			case "struct":
				var container = callsite;
				repeat (arg_count) {
					var value = pop();
					var ty = typeof(container);
					switch (ty) {
					case "array":
						container = container[value];
						break;
					case "struct":
						container = container[$ string(value)];
						break;
					default:
						error("cannot index value of type `" + ty + "`");
					}
					
				}
				push(container);
				break;
			case "method":
				error("methods are not supported");
				break;
			case "number":
			case "bool":
			case "int32":
			case "int64":
				// verify the asset exists before attempting to access it
				error("asset indexes are not supported");
				break;
			default:
				error("invalid callsite of type `" + ty + "`");
				break;
			}
			break;
		case CatspeakOpCode.RETURN:
			var value = pop();
			if (resultHandler != undefined) {
				resultHandler(value);
			}
			terminateChunk(); // complete execution
			return;
		default:
			error("unknown program instruction `" + string(inst) + "` (" + catspeak_code_render(inst) + ")");
			break;
		}
		pc += 1;
	}
}

var src = @'
set x {
	.fps : 64
	.player_speed : 1
	.colours : [
		"hello"
		12
	]
}
print : x
print : `+`
';
var chunk = catspeak_compile(src);
var vm = new CatspeakVM()
		.addInterface(catspeak_ext_gml())
		.addInterface(catspeak_ext_arithmetic())
		.setResultHandler(function(_result) {
			show_message(_result);
		});
vm.addChunk(chunk);
while (vm.inProgress()) {
	vm.computeProgram();
}