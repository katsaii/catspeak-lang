//! "Meow" is the code name for the built-in Catspeak programming language,
//! loosely inspired by syntax from JavaScript, GML, and others.
//!
//! This module contains the parser for Catspeak, responsible for converting
//! tokens emitted by `CatspeakLexer` into a runnable representation. More
//! about this representation can be found on `CatspeakirOld`.
//!
//# feather use syntax-errors

/// Consumes tokens produced by a `CatspeakLexer`, transforming the program
/// they represent into a Catspeak cartridge. This cartridge can be further
/// compiled into a callable GML function using a combination of
/// `CatspeakCartReader` and `CatspeakGenGML`. (Though, it's probably best
/// if you stick to using the stable `CatspeakCtx` API!)
///
/// @experimental
///
/// @param {Struct.CatspeakCartWriter} cartWriter
///   The writer for the cartridge to emit.
///
/// @param {Struct.CatspeakLexer} lexer_
///   The lexer to consume tokens from.
function CatspeakParser(cartWriter, lexer_) constructor {
    __catspeak_assert(is_struct(cartWriter) && instanceof(cartWriter) == "CatspeakCartWriter",
        "invalid cart writer"
    );
    __catspeak_assert(is_struct(lexer_) && instanceof(lexer_) == "CatspeakLexer",
        "invalid lexer"
    );
    /// @ignore
    ir = cartWriter;
    /// @ignore
    lexer = lexer_;
    /// @ignore
    funcs = array_create(4, undefined);
    /// @ignore
    funcTop = -1;
    /// @ignore
    isAlive = true;
    __pushFunc();

    /// @ignore
    static __pushFunc = function () {
        ir.pushFunction();
        funcTop += 1;
        funcs[@ funcTop] = {
            blocks : array_create(8, undefined),
            blockTop : -1,
        };
        __pushBlock();
    };

    /// @ignore
    static __popFunc = function () {
        __popBlock();
        funcs[@ funcTop] = undefined;
        funcTop -= 1;
        return ir.popFunction();
    };

    /// @ignore
    static __pushBlock = function () {
        var func = funcs[funcTop];
        func.blockTop += 1;
        func.blocks[@ func.blockTop] = {
            vars : { },
            // used to track the number of statements to pop in `__popBlock`
            stackSize : ir.getStackSize(),
        };
    };

    /// @ignore
    static __popBlock = function () {
        var func = funcs[funcTop];
        var exprCount = ir.getStackSize() - func.blocks[func.blockTop].stackSize;
        func.blocks[@ func.blockTop] = undefined;
        func.blockTop -= 1;
        ir.emitSequence(exprCount);
    };

    /// @ignore
    static __err = function (msg = "no message") {
        var peeked = lexer.peek();
        var tokenStr;
        if (peeked == CatspeakToken.EOF) {
            tokenStr = "end of file";
        } else if (peeked == CatspeakToken.SEMICOLON) {
            tokenStr = "line break ';'";
        } else {
            tokenStr = "token '" + lexer.getLexeme() + "' (" + string(peeked) + ")";
        }
        __catspeak_error(msg + ", got " + tokenStr);
    };

    /// Parses single a top-level statement, adding any relevant parse
    /// information to the cartridge.
    ///
    /// @example
    ///   Creates a new `CatspeakParser` from a buffer `buff`, and
    ///   writes the program information to `cart`.
    ///
    ///   ```gml
    ///   var parser = new CatspeakParserV3(cart, buff;
    ///   do {
    ///       var moreRemains = parser.update();
    ///   } until (!moreRemains);
    ///   ```
    ///
    /// @return {Real}
    ///   `undefined` if there is still more data left to parse, or a number
    ///   representing the compiled function, if the parser has reached the
    ///   end of the file.
    static parseOnce = function () {
        __catspeak_assert(isAlive, "parser has expired");
        if (lexer.peek() == CatspeakToken.EOF) {
            return __popFunc();
        }
        try {
            __parseStatement();
        } catch (ex) {
            catspeak_location_trace(ex, lexer.getLocationStart(), ir.path);
            throw ex;
        }
        return undefined;
    };

    /// @ignore
    static __parseStatement = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.SEMICOLON) {
            lexer.next();
            return;
        } else if (peeked == CatspeakToken.LET) {
            lexer.next();
            __catspeak_error_unimplemented("let statements");
            // TODO
        } else {
            __parseExpression();
        }
    };

    /// @ignore
    static __parseStatements = function (keyword) {
        if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
            __err(__catspeak_cat(
                "expected opening '{' at the start of '", keyword, "' block"
            ));
        }
        lexer.next();
        var peeked = lexer.peek();
        while (peeked != CatspeakToken.BRACE_RIGHT && peeked != CatspeakToken.EOF) {
            __parseStatement();
            peeked = lexer.peek();
        }
        if (lexer.peek() != CatspeakToken.BRACE_RIGHT) {
            __err(__catspeak_cat(
                "expected closing '}' after '", keyword, "' block"
            ));
        }
        lexer.next();
    };

    /// @ignore
    static __parseExpression = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__EXPR_BEGIN__ &&
            peeked < CatspeakToken.__EXPR_END__
        ) {
            lexer.next();
            if (peeked == CatspeakToken.RETURN) {
                __catspeak_error_unimplemented("return");
                //peeked = lexer.peek();
                //if (
                //    peeked == CatspeakToken.SEMICOLON ||
                //    peeked == CatspeakToken.BRACE_RIGHT ||
                //    peeked == CatspeakToken.LET
                //) {
                //    ir.emitConstUndefined();
                //} else {
                //    __parseExpression();
                //}
                //scope.emitReturn();
            } else if (peeked == CatspeakToken.CONTINUE) {
                __catspeak_error_unimplemented("continue");
                //scope.emitContinue();
            } else if (peeked == CatspeakToken.BREAK) {
                peeked = lexer.peek();
                if (
                    peeked == CatspeakToken.SEMICOLON ||
                    peeked == CatspeakToken.BRACE_RIGHT ||
                    peeked == CatspeakToken.LET
                ) {
                    ir.emitConstUndefined();
                } else {
                    __parseExpression();
                }
                __catspeak_error_unimplemented("break");
                //scope.emitBreak();
            } else if (peeked == CatspeakToken.THROW) {
                __parseExpression();
                __catspeak_error_unimplemented("throw");
                //ir.emitThrow();
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseCatch();
        }
    };

    /// @ignore
    static __parseCatch = function () {
        // TODO
        __parseExpressionBlock();
    };

    /// @ignore
    static __parseExpressionBlock = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__BLOCKEXPR_BEGIN__ &&
            peeked < CatspeakToken.__BLOCKEXPR_END__
        ) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            if (peeked == CatspeakToken.DO) {
                __pushBlock();
                __parseStatements("do");
                __popBlock();
            } else if (peeked == CatspeakToken.IF) {
                __catspeak_error_unimplemented("if");
                __parseCondition();
                __pushBlock();
                __parseStatements("if");
                __popBlock();
                if (lexer.peek() == CatspeakToken.ELSE) {
                    lexer.next();
                    if (lexer.peek() == CatspeakToken.IF) {
                        // for `else if` support
                        __parseExpressionBlock();
                    } else {
                        __pushBlock();
                        __parseStatements("else");
                        __popBlock();
                    }
                } else {
                    ir.emitConstUndefined();
                }
                ir.emitIfThenElse(dbg);
            } else if (peeked == CatspeakToken.WHILE) {
                // TODO
            } else if (peeked == CatspeakToken.FOR) {
                __catspeak_error_unimplemented("for loops");
            } else if (peeked == CatspeakToken.LOOP) {
                __catspeak_error_unimplemented("infinite loops");
            } else if (peeked == CatspeakToken.WITH) {
                // TODO
            } else if (peeked == CatspeakToken.MATCH) {
                // TODO
            } else if (peeked == CatspeakToken.FUN) {
                __pushFunc();
                if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
                    if (lexer.next() != CatspeakToken.PAREN_LEFT) {
                        __ex("expected opening '(' after 'fun' keyword");
                    }
                    var peeked = lexer.peek();
                    while (peeked != CatspeakToken.PAREN_RIGHT && peeked != CatspeakToken.EOF) {
                        // TODO function args
                        peeked = lexer.peek();
                    }
                    if (lexer.peek() != CatspeakToken.PAREN_RIGHT) {
                        __ex("expected closing ')' after function arguments");
                    }
                    lexer.next();
                }
                __parseStatements("fun");
                ir.emitClosure(__popFunc(), dbg);
            } else if (peeked == CatspeakToken.IMPL) {
                __catspeak_error_unimplemented("impl blocks");
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseCondition();
        }
    };
    
    /// @ignore
    static __parseCondition = function () {
        __parseOpLogicalOR();
    };

    /// @ignore
    static __parseOpLogicalOR = function () {
        __parseOpLogicalAND();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_OR_BEGIN__ &&
                peeked < CatspeakToken.__OP_OR_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpLogicalAND();
                if (peeked == CatspeakToken.OR) {
                    ir.emitOr(dbg);
                } else if (peeked == CatspeakToken.XOR) {
                    ir.emitXor(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpLogicalAND = function () {
        __parseOpPipe();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.AND) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpPipe();
                ir.emitAnd(dbg);
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpPipe = function () {
        // TODO
        __parseOpEquality();
    };

    /// @ignore
    static __parseOpEquality = function () {
        __parseOpRelational();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_EQUAL_BEGIN__ &&
                peeked < CatspeakToken.__OP_EQUAL_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpRelational();
                if (peeked == CatspeakToken.EQUAL) {
                    ir.emitEqual(dbg);
                } else if (peeked == CatspeakToken.NOT_EQUAL) {
                    ir.emitNotEqual(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpRelational = function () {
        __parseOpBitwise();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_RELATE_BEGIN__ &&
                peeked < CatspeakToken.__OP_RELATE_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpBitwise();
                if (peeked == CatspeakToken.LESS) {
                    ir.emitLessThan(dbg);
                } else if (peeked == CatspeakToken.LESS_EQUAL) {
                    ir.emitLessThanOrEqualTo(dbg);
                } else if (peeked == CatspeakToken.GREATER) {
                    ir.emitGreaterThan(dbg);
                } else if (peeked == CatspeakToken.GREATER_EQUAL) {
                    ir.emitGreaterThanOrEqualTo(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpBitwise = function () {
        __parseOpAdd();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_BITWISE_BEGIN__ &&
                peeked < CatspeakToken.__OP_BITWISE_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpAdd();
                if (peeked == CatspeakToken.AND) {
                    ir.emitBitwiseAnd(dbg);
                } else if (peeked == CatspeakToken.OR) {
                    ir.emitBitwiseOr(dbg);
                } else if (peeked == CatspeakToken.XOR) {
                    ir.emitBitwiseXor(dbg);
                } else if (peeked == CatspeakToken.SHIFT_LEFT) {
                    ir.emitBitwiseShiftLeft(dbg);
                } else if (peeked == CatspeakToken.SHIFT_RIGHT) {
                    ir.emitBitwiseShiftRight(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpAdd = function () {
        __parseOpMultiply();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_ADD_BEGIN__ &&
                peeked < CatspeakToken.__OP_ADD_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpMultiply();
                if (peeked == CatspeakToken.PLUS) {
                    ir.emitAdd(dbg);
                } else if (peeked == CatspeakToken.MINUS) {
                    ir.emitSubtract(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpMultiply = function () {
        __parseOpUnary();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked > CatspeakToken.__OP_MULT_BEGIN__ &&
                peeked < CatspeakToken.__OP_MULT_END__
            ) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseOpUnary();
                if (peeked == CatspeakToken.MULTIPLY) {
                    ir.emitMultiply(dbg);
                } else if (peeked == CatspeakToken.DIVIDE) {
                    ir.emitDivide(dbg);
                } else if (peeked == CatspeakToken.DIVIDE_INT) {
                    ir.emitDivideInt(dbg);
                } else if (peeked == CatspeakToken.REMAINDER) {
                    ir.emitRemainder(dbg);
                } else {
                    __catspeak_error_bug();
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parseOpUnary = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__OP_UNARY_BEGIN__ &&
            peeked < CatspeakToken.__OP_UNARY_END__
        ) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            __parseIndex();
            if (peeked == CatspeakToken.PLUS) {
                ir.emitPositive(dbg);
            } else if (peeked == CatspeakToken.MINUS) {
                ir.emitNegative(dbg);
            } else if (peeked == CatspeakToken.NOT) {
                ir.emitNot(dbg);
            } else if (peeked == CatspeakToken.BITWISE_NOT) {
                ir.emitBitwiseNot(dbg);
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseIndex();
        }
    };

    /// @ignore
    static __parseIndex = function () {
        // TODO
        __parseTerminal();
    };

    /// @ignore
    static __peekAssignOp = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__OP_ASSIGN_BEGIN__ &&
            peeked < CatspeakToken.__OP_ASSIGN_END__
        ) {
            if (peeked == CatspeakToken.ASSIGN) {
                return "direct";
            } else if (peeked == CatspeakToken.ASSIGN_MULTIPLY) {
                return "multiply";
            } else if (peeked == CatspeakToken.ASSIGN_DIVIDE) {
                return "divide";
            } else if (peeked == CatspeakToken.ASSIGN_PLUS) {
                return "add";
            } else if (peeked == CatspeakToken.ASSIGN_MINUS) {
                return "subtract";
            } else {
                __catspeak_error_bug();
            }
        }
        return undefined;
    };

    /// @ignore
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.NUMBER) {
            lexer.next();
            ir.emitConstNumber(lexer.getValue(), lexer.getLocationStart());
        } else if (peeked == CatspeakToken.STRING) {
            lexer.next();
            ir.emitConstString(lexer.getValue(), lexer.getLocationStart());
        } else if (peeked == CatspeakToken.UNDEFINED) {
            lexer.next();
            ir.emitConstUndefined(lexer.getLocationStart());
        } else if (peeked == CatspeakToken.IDENT) {
            __catspeak_error_unimplemented("ids");
            //lexer.next();
            //var varName = lexer.getValue();
            //var varDbg = lexer.getLocationStart();
            //var op = __peekAssignOp();
            //if (op == undefined) {
            //    scope.emitGet(varName, varDbg);
            //} else {
            //    __parseExpression();
            //    scope.emitSet(op, varName, varDbg);
            //}
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            __catspeak_error_unimplemented("self");
            //ir.emitSelf(lexer.getLocationStart());
        } else if (peeked == CatspeakToken.OTHER) {
            lexer.next();
            __catspeak_error_unimplemented("other");
            //ir.emitOther(lexer.getLocationStart());
        } else {
            __parseGrouping();
        }
    };

    /// @ignore
    static __parseGrouping = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            __parseExpression();
            if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                __err("expected closing ')' after group expression");
            }
        } else if (peeked == CatspeakToken.BOX_LEFT) {
            lexer.next();
            __catspeak_error_unimplemented("array literals");
            // TODO
        } else if (peeked == CatspeakToken.BRACE_LEFT) {
            lexer.next();
            __catspeak_error_unimplemented("struct literals");
            // TODO
        } else {
            __err("unexpected end of expression, expected one of: '(', '[' or '{'");
        }
    };
}