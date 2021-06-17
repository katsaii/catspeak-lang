

/// @desc Represents a kind of IR node.
enum CatspeakIRKind {
	NOTHING,
	EXPRESSION_STATEMENT,
	SET,
	SEQUENCE,
	CONDITIONAL,
	LOOP,
	PRINT,
	RETURN,
	SUBSCRIPT,
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
	case CatspeakIRKind.SEQUENCE: return "SEQUENCE";
	case CatspeakIRKind.CONDITIONAL: return "CONDITIONAL";
	case CatspeakIRKind.LOOP: return "LOOP";
	case CatspeakIRKind.PRINT: return "PRINT";
	case CatspeakIRKind.RETURN: return "RETURN";
	case CatspeakIRKind.SUBSCRIPT: return "SUBCRIPT";
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
		return new CatspeakIRNode(pos, CatspeakIRKind.IDENTIFIER, lexeme);
	}
	/// @desc Creates a string node.
	static genStringIR = function() {
		return new CatspeakIRNode(pos, CatspeakIRKind.CONSTANT, lexeme);
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
			var lvalue = parseArg();
			var rvalue = parseArg();
			expectsSemicolon("after `set` statements");
			return new CatspeakIRNode(start, CatspeakIRKind.SET, {
				lvalue : lvalue,
				rvalue : rvalue
			});
		} else if (consume(CatspeakToken.IF)) {
			var start = pos;
			var condition = parseArg();
			var if_true = parseSequence();
			var if_false = undefined;
			if (consume(CatspeakToken.ELSE)) {
				if (matches(CatspeakToken.IF)) {
					if_false = parseStmt();
				} else {
					if_false = parseSequence();
				}
			}
			return new CatspeakIRNode(start, CatspeakIRKind.CONDITIONAL, {
				condition : condition,
				ifTrue : if_true,
				ifFalse : if_false
			});
		} else if (consume(CatspeakToken.WHILE)) {
			var start = pos;
			var condition = parseArg();
			var body = parseSequence();
			return new CatspeakIRNode(start, CatspeakIRKind.LOOP, {
				condition : condition,
				body : body
			});
		} else if (consume(CatspeakToken.PRINT)) {
			var start = pos;
			var values = [];
			while (matchesExpression()) {
				array_push(values, parseArg());
			}
			expectsSemicolon("after `print` statements");
			return new CatspeakIRNode(start, CatspeakIRKind.PRINT, values);
		} else if (consume(CatspeakToken.RETURN)) {
			var start = pos;
			var value = parseArg();
			expectsSemicolon("after `return` statements");
			return new CatspeakIRNode(start, CatspeakIRKind.RETURN, value);
		} else {
			var value = parseExpr();
			expectsSemicolon("after expression statements");
			return new CatspeakIRNode(value.pos, CatspeakIRKind.EXPRESSION_STATEMENT, value);
		}
	}
	/// @desc Parses a sequence of statements.
	static parseSequence = function() {
		var start = pos;
		expects(CatspeakToken.BRACE_LEFT, "expected opening `{` in statement sequence");
		var stmts = [];
		while not (matches(CatspeakToken.BRACE_RIGHT)) {
			var stmt = parseStmt();
			array_push(stmts, stmt);
		}
		expects(CatspeakToken.BRACE_RIGHT, "expected closing `}` in statement sequence");
		return new CatspeakIRNode(start, CatspeakIRKind.SEQUENCE, stmts);
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
		if (consume(CatspeakToken.RUN)) {
			var callsite = parseArg();
			return genCallIR(callsite, []);
		}
		var callsite = parseArg();
		var params = [];
		while (matchesExpression()) {
			var param = parseArg();
			array_push(params, param);
		}
		var arg_count = array_length(params);
		if (arg_count == 0) {
			return callsite;
		} else {
			return genCallIR(callsite, params);
		}
	}
	/// @desc Entry point for parsing function parameters.
	static parseArg = function() {
		return parseSubscript();
	}
	/// @desc Parses an index operation.
	static parseSubscript = function() {
		var container = parseValue();
		while (consume(CatspeakToken.DOT)) {
			var subscript;
			var unordered = true;
			if (consume(CatspeakToken.BOX_LEFT)) {
				unordered = false;
				subscript = parseExpr();
				expects(CatspeakToken.BOX_RIGHT, "expected closing `]` in ordered indexing");
			} else if (consume(CatspeakToken.BRACE_LEFT)) {
				subscript = parseExpr();
				expects(CatspeakToken.BRACE_RIGHT, "expected closing `}` in unordered indexing");
			} else {
				expects(CatspeakToken.IDENTIFIER, "expected identifier after `.` operator");
				subscript = genStringIR();
			}
			container = new CatspeakIRNode(container.pos, CatspeakIRKind.SUBSCRIPT, {
				container : container,
				subscript : subscript,
				unordered : unordered
			});
		}
		return container;
	}
	/// @desc Parses a terminal value or expression.
	static parseValue = function() {
		if (consume(CatspeakToken.IDENTIFIER)) {
			return genIdentIR();
		} else if (matchesOperator()) {
			advance();
			return genIdentIR();
		} else if (consume(CatspeakToken.STRING)) {
			return genStringIR();
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
			do {
				var key;
				if (consume(CatspeakToken.DOT)) {
					expects(CatspeakToken.IDENTIFIER, "identifier after `.` operator");
					key = genStringIR();
				} else if (matchesExpression()) {
					key = parseValue();
				} else {
					break;
				}
				var value = parseValue();
				array_push(params, key);
				array_push(params, value);
				if not (matches(CatspeakToken.BOX_RIGHT)) {
					expectsSemicolon("between object elements");
				}
			} until (false);
			expects(CatspeakToken.BRACE_RIGHT, "expected closing `}` in object literal");
			return new CatspeakIRNode(start, CatspeakIRKind.OBJECT, params);
		} else {
			errorAndAdvance("unexpected symbol in expression");
		}
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
			var lvalue = inner.lvalue;
			var rvalue = inner.rvalue;
			if (lvalue.kind == CatspeakIRKind.IDENTIFIER) {
				visitTerm(rvalue);
				out.addCode(pos, CatspeakOpCode.VAR_SET);
				out.addCode(pos, lvalue.inner);
			} else if (lvalue.kind == CatspeakIRKind.SUBSCRIPT) {
				visitTerm(lvalue.inner.container);
				visitTerm(lvalue.inner.subscript);
				visitTerm(rvalue);
				out.addCode(pos, CatspeakOpCode.REF_SET);
				out.addCode(pos, lvalue.inner.unordered);
			} else {
				error(_term, "invalid left value");
			}
			break;
		case CatspeakIRKind.SEQUENCE:
			var stmt_count = array_length(inner);
			for (var i = 0; i < stmt_count; i += 1) {
				visitTerm(inner[i]);
			}
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
		case CatspeakIRKind.RETURN:
			visitTerm(inner);
			out.addCode(pos, CatspeakOpCode.RETURN);
			break;
		case CatspeakIRKind.SUBSCRIPT:
			var container = inner.container;
			var subscript = inner.subscript;
			var unordered = inner.unordered;
			visitTerm(container);
			visitTerm(subscript);
			out.addCode(pos, CatspeakOpCode.REF_GET);
			out.addCode(pos, unordered);
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
