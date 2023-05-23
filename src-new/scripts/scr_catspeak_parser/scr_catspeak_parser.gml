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
        asg.addRoot(__parseTerminal());
        return true;
    };

    /// @ignore
    /// @return {Real}
    static __parseTerminal = function () {
        var token = lexer.peek();
        if (token == CatspeakToken.STRING || token == CatspeakToken.NUMBER) {
            lexer.next();
            return asg.addValue(lexer.getValue(), lexer.getLocation());
        } else if (token == CatspeakToken.IDENT) {
            __catspeak_error_bug();
        } else if (token == CatspeakToken.EOF) {
            __ex("unexpected end of file");
        } else {
            __ex(
                "unexpected token '", lexer.getLexeme(),
                "' (", token,") in expression"
            );
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
            __catspeak_error(dbg, " -- ", msg);
        }
    }
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

        asg.root = __mergeTerms(asg.root, term);
    };

    /// @ignore
    ///
    /// @param {Real} termA
    /// @param {Real} termB
    /// @return {Real}
    static __mergeTerms = function (termA, termB) {
        if (termA.type == CatspeakTerm.VALUE) {
            return termB;
        } else {
            __catspeak_error_unimplemented("other-terms");
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
    __SIZE__
}