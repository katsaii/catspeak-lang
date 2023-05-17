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
/// @param {Struct.CatspeakASG} asg
///   The syntax graph to 
function CatspeakParser(lexer, asg) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_instanceof("lexer", lexer, "CatspeakLexer");
        __catspeak_check_instanceof("asg", asg, "CatspeakASG");
    }

    self.lexer = lexer;
    self.asg = asg;

    /// Returns `true` if the parser has reached the end of the file, or
    /// `false` if there is still more left to parse.
    ///
    /// @return {Bool}
    static empty = function () {
        return lexer.peek() == 0;
    };

    /// Parses a single Catspeak expression from the lexer and adds relevant
    /// parse information to the syntax graph.
    static parseExpression = function () {
        
    };
}

/// Handles the generation and optimisation of a syntax graph.
function CatspeakASGBuilder() constructor {
    self.globals = [];
    self.root = [];
    self.terms = [];
    self.globalsLookup = { };
    self.asg = {
        globals : self.globals,
        locals : self.locals,
        roots : self.roots,
        terms : self.terms,
    };

    /// Returns the underlying syntax graph for this builder.
    static get = function () {
        return asg;
    };

    /// Builds a new value term and returns its handle.
    ///
    /// @param {Any} value
    ///
    /// @return {Real}
    static addValue = function (value) {
        return __addTerm(CatspeakTerm.VALUE, {
            value : value
        });
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