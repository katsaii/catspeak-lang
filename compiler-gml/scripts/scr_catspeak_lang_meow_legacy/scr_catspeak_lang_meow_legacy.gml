//! Responsible for the lexical analysis stage of the Catspeak compiler.
//! This stage converts UTF8 encoded text from individual characters into
//! discrete clusters of characters called [tokens](https://en.wikipedia.org/wiki/Lexical_analysis#Lexical_token_and_lexical_tokenization).

//# feather use syntax-errors

//! Responsible for the syntax analysis stage of the Catspeak compiler.
//!
//! This stage uses `CatspeakIRBuilder` to create a hierarchical
//! representation of your Catspeak programs, called an abstract syntax graph
//! (or ASG for short). These graphs are encoded as a JSON object, making it
//! possible for you to cache the result of parsing a mod to a file, instead
//! of re-parsing each time the game loads.

//# feather use syntax-errors

/// Consumes tokens produced by a `CatspeakLexerV3`, transforming the program
/// they represent into Catspeak IR. This Catspeak IR can be further compiled
/// down into a callable GML function using `CatspeakGMLCompiler`.
///
/// @experimental
///
/// @param {Struct.CatspeakLexerV3} lexer
///   The lexer to consume tokens from.
///
/// @param {Struct.CatspeakIRBuilder} builder
///   The Catspeak IR builder to write the program to.
function CatspeakParser(lexer, builder) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg_struct_instanceof(
                "lexer", lexer, "CatspeakLexerV3");
        __catspeak_check_arg_struct_instanceof(
                "builder", builder, "CatspeakIRBuilder");
    }
    /// @ignore
    self.lexer = lexer;
    /// @ignore
    self.ir = builder;
    /// @ignore
    self.finalised = false;
    builder.pushFunction();

    /// Parses a top-level Catspeak statement from the supplied lexer, adding
    /// any relevant parse information to the supplied IR.
    ///
    /// @example
    ///   Creates a new `CatspeakParser` from the variables `lexer` and
    ///   `builder`, then loops until there is nothing left to parse.
    ///
    ///   ```gml
    ///   var parser = new CatspeakParser(lexer, builder);
    ///   var moreToParse;
    ///   do {
    ///       moreToParse = parser.update();
    ///   } until (!moreToParse);
    ///   ```
    ///
    /// @return {Bool}
    ///   `true` if there is still more data left to parse, and `false`
    ///   if the parser has reached the end of the file.
    static update = function () {
        if (lexer.peek() == CatspeakTokenV3.EOF) {
            if (!finalised) {
                ir.popFunction();
                finalised = true;
            }
            return false;
        }
        if (CATSPEAK_DEBUG_MODE && finalised) {
            __catspeak_error(
                "attempting to update parser after it has been finalised"
            );
        }
        __parseStatement();
        return true;
    };

    /// @ignore
    static __parseStatement = function () {
        var result;
        var peeked = lexer.peek();
        if (peeked == CatspeakTokenV3.SEMICOLON) {
            lexer.next();
            return;
        } else if (peeked == CatspeakTokenV3.LET) {
            lexer.next();
            if (lexer.next() != CatspeakTokenV3.IDENT) {
                __ex("expected identifier after 'let' keyword");
            }
            var localName = lexer.getValue();
            var location = lexer.getLocation();
            var valueTerm;
            if (lexer.peek() == CatspeakTokenV3.ASSIGN) {
                lexer.next();
                valueTerm = __parseExpression();
            } else {
                valueTerm = ir.createValue(undefined, location);
            }
            var getter = ir.allocLocal(localName, location);
            result = ir.createAssign(
                CatspeakAssign.VANILLA,
                getter,
                valueTerm,
                lexer.getLocation()
            );
        } else {
            result = __parseExpression();
        }
        ir.createStatement(result);
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseExpression = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakTokenV3.RETURN) {
            lexer.next();
            peeked = lexer.peek();
            var value;
            if (
                peeked == CatspeakTokenV3.SEMICOLON ||
                peeked == CatspeakTokenV3.BRACE_RIGHT ||
                peeked == CatspeakTokenV3.LET
            ) {
                value = ir.createValue(undefined, lexer.getLocation());
            } else {
                value = __parseExpression();
            }
            return ir.createReturn(value, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.CONTINUE) {
            lexer.next();
            return ir.createContinue(lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.BREAK) {
            lexer.next();
            peeked = lexer.peek();
            var value;
            if (
                peeked == CatspeakTokenV3.SEMICOLON ||
                peeked == CatspeakTokenV3.BRACE_RIGHT ||
                peeked == CatspeakTokenV3.LET
            ) {
                value = ir.createValue(undefined, lexer.getLocation());
            } else {
                value = __parseExpression();
            }
            return ir.createBreak(value, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.THROW) {
            lexer.next();
            peeked = lexer.peek();
            var value = __parseExpression();
            return ir.createThrow(value, lexer.getLocation());
        } else {
            return __parseAssign();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseAssign = function () {
        var lhs = __parseCatch();
        var peeked = lexer.peek();
        if (
            peeked == CatspeakTokenV3.ASSIGN ||
            peeked == CatspeakTokenV3.ASSIGN_MULTIPLY ||
            peeked == CatspeakTokenV3.ASSIGN_DIVIDE ||
            peeked == CatspeakTokenV3.ASSIGN_SUBTRACT ||
            peeked == CatspeakTokenV3.ASSIGN_PLUS
        ) {
            lexer.next();
            var assignType = __catspeak_operator_assign_from_token(peeked);
            lhs = ir.createAssign(
                assignType,
                lhs,
                __parseExpression(),
                lexer.getLocation()
            );
        }
        return lhs;
    };
    
    /// @ignore
    ///
    /// @return {Struct}
    static __parseCatch = function () {
        var result = __parseExpressionBlock();
        while (true) {
            if (lexer.peek() == CatspeakTokenV3.CATCH) {
                lexer.next();
                ir.pushBlock();
                var localRef = undefined;
                if (lexer.peek() == CatspeakTokenV3.IDENT) {
                    lexer.next();
                    var localName = lexer.getValue();
                    localRef = ir.allocLocal(localName, lexer.getLocation());
                }
                __parseStatements("catch");
                var catchBlock_ = ir.popBlock();
                result = ir.createCatch(result, catchBlock_, localRef, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseExpressionBlock = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakTokenV3.DO) {
            lexer.next();
            ir.pushBlock(true);
            __parseStatements("do");
            return ir.popBlock();
        } else if (peeked == CatspeakTokenV3.IF) {
            lexer.next();
            var condition = __parseCondition();
            ir.pushBlock();
            __parseStatements("if")
            var ifTrue = ir.popBlock();
            var ifFalse;
            if (lexer.peek() == CatspeakTokenV3.ELSE) {
                lexer.next();
                ir.pushBlock();
                if (lexer.peek() == CatspeakTokenV3.IF) {
                    // for `else if` support
                    var elseIf = __parseExpression();
                    ir.createStatement(elseIf);
                } else {
                    __parseStatements("else");
                }
                ifFalse = ir.popBlock();
            } else {
                ifFalse = ir.createValue(undefined, lexer.getLocation());
            }
            return ir.createIf(condition, ifTrue, ifFalse, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.WHILE) {
            lexer.next();
            var condition = __parseCondition();
            ir.pushBlock();
            __parseStatements("while");
            var body = ir.popBlock();
            return ir.createWhile(condition, body, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.WITH) {
            lexer.next();
            var scope = __parseCondition();
            ir.pushBlock();
            __parseStatements("with");
            var body = ir.popBlock();
            return ir.createWith(scope, body, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.MATCH) {
            lexer.next();
            var value = __parseExpression();
            var conditions = __parseMatchArms();
            return ir.createMatch(value, conditions, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.FUN) {
            lexer.next();
            ir.pushFunction();
            if (lexer.peek() != CatspeakTokenV3.BRACE_LEFT) {
                if (lexer.next() != CatspeakTokenV3.PAREN_LEFT) {
                    __ex("expected opening '(' after 'fun' keyword");
                }
                while (__isNot(CatspeakTokenV3.PAREN_RIGHT)) {
                    if (lexer.next() != CatspeakTokenV3.IDENT) {
                        __ex("expected identifier in function arguments");
                    }
                    ir.allocArg(lexer.getValue(), lexer.getLocation());
                    if (lexer.peek() == CatspeakTokenV3.COMMA) {
                        lexer.next();
                    }
                }
                if (lexer.next() != CatspeakTokenV3.PAREN_RIGHT) {
                    __ex("expected closing ')' after function arguments");
                }
            }
            __parseStatements("fun");
            return ir.popFunction();
        } else {
            return __parseCondition();
        }
    };

    /// @ignore
    ///
    /// @param {String} keyword
    /// @return {Struct}
    static __parseStatements = function (keyword) {
        if (lexer.next() != CatspeakTokenV3.BRACE_LEFT) {
            __ex("expected opening '{' at the start of '", keyword, "' block");
        }
        while (__isNot(CatspeakTokenV3.BRACE_RIGHT)) {
            __parseStatement();
        }
        if (lexer.next() != CatspeakTokenV3.BRACE_RIGHT) {
            __ex("expected closing '}' after '", keyword, "' block");
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseCondition = function () {
        return __parseOpLogicalOR();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpLogicalOR = function () {
        var result = __parseOpLogicalAND();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakTokenV3.OR) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpLogicalAND();
                result = ir.createOr(lhs, rhs, lexer.getLocation());
            } else if (peeked == CatspeakTokenV3.XOR) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpLogicalAND();
                result = ir.createBinary(CatspeakOperator.XOR, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpLogicalAND = function () {
        var result = __parseOpPipe();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakTokenV3.AND) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpPipe();
                result = ir.createAnd(lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpPipe = function () {
        var result = __parseOpEquality();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakTokenV3.PIPE_RIGHT) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpEquality();
                result = ir.createCall(rhs, [lhs], lexer.getLocation());
            } else if (peeked == CatspeakTokenV3.PIPE_LEFT) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpEquality();
                result = ir.createCall(lhs, [rhs], lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpEquality = function () {
        var result = __parseOpRelational();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakTokenV3.EQUAL ||
                peeked == CatspeakTokenV3.NOT_EQUAL
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpRelational();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpRelational = function () {
        var result = __parseOpBitwise();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakTokenV3.LESS ||
                peeked == CatspeakTokenV3.LESS_EQUAL ||
                peeked == CatspeakTokenV3.GREATER ||
                peeked == CatspeakTokenV3.GREATER_EQUAL
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpBitwise();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };


    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpBitwise = function () {
        var result = __parseOpAdd();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakTokenV3.BITWISE_AND ||
                peeked == CatspeakTokenV3.BITWISE_XOR ||
                peeked == CatspeakTokenV3.BITWISE_OR ||
                peeked == CatspeakTokenV3.SHIFT_LEFT ||
                peeked == CatspeakTokenV3.SHIFT_RIGHT
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpAdd();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };
    
    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpAdd = function () {
        var result = __parseOpMultiply();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakTokenV3.PLUS ||
                peeked == CatspeakTokenV3.SUBTRACT
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpMultiply();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpMultiply = function () {
        var result = __parseOpUnary();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakTokenV3.MULTIPLY ||
                peeked == CatspeakTokenV3.DIVIDE ||
                peeked == CatspeakTokenV3.DIVIDE_INT ||
                peeked == CatspeakTokenV3.REMAINDER
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpUnary();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpUnary = function () {
        var peeked = lexer.peek();
        if (
            peeked == CatspeakTokenV3.NOT ||
            peeked == CatspeakTokenV3.BITWISE_NOT ||
            peeked == CatspeakTokenV3.SUBTRACT ||
            peeked == CatspeakTokenV3.PLUS
        ) {
            lexer.next();
            var op = __catspeak_operator_from_token(peeked);
            var value = __parseIndex();
            return ir.createUnary(op, value, lexer.getLocation());
        //} else if (peeked == CatspeakTokenV3.COLON) {
        //    // `:property` syntax
        //    lexer.next();
        //    return ir.createProperty(__parseTerminal(), lexer.getLocation());
        } else {
            return __parseIndex();
        }
    };
    
    /// @ignore
    ///
    /// @return {Array}
    static __parseMatchArms = function () {
        if (lexer.next() != CatspeakTokenV3.BRACE_LEFT) {
            __ex("expected opening '{' before 'match' arms");
        }
        var conditions = [];
        while (__isNot(CatspeakTokenV3.BRACE_RIGHT)) {
            var value;
            var prefix = lexer.next();
            if (prefix == CatspeakTokenV3.ELSE) {
                value = undefined;
            } else if (lexer.getLexeme() != "case") {
                __ex("expected 'case' keyword before non-default match arm");
            } else {
                value = __parseExpression();
            }
            ir.pushBlock();
            __parseStatements("case");
            var result = ir.popBlock();
            array_push(conditions, [value, result]);
        }
        if (lexer.next() != CatspeakTokenV3.BRACE_RIGHT) {
            __ex("expected closing '}' after 'match' arm");
        }
        return conditions;
    }

    /// @ignore
    ///
    /// @return {Struct}
    static __parseIndex = function () {
        var callNew = lexer.peek() == CatspeakTokenV3.NEW;
        if (callNew) {
            lexer.next();
        }
        var result = __parseTerminal();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakTokenV3.PAREN_LEFT) {
                // function call syntax
                lexer.next();
                var args = [];
                while (__isNot(CatspeakTokenV3.PAREN_RIGHT)) {
                    array_push(args, __parseExpression());
                    if (lexer.peek() == CatspeakTokenV3.COMMA) {
                        lexer.next();
                    }
                }
                if (lexer.next() != CatspeakTokenV3.PAREN_RIGHT) {
                    __ex("expected closing ')' after function arguments");
                }
                result = callNew
                        ? ir.createCallNew(result, args, lexer.getLocation())
                        : ir.createCall(result, args, lexer.getLocation());
                callNew = false;
            } else if (peeked == CatspeakTokenV3.BOX_LEFT) {
                // accessor syntax
                lexer.next();
                var collection = result;
                var key = __parseExpression();
                if (lexer.next() != CatspeakTokenV3.BOX_RIGHT) {
                    __ex("expected closing ']' after accessor expression");
                }
                result = ir.createAccessor(collection, key, lexer.getLocation());
            } else if (peeked == CatspeakTokenV3.DOT) {
                // dot accessor syntax
                lexer.next();
                var collection = result;
                if (lexer.next() != CatspeakTokenV3.IDENT) {
                    __ex("expected identifier after '.' operator");
                }
                var key = ir.createValue(lexer.getValue(), lexer.getLocation());
                result = ir.createAccessor(collection, key, lexer.getLocation());
            } else {
                break;
            }
        }
        if (callNew) {
            // implicit new: `let t = new Thing;`
            result = ir.createCallNew(result, [], lexer.getLocation());
        }
        return result;
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (
            peeked == CatspeakTokenV3.VALUE_NUMBER ||
            peeked == CatspeakTokenV3.VALUE_STRING ||
            peeked == CatspeakTokenV3.VALUE_UNDEFINED
        ) {
            lexer.next();
            return ir.createValue(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.IDENT) {
            lexer.next();
            return ir.createGet(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.SELF) {
            lexer.next();
            return ir.createSelf(lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.OTHER) {
            lexer.next();
            return ir.createOther(lexer.getLocation());
        } else {
            return __parseGrouping();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseGrouping = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakTokenV3.PAREN_LEFT) {
            lexer.next();
            var inner = __parseExpression();
            if (lexer.next() != CatspeakTokenV3.PAREN_RIGHT) {
                __ex("expected closing ')' after group expression");
            }
            return inner;
        } else if (peeked == CatspeakTokenV3.BOX_LEFT) {
            lexer.next();
            var values = [];
            while (__isNot(CatspeakTokenV3.BOX_RIGHT)) {
                array_push(values, __parseExpression());
                if (lexer.peek() == CatspeakTokenV3.COMMA) {
                    lexer.next();
                }
            }
            if (lexer.next() != CatspeakTokenV3.BOX_RIGHT) {
                __ex("expected closing ']' after array literal");
            }
            return ir.createArray(values, lexer.getLocation());
        } else if (peeked == CatspeakTokenV3.BRACE_LEFT) {
            lexer.next();
            var values = [];
            while (__isNot(CatspeakTokenV3.BRACE_RIGHT)) {
                var key;
                var keyToken = lexer.next();
                if (keyToken == CatspeakTokenV3.BOX_LEFT) {
                    key = __parseExpression();
                    if (lexer.next() != CatspeakTokenV3.BOX_RIGHT) {
                        __ex(
                            "expected closing ']' after computed struct key"
                        );
                    }
                } else if (
                    keyToken == CatspeakTokenV3.IDENT ||
                    keyToken == CatspeakTokenV3.VALUE_NUMBER ||
                    keyToken == CatspeakTokenV3.VALUE_STRING ||
                    keyToken == CatspeakTokenV3.VALUE_UNDEFINED
                ) {
                    key = ir.createValue(lexer.getValue(), lexer.getLocation());
                } else {
                    __ex("expected identifier or value as struct key");
                }
                var value;
                if (lexer.peek() == CatspeakTokenV3.COLON) {
                    lexer.next();
                    value = __parseExpression();
                } else if (keyToken == CatspeakTokenV3.IDENT) {
                    value = ir.createGet(key.value, lexer.getLocation());
                } else {
                    __ex(
                        "expected ':' between key and value ",
                        "of struct literal"
                    );
                }
                if (lexer.peek() == CatspeakTokenV3.COMMA) {
                    lexer.next();
                }
                array_push(values, key, value);
            }
            if (lexer.next() != CatspeakTokenV3.BRACE_RIGHT) {
                __ex("expected closing '}' after struct literal");
            }
            return ir.createStruct(values, lexer.getLocation());
        } else {
            __ex("malformed expression, expected: '(', '[' or '{'");
        }
    };

    /// @ignore
    ///
    /// @param {String} ...
    static __ex = function () {
        var dbg = __catspeak_location_show(lexer.getLocation(), ir.filepath) + " when parsing";
        if (argument_count < 1) {
            __catspeak_error(dbg);
        } else {
            var msg = "";
            for (var i = 0; i < argument_count; i += 1) {
                msg += __catspeak_string(argument[i]);
            }
            __catspeak_error(dbg, " -- ", msg, ", got ", __tokenDebug());
        }
    };

    /// @ignore
    ///
    /// @return {String}
    static __tokenDebug = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakTokenV3.EOF) {
            return "end of file";
        } else if (peeked == CatspeakTokenV3.SEMICOLON) {
            return "line break ';'";
        }
        return "token '" + lexer.getLexeme() + "' (" + string(peeked) + ")";
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakTokenV3} expect
    /// @return {Bool}
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakTokenV3.EOF;
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakTokenV3} expect
    /// @return {Bool}
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakTokenV3.EOF;
    };
}