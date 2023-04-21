//! Responsible for the syntax analysis stage of the Catspeak compiler.
//!
//! This stage creates a hierarchical representation of your Catspeak programs
//! called an abstract syntax graph, or ASG for short. These graphs are
//! encoded as a JSON object, making it possible for you to cache the result
//! of parsing a mod to a file, instead of re-parsing each time the game loads.

//# feather use syntax-errors

/// Consumes tokens produced by a [CatspeakLexer] and transforms them into an
/// abstract syntax graph representing a Catspeak program.
///
/// @param {Struct.CatspeakLexer} lexer
///   The lexer to consume tokens from.
function CatspeakParser(lexer) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_instanceof("lexer", lexer, "CatspeakLexer");
    }

    self.lexer = lexer;

    /// Returns `true` if the parser has reached the end of the file, or
    /// `false` if there is still more left to parse.
    ///
    /// @return {Bool}
    static empty = function () {
        return lexer.peek() == 0;
    };

    /// Parses a single Catspeak expression from the lexer and adds its data
    /// to the supplied syntax graph.
    static parseExpression = function (builder) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_instanceof("builder", builder, "CatspeakASGBuilder");
        }
    };
}

/// Handles the generation and optimisation of a syntax graph.
function CatspeakASGBuilder() constructor {
    self.globals = asg.globals;
    self.locals = asg.locals;
    self.roots = asg.roots;
    self.terms = asg.terms;
    self.asg = undefined;

    /// 
    static finalise = function () {
        asg ??= {
            globals : globals,
            locals : locals,
            roots : roots,
            terms : terms,
        };
        return asg;
    };
}