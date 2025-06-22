//! "Meow" is the code name for the built-in Catspeak programming language,
//! loosely inspired by syntax from JavaScript, GML, and others.
//!
//! This module contains the parser for Catspeak, responsible for converting
//! tokens emitted by `CatspeakLexer` into a runnable representation. More
//! about this representation can be found on `CatspeakCartWriter`.
//!
//# feather use syntax-errors

/// Consumes tokens produced by a `CatspeakLexer`, transforming the program
/// they represent into a Catspeak cartridge. This cartridge can be further
/// compiled into a callable GML function using a combination of
/// `CatspeakCartReader` and `CatspeakCodegenGML`. (Though, it's probably
/// best if you stick to using the stable `CatspeakCtx` API!)
///
/// @experimental
///
/// @warning
///   The lexer does not take ownership of its buffer, so you must make sure
///   to delete the buffer once the lexer is complete. Failure to do this will
///   result in leaking memory.
///
/// @param {Struct.CatspeakCartWriter} cartWriter
///   The writer for the cartridge to emit.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to parse tokens from.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit
///   will be treated as the end of the file. Defaults to `infinity`.
function CatspeakParser(cartWriter_, buff, offset = undefined, size = undefined) constructor {
    /// @ignore
    cartWriter = cartWriter_;
    /// @ignore
    scope = new CatspeakScopeStack(cartWriter);
    /// @ignore
    lexer = new CatspeakLexer(buff, offset, size);
    /// @ignore
    finalised = false;
    scope.beginFunction();

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
    /// @return {Bool}
    ///   `true` if there is still more data left to parse, and `false`
    ///   if the parser has reached the end of the file.
    static parseOnce = function () {
        __catspeak_assert(!finalised, "attempting to update parser after it has been finalised");
        if (lexer.peek() == CatspeakToken.EOF) {
            scope.endFunction();
            cartWriter.finalise();
            finalised = true;
            return false;
        }
        __parseStatement();
        return true;
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
            scope.prepareStatement();
            __parseExpression();
        }
    };

    /// @ignore
    static __parseStatements = function (keyword) {
        if (lexer.next() != CatspeakToken.BRACE_LEFT) {
            __ex("expected opening '{' at the start of '", keyword, "' block");
        }
        while (__isNot(CatspeakToken.BRACE_RIGHT)) {
            __parseStatement();
        }
        if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
            __ex("expected closing '}' after '", keyword, "' block");
        }
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
                peeked = lexer.peek();
                if (
                    peeked == CatspeakToken.SEMICOLON ||
                    peeked == CatspeakToken.BRACE_RIGHT ||
                    peeked == CatspeakToken.LET
                ) {
                    cartWriter.emitConstUndefined(lexer.getLocation());
                } else {
                    __parseExpression();
                }
                cartWriter.emitReturn(lexer.getLocation());
            } else if (peeked == CatspeakToken.CONTINUE) {
                cartWriter.emitContinue(lexer.getLocation());
            } else if (peeked == CatspeakToken.BREAK) {
                peeked = lexer.peek();
                if (
                    peeked == CatspeakToken.SEMICOLON ||
                    peeked == CatspeakToken.BRACE_RIGHT ||
                    peeked == CatspeakToken.LET
                ) {
                    cartWriter.emitConstUndefined(lexer.getLocation());
                } else {
                    __parseExpression();
                }
                cartWriter.emitBreak(lexer.getLocation());
            } else if (peeked == CatspeakToken.THROW) {
                __parseExpression();
                cartWriter.emitBreak(lexer.getLocation());
            } else {
                __catspeak_error_bug();
            }
        } else {
            __parseAssign();
        }
    };

    /// @ignore
    static __parseAssign = function () {
        // TODO
        __parseCatch();
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
            lexer.next();
            if (peeked == CatspeakToken.DO) {
                scope.beginBlock();
                __parseStatements("do");
                scope.endBlock();
            } else if (peeked == CatspeakToken.IF) {
                __parseCondition();
                scope.beginBlock();
                __parseStatements("if");
                scope.endBlock();
                if (lexer.peek() == CatspeakToken.ELSE) {
                    lexer.next();
                    if (lexer.peek() == CatspeakToken.IF) {
                        // for `else if` support
                        __parseExpressionBlock();
                    } else {
                        scope.beginBlock();
                        __parseStatements("else");
                        scope.endBlock();
                    }
                } else {
                    cartWriter.emitConstUndefined(lexer.getLocation());
                }
                cartWriter.emitIfThenElse(lexer.getLocation());
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
                // TODO
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
                lexer.next();
                __parseOpLogicalAND();
                if (peeked == CatspeakToken.OR) {
                    cartWriter.emitOr(lexer.getLocation());
                } else if (peeked == CatspeakToken.XOR) {
                    cartWriter.emitXor(lexer.getLocation());
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
                lexer.next();
                __parseOpPipe();
                cartWriter.emitAnd(lexer.getLocation());
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
                lexer.next();
                __parseOpRelational();
                if (peeked == CatspeakToken.EQUAL) {
                    cartWriter.emitEqual(lexer.getLocation());
                } else if (peeked == CatspeakToken.NOT_EQUAL) {
                    cartWriter.emitNotEqual(lexer.getLocation());
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
                lexer.next();
                __parseOpBitwise();
                if (peeked == CatspeakToken.LESS) {
                    cartWriter.emitLessThan(lexer.getLocation());
                } else if (peeked == CatspeakToken.LESS_EQUAL) {
                    cartWriter.emitLessThanOrEqualTo(lexer.getLocation());
                } else if (peeked == CatspeakToken.GREATER) {
                    cartWriter.emitGreaterThan(lexer.getLocation());
                } else if (peeked == CatspeakToken.GREATER_EQUAL) {
                    cartWriter.emitGreaterThanOrEqualTo(lexer.getLocation());
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
                lexer.next();
                __parseOpAdd();
                if (peeked == CatspeakToken.AND) {
                    cartWriter.emitBitwiseAnd(lexer.getLocation());
                } else if (peeked == CatspeakToken.OR) {
                    cartWriter.emitBitwiseOr(lexer.getLocation());
                } else if (peeked == CatspeakToken.XOR) {
                    cartWriter.emitBitwiseXor(lexer.getLocation());
                } else if (peeked == CatspeakToken.SHIFT_LEFT) {
                    cartWriter.emitBitwiseShiftLeft(lexer.getLocation());
                } else if (peeked == CatspeakToken.SHIFT_RIGHT) {
                    cartWriter.emitBitwiseShiftRight(lexer.getLocation());
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
                lexer.next();
                __parseOpMultiply();
                if (peeked == CatspeakToken.PLUS) {
                    cartWriter.emitAdd(lexer.getLocation());
                } else if (peeked == CatspeakToken.MINUS) {
                    cartWriter.emitSubtract(lexer.getLocation());
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
                lexer.next();
                __parseOpUnary();
                if (peeked == CatspeakToken.MULTIPLY) {
                    cartWriter.emitMultiply(lexer.getLocation());
                } else if (peeked == CatspeakToken.DIVIDE) {
                    cartWriter.emitDivide(lexer.getLocation());
                } else if (peeked == CatspeakToken.DIVIDE_INT) {
                    cartWriter.emitDivideInt(lexer.getLocation());
                } else if (peeked == CatspeakToken.REMAINDER) {
                    cartWriter.emitRemainder(lexer.getLocation());
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
            lexer.next();
            __parseIndex();
            if (peeked == CatspeakToken.PLUS) {
                cartWriter.emitPositive(lexer.getLocation());
            } else if (peeked == CatspeakToken.MINUS) {
                cartWriter.emitNegative(lexer.getLocation());
            } else if (peeked == CatspeakToken.NOT) {
                cartWriter.emitNot(lexer.getLocation());
            } else if (peeked == CatspeakToken.BITWISE_NOT) {
                cartWriter.emitBitwiseNot(lexer.getLocation());
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
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.NUMBER) {
            lexer.next();
            cartWriter.emitConstNumber(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.STRING) {
            lexer.next();
            cartWriter.emitConstString(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.UNDEFINED) {
            lexer.next();
            cartWriter.emitConstUndefined(lexer.getLocation());
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            scope.emitGet(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            __catspeak_error_unimplemented("self");
            //cartWriter.emitSelf(lexer.getLocation());
        } else if (peeked == CatspeakToken.OTHER) {
            lexer.next();
            __catspeak_error_unimplemented("other");
            //cartWriter.emitSelf(lexer.getLocation());
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
                __ex("expected closing ')' after group expression");
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
            __ex("unexpected end of expression, expected one of: '(', '[' or '{'");
        }
    };

    /// @ignore
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    static __ex = function (msg = "no message") {
        __catspeak_error_v3(
            catspeak_location_show(lexer.getLocationStart(), cartWriter.path) + " during parsing",
            msg, ", got", __token
        );
    };

    /// @ignore
    static __tokenDebug = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.EOF) {
            return "end of file";
        } else if (peeked == CatspeakToken.SEMICOLON) {
            return "line break ';'";
        }
        return "token '" + lexer.getLexeme() + "' (" + string(peeked) + ")";
    };
}