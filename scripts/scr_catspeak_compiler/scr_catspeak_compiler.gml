/* Catspeak Syntactic Analysis and Code Generation Stage
 * -----------------------------------------------------
 * Kat @katsaii
 */

/// @desc Represents a type of compiler state.
enum CatspeakCompilerState {
	EXPRESSION,
	TERMINAL,
	GROUPING_BEGIN,
	GROUPING_END
}

/// @desc Displays the compiler state as a string.
/// @param {CatspeakCompilerState} state The state to display.
function catspeak_compiler_state_render(_state) {
	switch (_state) {
	case CatspeakCompilerState.EXPRESSION: return "EXPRESSION";
	case CatspeakCompilerState.TERMINAL: return "TERMINAL";
	case CatspeakCompilerState.GROUPING_BEGIN: return "GROUPING_BEGIN";
	case CatspeakCompilerState.GROUPING_END: return "GROUPING_END";
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
	diagnosticStack = [];
	/// @desc Adds a new compiler state to the instruction stack.
	/// @param {CatspeakCompilerState} state The state to insert.
	/// @param {CatspeakCompilerState} ... Additional states.
	static pushState = function() {
		for (var i = argument_count - 1; i >= 0; i -= 1) {
			var state = argument[i];
			array_push(instructionStack, state);
		}
	}
	/// @desc Pops the top state from the instruction stack.
	static popState = function() {
		return array_pop(instructionStack);
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
			pushState(CatspeakCompilerState.TERMINAL);
			break;
		case CatspeakCompilerState.TERMINAL:
			if (consume(CatspeakToken.IDENTIFIER)) {
				out.addCode(pos, CatspeakOpCode.VAR_GET);
				out.addCode(pos, lexeme);
			} else if (matchesOperator()) {
				advance();
				return genIdentIR();
			} else if (consume(CatspeakToken.STRING)) {
				out.addCode(pos, CatspeakOpCode.PUSH);
				out.addCode(pos, lexeme);
			} else if (consume(CatspeakToken.NUMBER)) {
				out.addCode(pos, CatspeakOpCode.PUSH);
				out.addCode(pos, real(lexeme));
			} else {
				pushState(CatspeakCompilerState.GROUPING_BEGIN,
						CatspeakCompilerState.EXPRESSION,
						CatspeakCompilerState.GROUPING_END);
			}
			break;
		case CatspeakCompilerState.GROUPING_BEGIN:
			expects(CatspeakToken.PAREN_LEFT, "unexpected symbol in expression");
			break;
		case CatspeakCompilerState.GROUPING_END:
			expects(CatspeakToken.PAREN_RIGHT, "expected closing `)` in grouping");
			break;
		default:
			error("unknown compiler instruction `" + string(inst) + "` (" + catspeak_compiler_state_render(inst) + ")");
			break;
		}
	}
}