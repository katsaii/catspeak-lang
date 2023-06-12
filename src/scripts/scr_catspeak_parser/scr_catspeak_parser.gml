//! Responsible for the syntax analysis stage of the Catspeak compiler.
//!
//! This stage creates a hierarchical representation of your Catspeak programs,
//! called an abstract syntax graph (or ASG for short). These graphs are
//! encoded as a JSON object, making it possible for you to cache the result
//! of parsing a mod to a file, instead of re-parsing each time the game loads.

//# feather use syntax-errors

/// Consumes tokens produced by a [CatspeakLexer] and transforms them into an
/// abstract syntax graph representing a Catspeak program.
///
/// @param {Struct.CatspeakLexer} lexer
///   The lexer to consume tokens from.
///
/// @param {Struct.CatspeakASGBuilder} builder
///   The syntax graph builder to write data to.
function CatspeakParser(lexer, builder) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg_struct_instanceof(
                "lexer", lexer, "CatspeakLexer");
        __catspeak_check_arg_struct_instanceof(
                "builder", builder, "CatspeakASGBuilder");
    }

    self.lexer = lexer;
    self.asg = builder;
    self.finalised = false;
    builder.pushFunction();

    /// Updates the parser by parsing a simple Catspeak expression from the
    /// supplied lexer, adding any relevant parse information to the supplied
    /// syntax graph.
    ///
    /// Returns `true` if there is still more data left to parse, and `false`
    /// if the parser has reached the end of the file.
    ///
    /// @example
    ///   Creates a new [CatspeakParser] from the variables `lexer` and
    ///   `builder`, then loops until there is nothing left to parse.
    ///
    /// ```gml
    /// var parser = new CatspeakParser(lexer, builder);
    /// var moreToParse;
    /// do {
    ///     moreToParse = parser.update();
    /// } until (!moreToParse);
    /// ```
    ///
    /// @return {Function}
    static update = function () {
        if (lexer.peek() == CatspeakToken.EOF) {
            if (!finalised) {
                asg.popFunction();
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
        if (peeked == CatspeakToken.BREAK_LINE) {
            lexer.next();
            return;
        } else if (peeked == CatspeakToken.LET) {
            lexer.next();
            if (lexer.next() != CatspeakToken.IDENT) {
                __ex("expected identifier after 'let' keyword");
            }
            var localName = lexer.getValue();
            var location = lexer.getLocation();
            var valueTerm;
            if (lexer.peek() == CatspeakToken.ASSIGN) {
                lexer.next();
                valueTerm = __parseExpression();
            } else {
                valueTerm = asg.createValue(undefined, location);
            }
            var getter = asg.allocLocal(localName, location);
            result = asg.createAssign(getter, valueTerm);
        } else {
            result = __parseExpression();
        }
        asg.createStatement(result);
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseExpression = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.RETURN) {
            lexer.next();
            peeked = lexer.peek();
            var value;
            if (
                peeked == CatspeakToken.BREAK_LINE ||
                peeked == CatspeakToken.BRACE_RIGHT
            ) {
                value = asg.createValue(undefined, lexer.getLocation());
            } else {
                value = __parseExpression();
            }
            return asg.createReturn(value, lexer.getLocation());
        } else if (peeked == CatspeakToken.CONTINUE) {
            lexer.next();
            return asg.createContinue(lexer.getLocation());
        } else if (peeked == CatspeakToken.BREAK) {
            lexer.next();
            peeked = lexer.peek();
            var value;
            if (
                peeked == CatspeakToken.BREAK_LINE ||
                peeked == CatspeakToken.BRACE_RIGHT
            ) {
                value = asg.createValue(undefined, lexer.getLocation());
            } else {
                value = __parseExpression();
            }
            return asg.createBreak(value, lexer.getLocation());
        } else if (peeked == CatspeakToken.DO) {
            lexer.next();
            asg.pushBlock(true);
            __parseStatements("do");
            return asg.popBlock();
        } else if (peeked == CatspeakToken.IF) {
            lexer.next();
            var condition = __parseCondition();
            asg.pushBlock();
            __parseStatements("if")
            var ifTrue = asg.popBlock();
            var ifFalse;
            if (lexer.peek() == CatspeakToken.ELSE) {
                lexer.next();
                asg.pushBlock();
                __parseStatements("else");
                ifFalse = asg.popBlock();
            } else {
                ifFalse = asg.createValue(undefined, lexer.getLocation());
            }
            return asg.createIf(condition, ifTrue, ifFalse);
        } else if (peeked == CatspeakToken.WHILE) {
            lexer.next();
            var condition = __parseCondition();
            asg.pushBlock();
            __parseStatements("while")
            var body = asg.popBlock();
            return asg.createWhile(condition, body);
        } else if (peeked == CatspeakToken.FUN) {
            lexer.next();
            asg.pushFunction();
            __parseStatements("fun");
            return asg.popFunction();
        } else {
            return __parseAssign();
        }
    };

    /// @ignore
    ///
    /// @param {String} keyword
    /// @return {Struct}
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

    static __parseCondition = function () {
        return __parseAssign();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseAssign = function () {
        var lhs = __parseOpLogical();
        if (lexer.peek() == CatspeakToken.ASSIGN) {
            lexer.next();
            lhs = asg.createAssign(lhs, __parseExpression());
        }
        // TODO :: *= /= += -=
        return lhs;
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpLogical = function () {
        // TODO :: and or
        return __parseOpUnary();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpBitwise = function () {
        // TODO :: | ^ &
        return __parseOpBitwiseShift();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpBitwiseShift = function () {
        // TODO :: << >>
        return __parseOpEquality();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpEquality = function () {
        // TODO :: == !=
        return __parseOpRelational();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpRelational = function () {
        // TODO :: == !=
        return __parseOpAdd();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpAdd = function () {
        // TODO :: + -
        return __parseOpMultiply();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpMultiply = function () {
        // TODO :: * / // %
        return __parseOpUnary();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpUnary = function () {
        var peeked = lexer.peek();
        if (
            peeked == CatspeakToken.NOT ||
            peeked == CatspeakToken.SUBTRACT ||
            peeked == CatspeakToken.PLUS
        ) {
            lexer.next();
            var op = __catspeak_operator_from_token(peeked);
            var value = __parseIndex();
            return asg.createUnary(op, value, lexer.getLocation());
        } else {
            return __parseIndex();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseIndex = function () {
        var result = __parseTerminal();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.PAREN_LEFT) {
                // function call syntax
                lexer.next();
                var args = [];
                if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                    __ex("expected closing ')' after function arguments");
                }
                result = asg.createCall(result, args, lexer.getLocation());
            } else if (peeked == CatspeakToken.BOX_LEFT) {
                // accessor syntax
                lexer.next();
                var collection = result;
                var key = __parseExpression();
                if (lexer.next() != CatspeakToken.BOX_RIGHT) {
                    __ex("expected closing ']' after accessor expression");
                }
                result = asg.createAccessor(collection, key, lexer.getLocation());
            } else if (peeked == CatspeakToken.DOT) {
                // dot accessor syntax
                lexer.next();
                var collection = result;
                if (lexer.next() != CatspeakToken.IDENT) {
                    __ex("expected identifier after '.' operator");
                }
                var key = asg.createValue(lexer.getValue(), lexer.getLocation());
                result = asg.createAccessor(collection, key, lexer.getLocation());
            } else {
                break;
            }
        }
        return result;
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.VALUE) {
            lexer.next();
            return asg.createValue(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            return asg.createGet(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            return asg.createSelf(lexer.getLocation());
        } else {
            return __parseGrouping();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseGrouping = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            var inner = __parseExpression();
            if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                __ex("expected closing ')' after group expression");
            }
            return inner;
        } else if (peeked == CatspeakToken.BOX_LEFT) {
            lexer.next();
            var values = [];
            while (__isNot(CatspeakToken.BOX_RIGHT)) {
                array_push(values, __parseExpression());
                if (lexer.peek() == CatspeakToken.COMMA) {
                    lexer.next();
                }
            }
            if (lexer.next() != CatspeakToken.BOX_RIGHT) {
                __ex("expected closing ']' after array literal");
            }
            return asg.createArray(values, lexer.getLocation());
        } else if (peeked == CatspeakToken.BRACE_LEFT) {
            lexer.next();
            var values = [];
            while (__isNot(CatspeakToken.BRACE_RIGHT)) {
                var key;
                var keyToken = lexer.next();
                if (keyToken == CatspeakToken.BOX_LEFT) {
                    key = __parseExpression();
                    if (lexer.next() != CatspeakToken.BOX_RIGHT) {
                        __ex(
                            "expected closing ']' after computed struct key"
                        );
                    }
                } else if (
                    keyToken == CatspeakToken.IDENT ||
                    keyToken == CatspeakToken.VALUE
                ) {
                    key = asg.createValue(lexer.getValue(), lexer.getLocation());
                } else {
                    __ex("expected identifier or value as struct key");
                }
                var value;
                if (lexer.peek() == CatspeakToken.COLON) {
                    lexer.next();
                    value = __parseExpression();
                } else if (keyToken == CatspeakToken.IDENT) {
                    value = asg.createGet(key.value, lexer.getLocation());
                } else {
                    __ex(
                        "expected ':' between key and value ",
                        "of struct literal"
                    );
                }
                if (lexer.peek() == CatspeakToken.COMMA) {
                    lexer.next();
                }
                array_push(values, key, value);
            }
            if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
                __ex("expected closing '}' after struct literal");
            }
            return asg.createStruct(values, lexer.getLocation());
        } else {
            __ex("malformed expression, expected: '(', '[' or '{'");
        }
    };

    /// @ignore
    ///
    /// @param {String} ...
    static __ex = function () {
        var dbg = __catspeak_location_show(lexer.getLocation()) + " when parsing";
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
        if (peeked == CatspeakToken.EOF) {
            return "end of file";
        } else if (peeked == CatspeakToken.BREAK_LINE) {
            return "line break ';'";
        }
        return "token '" + lexer.getLexeme() + "' (" + string() + ")";
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakToken.EOF;
    };
}