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
    //# feather disable once GM2043
    self.root = addValue(undefined);
    self.asg = {
        globals : globals,
        root : -1,
        terms : terms,
    };

    /// Returns the underlying syntax graph for this builder.
    ///
    /// @return {Struct}
    static get = function () {
        // patch the root before getting the asg
        asg.root = root;
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

        root = __mergeTerms(root, termId);
    };

    /// @ignore
    ///
    /// @param {Real} termAId
    /// @param {Real} termBId
    /// @return {Real}
    static __mergeTerms = function (termAId, termBId) {
        var termA = terms[termAId];
        if (termA.type == CatspeakTerm.VALUE) {
            return termBId;
        } else {
            __catspeak_error_unimplemented("other-terms");
        }
    }

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