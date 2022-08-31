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
    self.tokenLexeme = undefined;
    self.tokenPeeked = lexer.next();
    self.stateStack = [__stateProgram, undefined, undefined];
    self.loopStack = [];

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
        var suffix = "got `" + string(tokenLexeme) +
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

    /// Stages a new compiler production. Optionally takes a single value
    /// which can be used to pass arguments into this compiler state.
    ///
    /// @param {Function} state
    ///   The production to insert. Since this is a FIFO data structure, take
    ///   care to queue up states in reverse order of the expected execution.
    ///
    /// @param {Any} [value]
    ///   The value to use as a parameter to this state.
    ///
    /// @return {Struct}
    static addState = function(state, value) {
        array_push(stateStack, state, undefined, value);
    };

    /// identical to the normal `addState` method, except a register is
    /// returned containing the result of the production.
    ///
    /// @param {Function} state
    ///   The production to insert. Since this is a FIFO data structure, take
    ///   care to queue up states in reverse order of the expected execution.
    ///
    /// @param {Any} [value]
    ///   The value to use as a parameter to this state.
    ///
    /// @return {Struct}
    static addStateResult = function(state, value) {
        var reg = ir.emitRegister(pos);
        array_push(stateStack, state, reg, value);
        return reg;
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
        #macro __CATSPEAK_COMPILER_GENERATE_CODE                        \
                var stateArg = array_pop(stateStack_);                  \
                var stateReg = array_pop(stateStack_);                  \
                var state = array_pop(stateStack_);                     \
                var result = state(stateArg);                           \
                if (result != undefined && stateReg != undefined) {     \
                    ir.emitCode(CatspeakIntcode.MOV, result, stateReg); \
                }
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
    static __stateProgram = function() {
        if (matches(CatspeakToken.EOF)) {
            return;
        }
        addState(__stateProgram);
        addState(__stateStmt);
    };
    
    /// @ignore
    static __stateStmt = function() {
        if (consume(CatspeakToken.BREAK_LINE)) {
            // do nothing
        } else {
            addState(__stateExpr);
        }
    };

    /// @ignore
    static __stateExpr = function() {
        return addStateResult(__stateExprTerminal);
    };

    /// @ignore
    static __stateExprTerminal = function() {
        if (consume(CatspeakToken.STRING)) {
            return ir.emitConstant(pos.lexeme, pos);
        } else if (consume(CatspeakToken.NUMBER)) {
            return ir.emitConstant(real(pos.lexeme), pos);
        } else {
            addState(__stateError);
        }
    };
}