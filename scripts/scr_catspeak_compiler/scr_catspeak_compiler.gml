/* Catspeak Syntactic Analysis and Code Generation Stage
 * -----------------------------------------------------
 * Kat @katsaii
 */

/// @desc Represents a type of compiler state.
enum CatspeakCompilerState {
	EXPRESSION,
	ARG,
	SUBSCRIPT_BEGIN,
	SUBSCRIPT_END,
	TERMINAL,
	GROUPING_BEGIN,
	GROUPING_END,
	ARRAY,
	OBJECT
}

/// @desc Displays the compiler state as a string.
/// @param {CatspeakCompilerState} state The state to display.
function catspeak_compiler_state_render(_state) {
	switch (_state) {
	case CatspeakCompilerState.EXPRESSION: return "EXPRESSION";
	case CatspeakCompilerState.ARG: return "ARG";
	case CatspeakCompilerState.SUBSCRIPT_BEGIN: return "SUBSCRIPT_BEGIN";
	case CatspeakCompilerState.SUBSCRIPT_END: return "SUBSCRIPT_END";
	case CatspeakCompilerState.TERMINAL: return "TERMINAL";
	case CatspeakCompilerState.GROUPING_BEGIN: return "GROUPING_BEGIN";
	case CatspeakCompilerState.GROUPING_END: return "GROUPING_END";
	case CatspeakCompilerState.ARRAY: return "ARRAY";
	case CatspeakCompilerState.OBJECT: return "OBJECT";
	default: return "<unknown>";
	}
}

/// @desc Creates a new compiler that handles syntactic analysis and code generation.
/// @param {CatspeakLexer} lexer The lexer to use to generate the intcode program.
/// @param {CatspeakChunk} out The program to write code to.
function CatspeakCompiler(_lexer, _out) constructor {
	lexer = _lexer;
	out = _out;
	token = CatspeakToken.BOF;
	pos = lexer.getPosition();
	lexeme = lexer.getLexeme();
	peeked = lexer.next();
	instructionStack = [CatspeakCompilerState.EXPRESSION];
	storageStack = [];
	/// @desc Adds a new compiler state to the instruction stack.
	/// @param {CatspeakCompilerState} state The state to insert.
	static pushState = function(_state) {
		array_push(instructionStack, _state);
	}
	/// @desc Pops the top state from the instruction stack.
	static popState = function() {
		return array_pop(instructionStack);
	}
	/// @desc Adds a new value to the storage stack.
	/// @param {value} value The value to store.
	/// @param {value} ... Additional values.
	static pushStorage = function() {
		for (var i = 0; i < argument_count; i += 1) {
			var value = argument[i];
			array_push(storageStack, value);
		}
	}
	/// @desc Pops the top value from the storage stack.
	/// @param {value} value The value to store.
	static popStorage = function() {
		return array_pop(storageStack);
	}
	/// @desc Returns the current buffer position.
	static getPosition = function() {
		return pos;
	}
	/// @desc Advances the parser and returns the token.
	static advance = function() {
		token = peeked;
		pos = lexer.getPosition();
		lexeme = lexer.getLexeme();
		peeked = lexer.next();
		return token;
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
	/// @desc Throws a `CatspeakError` for the current token.
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
	/// @desc Throws a `CatspeakCompilerError` if the current token is not the expected value. Advances the parser otherwise.
	/// @param {CatspeakToken} kind The token kind to expect.
	/// @param {string} on_error The error message.
	static expects = function(_kind, _msg) {
		if (consume(_kind)) {
			return token;
		} else {
			errorAndAdvance(_msg);
			return undefined;
		}
	}
	/// @desc Throws a `CatspeakCompilerError` if the current token is not a semicolon. Advances the parser otherwise.
	/// @param {string} on_error The error message.
	static expectsSemicolon = function(_msg) {
		return expects(CatspeakToken.SEMICOLON, "expected `;` or new line " + _msg);
	}
	/// @desc Returns whether the compiler is in progress.
	static inProgress = function() {
		return array_length(instructionStack) > 0;
	}
	/// @desc Performs a single step of parsing and code generation.
	static generateCode = function() {
		var state = popState();
		switch (state) {
		case CatspeakCompilerState.EXPRESSION:
			pushState(CatspeakCompilerState.ARG);
			break;
		case CatspeakCompilerState.ARG:
			pushState(CatspeakCompilerState.SUBSCRIPT_BEGIN);
			pushState(CatspeakCompilerState.TERMINAL);
			break;
		case CatspeakCompilerState.SUBSCRIPT_BEGIN:
			if (consume(CatspeakToken.DOT)) {
				pushStorage(pos);
				pushState(CatspeakCompilerState.SUBSCRIPT_END);
				var access_type;
				if (consume(CatspeakToken.BOX_LEFT)) {
					access_type = 0x00;
					pushState(CatspeakCompilerState.EXPRESSION);
				} else if (consume(CatspeakToken.BRACE_LEFT)) {
					access_type = 0x01;
					pushState(CatspeakCompilerState.EXPRESSION);
				} else {
					access_type = 0x02;
					expects(CatspeakToken.IDENTIFIER, "expected identifier after binary `.` operator");
					out.addCode(pos, CatspeakOpCode.PUSH);
					out.addCode(pos, lexeme);
				}
				pushStorage(access_type);
			}
			break;
		case CatspeakCompilerState.SUBSCRIPT_END:
			var access_type = popStorage();
			var op_pos = popStorage();
			var unordered;
			switch (access_type) {
			case 0x00:
				unordered = false;
				expects(CatspeakToken.BOX_RIGHT, "expected closing `]` in ordered indexing");
				break;
			case 0x01:
				expects(CatspeakToken.BRACE_RIGHT, "expected closing `}` in unordered indexing");
			default:
				unordered = true;
				break;
			}
			out.addCode(op_pos, CatspeakOpCode.REF_GET);
			out.addCode(op_pos, unordered);
			pushState(CatspeakCompilerState.SUBSCRIPT_BEGIN);
			break;
		case CatspeakCompilerState.TERMINAL:
			if (consume(CatspeakToken.IDENTIFIER)) {
				out.addCode(pos, CatspeakOpCode.VAR_GET);
				out.addCode(pos, lexeme);
			} else if (matchesOperator()) {
				advance();
				out.addCode(pos, CatspeakOpCode.VAR_GET);
				out.addCode(pos, lexeme);
			} else if (consume(CatspeakToken.STRING)) {
				out.addCode(pos, CatspeakOpCode.PUSH);
				out.addCode(pos, lexeme);
			} else if (consume(CatspeakToken.NUMBER)) {
				out.addCode(pos, CatspeakOpCode.PUSH);
				out.addCode(pos, real(lexeme));
			} else {
				pushState(CatspeakCompilerState.GROUPING_BEGIN);
			}
			break;
		case CatspeakCompilerState.GROUPING_BEGIN:
			if (consume(CatspeakToken.COLON)) {
				pushState(CatspeakCompilerState.EXPRESSION);
			} else if (consume(CatspeakToken.PAREN_LEFT)) {
				pushState(CatspeakCompilerState.EXPRESSION,
						CatspeakCompilerState.GROUPING_END);
			} else if (consume(CatspeakToken.BOX_LEFT)) {
				pushStorage(pos, 0); // store the source position and array length
				pushState(CatspeakCompilerState.ARRAY);
			} else if (consume(CatspeakToken.BRACE_LEFT)) {
				pushStorage(pos, 0);
				pushState(CatspeakCompilerState.OBJECT);
			} else {
				errorAndAdvance("unexpected symbol in expression");
			}
			break;
		case CatspeakCompilerState.GROUPING_END:
			expects(CatspeakToken.PAREN_RIGHT, "expected closing `)` in grouping");
			break;
		case CatspeakCompilerState.ARRAY:
			var size = popStorage();
			while (consume(CatspeakToken.SEMICOLON)) { }
			if (consume(CatspeakToken.BOX_RIGHT)) {
				var start_pos = popStorage();
				out.addCode(start_pos, CatspeakOpCode.MAKE_ARRAY);
				out.addCode(start_pos, size);
			} else {
				pushStorage(size + 1);
				pushState(CatspeakCompilerState.ARRAY);
				pushState(CatspeakCompilerState.EXPRESSION);
			}
			break;
		case CatspeakCompilerState.OBJECT:
			var size = popStorage();
			while (consume(CatspeakToken.SEMICOLON)) { }
			if (consume(CatspeakToken.BRACE_RIGHT)) {
				var start_pos = popStorage();
				out.addCode(start_pos, CatspeakOpCode.MAKE_OBJECT);
				out.addCode(start_pos, size);
			} else {
				pushStorage(size + 1);
				pushState(CatspeakCompilerState.OBJECT);
				pushState(CatspeakCompilerState.ARG);
				if (consume(CatspeakToken.DOT)) {
					expects(CatspeakToken.IDENTIFIER, "expected identifier after unary `.` operator");
					out.addCode(pos, CatspeakOpCode.PUSH);
					out.addCode(pos, lexeme);
				} else {
					pushState(CatspeakCompilerState.ARG);
				}
			}
			break;
		default:
			error("unknown compiler instruction `" + string(inst) + "` (" + catspeak_compiler_state_render(inst) + ")");
			break;
		}
		if not (inProgress()) {
			// code generation complete, add a final return code
			out.addCode(pos, CatspeakOpCode.PRINT); // temporary
			out.addCode(pos, CatspeakOpCode.PUSH);
			out.addCode(pos, undefined);
			out.addCode(pos, CatspeakOpCode.RETURN);
		}
	}
}

/// @desc Compiles this string and returns the resulting intcode program.
/// @param {string} str The string that contains the source code.
function catspeak_eagar_compile(_str) {
	var buff = catspeak_string_to_buffer(_str);
	var scanner = new CatspeakScanner(buff);
	var lexer = new CatspeakLexer(scanner);
	var out = new CatspeakChunk();
	var compiler = new CatspeakCompiler(lexer, out);
	while (compiler.inProgress()) {
		compiler.generateCode();
	}
	buffer_delete(buff);
	return out;
}