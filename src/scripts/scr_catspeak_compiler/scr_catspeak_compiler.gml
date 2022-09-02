//! Handles the parsing and codegen stage of the Catspeak compiler.

//# feather use syntax-errors

/// Creates a new Catspeak compiler, responsible for converting a stream of
/// `CatspeakToken` into executable code.
///
/// @param {Struct.CatspeakLexer} lexer
///   The iterator that yields tokens to be consumed by the compiler. Must
///   be a struct with at least a `next` method on it.
///
/// @param {Struct.CatspeakIR} [ir]
///   The Catspeak IR target to write code to, if left empty a new target is
///   created. This can be accessed using the `ir` field on a compiler
///   instance.
function CatspeakCompiler(lexer, ir) constructor {
    self.lexer = lexer;
    self.ir = ir ?? new CatspeakFunction();
    self.pos = new CatspeakLocation(0, 0);
    self.token = CatspeakToken.BOF;
    self.tokenPeeked = lexer.next();
    self.stateStack = [__stateInit];
    self.resultStack = [];
    self.scope = undefined;

    /// Advances the parser and returns the current token.
    ///
    /// @return {Enum.CatspeakToken}
    static advance = function() {
        pos.reflect(lexer.pos);
        token = tokenPeeked;
        tokenPeeked = lexer.next();
        return token;
    };

    /// Returns true if the current token matches this token kind.
    ///
    /// @param {Enum.CatspeakToken} kind
    ///   The token kind to expect.
    ///
    /// @return {Bool}
    static matches = function(kind) {
        return tokenPeeked == kind;
    };

    /// Returns true if the current token satisfies a predicate.
    ///
    /// @param {Function} predicate
    ///   The predicate to call on the peeked token, must return a Boolean
    ///   value.
    ///
    /// @return {Bool}
    static satisfies = function(predicate) {
        return predicate(tokenPeeked);
    };

    /// Attempts to match against a token and advances the parser if there
    /// was a match. Returns whether the match was successful.
    ///
    /// @param {Enum.CatspeakToken} kind
    ///   The token kind to expect.
    ///
    /// @return {Bool}
    static consume = function(kind) {
        var matched = matches(kind);
        if (matched) {
            advance();
        }
        return matched;
    };

    /// @desc Throws a `CatspeakError` for the current token.
    ///
    /// @param {String} [message]
    ///   The error message to use.
    static error = function(message) {
        throw new CatspeakError(pos, message);
    };

    /// Advances the parser and throws an for the current token.
    ///
    /// @param {String} [message]
    ///   The error message to use.
    static errorAndAdvance = function(message) {
        advance();
        var suffix = "got `" + string(pos.lexeme) +
                "` (" + catspeak_token_show(token) + ")";
        if (message == undefined) {
            message = suffix;
        } else {
            message += " -- " + suffix;
        }
        error(message);
    };

    /// Throws a `CatspeakError` if the current token is not the
    /// expected token. Advances the parser otherwise.
    ///
    /// @param {Enum.CatspeakToken} kind
    ///   The token kind to expect.
    ///
    /// @param {String} [message]
    ///   The error message to use.
    static expects = function(kind, message) {
        if (!consume(kind)) {
            errorAndAdvance(message);
        }
    };

    /// Throws a `CatspeakError` if the current token is not a semicolon
    /// or new line. Advances the parser otherwise.
    ///
    /// @param {String} [message]
    ///   The error message to use.
    static expectsSemicolon = function(message) {
        return expects(CatspeakToken.BREAK_LINE,
                "expected `;` or new line " + (message ?? ""));
    };

    /// Returns whether the compiler is in progress.
    static inProgress = function() {
        return array_length(stateStack) > 0;
    };

    /// Stages a new compiler production.
    ///
    /// @param {Function} state
    ///   The production to insert. Since this is a FIFO data structure, take
    ///   care to queue up states in reverse order of the expected execution.
    ///
    /// @return {Struct}
    static pushState = function(state) {
        array_push(stateStack, state);
    };

    /// Allocates a new register for a local variable and returns its
    /// reference.
    ///
    /// @param {String} name
    ///   The name of the variable to declare.
    ///
    /// @param {Real} reg
    ///   The register where the value of this variable is stored.
    ///
    /// @return {Real}
    static declareLocal = function(name, reg) {
        scope.vars[$ name] = reg;
    };

    /// Looks up a variable by name and returns its register. If the variable
    /// does not exist, then a global variable is used instead.
    ///
    /// @param {String} name
    ///   The name of the variable to search for.
    ///
    /// @return {Real}
    static getVar = function(name) {
        var builtin = catspeak_string_to_builtin(name);
        if (builtin != undefined || name == "undefined") {
            return ir.emitConstant(builtin);
        }
        var scope_ = scope;
        while (scope_ != undefined) {
            var reg = scope.vars[$ name];
            if (reg != undefined) {
                return reg;
            }
            scope_ = scope_.parent;
        }
        error("global variables unimplemented");
    };

    /// Looks up a variable by name and attempts to assign it a value. If the
    /// variable does not exist, then a global variable is used instead.
    ///
    /// @param {String} name
    ///   The name of the variable to search for.
    ///
    /// @param {Real} value
    ///   The register containing the value to assign.
    ///
    /// @return {Real}
    static setVar = function(name, value) {
        var scope_ = scope;
        while (scope_ != undefined) {
            var reg = scope.vars[$ name];
            if (reg != undefined) {
                ir.emitMove(value, reg);
                return value;
            }
            scope_ = scope_.parent;
        }
        error("global variables unimplemented");
    };

    /// Pushes a register which can be used to pass arguments into compiler
    /// states.
    ///
    /// @param {Any} result
    ///   The result to push onto the stack. Typically this is a register ID.
    static pushResult = function(result) {
        array_push(resultStack, result);
    };

    /// Pops the top value of the result stack and returns it.
    ///
    /// @return {Any}
    static popResult = function() {
        return array_pop(resultStack);
    };

    /// Starts a new lexical scope.
    static pushBlock = function() {
        scope = new CatspeakLocalScope(scope);
    };

    /// Pops the current block scope and returns its value.
    static popBlock = function() {
        var result = scope.result;
        scope = scope.parent;
        return result;
    };

    /// Performs `n`-many steps of the parsing and code generation process.
    /// The steps are discrete so that compilation can be paused if necessary,
    /// e.g. to avoid freezing the game for large files.
    ///
    /// @param {Real} [n]
    ///   The number of steps of codegen to perform, defaults to 1. Use `-1`
    ///   to peform all steps in a single frame. (Not recommended since large
    ///   loads may cause your game to pause.)
    static emitProgram = function(n=1) {
        var stateStack_ = stateStack;
        /// @ignore
        #macro __CATSPEAK_COMPILER_GENERATE_CODE    \
                var state = array_pop(stateStack_); \
                state()
        if (n < 0) {
            while (inProgress()) {
                __CATSPEAK_COMPILER_GENERATE_CODE;
            }
        } else {
            repeat (n) {
                if (!inProgress()) {
                    break;
                }
                __CATSPEAK_COMPILER_GENERATE_CODE;
            }
        }
    };

    /// @ignore
    static __stateError = function() {
        throw new CatspeakError(pos, "invalid state");
    }

    /// @ignore
    static __stateInit = function() {
        pushBlock();
        pushState(__stateDeinit);
        pushState(__stateProgram);
    }

    /// @ignore
    static __stateDeinit = function() {
        var result = popBlock();
        // add a final return statement
        ir.emitReturn(result);
    }

    /// @ignore
    static __stateProgram = function() {
        if (matches(CatspeakToken.EOF)) {
            return;
        }
        pushState(__stateProgram);
        pushState(__stateStmt);
    };

    /// @ignore
    static __stateStmt = function() {
        if (consume(CatspeakToken.BREAK_LINE)) {
            // do nothing
        } else if (consume(CatspeakToken.LET)) {
            pushState(__stateStmtLetBegin);
        } else {
            pushState(__stateExprPop);
            pushState(__stateExpr);
        }
    };

    /// @ignore
    static __stateStmtLetBegin = function() {
        expects(CatspeakToken.IDENT,
                "expected identifier after `let` keyword");
        pushResult(ir.emitRegister(pos));
        pushResult(pos.lexeme);
        pushState(__stateStmtLetEnd);
        if (consume(CatspeakToken.ASSIGN)) {
            pushState(__stateExpr);
        } else {
            pushResult(undefined);
        }
    };

    /// @ignore
    static __stateStmtLetEnd = function() {
        var value = popResult();
        var name = popResult();
        var reg = popResult();
        declareLocal(name, reg);
        if (value != undefined) {
            ir.emitMove(value, reg);
        }
        scope.result = undefined;
    };

    /// @ignore
    static __stateExpr = function() {
        pushState(__stateExprStmt);
    };

    /// @ignore
    static __stateExprPop = function() {
        // implicit return
        scope.result = popResult();
    };

    /// @ignore
    static __stateExprStmt = function() {
        if (consume(CatspeakToken.RETURN)) {
            pushState(__stateExprReturnBegin);
        } else if (consume(CatspeakToken.DO)) {
            pushState(__stateExprBlockBegin);
        } else if (consume(CatspeakToken.FUN)) {
            // TODO
        } else {
            pushResult(CatspeakToken.__OPERATORS_BEGIN__ + 1);
            pushState(__stateOpBinaryBegin);
        }
    };

    /// @ignore
    static __stateExprReturnBegin = function() {
        pushState(__stateExprReturnEnd);
        if (satisfies(catspeak_token_is_expression)) {
            pushState(__stateExpr);
        } else {
            pushResult(undefined);
        }
    };

    /// @ignore
    static __stateExprReturnEnd = function() {
        pushResult(ir.emitReturn(popResult()));
    };

    /// @ignore
    static __stateExprBlockBegin = function() {
        expects(CatspeakToken.BRACE_LEFT,
                "expected opening `{` at the start of a new block");
        pushBlock();
        pushState(__stateExprBlockEnd);
    };

    /// @ignore
    static __stateExprBlockEnd = function() {
        if (matches(CatspeakToken.EOF)) {
            error("missing closing `}` in block");
        } else if (consume(CatspeakToken.BRACE_RIGHT)) {
            pushResult(popBlock());
            return;
        }
        pushState(__stateExprBlockEnd);
        pushState(__stateStmt);
    };

    /// @ignore
    static __stateOpBinaryBegin = function() {
        var precedence = popResult();
        if (precedence >= CatspeakToken.__OPERATORS_END__) {
            pushState(__stateExprOpUnaryBegin);
            return;
        }
        pushResult(precedence);
        pushState(__stateOpBinary);
        pushResult(precedence + 1);
        pushState(__stateOpBinaryBegin);
    };

    /// @ignore
    static __stateOpBinary = function() {
        var lhs = popResult();
        var precedence = popResult();
        if (consume(precedence)) {
            var opReg = getVar(pos.lexeme);
            pushResult(precedence);
            pushState(__stateOpBinary);
            pushResult(opReg);
            pushResult(lhs);
            pushState(__stateOpBinaryEnd);
            pushResult(precedence + 1);
            pushState(__stateOpBinaryBegin);
        } else {
            pushResult(lhs);
        }
    };

    /// @ignore
    static __stateOpBinaryEnd = function() {
        var rhs = popResult();
        var lhs = popResult();
        var op = popResult();
        pushResult(ir.emitCall(op, [lhs, rhs]));
    };

    /// @ignore
    static __stateExprOpUnaryBegin = function() {
        if (satisfies(catspeak_token_is_operator)) {
            advance();
            var opReg = getVar(pos.lexeme);
            pushResult(opReg);
            pushState(__stateExprOpUnaryEnd);
            pushState(__stateExprTerminal);
        } else {
            pushState(__stateExprCallBegin);
            pushState(__stateExprTerminal);
        }
    };

    /// @ignore
    static __stateExprOpUnaryEnd = function() {
        var val = popResult();
        var op = popResult();
        pushResult(ir.emitCall(op, [val]));
    };

    static __stateExprCallBegin = function() {
        if (!satisfies(catspeak_token_is_expression)) {
            return;
        }
        var parens = consume(CatspeakToken.PAREN_LEFT);
        pushResult(parens);
        pushResult([]);
        pushState(__stateExprCallEnd);
        pushState(__stateExpr);
    };

    /// @ignore
    static __stateExprCallEnd = function() {
        var exprReg = popResult();
        var callArgs = popResult();
        array_push(callArgs, exprReg);
        if (consume(CatspeakToken.COMMA)) {
            pushResult(callArgs);
            pushState(__stateExprCallEnd);
            pushState(__stateExpr);
            return;
        }
        var parens = popResult();
        if (parens) {
            expects(CatspeakToken.PAREN_RIGHT,
                    "expected `)` at end of function call");
        }
        var callee = popResult();
        pushResult(ir.emitCall(callee, callArgs));
    };

    /// @ignore
    static __stateExprTerminal = function() {
        if (consume(CatspeakToken.STRING)) {
            var reg = ir.emitConstant(pos.lexeme, pos);
            pushResult(reg);
        } else if (consume(CatspeakToken.NUMBER)) {
            var reg = ir.emitConstant(real(pos.lexeme), pos);
            pushResult(reg);
        } else if (consume(CatspeakToken.IDENT)) {
            var reg = getVar(pos.lexeme);
            pushResult(reg);
        } else {
            pushState(__stateExprGroupingBegin);
        }
    };
    
    /// @ignore
    static __stateExprGroupingBegin = function() {
        if (consume(CatspeakToken.PAREN_LEFT)) {
            pushState(__stateExprGroupingEnd);
            pushState(__stateExpr);
        } else if (consume(CatspeakToken.BOX_LEFT)) {
            pushState(__stateExprArray);
        } else if (consume(CatspeakToken.BRACE_LEFT)) {
            pushState(__stateExprObject);
        } else {
            errorAndAdvance("invalid expression");
        }
    };
    
    /// @ignore
    static __stateExprGroupingEnd = function() {
        expects(CatspeakToken.PAREN_RIGHT, "expected closing `)`");
    };

    /// @ignore
    static __stateExprArray = function() {
        errorAndAdvance("arrays unimplemented");
    };

    /// @ignore
    static __stateExprObject = function() {
        errorAndAdvance("objects unimplemented");
    };
}

/// Represents a lexically scoped block of code in the compiler.
///
/// @param {Struct.CatspeakLocalScope} parent
///   The parent scope to inherit.
function CatspeakLocalScope(parent) constructor {
    self.result = undefined;
    self.vars = { };
    self.parent = parent;
}

/// Returns the value of a built-in Catspeak constant, if one exists.
/// Returns `undefined` if a built-in couldn't be found.
///
/// @param {String} name
///   The name of the built-in to find.
function catspeak_string_to_builtin(name) {
    static keywords = undefined;
    if (keywords == undefined) {
        keywords = { };
        keywords[$ "+"] = function(lhs, rhs) { return lhs + rhs };
        keywords[$ "null"] = pointer_null;
        keywords[$ "undefined"] = undefined;
        keywords[$ "true"] = true;
        keywords[$ "false"] = false;
        keywords[$ "NaN"] = NaN;
        keywords[$ "infinity"] = infinity;
        
        /*
        f(pos, "+", function(_l, _r) { return _l + _r; });
        f(pos, "++", function(_l, _r) { return (is_string(_l) ? _l : string(_l)) + (is_string(_r) ? _r : string(_r)); });
        f(pos, "-", function(_l, _r) { return _r == undefined ? -_l : _l - _r; });
        f(pos, "*", function(_l, _r) { return _l * _r; });
        f(pos, "/", function(_l, _r) { return _l / _r; });
        f(pos, "%", function(_l, _r) { return _l % _r; });
        f(pos, "//", function(_l, _r) { return _l div _r; });
        f(pos, "|", function(_l, _r) { return _l | _r; });
        f(pos, "&", function(_l, _r) { return _l & _r; });
        f(pos, "^", function(_l, _r) { return _l ^ _r; });
        f(pos, "~", function(_x) { return ~_x; });
        f(pos, "<<", function(_l, _r) { return _l << _r; });
        f(pos, ">>", function(_l, _r) { return _l >> _r; });
        f(pos, "||", function(_l, _r) { return _l || _r; });
        f(pos, "&&", function(_l, _r) { return _l && _r; });
        f(pos, "^^", function(_l, _r) { return _l ^^ _r; });
        f(pos, "!", function(_x) { return !_x; });
        f(pos, "==", function(_l, _r) { return _l == _r; });
        f(pos, "!=", function(_l, _r) { return _l != _r; });
        f(pos, ">=", function(_l, _r) { return _l >= _r; });
        f(pos, "<=", function(_l, _r) { return _l <= _r; });
        f(pos, ">", function(_l, _r) { return _l > _r; });
        f(pos, "<", function(_l, _r) { return _l < _r; });
        f(pos, "bool", function(_x) { return is_numeric(_x) && _x; });
        f(pos, "string", function(_x) { return __catspeak_legacy_encode_value(_x); });
        f(pos, "real", function(_x) { return is_real(_x) ? _x : real(_x); });
        f(pos, "typeof", function(_x) { return typeof(_x); });
        f(pos, "length", __catspeak_legacy_get_ordered_collection_length);
        f(pos, "keys", __catspeak_legacy_get_unordered_collection_keys);
        c(pos, "undefined", undefined);
        c(pos, "true", true);
        c(pos, "false", false);
        c(pos, "NaN", NaN);
        c(pos, "infinity", infinity);
        */
    }
    return keywords[$ name];
}