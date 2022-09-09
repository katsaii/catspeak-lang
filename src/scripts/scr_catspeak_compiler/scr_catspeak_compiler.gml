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
    self.scope = undefined;
    self.stateStack = catspeak_alloc_ds_stack(self);
    self.resultStack = catspeak_alloc_ds_stack(self);
    self.itStack = catspeak_alloc_ds_stack(self);
    ds_stack_push(self.stateStack, __stateInit);

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

    /// A helper function which consumes any line breaks which may appear in
    /// an unexpected location.
    static consumeLinebreaks = function() {
        while (consume(CatspeakToken.BREAK_LINE)) {
            // nothing
        }
    }

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

    /// Allocates a new register for a local variable and returns its
    /// reference.
    ///
    /// @param {String} name
    ///   The name of the variable to declare.
    ///
    /// @param {Real} [initReg]
    ///   The accessor containing the initialiser expression, or `undefined`
    ///   if there is no initialiser.
    ///
    /// @return {Real}
    static declareLocal = function(name, initReg) {
        var scope_ = scope;
        var vars = scope_.vars;
        var init_ = initReg ?? ir.emitPermanentConstant(undefined);
        if (variable_struct_exists(vars, name)) {
            // a variable with this name already exists, so just use it
            var result = vars[$ name];
            ir.emitMove(init_, result);
            return result;
        }
        var result = ir.emitClone(init_);
        vars[$ name] = result;
        array_push(scope_.varRegisters, result);
        return result;
    };

    /// Looks up a variable by name and returns its register. If the variable
    /// does not exist, then a global constant is loaded from the runtime
    /// interface.
    ///
    /// @param {String} name
    ///   The name of the variable to search for.
    ///
    /// @return {Real}
    static getVar = function(name) {
        var scope_ = scope;
        while (scope_ != undefined) {
            var reg = scope_.vars[$ name];
            if (reg != undefined) {
                return reg;
            }
            scope_ = scope_.parent;
        }
        if (catspeak_string_is_builtin(name)) {
            var builtin = catspeak_string_to_builtin(name);
            if (is_method(builtin)) {
                // functions are less likely to be used as a parameter, so
                // make them permanent
                return ir.emitPermanentConstant(builtin);
            }
            // values like `true`, `false` or `null` are likely to be
            // consumed immediately, so make them temporary
            return ir.emitConstant(builtin);
        }
        return ir.emitRuntimeConstant(name, pos);
    };

    /// Looks up a variable by name and attempts to assign it a value. If the
    /// variable does not exist, an error is raised.
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
            var reg = scope_.vars[$ name];
            if (reg != undefined) {
                ir.emitMove(value, reg);
                return value;
            }
            scope_ = scope_.parent;
        }
        error("variable with name `" + name +
                "` does not exist in this scope");
    };

    /// Stages a new compiler production.
    ///
    /// @param {Function} state
    ///   The production to insert. Since this is a FIFO data structure, take
    ///   care to queue up states in reverse order of the expected execution.
    ///
    /// @return {Struct}
    static pushState = function(state) {
        ds_stack_push(stateStack, state);
    };

    /// Pushes a register which can be used to pass arguments into compiler
    /// states.
    ///
    /// @param {Any} result
    ///   The result to push onto the stack. Typically this is a register ID.
    static pushResult = function(result) {
        ds_stack_push(resultStack, result);
    };

    /// Returns the top result in the result stack without removing it.
    ///
    /// @return {Any}
    static topResult = function() {
        return ds_stack_top(resultStack);
    };

    /// Pops the top value of the result stack and returns it.
    ///
    /// @return {Any}
    static popResult = function() {
        return ds_stack_pop(resultStack);
    };

    /// Starts a new lexical scope.
    static pushBlock = function() {
        scope = new CatspeakLocalScope(scope);
    };

    /// Pops the current block scope and returns its value. Any variables
    /// defined in this scope are freed up to be used by new declarations.
    static popBlock = function() {
        var scope_ = scope;
        var result = scope_.result ?? ir.emitConstant(undefined, pos);
        scope = scope_.parent;
        // free variable registers
        var vars = scope_.varRegisters;
        var varCount = array_length(vars);
        for (var i = 0; i < varCount; i += 1) {
            ir.discardRegister(vars[i]);
        }
        return new CatspeakReadOnlyAccessor(result);
    };

    /// Pushes the new accessor for the `it` keyword onto the stack.
    ///
    /// @param {Any} reg
    ///   The register or accessor representing the left-hand-side of an
    ///   assignment expression.
    static pushIt = function(reg) {
        ds_stack_push(itStack, new CatspeakReadOnlyAccessor(reg));
    };

    /// Returns the accessor for the `it` keyword.
    static topIt = function() {
        if (ds_stack_empty(itStack)) {
            throw new CatspeakError(pos, "`it` keyword invalid in this case");
        }
        return ds_stack_top(itStack);
    };

    /// Pops the top accessor the `it` keyword represents.
    static popIt = function() {
        ds_stack_pop(itStack);
    };

    /// Returns whether the compiler is in progress.
    static inProgress = function() {
        return !ds_stack_empty(stateStack);
    };

    /// Performs `n`-many steps of the parsing and code generation process.
    /// The steps are discrete so that compilation can be paused if necessary,
    /// e.g. to avoid freezing the game for large files.
    ///
    /// @param {Real} n
    ///   The number of steps of process.
    static emitProgram = function(n) {
        var stateStack_ = stateStack;
        repeat (n) {
            var state = ds_stack_pop(stateStack);
            if (state == undefined) {
                return;
            }
            state();
        }
    };

    /// @ignore
    static __replaceImplicitReturn = function(replacement) {
        var scope_ = scope;
        if (scope_.result != undefined) {
            ir.emitGet(scope_.result);
        }
        scope_.result = replacement;
    }

    /// @ignore
    static __stateError = function() {
        throw new CatspeakError(pos, "invalid state");
    }

    /// @ignore
    static __stateInit = function() {
        pushBlock();
        pushState(__stateDeinit);
        pushState(__stateProgram);
        // init some of the common built-in functions
        ir.emitPermanentConstant(__newArrayFunc);
        ir.emitPermanentConstant(__newStructFunc);
    }

    /// @ignore
    static __stateDeinit = function() {
        var result = popBlock();
        // add a final return statement and perform backpatching on any
        // deferred registers
        ir.emitReturn(result);
        ir.patchPermanentRegisters();
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
        declareLocal(name, value);
        __replaceImplicitReturn(undefined);
    };

    /// @ignore
    static __stateExpr = function() {
        pushState(__stateExprStmt);
    };

    /// @ignore
    static __stateExprPop = function() {
        // implicit return
        __replaceImplicitReturn(popResult());
    };

    /// @ignore
    static __stateExprStmt = function() {
        if (consume(CatspeakToken.RETURN)) {
            pushState(__stateExprReturnBegin);
        } else if (consume(CatspeakToken.CONTINUE)) {
            // TODO
        } else if (consume(CatspeakToken.BREAK)) {
            // TODO
        } else if (consume(CatspeakToken.DO)) {
            pushState(__stateExprBlockBegin);
        } else if (consume(CatspeakToken.IF)) {
            // TODO
            pushState(__stateExprIfBegin);
            pushState(__stateExprBlockBegin);
            pushState(__stateExprGroupingBegin);
        } else if (consume(CatspeakToken.WHILE)) {
            // TODO
        } else if (consume(CatspeakToken.FOR)) {
            // TODO
        } else if (consume(CatspeakToken.FUN)) {
            // TODO
        } else {
            pushState(__stateExprAssignBegin);
        }
    };

    /// @ignore
    static __stateExprReturnBegin = function() {
        pushState(__stateExprReturnEnd);
        if (satisfies(__tokenIsExpr)) {
            pushState(__stateExprAssignBegin);
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
    static __stateExprIfBegin = function() {
        pushState(__stateExprIfEnd);
        if (consume(CatspeakToken.ELSE)) {
            pushState(__stateExprBlockBegin);
        } else {
            pushResult(ir.emitConstant(undefined));
        }
    };

    /// @ignore
    static __stateExprIfEnd = function() {
        var ifElse = popResult();
        var ifThen = popResult();
        var condition = popResult();
        throw new CatspeakError("unimplemented");
    };

    /// @ignore
    static __stateExprAssignBegin = function() {
        pushState(__stateExprAssign);
        pushResult(CatspeakToken.__OPERATORS_BEGIN__ + 1);
        pushState(__stateOpBinaryBegin);
    };

    /// @ignore
    static __stateExprAssign = function() {
        var lhs = popResult();
        if (consume(CatspeakToken.ASSIGN)) {
            pushResult(lhs);
            pushIt(lhs);
            pushState(__stateExprAssignEnd);
            pushState(__stateExpr);
        } else {
            pushResult(lhs);
        }
    };

    /// @ignore
    static __stateExprAssignEnd = function() {
        var rhs = popResult();
        var lhs = popResult();
        popIt();
        pushResult(ir.emitSet(lhs, rhs, pos));
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
        if (satisfies(__tokenIsExpr)) {
            var parens = consume(CatspeakToken.PAREN_LEFT);
            pushResult(parens);
            pushResult([]);
            pushState(__stateExprCallEnd);
            pushState(__stateExpr);
        } else {
            pushState(__stateExprIndexBegin);
        }
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
    static __stateExprIndexBegin = function() {
        if (!consume(CatspeakToken.DOT)) {
            return;
        }
        pushState(__stateExprIndexEnd);
        pushState(__stateExprFieldBegin);
    };

    /// @ignore
    static __stateExprIndexEnd = function() {
        var key = popResult();
        var collection = popResult();
        var accessor = new CatspeakCollectionAccessor(self, collection, key);
        pushResult(accessor);
        pushState(__stateExprIndexBegin);
    };

    /// @ignore
    static __stateExprTerminal = function() {
        if (consume(CatspeakToken.STRING) || consume(CatspeakToken.NUMBER)) {
            var reg = ir.emitConstant(pos.lexeme);
            pushResult(reg);
        } else if (consume(CatspeakToken.IDENT)) {
            var reg = getVar(pos.lexeme);
            pushResult(reg);
        } else if (consume(CatspeakToken.IT)) {
            var reg = topIt();
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
            pushState(__stateExprArrayBegin);
        } else if (consume(CatspeakToken.BRACE_LEFT)) {
            pushState(__stateExprStructBegin);
        } else {
            errorAndAdvance("invalid expression");
        }
    };
    
    /// @ignore
    static __stateExprGroupingEnd = function() {
        consumeLinebreaks();
        expects(CatspeakToken.PAREN_RIGHT, "expected closing `)`");
    };

    /// @ignore
    static __stateExprArrayBegin = function() {
        pushResult([]);
        pushState(__stateExprArrayEnd);
        if (consume(CatspeakToken.BOX_RIGHT)) {
            return;
        }
        pushState(__stateExprArray);
        pushState(__stateExpr);
    };

    /// @ignore
    static __stateExprArray = function() {
        var elem = popResult();
        var elems = topResult();
        array_push(elems, elem);
        var hasComma = consume(CatspeakToken.COMMA);
        consumeLinebreaks();
        if (consume(CatspeakToken.BOX_RIGHT)) {
            return;
        }
        if (!hasComma) {
            error("expected `,` between array elements");
        }
        pushState(__stateExprArray);
        pushState(__stateExpr);
    };

    /// @ignore
    static __stateExprArrayEnd = function() {
        var args = popResult();
        var newFuncReg = ir.emitPermanentConstant(__newArrayFunc);
        pushResult(ir.emitCall(newFuncReg, args, pos));
    };

    /// @ignore
    static __stateExprStructBegin = function() {
        pushResult([]);
        pushState(__stateExprStructEnd);
        if (consume(CatspeakToken.BRACE_RIGHT)) {
            return;
        }
        pushState(__stateExprStruct);
        pushState(__stateExprStructKeyValueShorthand);
    };

    /// @ignore
    static __stateExprStructKeyValueShorthand = function() {
        if (consume(CatspeakToken.IDENT)) {
            // `{ x }` is short for `{ "x" : x }`
            var varName = pos.lexeme;
            var varNameReg = ir.emitConstant(varName);
            pushResult(varNameReg);
            if (consume(CatspeakToken.COLON)) {
                pushState(__stateExpr);
            } else {
                var varReg = getVar(varName);
                pushResult(varReg);
            }
        } else {
            pushState(__stateExprStructKeyValue);
            pushState(__stateExprFieldBegin);
        }
    };

    /// @ignore
    static __stateExprStructKeyValue = function() {
        expects(CatspeakToken.COLON,
                "expected `:` between key and value of struct element");
        pushState(__stateExpr);
    };

    /// @ignore
    static __stateExprStruct = function() {
        var elem = popResult();
        var elemKey = popResult();
        var elems = topResult();
        array_push(elems, elemKey, elem);
        var hasComma = consume(CatspeakToken.COMMA);
        consumeLinebreaks();
        if (consume(CatspeakToken.BRACE_RIGHT)) {
            return;
        }
        if (!hasComma) {
            error("expected `,` between struct elements");
        }
        pushState(__stateExprStruct);
        pushState(__stateExprStructKeyValueShorthand);
    };

    /// @ignore
    static __stateExprStructEnd = function() {
        var args = popResult();
        var newFuncReg = ir.emitPermanentConstant(__newStructFunc);
        pushResult(ir.emitCall(newFuncReg, args, pos));
    };

    /// @ignore
    static __stateExprFieldBegin = function() {
        pushState(__stateExprFieldEnd);
        if (consume(CatspeakToken.IDENT)
                || consume(CatspeakToken.STRING)
                || consume(CatspeakToken.NUMBER)) {
            var reg = ir.emitConstant(pos.lexeme);
            pushResult(false); // no paren
            pushResult(reg);
        } else if (consume(CatspeakToken.BOX_LEFT)) {
            pushResult(true); // yes paren
            pushState(__stateExpr);
        } else {
            error("expected `[` or identifier in accessor expression");
        }
    };

    /// @ignore
    static __stateExprFieldEnd = function() {
        var key = popResult();
        var parens = popResult();
        if (parens) {
            consumeLinebreaks();
            expects(CatspeakToken.BOX_RIGHT,
                    "expected closing `]` after accessor expression");
        }
        pushResult(key);
    };

    /// @ignore
    static __newArrayFunc = method(undefined, __catspeak_builtin_array);

    /// @ignore
    static __newStructFunc = method(undefined, __catspeak_builtin_struct);

    /// @ignore
    static __tokenIsExpr = method(undefined, catspeak_token_is_expression);
}

/// Represents a lexically scoped block of code in the compiler.
///
/// @param {Struct.CatspeakLocalScope} parent
///   The parent scope to inherit.
function CatspeakLocalScope(parent) constructor {
    self.result = undefined;
    self.vars = { };
    self.varRegisters = [];
    self.parent = parent;
}

/// An accessor for array and object access expressions.
///
/// @param {Struct.CatspeakCompiler} compiler
///   The Catspeak compiler which generated this accessor.
///
/// @param {Any} collection
///   The register or accessor containing the collection to access.
///
/// @param {Any} index
///   The register or accessor containing the index to access.
function CatspeakCollectionAccessor(
    compiler, collection, index,
) : CatspeakAccessor() constructor {
    var pos_ = compiler.pos;
    var ir_ = compiler.ir;
    self.pos = pos_;
    self.ir = ir_;
    self.collection = ir_.emitGet(collection, pos_);
    self.index = ir_.emitGet(index, pos_);
    self.getReg = undefined;
    self.getValue = function() {
        if (getReg != undefined) {
            return getReg;
        }
        // could improve this to only copy if necessary
        // e.g. constant registers don't need to copied
        collection = ir.emitClone(collection);
        index = ir.emitClone(index);
        var getFuncReg = ir.emitPermanentConstant(getFunc);
        var result = ir.emitClone(
                ir.emitCall(getFuncReg, [collection, index], pos));
        getReg = result;
        return result;
    };
    self.setValue = function(value) {
        var setFuncReg = ir.emitPermanentConstant(setFunc);
        var result = ir.emitCall(setFuncReg, [collection, index, value], pos);
        if (getReg != undefined) {
            // dispose of allocated registers
            ir.discardRegister(getReg);
            ir.discardRegister(collection);
            ir.discardRegister(index);
        }
        getValue = undefined; // accessor is not longer valid
        setValue = undefined;
        return result;
    };

    /// @ignore
    static getFunc = method(undefined, __catspeak_builtin_get);

    /// @ignore
    static setFunc = method(undefined, __catspeak_builtin_set);
}

/// Returns the value of a built-in Catspeak constant, if one exists.
/// Returns `undefined` if a built-in couldn't be found.
///
/// @param {String} name
///   The name of the built-in to find.
///
/// @return {Any}
function catspeak_string_to_builtin(name) {
    static builtins = undefined;
    if (builtins == undefined) {
        builtins = { };
        var funcs = [
            "+", __catspeak_builtin_add,
            "++", __catspeak_builtin_add_string,
            "-", __catspeak_builtin_sub,
            "*", __catspeak_builtin_mul,
            "/", __catspeak_builtin_div,
            "%", __catspeak_builtin_mod,
            "//", __catspeak_builtin_div_int,
            "|", __catspeak_builtin_bit_or,
            "&", __catspeak_builtin_bit_and,
            "^", __catspeak_builtin_bit_xor,
            "~", __catspeak_builtin_bit_not,
            "<<", __catspeak_builtin_bit_lshift,
            ">>", __catspeak_builtin_bit_rshift,
            "||", __catspeak_builtin_or,
            "&&", __catspeak_builtin_and,
            "^^", __catspeak_builtin_xor,
            "!", __catspeak_builtin_not,
            "==", __catspeak_builtin_eq,
            "!=", __catspeak_builtin_neq,
            ">=", __catspeak_builtin_geq,
            "<=", __catspeak_builtin_leq,
            ">", __catspeak_builtin_gt,
            "<", __catspeak_builtin_lt,
            "bool", bool,
            "string", string,
            "real", real,
            "int64", int64,
            "typeof", typeof,
            "instanceof", instanceof,
            "is_array", is_array,
            "is_bool", is_bool,
            "is_infinity", is_infinity,
            "is_int32", is_int32,
            "is_int64", is_int64,
            "is_method", is_method,
            "is_nan", is_nan,
            "is_numeric", is_numeric,
            "is_ptr", is_ptr,
            "is_real", is_real,
            "is_string", is_string,
            "is_struct", is_struct,
            "is_undefined", is_undefined,
            "is_vec3", is_vec3,
            "is_vec4", is_vec4,
        ];
        for (var i = 0; i < array_length(funcs); i += 2) {
            builtins[$ funcs[i + 0]] = method(undefined, funcs[i + 1]);
        }
        var consts = [
            "null", pointer_null,
            "undefiend", undefined,
            "true", true,
            "false", false,
            "NaN", NaN,
            "infinity", infinity,
        ];
        for (var i = 0; i < array_length(consts); i += 2) {
            builtins[$ consts[i + 0]] = consts[i + 1];
        }
    }
    return builtins[$ name];
}

/// Returns whether this string represents a built-in Catspeak constant.
///
/// @param {String} name
///   The name of the built-in to find.
///
/// @return {Bool}
function catspeak_string_is_builtin(name) {
    gml_pragma("forceinline");
    var builtin = catspeak_string_to_builtin(name);
    return builtin != undefined || name == "undefined";
}

/// @ignore
function __catspeak_builtin_add(lhs, rhs) {
    return rhs == undefined ? +lhs : lhs + rhs;
}

/// @ignore
function __catspeak_builtin_add_string(lhs, rhs) {
    var lhs_ = is_string(lhs) ? lhs : string(lhs);
    var rhs_ = is_string(rhs) ? rhs : string(rhs);
    return lhs_ + rhs_;
}

/// @ignore
function __catspeak_builtin_sub() {
    return rhs == undefined ? -lhs : lhs - rhs;
}

/// @ignore
function __catspeak_builtin_mul(lhs, rhs) {
    return lhs * rhs;
}

/// @ignore
function __catspeak_builtin_div(lhs, rhs) {
    return lhs / rhs;
}

/// @ignore
function __catspeak_builtin_mod(lhs, rhs) {
    return lhs % rhs;
}

/// @ignore
function  __catspeak_builtin_div_int(lhs, rhs) {
    return lhs div rhs;
}

/// @ignore
function __catspeak_builtin_bit_or(lhs, rhs) {
    return lhs | rhs;
}

/// @ignore
function __catspeak_builtin_bit_and(lhs, rhs) {
    return lhs & rhs;
}

/// @ignore
function __catspeak_builtin_bit_xor(lhs, rhs) {
    return lhs ^ rhs;
}

/// @ignore
function __catspeak_builtin_bit_not(lhs) {
    return ~lhs;
}

/// @ignore
function  __catspeak_builtin_bit_lshift(lhs, rhs) {
    return lhs << rhs;
}

/// @ignore
function  __catspeak_builtin_bit_rshift(lhs, rhs) {
    return lhs >> rhs;
}

/// @ignore
function  __catspeak_builtin_or(lhs, rhs) {
    return lhs || rhs;
}

/// @ignore
function  __catspeak_builtin_and(lhs, rhs) {
    return lhs && rhs;
}

/// @ignore
function  __catspeak_builtin_xor(lhs, rhs) {
    return lhs ^^ rhs;
}

/// @ignore
function __catspeak_builtin_not(lhs) {
    return !lhs;
}

/// @ignore
function  __catspeak_builtin_eq(lhs, rhs) {
    return lhs == rhs;
}

/// @ignore
function  __catspeak_builtin_neq(lhs, rhs) {
    return lhs != rhs;
}

/// @ignore
function  __catspeak_builtin_geq(lhs, rhs) {
    return lhs >= rhs;
}

/// @ignore
function  __catspeak_builtin_leq(lhs, rhs) {
    return lhs <= rhs;
}

/// @ignore
function __catspeak_builtin_gt(lhs, rhs) {
    return lhs > rhs;
}

/// @ignore
function __catspeak_builtin_lt(lhs, rhs) {
    return lhs < rhs;
}

/// @ignore
function __catspeak_builtin_array() {
    var arr = array_create(argument_count);
    for (var i = 0; i < argument_count; i += 1) {
        arr[i] = argument[i];
    }
    return arr;
}

/// @ignore
function __catspeak_builtin_struct() {
    var obj = { };
    for (var i = 0; i < argument_count; i += 2) {
        obj[$ argument[i + 0]] = argument[i + 1];
    }
    return obj;
}

/// @ignore
function __catspeak_builtin_get(collection, key) {
    if (is_array(collection)) {
        if (key < 0 || key >= array_length(collection)) {
            return undefined;
        } else {
            return collection[key];
        }
    } else {
        __catspeak_verify_struct(collection);
        return collection[$ key];
    }
}

/// @ignore
function __catspeak_builtin_set(collection, key, value) {
    if (is_array(collection)) {
        collection[@ key] = value;
    } else {
        __catspeak_verify_struct(collection);
        collection[$ key] = value;
    }
    return value;
}

/// @ignore
function __catspeak_verify_struct(collection) {
    if (string_pos("Catspeak", instanceof(collection)) == 1) {
        throw new CatspeakError(undefined,
                "self-modification is prohibited by Catspeak");
    }
}