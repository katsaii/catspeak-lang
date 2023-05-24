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
        __catspeak_check_instanceof("lexer", lexer, "CatspeakLexer");
        __catspeak_check_instanceof("builder", builder, "CatspeakASGBuilder");
    }

    self.lexer = lexer;
    self.asg = builder;

    /// Enables or disables any additional features for this parser, according
    /// to the supplied feature flags.
    ///
    /// @param {Enum.CatspeakFeature} featureFlags
    ///   An instance of [CatspeakFeature] specifying which features to enable.
    ///
    /// @return {Struct}
    static withFeatures = function (featureFlags) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof_numeric("featureFlags", featureFlags);
        }

        return self;
    };

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
            return false;
        }
        asg.addRoot(__parseExpression());
        return true;
    };

    /// @ignore
    /// @return {Struct}
    static __parseExpression = function() {
        return __parseTerminal();
    };

    /// @ignore
    /// @return {Struct}
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.STRING || peeked == CatspeakToken.NUMBER) {
            lexer.next();
            return asg.addValue(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.IDENT) {
            __catspeak_error_bug();
        } else {
            return __parseGrouping();
        }
    };

    /// @ignore
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
        } else if (peeked == CatspeakToken.DO) {
            lexer.next();
            if (lexer.next() != CatspeakToken.BRACE_LEFT) {
                __ex("expected opening '{' after 'do' keyword");
            }
            var inner = asg.addValue(undefined, lexer.getLocation());
            while (__isNot(CatspeakToken.BRACE_RIGHT)) {
                inner = asg.mergeTerms(inner, __parseExpression());
            }
            if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
                __ex("expected closing '}' after 'do' block");
            }
            return inner;
        } else {
            __ex("malformed expression");
        }
    };

    /// @ignore
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
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakToken.EOF;
    };
}

/// Handles the generation and optimisation of a syntax graph.
function CatspeakASGBuilder() constructor {
    self.asg = {
        localCount : 0,
        root : undefined,
    };
    //# feather disable once GM2043
    self.asg.root = addValue(undefined);

    /// Returns the underlying syntax graph for this builder.
    ///
    /// @return {Struct}
    static get = function () {
        return asg;
    };

    /// Builds a new value term and returns its handle.
    ///
    /// @param {Any} value
    ///   The value this term should resolve to.
    ///
    /// @param {Real} [location]
    ///   The value this term should resolve to.
    ///
    /// @return {Real}
    static addValue = function (value, location=undefined) {
        return __createTerm(CatspeakTerm.VALUE, location, {
            value : value
        });
    };

    /// Adds an existing node to the program's root node.
    ///
    /// @param {Real} term
    ///   The term to register to the root node.
    static addRoot = function (term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof("term", term, "struct");
            __catspeak_check_var_exists("term", term, "type");
            __catspeak_check_typeof_numeric("term.type", term.type);
        }

        asg.root = mergeTerms(asg.root, term);
    };

    /// Composes two terms together, producing a new term where term A
    /// executes first, followed by term B.
    ///
    /// NOTE: Either terms A or B could be optimised or modified, therefore
    ///       you should always treat both terms as being invalid after
    ///       calling this method. Always use the result returned by this
    ///       method as the new source of truth.
    ///
    /// @param {Real} termA
    ///   The term to execute first.
    ///
    /// @param {Real} termB
    ///   The term to execute second.
    ///
    /// @return {Real}
    static mergeTerms = function (termA, termB) {
        var aType = termA.type;
        var bType = termB.type;
        var aIsBlock = aType == CatspeakTerm.BLOCK;
        var bIsBlock = bType == CatspeakTerm.BLOCK;
        if (aIsBlock && !bIsBlock) {
            if (termA.result.type != CatspeakTerm.VALUE) {
                array_push(termA.terms, termA.result);
            }
            termA.result = termB;
            return termA;
        } else if (aIsBlock && bIsBlock) {
            var aTerms = termA.terms;
            var bTerms = termB.terms;
            var aResult = termA.result;
            if (aResult.type == CatspeakTerm.VALUE) {
                array_push(aTerms, aResult);
            }
            array_copy(
                aTerms, array_length(aTerms),
                bTerms, 0, array_length(bTerms)
            );
            termA.result = termB.result;
            return termA;
        } else if (aType == CatspeakTerm.VALUE) {
            return termB;
        } else if (!aIsBlock && bIsBlock) {
            // hoping that this doesn't happen often
            array_insert(termB.terms, 0, termA);
            return termB;
        } else {
            return __createTerm(CatspeakTerm.BLOCK, termA.location, {
                terms : [termA],
                result : termB,
            });
        }
    }

    /// @ignore
    ///
    /// @param {Enum.CatspeakTerm} term
    /// @param {Real} location
    /// @param {Struct} container
    /// @return {Struct}
    static __createTerm = function (term, location, container) {
        container.type = term;
        if (location != undefined) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_size_bits("location", location, 32);
            }

            container.dbg = location;
        }
        return container;
    };
}

/// Indicates the type of term within a Catspeak syntax graph.
enum CatspeakTerm {
    VALUE,
    BLOCK,
    __SIZE__
}