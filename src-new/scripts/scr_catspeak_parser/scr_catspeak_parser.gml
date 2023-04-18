//! Responsible for the syntax analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// Consumes tokens produced by a [CatspeakLexer] and transforms them into an
/// abstract syntax graph representing a Catspeak program.
function CatspeakParser(lexer) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
        __catspeak_check_instanceof("lexer", lexer, "CatspeakLexer");
    }

    self.lexer = lexer;
    self.asg = undefined;

    /// Builds the syntax graph of the completed Catspeak program and returns
    /// it as a JSON struct.
    ///
    /// @return {Struct}
    static complete = function () {
        asg ??= { }; // TODO
        return asg;
    };
}