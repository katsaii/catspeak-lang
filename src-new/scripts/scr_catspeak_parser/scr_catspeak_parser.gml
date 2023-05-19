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
    self.total = false;

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

        total = (featureFlags & CatspeakFeature.TOTAL) != 0;
        return self;
    };

    /// Returns `false` if the parser has reached the end of the file, or
    /// `true` if there is still more left to parse.
    ///
    /// @return {Bool}
    static inProgress = function () {
        return lexer.peek() != CatspeakToken.EOF;
    };

    /// Parses a single Catspeak expression from the lexer and adds relevant
    /// parse information to the syntax graph.
    static update = function () {
        var term = __parseTerminal();
        asg.addRoot(term);
    };

    /// @ignore
    /// @return {Real}
    static __parseTerminal = function () {
        var token = lexer.peek();
        if (token == CatspeakToken.STRING || token == CatspeakToken.NUMBER) {
            lexer.next();
            return asg.addValue(lexer.getValue());
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
    self.globals = [];
    self.terms = [];
    self.rootTerms = [];
    self.asg = {
        globals : globals,
        rootTerms : rootTerms,
        terms : terms,
    };

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
    /// @return {Real}
    static addValue = function (value) {
        return __addTerm(CatspeakTerm.VALUE, {
            value : value
        });
    };

    /// Adds an existing node to the program's root node.
    ///
    /// @param {Real} termId
    ///   The term to register to the root node.
    static addRoot = function (termId) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof_numeric("termId", termId);
        }

        array_push(rootTerms, termId);
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakTerm} term
    /// @param {Struct} container
    /// @return {Real}
    static __addTerm = function (term, container) {
        container.type = term;
        var idx = array_length(terms);
        array_push(terms, container);
        return idx;
    };
}

/// Indicates the type of term within a Catspeak syntax graph.
enum CatspeakTerm {
    VALUE
}