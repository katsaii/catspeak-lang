/* Catspeak Core Compiler
 * ----------------------
 * Kat @katsaii
 */

// TODO refactor language so operators are equivalent to identifiers
// TODO refactor language so that precedence of identifiers is determined entirely by user configuration

/// @desc Represents a Catspeak error.
/// @param {vector} pos The vector holding the row and column numbers.
/// @param {string} msg The error message.
function CatspeakError(_pos, _msg) constructor {
	pos = _pos;
	reason = is_string(_msg) ? _msg : string(_msg);
	/// @desc Displays the content of this error.
	toString = function() {
		return instanceof(self) + " " + string(pos) + ": " + reason;
	}
}

/// @desc Represents a span of bytes of some buffer.
/// @param {real} begin The start of the span.
/// @param {real} end The end of the span.
function CatspeakSpan(_begin, _end) constructor {
	start = min(_begin, _end);
	limit = max(_begin, _end) - start;
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
	// function application operator `f (a + b)` is equivalent to `f : a + b`
	COLON,
	// statement terminator
	SEMICOLON,
	__OPERATORS_BEGIN__,
	ADDITION,
	__OPERATORS_END__,
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
	case CatspeakToken.LEFT_PAREN: return "LEFT_PAREN";
	case CatspeakToken.RIGHT_PAREN: return "RIGHT_PAREN";
	case CatspeakToken.LEFT_BOX: return "LEFT_BOX";
	case CatspeakToken.RIGHT_BOX: return "RIGHT_BOX";
	case CatspeakToken.LEFT_BRACE: return "LEFT_BRACE";
	case CatspeakToken.RIGHT_BRACE: return "RIGHT_BRACE";
	case CatspeakToken.DOT: return "DOT";
	case CatspeakToken.COLON: return "COLON";
	case CatspeakToken.SEMICOLON: return "SEMICOLON";
	case CatspeakToken.ADDITION: return "ADDITION";
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
	offset = buffer_tell(_buff);
	alignment = buffer_get_alignment(_buff);
	limit = buffer_get_size(_buff);
	row = 1; // assumes the buffer is always at its starting position, even if it's not
	col = 1;
	cr = false;
	commentLexeme = true;
	commentLexemeLength = 0;
	spanBegin = offset;
	skipNextByte = false;
	/// @desc Checks for a new line character and increments the source position.
	/// @param {real} byte The byte to register.
	static checkByte = function(_byte) {
		if (commentLexeme) {
			if (_byte == ord("-")) {
				commentLexemeLength += 1;
			} else {
				commentLexeme = false;
			}
		}
		if (_byte == ord("\r")) {
			cr = true;
			row = 0;
			col += 1;
		} else if (_byte == ord("\n")) {
			row = 0;
			if (cr) {
				cr = false;
			} else {
				col += 1;
			}
		} else {
			row += 1;
			cr = false;
		}
	}
	/// @desc Resets the current span.
	static clearSpan = function() {
		spanBegin = buffer_tell(buff);
		commentLexeme = true;
		commentLexemeLength = 0;
	}
	/// @desc Returns the current buffer span.
	static getSpan = function() {
		return new CatspeakSpan(spanBegin, buffer_tell(buff));
	}
	/// @desc Returns the current buffer position.
	static getPosition = function() {
		return [row, col];
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
		checkByte(actual);
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
			checkByte(byte);
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
			checkByte(buffer_read(buff, buffer_u8));
			skipNextByte = false;
			return next();
		}
		clearSpan();
		var byte = buffer_read(buff, buffer_u8);
		checkByte(byte);
		switch (byte) {
		case ord("\\"):
			// this is needed for a specific case where `\` is the first character in a line
			advanceWhile(catspeak_byte_is_newline);
			advanceWhile(catspeak_byte_is_whitespace);
			return CatspeakToken.WHITESPACE;
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
		case ord(":"):
			return CatspeakToken.COLON;
		case ord(";"):
			return CatspeakToken.SEMICOLON;
		case ord("+"):
		case ord("-"):
			advanceWhile(catspeak_byte_is_operator);
			if (commentLexeme && commentLexemeLength > 1) {
				advanceWhile(catspeak_byte_is_not_newline);
				return CatspeakToken.COMMENT;
			}
			return CatspeakToken.ADDITION;
		case ord("\""):
			clearSpan();
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
	span = lexer.getSpan();
	pos = lexer.getPosition();
	current = lexer.nextWithoutSpace();
	parenDepth = 0;
	eof = false;
	/// @desc Returns the current buffer span.
	static getSpan = function() {
		return span;
	}
	/// @desc Returns the current buffer position.
	static getPosition = function() {
		return pos;
	}
	/// @desc Advances the lexer and returns the next token.
	static next = function() {
		while (true) {
			span = lexer.getSpan();
			pos = lexer.getPosition();
			var succ = lexer.nextWithoutSpace();
			switch (current) {
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
				var implicit_semicolon = parenDepth <= 0;
				switch (pred) {
				case CatspeakToken.LEFT_BRACE:
				case CatspeakToken.DOT:
				case CatspeakToken.COLON:
				case CatspeakToken.SEMICOLON:
				case CatspeakToken.ADDITION:
					implicit_semicolon = false;
					break;
				}
				switch (succ) {
				case CatspeakToken.LEFT_BRACE:
				case CatspeakToken.DOT:
				case CatspeakToken.COLON:
				case CatspeakToken.SEMICOLON:
				case CatspeakToken.ADDITION:
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

/// @desc Represents a kind of IR node.
enum CatspeakIRKind {
	NO_OP,
	STATEMENT,
	PRINT,
	CALL,
	VALUE,
	IDENTIFIER,
	GROUPING
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function catspeak_ir_render(_kind) {
	switch (_kind) {
	case CatspeakIRKind.NO_OP: return "NO_OP";
	case CatspeakIRKind.STATEMENT: return "STATEMENT";
	case CatspeakIRKind.PRINT: return "PRINT";
	case CatspeakIRKind.CALL: return "CALL";
	case CatspeakIRKind.VALUE: return "VALUE";
	case CatspeakIRKind.IDENTIFIER: return "IDENTIFIER";
	case CatspeakIRKind.GROUPING: return "GROUPING";
	default: return "<unknown>";
	}
}

/// @desc Represents an IR node.
/// @param {vector} pos The vector holding the row and column numbers.
/// @param {CatspeakIRKind} kind The kind of ir node.
/// @param {value} value The value held by the ir node.
function CatspeakIRNode(_pos, _kind, _value) constructor {
	pos = _pos;
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
	pos = [0, 0];
	peeked = lexer.next();
	/// @desc Creates a call node.
	/// @param {vector} pos The vector holding the row and column numbers.
	/// @param {CatspeakIRNode} callsite The callsite.
	/// @param {array} params The paramter array.
	static genCallIR = function(_pos, _callsite, _params) {
		return new CatspeakIRNode(
				_pos, CatspeakIRKind.CALL, {
					callsite : _callsite,
					params : _params
				});
	}
	/// @desc Creates an identifier node.
	static genIdentIR = function() {
		return new CatspeakIRNode(
				pos, CatspeakIRKind.IDENTIFIER, content());
	}
	/// @desc Advances the parser and returns the token.
	static advance = function() {
		token = peeked;
		span = lexer.getSpan();
		pos = lexer.getPosition();
		peeked = lexer.next();
		return token;
	}
	/// @desc Renders the current span of the parser.
	static content = function() {
		return span.render(buff);
	}
	/// @desc Throws a `CatspeakCompilerError` for the current token.
	/// @param {string} on_error The error message.
	static error = function(_msg) {
		throw new CatspeakError(pos, _msg + " -- got `" + string(content()) + "` (" + catspeak_token_render(token) + ")");
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
	/// @desc Returns true if the current token matches any kind of operator.
	static matchesOperator = function() {
		return peeked > CatspeakToken.__OPERATORS_BEGIN__
				&& peeked < CatspeakToken.__OPERATORS_END__
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
	/// @desc Entry point for parsing statements.
	static parseStmt = function() {
		if (consume(CatspeakToken.SEMICOLON)) {
			return new CatspeakIRNode(
					pos, CatspeakIRKind.NO_OP, undefined);
		} else {
			var value = parseExpr();
			expects(CatspeakToken.SEMICOLON, "expected `;` after statement");
			return new CatspeakIRNode(
					value.pos, CatspeakIRKind.STATEMENT, value);
		}
	}
	/// @desc Entry point for parsing expressions.
	static parseExpr = function() {
		return parseBinary(CatspeakToken.__OPERATORS_END__ - 1);
	}
	/// @desc Parses binary operators.
	/// @param {CatspeakToken} token The kind of operator token to check for.
	static parseBinary = function(_kind) {
		if (_kind <= CatspeakToken.__OPERATORS_BEGIN__) {
			return parseCall();
		}
		var next_kind = _kind - 1;
		var expr = parseBinary(next_kind);
		while (consume(_kind)) {
			var callsite = genIdentIR();
			expr = genCallIR(expr.pos, callsite, [expr, parseBinary(next_kind)]);
		}
		return expr;
	}
	/// @desc Parses a function call.
	static parseCall = function() {
		var callsite = parseValue();
		if (callsite.kind = CatspeakIRKind.IDENTIFIER) {
			// parse keywords
			switch (callsite.value) {
			case "print":
				var value = self.parseValue();
				return new CatspeakIRNode(
						callsite.pos, CatspeakIRKind.PRINT, value);
			}
		}
		var params = [];
		while (matches(CatspeakToken.LEFT_PAREN)
				|| matches(CatspeakToken.LEFT_BOX)
				|| matches(CatspeakToken.LEFT_BRACE)
				|| matches(CatspeakToken.COLON)
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
			return genCallIR(callsite.pos, callsite, params);
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
					pos, CatspeakIRKind.VALUE, content());
		} else if (consume(CatspeakToken.NUMBER)) {
			return new CatspeakIRNode(
					pos, CatspeakIRKind.VALUE, real(content()));
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
		} else if (consume(CatspeakToken.LEFT_PAREN)) {
			var start = pos;
			var value = parseExpr();
			expects(CatspeakToken.RIGHT_PAREN, "expected closing `)` in grouping");
			return new CatspeakIRNode(
					start, CatspeakIRKind.GROUPING, value);
		} else {
			errorAndAdvance("unexpected symbol in expression");
		}
	}
}

/// @desc Represents a kind of intcode.
enum CatspeakOpCode {
	PUSH_VALUE,
	POP_VALUE,
	GET_VALUE,
	SET_VALUE,
	ADD,
	CONCAT,
	SUB,
	NEG,
	PRINT,
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
	case CatspeakOpCode.ADD: return "ADD";
	case CatspeakOpCode.CONCAT: return "CONCAT";
	case CatspeakOpCode.SUB: return "SUB";
	case CatspeakOpCode.NEG: return "NEG";
	case CatspeakOpCode.PRINT: return "PRINT";
	case CatspeakOpCode.CALL: return "CALL";
	default: return "<unknown>";
	}
}

/// @desc Represents a Catspeak intcode program with associated debug information.
function CatspeakProgram() constructor {
	diagnostic = [];
	intcode = [];
	size = 0;
	/// @desc Adds a code and its positional information to the program.
	/// @param {vector} pos The position of this piece of code.
	/// @param {value} code The pieve of code to write.
	static addCode = function(_pos, _code) {
		array_push(diagnostic, _pos);
		array_push(intcode, _code);
		size += 1;
	}
}

/// @desc Handles the generation of intcode from Catspeak IR.
/// @param {real} buffer The id of the buffer to use.
/// @param {CatspeakProgram} out The program to populate code with.
function CatspeakCodegen(_buff, _out) constructor {
	parser = new CatspeakParser(_buff);
	buff = _buff;
	out = _out;
	/// @desc Generates the code for the next IR term.
	/// @param {CatspeakIRTerm} term The term to generate code for.
	static visitTerm = function(_term) {
		var pos = _term.pos;
		var kind = _term.kind;
		var value = _term.value;
		switch (_term.kind) {
		case CatspeakIRKind.NO_OP:
			return;
		case CatspeakIRKind.STATEMENT:
			visitTerm(value);
			out.addCode(pos, CatspeakOpCode.POP_VALUE);
			return;
		case CatspeakIRKind.PRINT:
			visitTerm(value);
			out.addCode(pos, CatspeakOpCode.PRINT);
			return;
		case CatspeakIRKind.CALL:
			var callsite = value.callsite;
			var params = value.params;
			var arg_count = array_length(params);
			for (var i = 0; i < arg_count; i += 1) {
				visitTerm(params[i]);
			}
			visitTerm(callsite);
			out.addCode(pos, CatspeakOpCode.CALL);
			return;
		case CatspeakIRKind.VALUE:
			out.addCode(pos, CatspeakOpCode.PUSH_VALUE);
			out.addCode(pos, value);
			return;
		case CatspeakIRKind.IDENTIFIER:
			throw new CatspeakError(pos, "identifiers not implemented");
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

/// @desc Compiles this string and returns the resulting intcode program.
/// @param {string} str The string that contains the source code.
function catspeak_compile(_str) {
	var size = string_byte_length(_str);
	var buff = buffer_create(size, buffer_fixed, 1);
	buffer_write(buff, buffer_text, _str);
	buffer_seek(buff, buffer_seek_start, 0);
	var out = new CatspeakProgram();
	var codegen = new CatspeakCodegen(buff, out);
	while (codegen.generateCode()) { }
	buffer_delete(buff);
	return out;
}

/// @desc Handles the execution of Catspeak intcode.
function CatspeakVM() constructor {
	stack = [];
	/// @desc Pushes a value onto the stack.
	/// @param {value} value The value to push.
	static push = function(_value) {
		array_push(stack, _value);
	}
	/// @desc Pops the top value from the stack.
	static pop = function() {
		var pos = array_length(stack) - 1;
		if (pos < 0) {
			throw new CatspeakError(undefined, "VM stack underflow");
		}
		return array_pop(stack);
	}
	/// @desc Returns the top value of the stack.
	static top = function() {
		var pos = array_length(stack) - 1;
		if (pos < 0) {
			throw new CatspeakError(undefined, "cannot peek into empty VM stack");
		}
		return stack[pos];
	}
	/// @desc Executes this block of code using the current catspeak session.
	/// @param {CatspeakProgram} program The program to run.
	static run = function(_program) {
		var diagnostic = _program.diagnostic;
		var intcode = _program.intcode;
		var n = _program.size;
		for (var pc = 0; pc < n; pc += 1) {
			var code = intcode[pc];
			var pos = diagnostic[pc];
			switch (code) {
			case CatspeakOpCode.PUSH_VALUE:
				pc += 1;
				var value = intcode[pc];
				push(value);
				break;
			case CatspeakOpCode.POP_VALUE:
				pop();
				break;
			case CatspeakOpCode.GET_VALUE:
			case CatspeakOpCode.SET_VALUE:
				throw new CatspeakError(pos, "get and set instructions are not implemented");
			case CatspeakOpCode.ADD:
				var b = pop();
				var a = pop();
				if not (is_numeric(a)) {
					a = real(a);
				}
				if not (is_numeric(b)) {
					b = real(b);
				}
				push(a + b);
				break;
			case CatspeakOpCode.CONCAT:
				var b = pop();
				var a = pop();
				if not (is_string(a)) {
					a = string(a);
				}
				if not (is_string(b)) {
					b = string(b);
				}
				push(a + b);
				break;
			case CatspeakOpCode.SUB:
				var b = pop();
				var a = pop();
				push(a - b);
				break;
			case CatspeakOpCode.NEG:
				var a = pop();
				push(-a);
				break;
			case CatspeakOpCode.PRINT:
				var value = top();
				show_debug_message(value);
				break;
			case CatspeakOpCode.CALL:
				throw new CatspeakError(pos, "call instructions are not implemented");
			default:
				throw new CatspeakError(pos, "unknown opcode at index " + string(pc) +
						" (" + catspeak_code_render(code) + ")");
			}
		}
	}
}

var program = @'
# adds to numbers together
fun add : arr {
  var acc 0
  for arr : [x] {
    set acc : acc + x
  }
  ret acc
}
';
var program = catspeak_compile(@'
print : "hello" ++ (-1) -- prints 4
');
var vm = new CatspeakVM();
vm.run(program);