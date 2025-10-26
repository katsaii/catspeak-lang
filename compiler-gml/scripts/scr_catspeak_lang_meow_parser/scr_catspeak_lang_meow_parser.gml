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
    __catspeak_assert_instanceof(cartWriter, CatspeakCartWriter, "invalid cart writer");
    __catspeak_assert_instanceof(lexer_, CatspeakLexer, "invalid lexer");

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
            unwindDepth : 0,
        };
        __pushBlock();
    };

    /// @ignore
    static __popFunc = function () {
        __popBlock();
        ir.emitUnwindLanding(__getLabelReturn());
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
        if (exprCount != 1) {
            ir.emitSequence(exprCount);
        }
    };

    /// @ignore
    static __allocLocal = function (name) {
        var func = funcs[funcTop];
        var block = func.blocks[func.blockTop];
        var idx = ir.getFreshVar();
        block.vars[$ name] = idx;
        return idx;
    };

    /// @ignore
    static __findLocal = function (name) {
        var func = funcs[funcTop];
        for (var i = func.blockTop; i >= 0; i -= 1) {
            var block = func.blocks[i];
            var idx = block.vars[$ name];
            if (idx != undefined) {
                return idx;
            }
        }
        return undefined;
    };

    /// @ignore
    static __emitVarGet = function (name, dbg) {
        var idx = __findLocal(name);
        if (idx != undefined) {
            ir.emitGetLocal(idx, dbg);
        } else {
            ir.emitGetGlobal(name, dbg);
        }
    };

    /// @ignore
    static __emitVarSet = function (op, name, dbg) {
        var idx = __findLocal(name);
        if (idx != undefined) {
            ir.emitSetLocal(op, idx, dbg);
        } else {
            ir.emitSetGlobal(op, name, dbg);
        }
    };

    /// @ignore
    static __getLabelReturn = function () { return 0 };

    /// @ignore
    static __getLabelContinue = function () { return 1 };

    /// @ignore
    static __getLabelBreak = function () { return 2 };

    /// @ignore
    static __err = function (msg = "no message") {
        var token = lexer.next();
        var tokenStr;
        if (token == CatspeakToken.EOF) {
            tokenStr = "end of file";
        } else if (token == CatspeakToken.SEMICOLON) {
            tokenStr = "line break ';'";
        } else {
            tokenStr = "token '" + lexer.getLexeme() + "' (" + string(token) + ")";
        }
        __catspeak_error(msg + ", got " + tokenStr);
    };

    /// @ignore
    static __expect = function (expect, msg = "no message") {
        if (expect == lexer.peek()) {
            return lexer.next();
        }
        __err(msg);
    };

    /// Parses single a top-level statement, adding any relevant parse
    /// information to the cartridge.
    ///
    /// @example
    ///   Creates a new `CatspeakParser` from a cart writer `writer`, and
    ///   parses a `lexer` to completion.
    ///
    ///   ```gml
    ///   var parser = new CatspeakParser(writer, lexer);
    ///   do {
    ///     var keepParsing = parser.parseOnce() == undefined;
    ///   } until (!keepParsing);
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
            __expect(CatspeakToken.IDENT, "expected identifier after 'let' keyword");
            var idx = __allocLocal(lexer.getValue());
            var dbg = undefined;
            if (lexer.peek() == CatspeakToken.ASSIGN) {
                lexer.next();
                dbg = lexer.getLocationStart();
                __parseExpression();
            } else {
                ir.emitConstUndefined();
            }
            ir.emitSetLocal(ord("="), idx, dbg);
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
            var dbg = lexer.getLocationStart();
            lexer.next();
            if (peeked == CatspeakToken.RETURN) {
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
                ir.emitUnwind(__getLabelReturn(), dbg);
            } else if (peeked == CatspeakToken.CONTINUE) {
                __catspeak_error_unimplemented("continue");
                ir.emitConstUndefined();
                ir.emitUnwind(__getLabelContinue(), dbg);
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
                ir.emitUnwind(__getLabelBreak(), dbg);
            } else if (peeked == CatspeakToken.THROW) {
                __parseExpression();
                ir.emitThrow(dbg);
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseCatch();
        }
    };

    /// @ignore
    static __parseCatch = function () {
        __parseExpressionBlock();
        if (lexer.peek() == CatspeakToken.CATCH) {
            var dbg = lexer.getLocationStart();
            lexer.next();
            var idx;
            if (lexer.peek() == CatspeakToken.IDENT) {
                lexer.next();
                var name = lexer.getValue();
                idx = __findLocal(name);
            } else {
                // TODO :: reuse this
                idx = ir.getFreshVar();
            }
            __pushBlock();
            __parseStatements("catch");
            __popBlock();
            ir.emitCatch(idx, dbg);
        }
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
                __parseExpression();
                __pushBlock();
                __parseStatements("while");
                __popBlock();
                ir.emitUnwindLanding(__getLabelContinue());
                ir.emitLoop(dbg);
                ir.emitUnwindLanding(__getLabelBreak());
            } else if (peeked == CatspeakToken.FOR) {
                __catspeak_error_unimplemented("for loops");
            } else if (peeked == CatspeakToken.LOOP) {
                __pushBlock();
                __parseStatements("loop");
                __popBlock();
                ir.emitUnwindLanding(__getLabelContinue());
                ir.emitLoopInf(dbg);
                ir.emitUnwindLanding(__getLabelBreak());
            } else if (peeked == CatspeakToken.WITH) {
                __parseExpression();
                __pushBlock();
                __parseStatements("with");
                __popBlock();
                ir.emitUnwindLanding(__getLabelContinue());
                ir.emitLoopWith(dbg);
                ir.emitUnwindLanding(__getLabelBreak());
            } else if (peeked == CatspeakToken.MATCH) {
                // TODO
            } else if (peeked == CatspeakToken.FUN) {
                __pushFunc();
                if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
                    __expect(CatspeakToken.PAREN_LEFT, "expected opening '(' after 'fun' keyword");
                    var peeked = lexer.peek();
                    while (peeked != CatspeakToken.PAREN_RIGHT && peeked != CatspeakToken.EOF) {
                        // TODO function args
                        peeked = lexer.peek();
                    }
                    __expect(CatspeakToken.PAREN_RIGHT, "expected closing ')' after function arguments");
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
        __parsePrimary();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.PAREN_LEFT) {
                __catspeak_error_unimplemented("function calls");
            } else if (peeked == CatspeakToken.BOX_LEFT) {
                var dbg = lexer.getLocationStart();
                lexer.next();
                __parseExpression();
                __expect(CatspeakToken.BOX_RIGHT, "expected closing ']' after index expression");
                var op = __parseAssignOp();
                if (op == undefined) {
                    ir.emitGetIndex(dbg);
                } else {
                    __parseExpression();
                    ir.emitSetIndex(op, dbg);
                }
            } else {
                break;
            }
        }
    };

    /// @ignore
    static __parsePrimary = function () {
        var peeked = lexer.peek();
        var dbg = lexer.getLocationStart();
        if (peeked == CatspeakToken.NUMBER) {
            lexer.next();
            ir.emitConstNumber(lexer.getValue(), dbg);
        } else if (peeked == CatspeakToken.STRING) {
            lexer.next();
            ir.emitConstString(lexer.getValue(), dbg);
        } else if (peeked == CatspeakToken.UNDEFINED) {
            lexer.next();
            ir.emitConstUndefined(dbg);
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            var name = lexer.getValue();
            var op = __parseAssignOp();
            if (op == undefined) {
                __emitVarGet(name, dbg);
            } else {
                __parseExpression();
                __emitVarSet(op, name, dbg);
            }
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            __catspeak_error_unimplemented("self");
            //ir.emitSelf(lexer.getLocationStart());
        } else if (peeked == CatspeakToken.OTHER) {
            lexer.next();
            __catspeak_error_unimplemented("other");
            //ir.emitOther(lexer.getLocationStart());
        } else if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            __parseExpression();
            __expect(CatspeakToken.PAREN_RIGHT, "expected closing ')' after group expression");
        } else if (peeked == CatspeakToken.BOX_LEFT) {
            lexer.next();
            var n = 0;
            peeked = lexer.peek();
            var expectExpr = true;
            while (expectExpr && peeked != CatspeakToken.BOX_RIGHT) {
                __parseExpression();
                n += 1;
                peeked = lexer.peek();
                expectExpr = peeked == CatspeakToken.COMMA;
                if (expectExpr) {
                    lexer.next();
                    peeked = lexer.peek();
                }
            }
            __expect(CatspeakToken.BOX_RIGHT, "expected closing ']' after array literal");
            ir.emitArray(n, dbg);
        } else if (peeked == CatspeakToken.BRACE_LEFT) {
            lexer.next();
            var n = 0;
            peeked = lexer.peek();
            var expectExpr = true;
            while (expectExpr && peeked != CatspeakToken.BRACE_RIGHT) {
                // struct keys
                var key = lexer.peek();
                var keyDbg = lexer.getLocationStart();
                var keyValue = undefined;
                if (key == CatspeakToken.BOX_LEFT) {
                    lexer.next();
                    __parseExpression();
                    __expect(CatspeakToken.BOX_RIGHT, "expected closing ']' after computed struct key");
                } else if (
                    key == CatspeakToken.IDENT ||
                    key == CatspeakToken.STRING ||
                    key == CatspeakToken.NUMBER ||
                    key == CatspeakToken.UNDEFINED
                ) {
                    lexer.next();
                    keyValue = lexer.getValue();
                    ir.emitConstString(keyValue, keyDbg);
                } else {
                    __err("expected identifier or value as struct key");
                }
                // struct values
                if (lexer.peek() == CatspeakToken.COLON) {
                    lexer.next();
                    __parseExpression();
                } else if (key == CatspeakToken.IDENT) {
                    __emitVarGet(keyValue, keyDbg);
                } else {
                    __err("expected ':' between key and value of struct literal");
                }
                n += 2;
                peeked = lexer.peek();
                expectExpr = peeked == CatspeakToken.COMMA;
                if (expectExpr) {
                    lexer.next();
                    peeked = lexer.peek();
                }
            }
            __expect(CatspeakToken.BRACE_RIGHT, "expected closing '}' after struct literal");
            ir.emitStruct(n, dbg);
        } else {
            __err("unexpected end of expression, expected one of: '(', '[' or '{'");
        }
    };

    /// @ignore
    static __parseAssignOp = function () {
        var peeked = lexer.peek();
        if (
            peeked > CatspeakToken.__OP_ASSIGN_BEGIN__ &&
            peeked < CatspeakToken.__OP_ASSIGN_END__
        ) {
            lexer.next();
            if (peeked == CatspeakToken.ASSIGN) {
                return ord("=");
            } else if (peeked == CatspeakToken.ASSIGN_MULTIPLY) {
                return ord("*");
            } else if (peeked == CatspeakToken.ASSIGN_DIVIDE) {
                return ord("/");
            } else if (peeked == CatspeakToken.ASSIGN_PLUS) {
                return ord("+");
            } else if (peeked == CatspeakToken.ASSIGN_MINUS) {
                return ord("-");
            } else {
                __catspeak_error_bug();
            }
        }
        return undefined;
    };
}