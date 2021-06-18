/* Catspeak Syntactic Analysis and Code Generation Stage
 * -----------------------------------------------------
 * Kat @katsaii
 */

/// @desc Represents a type of compiler state.
enum CatspeakCompilerState {
	PROGRAM,
	STATEMENT,
	SET_BEGIN,
	SET_END,
	PRINT,
	RETURN,
	POP_VALUE,
	EXPRESSION,
	BINARY_BEGIN,
	BINARY_END,
	RUN,
	CALL_BEGIN,
	CALL_END,
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
	case CatspeakCompilerState.PROGRAM: return "PROGRAM";
	case CatspeakCompilerState.STATEMENT: return "STATEMENT";
	case CatspeakCompilerState.SET_BEGIN: return "SET_BEGIN";
	case CatspeakCompilerState.SET_END: return "SET_END";
	case CatspeakCompilerState.PRINT: return "PRINT";
	case CatspeakCompilerState.RETURN: return "RETURN";
	case CatspeakCompilerState.POP_VALUE: return "POP_VALUE";
	case CatspeakCompilerState.EXPRESSION: return "EXPRESSION";
	case CatspeakCompilerState.BINARY_BEGIN: return "BINARY_BEGIN";
	case CatspeakCompilerState.BINARY_END: return "BINARY_END";
	case CatspeakCompilerState.RUN: return "RUN";
	case CatspeakCompilerState.CALL_BEGIN: return "CALL_BEGIN";
	case CatspeakCompilerState.CALL_END: return "CALL_END";
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
	instructionStack = [CatspeakCompilerState.PROGRAM];
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
		case CatspeakCompilerState.PROGRAM:
			if not (matches(CatspeakToken.EOF)) {
				pushState(CatspeakCompilerState.PROGRAM);
				pushState(CatspeakCompilerState.STATEMENT);
			}
			break;
		case CatspeakCompilerState.STATEMENT:
			if (consume(CatspeakToken.SEMICOLON)) {
				// do nothing
			} else if (consume(CatspeakToken.SET)) {
				pushState(CatspeakCompilerState.SET_BEGIN);
				pushState(CatspeakCompilerState.ARG);
			} else if (consume(CatspeakToken.IF)) {
				error("if statements not implemented");
			} else if (consume(CatspeakToken.WHILE)) {
				error("while loops not implemented");
			} else if (consume(CatspeakToken.PRINT)) {
				pushState(CatspeakCompilerState.PRINT);
				pushState(CatspeakCompilerState.ARG);
			} else if (consume(CatspeakToken.RETURN)) {
				pushState(CatspeakCompilerState.RETURN);
				pushState(CatspeakCompilerState.ARG);
			} else {
				pushState(CatspeakCompilerState.POP_VALUE);
				pushState(CatspeakCompilerState.EXPRESSION);
			}
			break;
		case CatspeakCompilerState.SET_BEGIN:
			var top_pc = out.getCurrentSize() - 1;
			var top_inst = out.getCode(top_pc);
			switch (top_inst.code) {
			case CatspeakOpCode.VAR_GET:
				pushStorage(CatspeakOpCode.VAR_SET);
				break;
			case CatspeakOpCode.REF_GET:
				pushStorage(CatspeakOpCode.REF_SET);
				break;
			default:
				error("invalid assignment target");
				break;
			}
			out.removeCode(top_pc);
			pushStorage(top_inst.param);
			pushState(CatspeakCompilerState.SET_END);
			pushState(CatspeakCompilerState.ARG);
			break;
		case CatspeakCompilerState.SET_END:
			expectsSemicolon("after assignment statements");
			var param = popStorage();
			var code = popStorage();
			out.addCode(pos, code, param);
			break;
		case CatspeakCompilerState.PRINT:
			expectsSemicolon("after print statements");
			out.addCode(pos, CatspeakOpCode.PRINT);
			break;
		case CatspeakCompilerState.RETURN:
			expectsSemicolon("after return statements");
			out.addCode(pos, CatspeakOpCode.RETURN);
			break;
		case CatspeakCompilerState.POP_VALUE:
			expectsSemicolon("after expression statements");
			out.addCode(pos, CatspeakOpCode.POP);
			break;
		case CatspeakCompilerState.EXPRESSION:
			pushStorage(CatspeakToken.__OPERATORS_BEGIN__ + 1);
			pushState(CatspeakCompilerState.BINARY_BEGIN);
			break;
		case CatspeakCompilerState.BINARY_BEGIN:
			var precedence = popStorage();
			if (precedence >= CatspeakToken.__OPERATORS_END__) {
				pushState(CatspeakCompilerState.RUN);
				break;
			}
			pushStorage(precedence);
			pushState(CatspeakCompilerState.BINARY_END);
			pushStorage(precedence + 1);
			pushState(CatspeakCompilerState.BINARY_BEGIN);
			break;
		case CatspeakCompilerState.BINARY_END:
			var precedence = popStorage();
			if (consume(precedence)) {
				out.addCode(pos, CatspeakOpCode.VAR_GET, lexeme);
				pushStorage(precedence);
				pushState(CatspeakCompilerState.BINARY_END);
				pushStorage(-1);
				pushState(CatspeakCompilerState.CALL_END);
				pushStorage(precedence + 1);
				pushState(CatspeakCompilerState.BINARY_BEGIN);
			}
			break;
		case CatspeakCompilerState.RUN:
			if (consume(CatspeakToken.RUN)) {
				pushStorage(0);
				pushState(CatspeakCompilerState.CALL_END);
			} else if (matchesOperator()) {
				advance();
				out.addCode(pos, CatspeakOpCode.VAR_GET, lexeme);
				pushStorage(1);
				pushState(CatspeakCompilerState.CALL_END);
			} else {
				pushStorage(0);
				pushState(CatspeakCompilerState.CALL_BEGIN);
			}
			pushState(CatspeakCompilerState.ARG);
			break;
		case CatspeakCompilerState.CALL_BEGIN:
			var arg_count = popStorage();
			if (matchesExpression()) {
				arg_count += 1;
				pushState(CatspeakCompilerState.CALL_BEGIN);
				pushState(CatspeakCompilerState.ARG);
			} else {
				if (arg_count <= 0) {
					break;
				}
				pushState(CatspeakCompilerState.CALL_END);
			}
			pushStorage(arg_count);
			break;
		case CatspeakCompilerState.CALL_END:
			var arg_count = popStorage();
			out.addCode(pos, CatspeakOpCode.CALL, arg_count);
			break;
		case CatspeakCompilerState.ARG:
			pushState(CatspeakCompilerState.SUBSCRIPT_BEGIN);
			pushState(CatspeakCompilerState.TERMINAL);
			break;
		case CatspeakCompilerState.SUBSCRIPT_BEGIN:
			if (consume(CatspeakToken.DOT)) {
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
					out.addCode(pos, CatspeakOpCode.PUSH, lexeme);
				}
				pushStorage(access_type);
			}
			break;
		case CatspeakCompilerState.SUBSCRIPT_END:
			var access_type = popStorage();
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
			out.addCode(pos, CatspeakOpCode.REF_GET, unordered);
			pushState(CatspeakCompilerState.SUBSCRIPT_BEGIN);
			break;
		case CatspeakCompilerState.TERMINAL:
			if (consume(CatspeakToken.IDENTIFIER)) {
				out.addCode(pos, CatspeakOpCode.VAR_GET, lexeme);
			} else if (matchesOperator()) {
				advance();
				out.addCode(pos, CatspeakOpCode.VAR_GET, lexeme);
			} else if (consume(CatspeakToken.STRING)) {
				out.addCode(pos, CatspeakOpCode.PUSH, lexeme);
			} else if (consume(CatspeakToken.NUMBER)) {
				out.addCode(pos, CatspeakOpCode.PUSH, real(lexeme));
			} else {
				pushState(CatspeakCompilerState.GROUPING_BEGIN);
			}
			break;
		case CatspeakCompilerState.GROUPING_BEGIN:
			if (consume(CatspeakToken.COLON)) {
				pushState(CatspeakCompilerState.EXPRESSION);
			} else if (consume(CatspeakToken.PAREN_LEFT)) {
				pushState(CatspeakCompilerState.GROUPING_END);
				pushState(CatspeakCompilerState.EXPRESSION);
			} else if (consume(CatspeakToken.BOX_LEFT)) {
				pushStorage(0); // store the source position and array length
				pushState(CatspeakCompilerState.ARRAY);
			} else if (consume(CatspeakToken.BRACE_LEFT)) {
				pushStorage(0);
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
				out.addCode(pos, CatspeakOpCode.MAKE_ARRAY, size);
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
				out.addCode(pos, CatspeakOpCode.MAKE_OBJECT, size);
			} else {
				pushStorage(size + 1);
				pushState(CatspeakCompilerState.OBJECT);
				pushState(CatspeakCompilerState.ARG);
				if (consume(CatspeakToken.DOT)) {
					expects(CatspeakToken.IDENTIFIER, "expected identifier after unary `.` operator");
					out.addCode(pos, CatspeakOpCode.PUSH, lexeme);
				} else {
					pushState(CatspeakCompilerState.ARG);
				}
			}
			break;
		default:
			error("unknown compiler instruction `" + string(state) + "` (" + catspeak_compiler_state_render(state) + ")");
			break;
		}
		if not (inProgress()) {
			// code generation complete, add a final return code
			out.addCode(pos, CatspeakOpCode.PUSH, undefined);
			out.addCode(pos, CatspeakOpCode.RETURN);
		}
	}
}

/// @desc Creates a new asynchronous compiler session.
/// @param {string} str The string that contains the source code.
function catspeak_async_compile_begin(_str) {
	var buff = catspeak_string_to_buffer(_str);
	var scanner = new CatspeakScanner(buff);
	var lexer = new CatspeakLexer(scanner);
	var chunk = new CatspeakChunk();
	var compiler = new CatspeakCompiler(lexer, chunk);
	return {
		buff : buff,
		chunk : chunk,
		compiler : compiler
	};
}

/// @desc Returns the current progress of the compiler as a percentage.
/// @param {struct} session The compiler session to consider.
function catspeak_async_compile_in_progress(_session) {
	return _session.compiler.inProgress();
}

/// @desc Returns the current progress of the compiler as a percentage.
/// @param {struct} session The compiler session to consider.
function catspeak_async_compile_get_progress(_session) {
	var buff = _session.buff;
	return buffer_tell(buff) / buffer_get_size(buff);
}

/// @desc Updates the compiler progress.
/// @param {struct} session The compiler session to consider.
function catspeak_async_compile_update(_session) {
	return _session.compiler.generateCode();
}

/// @desc Finishes the current compiler session and destroys any dynamically allocated resources.
/// @param {struct} session The compiler session to finalise.
function catspeak_async_compile_end(_session) {
	var chunk = _session.chunk;
	buffer_delete(_session.buff);
	return chunk;
}

/// @desc Compiles this string and returns the resulting intcode program.
/// @param {string} str The string that contains the source code.
function catspeak_eagar_compile(_str) {
	var session = catspeak_async_compile_begin(_str);
	while (catspeak_async_compile_in_progress(session)) {
		catspeak_async_compile_update(session);
	}
	return catspeak_async_compile_end(session);
}