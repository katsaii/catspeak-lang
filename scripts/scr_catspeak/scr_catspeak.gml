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
	/// @desc Joins two spans together.
	/// @param {CatspeakSpan} other The other span to combine with.
	static join = function(_other) {
		var best_start = min(start, _other.start);
		var best_end = max(start + limit, _other.start + _other.limit);
		return new CatspeakSpan(best_start, best_end);
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
enum CatspeakToken {
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
/// @param {CatspeakToken} kind The token kind to display.
function catspeak_token_render(_kind) {
	switch (_kind) {
	case CatspeakToken.LEFT_PAREN: return "LEFT_PAREN";
	case CatspeakToken.RIGHT_PAREN: return "RIGHT_PAREN";
	case CatspeakToken.LEFT_BOX: return "LEFT_BOX";
	case CatspeakToken.RIGHT_BOX: return "RIGHT_BOX";
	case CatspeakToken.LEFT_BRACE: return "LEFT_BRACE";
	case CatspeakToken.RIGHT_BRACE: return "RIGHT_BRACE";
	case CatspeakToken.DOT: return "DOT";
	case CatspeakToken.BAR: return "BAR";
	case CatspeakToken.COLON: return "COLON";
	case CatspeakToken.SEMICOLON: return "SEMICOLON";
	case CatspeakToken.PLUS: return "PLUS";
	case CatspeakToken.MINUS: return "MINUS";
	case CatspeakToken.IDENTIFIER: return "IDENTIFIER";
	case CatspeakToken.STRING: return "STRING";
	case CatspeakToken.NUMBER: return "NUMBER";
	case CatspeakToken.WHITESPACE: return "WHITESPACE";
	case CatspeakToken.COMMENT: return "COMMENT";
	case CatspeakToken.EOL: return "EOL";
	case CatspeakToken.BOF: return "BOF";
	case CatspeakToken.EOF: return "EOF";
	case CatspeakToken.UNKNOWN: return "UNKNOWN";
	default: return "<unknown>";
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
			return CatspeakToken.EOF;
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
			return CatspeakToken.WHITESPACE;
		case ord("#"):
			advanceWhile(catspeak_byte_is_not_newline);
			return CatspeakToken.COMMENT;
		case ord("("):
			return CatspeakToken.LEFT_PAREN;
		case ord(")"):
			return CatspeakToken.RIGHT_PAREN;
		case ord("["):
			return CatspeakToken.LEFT_BOX;
		case ord("]"):
			return CatspeakToken.RIGHT_BOX;
		case ord("{"):
			return CatspeakToken.LEFT_BRACE;
		case ord("}"):
			return CatspeakToken.RIGHT_BRACE;
		case ord("."):
			return CatspeakToken.DOT;
		case ord("|"):
			return CatspeakToken.BAR;
		case ord(":"):
			return CatspeakToken.COLON;
		case ord(";"):
			return CatspeakToken.SEMICOLON;
		case ord("+"):
			return CatspeakToken.PLUS;
		case ord("-"):
			return CatspeakToken.MINUS;
		case ord("\""):
			resetSpan();
			advanceWhileEscape(catspeak_byte_is_not_quote, catspeak_byte_is_quote);
			skipNextByte = true;
			return CatspeakToken.STRING;
		default:
			if (catspeak_byte_is_newline(byte)) {
				advanceWhile(catspeak_byte_is_newline);
				return CatspeakToken.EOL;
			} else if (catspeak_byte_is_whitespace(byte)) {
				advanceWhile(catspeak_byte_is_whitespace);
				return CatspeakToken.WHITESPACE;
			} else if (catspeak_byte_is_alphabetic(byte)) {
				advanceWhile(catspeak_byte_is_alphanumeric);
				return CatspeakToken.IDENTIFIER;
			} else if (catspeak_byte_is_digit(byte)) {
				advanceWhile(catspeak_byte_is_digit);
				return CatspeakToken.NUMBER;
			} else {
				return CatspeakToken.UNKNOWN;
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
	span = lexer.getSpan();
	current = lexer.nextWithoutSpace();
	parenDepth = 0;
	seenBar = false;
	eof = false;
	/// @desc Returns the current buffer span.
	static getSpan = function() {
		return span;
	}
	/// @desc Advances the lexer and returns the next token.
	static next = function() {
		while (true) {
			span = lexer.getSpan();
			var succ = lexer.nextWithoutSpace();
			switch (current) {
			case CatspeakToken.BAR:
				seenBar = !seenBar;
			case CatspeakToken.LEFT_PAREN:
			case CatspeakToken.LEFT_BOX:
				parenDepth += 1;
				break;
			case CatspeakToken.RIGHT_PAREN:
			case CatspeakToken.RIGHT_BOX:
				if (parenDepth > 0) {
					parenDepth -= 1;
				}
				break;
			case CatspeakToken.EOL:
				var implicit_semicolon = !seenBar && parenDepth <= 0;
				switch (pred) {
				case CatspeakToken.LEFT_BRACE:
				case CatspeakToken.DOT:
				case CatspeakToken.BAR:
				case CatspeakToken.COLON:
				case CatspeakToken.SEMICOLON:
				case CatspeakToken.PLUS:
				case CatspeakToken.MINUS:
					implicit_semicolon = false;
					break;
				}
				switch (succ) {
				case CatspeakToken.LEFT_BRACE:
				case CatspeakToken.DOT:
				case CatspeakToken.BAR:
				case CatspeakToken.COLON:
				case CatspeakToken.SEMICOLON:
				case CatspeakToken.PLUS:
				case CatspeakToken.MINUS:
					implicit_semicolon = false;
					break;
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
	STATEMENT,
	VALUE,
	IDENTIFIER,
	NO_OP,
	CALL,
	GROUPING
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function catspeak_ir_render(_kind) {
	switch (_kind) {
	case CatspeakIRKind.VALUE: return "VALUE";
	case CatspeakIRKind.IDENTIFIER: return "IDENTIFIER";
	case CatspeakIRKind.NO_OP: return "NO_OP";
	case CatspeakIRKind.CALL: return "CALL";
	case CatspeakIRKind.GROUPING: return "GROUPING";
	default: return "<unknown>";
	}
}

/// @desc Represents an IR node.
/// @param {CatspeakSpan} span The span of the ir node.
/// @param {CatspeakIRKind} kind The kind of ir node.
/// @param {value} value The value held by the ir node.
function CatspeakIRNode(_span, _kind, _value) constructor {
	span = _span;
	kind = _kind;
	value = _value;
}

/// @desc Creates a new parser from this string.
/// @param {real} buffer The id of the buffer to use.
function CatspeakParser(_buff) constructor {
	lexer = new CatspeakParserLexer(_buff);
	buff = _buff;
	token = CatspeakToken.BOF;
	span = lexer.getSpan();
	peeked = lexer.next();
	/// @desc Advances the parser and returns the token.
	static advance = function() {
		token = peeked;
		span = lexer.getSpan();
		peeked = lexer.next();
		return token;
	}
	/// @desc Renders the current span of the parser.
	static renderContent = function() {
		return span.render(buff);
	}
	/// @desc Throws a `CatspeakCompilerError` for the current token.
	/// @param {string} on_error The error message.
	static error = function(_msg) {
		advance();
		throw new CatspeakCompilerError(_msg + " (" + catspeak_token_render(token) + ")", span);
	}
	/// @desc Returns true if the current token matches this token kind.
	/// @param {CatspeakToken} kind The token kind to match.
	static matches = function(_kind) {
		return peeked == _kind;
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
			error(_msg);
		}
	}
	/// @desc Entry point for parsing statements.
	static parseStmt = function() {
		if (consume(CatspeakToken.SEMICOLON)) {
			return new CatspeakIRNode(
					span, CatspeakIRKind.NO_OP, undefined);
		} else {
			var value = parseExpr();
			expects(CatspeakToken.SEMICOLON, "expected `;` after statement");
			var my_span = value.span.join(span);
			return new CatspeakIRNode(
					my_span, CatspeakIRKind.STATEMENT, value);
		}
	}
	/// @desc Entry point for parsing expressions.
	static parseExpr = function() {
		return parseCall();
	}
	/// @desc Parses a function call.
	static parseCall = function() {
		var callsite = parseValue();
		/*if (callsite.kind = CatspeakIRKind.IDENTIFIER) {
			// parse keywords
			switch (callsite.value) {
			case "var":
				// TODO
				throw "not implemented";
			}
		}*/
		var params = [];
		while (matches(CatspeakToken.LEFT_PAREN)
				|| matches(CatspeakToken.LEFT_BOX)
				|| matches(CatspeakToken.LEFT_BRACE)
				|| matches(CatspeakToken.COLON)
				|| matches(CatspeakToken.BAR)
				|| matches(CatspeakToken.IDENTIFIER)
				|| matches(CatspeakToken.STRING)
				|| matches(CatspeakToken.NUMBER)) {
			var param = parseValue();
			array_push(params, param);
		}
		var arg_count = array_length(params);
		if (arg_count == 0) {
			return callsite;
		} else {
			var my_span = callsite.span.join(params[arg_count - 1].span);
			return new CatspeakIRNode(
					my_span, CatspeakIRKind.CALL, {
						callsite : callsite,
						params : params
					});
		}
	}
	/// @desc Parses a terminal value or expression.
	static parseValue = function() {
		if (matches(CatspeakToken.IDENTIFIER)) {
			return new CatspeakIRNode(
					span, CatspeakIRKind.IDENTIFIER, renderContent());
		} else if (consume(CatspeakToken.STRING)) {
			return new CatspeakIRNode(
					span, CatspeakIRKind.VALUE, renderContent());
		} else if (consume(CatspeakToken.NUMBER)) {
			return new CatspeakIRNode(
					span, CatspeakIRKind.VALUE, real(renderContent()));
		} else {
			return parseGrouping();
		}
	}
	/// @desc Parses groupings of expressions.
	static parseGrouping = function() {
		var span_start = span;
		if (consume(CatspeakToken.COLON)) {
			var value = parseExpr();
			var my_span = span_start.join(value.span);
			return new CatspeakIRNode(
					my_span, CatspeakIRKind.GROUPING, value);
		} else if (consume(CatspeakToken.LEFT_PAREN)) {
			var value = parseExpr();
			expects(CatspeakToken.RIGHT_PAREN, "expected closing `)` in grouping");
			var my_span = span_start.join(span);
			return new CatspeakIRNode(
					my_span, CatspeakIRKind.GROUPING, value);
		} else {
			error("unexpected symbol in expression");
		}
	}
}

/// @desc Represents a kind of intcode.
enum CatspeakOpCode {
	PUSH_VALUE,
	POP_VALUE,
	GET_VALUE,
	SET_VALUE,
	CALL
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function catspeak_code_render(_kind) {
	switch (_kind) {
	case CatspeakOpCode.PUSH_VALUE: return "PUSH_VALUE";
	case CatspeakOpCode.POP_VALUE: return "POP_VALUE";
	case CatspeakOpCode.GET_VALUE: return "GET_VALUE";
	case CatspeakOpCode.SET_VALUE: return "SET_VALUE";
	case CatspeakOpCode.CALL: return "CALL";
	default: return "<unknown>";
	}
}

/// @desc Handles the generation of intcode from Catspeak IR.
/// @param {real} buffer The id of the buffer to use.
/// @param {array} out The array to populate code with.
function CatspeakCodegen(_buff, _out) constructor {
	parser = new CatspeakParser(_buff);
	buff = _buff;
	out = _out;
	/// @desc Writes a list of codes to the output array.
	/// @param {CatspeakOpCode} opcode The op code to write.
	/// @param {value} [value] Other values to write.
	static writeCode = function(_opcode) {
		array_push(out, _opcode);
		for (var i = 1; i < argument_count; i += 1) {
			array_push(out, argument[i]);
		}
	}
	/// @desc Generates the code for the next IR term.
	/// @param {CatspeakIRTerm} term The term to generate code for.
	static visitTerm = function(_term) {
		var kind = _term.kind;
		var value = _term.value;
		var span = _term.span;
		switch (_term.kind) {
		case CatspeakIRKind.STATEMENT:
			visitTerm(value);
			writeCode(CatspeakOpCode.POP_VALUE);
			return;
		case CatspeakIRKind.VALUE:
			writeCode(CatspeakOpCode.PUSH_VALUE, value);
			return;
		case CatspeakIRKind.IDENTIFIER:
			throw "not implemented";
			return;
		case CatspeakIRKind.NO_OP:
			return;
		case CatspeakIRKind.CALL:
			var callsite = value.callsite;
			var params = value.params;
			var arg_count = array_length(params);
			for (var i = 0; i < arg_count; i += 1) {
				visitTerm(params[i]);
			}
			visitTerm(callsite);
			writeCode(CatspeakOpCode.CALL);
			return;
		case CatspeakIRKind.GROUPING:
			visitTerm(_term.value);
			return;
		}
	}
	/// @desc Generates the code for a single term and returns whether more terms need to be parsed.
	static generateCode = function() {
		if (parser.matches(CatspeakToken.EOF)) {
			return false;
		}
		var ir = parser.parseStmt();
		visitTerm(ir);
		return true;
	}
}

/// @desc Creates a compiler session from this string.
/// @param {string} str The string that contains the source code.
function catspeak_session_create(_str) {
	var size = string_byte_length(_str);
	var buff = buffer_create(size, buffer_fixed, 1);
	buffer_write(buff, buffer_text, _str);
	buffer_seek(buff, buffer_seek_start, 0);
	return {
		buff : buff
	};
}

/// @desc Destroys this compiler session.
/// @param {struct} sess The session to kill.
function catspeak_session_destroy(_sess) {
	buffer_delete(_sess.buff);
}

/// @desc Compiles this session and returns the resulting intcode program.
/// @param {struct} sess The session to compile.
function catspeak_session_compile(_sess) {
	var buff = _sess.buff;
	buffer_seek(buff, buffer_seek_start, 0);
	var out = [];
	var codegen = new CatspeakCodegen(buff, out);
	while (codegen.generateCode()) { }
	return out;
}
