//! Handles the parsing and codegen stage of the Catspeak compiler.

//# feather use syntax-errors

/// Creates a new Catspeak compiler, responsible for converting a stream of
/// [CatspeakToken] into executable code.
///
/// @param {Struct.CatspeakLexer} lexer
///   The iterator that yields tokens to be consumed by the compiler. Must
///   be a struct with at least a [next] method on it.
///
/// @param {Struct.CatspeakFunction} [ir]
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
    self.stateStack = __catspeak_alloc_ds_stack(self);
    self.resultStack = __catspeak_alloc_ds_stack(self);
    self.itStack = __catspeak_alloc_ds_stack(self);
    self.loopStack = __catspeak_alloc_ds_stack(self);
    self.irStack = __catspeak_alloc_ds_stack(self);
    ds_stack_push(self.stateStack, __stateCheckAllParsed, __stateInit);

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

    /// @desc Throws a [CatspeakError] for the current token.
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

    /// Throws a [CatspeakError] if the current token is not the
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

    /// Throws a [CatspeakError] if the current token is not a semicolon
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
            scope_ = scope_.inherited ? scope_.parent : undefined;
        }
        if (__catspeak_string_is_builtin(name)) {
            var builtin = __catspeak_string_to_builtin(name);
            if (is_method(builtin)) {
                // functions are less likely to be used as a parameter, so
                // make them permanent
                return ir.emitPermanentConstant(builtin);
            }
            // values like `true`, `false` or `null` are likely to be
            // consumed immediately, so make them temporary
            return ir.emitConstant(builtin);
        }
        return new CatspeakGlobalAccessor(self, name);
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
    ///
    /// @param {Bool} [inherit]
    ///   Whether to inherit the previous scope, defaults to true.
    static pushBlock = function(inherit=true) {
        scope = new CatspeakLocalScope(scope, inherit);
    };

    /// Pops the current block scope and returns its value. Any variables
    /// defined in this scope are freed up to be used by new declarations.
    ///
    /// @return {Any}
    static popBlock = function() {
        var scope_ = scope;
        scope = scope_.parent;
        // free variable registers
        var vars = scope_.varRegisters;
        var varCount = array_length(vars);
        for (var i = 0; i < varCount; i += 1) {
            ir.discardRegister(vars[i]);
        }
        if (scope_.inherited) {
            var result = scope_.result ?? ir.emitConstant(undefined, pos);
            return new CatspeakReadOnlyAccessor(result);
        } else {
            return ir.emitUnreachable(); // shouldn't ever use this value
        }
    };

    /// Pushes the new accessor for the `it` keyword onto the stack.
    ///
    /// @param {Any} reg
    ///   The register or accessor representing the left-hand-side of an
    ///   assignment expression.
    static pushIt = function(reg) {
        if (is_struct(reg) && instanceof(reg) == "CatspeakCollectionAccessor") {
            // if this is the case, then it is possible that
            // ```
            // a.[0] = it + it
            // ```
            // will happen, so the accessor registers need to be non-temporary
            reg.isTemporary = false;
        }
        ds_stack_push(itStack, {
            ir : ir,
            it : new CatspeakReadOnlyAccessor(reg),
        });
    };

    /// Returns the accessor for the `it` keyword.
    ///
    /// @return {Any}
    static topIt = function() {
        if (!ds_stack_empty(itStack)) {
            var top = ds_stack_top(itStack);
            if (top.ir == ir) {
                return top.it;
            }
        }
        throw new CatspeakError(pos, "`it` keyword invalid in this case");
    };

    /// Pops the top accessor the `it` keyword represents.
    static popIt = function() {
        ds_stack_pop(itStack);
    };

    /// Pushes the loop onto the stack.
    ///
    /// @param {Struct.CatspeakBlock} breakBlock
    ///   The block to jump to if `break` is used.
    ///
    /// @param {Struct.CatspeakBlock} continueBlock
    ///   The block to jump to if `continue` is used.
    ///
    /// @param {Struct}
    static pushLoop = function(breakBlock, continueBlock) {
        var context = {
            ir : ir,
            breakBlock : breakBlock,
            continueBlock : continueBlock,
        };
        ds_stack_push(loopStack, context);
        return context;
    };

    /// Returns the data for the current loop.
    ///
    /// @return {Struct}
    static topLoop = function() {
        if (!ds_stack_empty(loopStack)) {
            var top = ds_stack_top(loopStack);
            if (top.ir == ir) {
                return top;
            }
        }
        throw new CatspeakError(pos,
                    "`break` or `continue` invalid in this case");
    };

    /// Pops the top loop.
    static popLoop = function() {
        ds_stack_pop(loopStack);
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
    static __stateCheckAllParsed = function() {
        expects(CatspeakToken.EOF, "expected end of file");
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
        // add a final return statement and perform backpatching on any
        // deferred registers
        ir.emitReturn(result);
        ir.patchPermanentRegisters();
    }

    /// @ignore
    static __stateProgram = function() {
        if (matches(CatspeakToken.EOF)
                || matches(CatspeakToken.BRACE_RIGHT)) {
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
            ir.emitJump(topLoop().continueBlock);
            pushResult(ir.emitUnreachable());
        } else if (consume(CatspeakToken.BREAK)) {
            ir.emitJump(topLoop().breakBlock);
            pushResult(ir.emitUnreachable());
        } else if (consume(CatspeakToken.DO)) {
            pushState(__stateExprBlockBegin);
        } else if (consume(CatspeakToken.IF)) {
            pushState(__stateExprIfBegin);
        } else if (consume(CatspeakToken.WHILE)) {
            pushState(__stateExprWhileBegin);
        } else if (consume(CatspeakToken.FUN)) {
            var name = "anon_" + string(pos.line) + "_" + string(pos.column);
            var func = ir.emitFunction(name);
            pushResult(ir.emitConstant(func));
            ds_stack_push(irStack, ir);
            ir = func;
            pushBlock(false);
            // load argument registers
            var parens = consume(CatspeakToken.PAREN_LEFT);
            if (consume(CatspeakToken.IDENT)) {
                var firstArg = ir.emitRegister(pos);
                var argCount = 1;
                scope.vars[$ pos.lexeme] = firstArg;
                while (consume(CatspeakToken.COMMA)) {
                    expects(CatspeakToken.IDENT,
                            "expected identifier after `,` in arguments");
                    scope.vars[$ pos.lexeme] = ir.emitRegister(pos);
                    argCount += 1;
                }
                ir.emitArgs(firstArg, argCount);
            }
            if (parens) {
                expects(CatspeakToken.PAREN_RIGHT,
                        "expected `)` after arguments");
            }
            expects(CatspeakToken.BRACE_LEFT,
                    "expected `{` in function definition");
            pushState(__stateExprFunEnd);
            pushState(__stateInit);
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
        pushResult({
            reg : undefined,
            ifEnd : new CatspeakBlock("if end", pos),
            ifElse : new CatspeakBlock("if else", pos),
        });
        pushState(__stateExprIfThen);
        pushState(__stateExprGroupingBegin);
    };

    /// @ignore
    static __stateExprIfThen = function() {
        var condition = popResult();
        ir.emitJumpFalse(topResult().ifElse, condition);
        pushState(__stateExprIfElse);
        pushState(__stateExprBlockBegin);
    };

    /// @ignore
    static __stateExprIfElse = function() {
        var ifThenValue = popResult();
        var ifContext = topResult();
        ifContext.reg = ir.emitClone(ifThenValue, pos);
        ir.emitJump(ifContext.ifEnd);
        ir.emitBlock(ifContext.ifElse);
        pushState(__stateExprIfEnd);
        if (consume(CatspeakToken.ELSE)) {
            if (consume(CatspeakToken.IF)) {
                pushState(__stateExprIfBegin);
            } else {
                pushState(__stateExprBlockBegin);
            }
        } else {
            pushResult(ir.emitConstant(undefined));
        }
    };

    /// @ignore
    static __stateExprIfEnd = function() {
        var ifElseValue = popResult();
        var ifContext = popResult();
        ir.emitMove(ifElseValue, ifContext.reg);
        ir.emitBlock(ifContext.ifEnd);
        pushResult(new CatspeakTempRegisterAccessor(ifContext.reg, ir));
    };

    /// @ignore
    static __stateExprWhileBegin = function() {
        var whileContext = pushLoop(
                new CatspeakBlock("while end", pos),
                new CatspeakBlock("while begin", pos));
        ir.emitBlock(whileContext.continueBlock);
        pushState(__stateExprWhile);
        pushState(__stateExprGroupingBegin);
    };

    /// @ignore
    static __stateExprWhile = function() {
        var condition = popResult();
        var whileContext = topLoop();
        ir.emitJumpFalse(whileContext.breakBlock, condition);
        pushState(__stateExprWhileEnd);
        pushState(__stateExprBlockBegin);
    };

    /// @ignore
    static __stateExprWhileEnd = function() {
        ir.emitGet(popResult()); // discards the result of the loop body
        var whileContext = topLoop();
        popLoop();
        ir.emitJump(whileContext.continueBlock);
        ir.emitBlock(whileContext.breakBlock);
        pushResult(ir.emitConstant(undefined));
    };

    /// @ignore
    static __stateExprFunEnd = function() {
        expects(CatspeakToken.BRACE_RIGHT,
                "expected `}` at end of function definition");
        popBlock();
        ir = ds_stack_pop(irStack);
    };

    /// @ignore
    static __stateExprAssignBegin = function() {
        pushState(__stateExprAssign);
        pushState(__stateExprOpLogicalBegin);
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
    static __stateExprOpLogicalBegin = function() {
        pushState(__stateExprOpLogical);
        pushResult(CatspeakToken.__OPERATORS_BEGIN__ + 1);
        pushState(__stateExprOpBinaryBegin);
    };

    /// @ignore
    static __stateExprOpLogical = function() {
        var lhs = popResult();
        if (consume(CatspeakToken.AND)) {
            var blk = new CatspeakBlock("and end", pos);
            var condition = ir.emitClone(lhs, pos);
            pushResult({
                reg : condition,
                andEnd : blk,
            });
            ir.emitJumpFalse(blk, condition);
            pushState(__stateExprOpLogicalEndAnd);
            pushState(__stateExprOpLogicalBegin);
        } else if (consume(CatspeakToken.OR)) {
            var blk = new CatspeakBlock("or end", pos);
            var condition = ir.emitClone(lhs, pos);
            pushResult({
                reg : condition,
                orEnd : blk,
            });
            ir.emitJumpTrue(blk, condition);
            pushState(__stateExprOpLogicalEndOr);
            pushState(__stateExprOpLogicalBegin);
        } else {
            pushResult(lhs);
        }
    };

    /// @ignore
    static __stateExprOpLogicalEndAnd = function() {
        var rhs = popResult();
        var info = popResult();
        ir.emitMove(rhs, info.reg);
        ir.emitBlock(info.andEnd);
        pushResult(new CatspeakTempRegisterAccessor(info.reg, ir));
    };

    /// @ignore
    static __stateExprOpLogicalEndOr = function() {
        var rhs = popResult();
        var info = popResult();
        ir.emitMove(rhs, info.reg);
        ir.emitBlock(info.orEnd);
        pushResult(new CatspeakTempRegisterAccessor(info.reg, ir));
    };

    /// @ignore
    static __stateExprOpBinaryBegin = function() {
        var precedence = popResult();
        if (precedence >= CatspeakToken.__OPERATORS_END__) {
            pushState(__stateExprOpUnaryBegin);
            return;
        }
        pushResult(precedence);
        pushState(__stateExprOpBinary);
        pushResult(precedence + 1);
        pushState(__stateExprOpBinaryBegin);
    };

    /// @ignore
    static __stateExprOpBinary = function() {
        var lhs = popResult();
        var precedence = popResult();
        if (consume(precedence)) {
            var opReg = getVar(pos.lexeme);
            pushResult(precedence);
            pushState(__stateExprOpBinary);
            pushResult(opReg);
            pushResult(ir.emitCloneTemp(lhs, pos));
            pushState(__stateExprOpBinaryEnd);
            pushResult(precedence + 1);
            pushState(__stateExprOpBinaryBegin);
        } else {
            pushResult(lhs);
        }
    };

    /// @ignore
    static __stateExprOpBinaryEnd = function() {
        var rhs = ir.emitCloneTemp(popResult(), pos);
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
            pushState(__stateExprIndexBegin);
            pushState(__stateExprTerminal);
        } else {
            pushState(__stateExprCallBegin);
            pushState(__stateExprIndexBegin);
            pushState(__stateExprTerminal);
        }
    };

    /// @ignore
    static __stateExprOpUnaryEnd = function() {
        var val = popResult();
        var op = popResult();
        pushResult(ir.emitCall(op, [val]));
    };

    /// @ignore
    static __stateExprCallBegin = function() {
        pushState(__stateExprCall);
    };

    static __stateExprCall = function() {
        if (satisfies(__tokenIsExpr)) {
            var parens = consume(CatspeakToken.PAREN_LEFT);
            if (parens && consume(CatspeakToken.PAREN_RIGHT)) {
                var callee = popResult();
                pushResult(__emitMethodCall(callee, []));
                return;
            }
            pushResult(parens);
            pushResult([]);
            pushState(__stateExprCallEnd);
            pushState(__stateExpr);
        }
    };

    /// @ignore
    static __stateExprCallEnd = function() {
        var exprReg = popResult();
        var callArgs = popResult();
        array_push(callArgs, ir.emitCloneTemp(exprReg));
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
        pushResult(__emitMethodCall(callee, callArgs));
    };

    /// @ignore
    static __emitMethodCall = function(callee, args) {
        if (is_struct(callee) &&
                instanceof(callee) == "CatspeakCollectionAccessor") {
            // create a call with the collection as the "self"
            var callself = ir.emitClone(callee.collection); // take ownership
            callself = new CatspeakTempRegisterAccessor(callself, ir, 2);
            callee.collection = callself;
            return ir.emitCallSelf(callself, callee, args, pos);
        } else {
            // use the global self
            return ir.emitCall(callee, args, pos);
        }
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
        } else if (consume(CatspeakToken.SELF)) {
            var self_ = ir.emitSelf();
            pushResult(self_);
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
        array_push(elems, ir.emitCloneTemp(elem, pos));
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
        array_push(elems,
                ir.emitCloneTemp(elemKey, pos),
                ir.emitCloneTemp(elem, pos));
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
///
/// @param {Bool} inherit
///   The whether to actually inherit the parent scope.
function CatspeakLocalScope(parent, inherit) constructor {
    self.result = undefined;
    self.vars = { };
    self.varRegisters = [];
    self.parent = parent;
    self.inherited = inherit;
}

/// An accessor for global variable accessor expressions.
///
/// @param {Struct.CatspeakCompiler} compiler
///   The Catspeak compiler which generated this accessor.
///
/// @param {String} name
///   The name of the global variable.
function CatspeakGlobalAccessor(
    compiler, name,
) : CatspeakAccessor() constructor {
    var pos_ = compiler.pos;
    var ir_ = compiler.ir;
    self.pos = pos_;
    self.ir = ir_;
    self.name = name;
    self.getReg = undefined;
    self.getValue = function() {
        if (getReg != undefined) {
            return getReg;
        }
        var result = ir.emitClone(ir.emitGlobalGet(name, pos));
        getReg = result;
        return result;
    };
    self.setValue = function(value) {
        var result = ir.emitGlobalSet(name, value, pos);
        if (getReg != undefined) {
            // dispose of allocated registers
            ir.discardRegister(getReg);
        }
        getValue = undefined; // accessor is not longer valid
        setValue = undefined;
        return result;
    };
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
    self.isTemporary = true;
    // TODO :: figure out how to handle accessors better, they seem a bit rough
    self.collection = collection;
    self.index = index;
    self.getReg = undefined;
    self.getValue = function() {
        if (getReg != undefined) {
            return getReg;
        }
        if (!isTemporary) {
            // could improve this to only copy if necessary
            // e.g. constant registers don't need to copied
            collection = ir.emitClone(collection);
            index = ir.emitClone(index);
        }
        var getFuncReg = ir.emitPermanentConstant(getFunc);
        var result = ir.emitCall(getFuncReg, [collection, index], pos)
        if (!isTemporary) {
            result = ir.emitClone(result);
            getReg = result;
        }
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