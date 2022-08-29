//! Handles the parsing and codegen stage of the Catspeak compiler.

//# feather use syntax-errors

/// Creates a new Catspeak compiler, responsible for converting a stream of
/// `CatspeakToken` into executable code.
///
/// @param {Struct.CatspeakLexer} lexer
///   The iterator that yields tokens to be consumed by the compiler. Must
///   be a struct with at least a `next` method on it.
///
/// @param {Struct.CatspeakIR} [ir]
///   The Catspeak IR target to write code to, if left empty a new target is
///   created. This can be accessed using the `ir` field on a compiler
///   instance.
function CatspeakCompiler(lexer, ir) constructor {
    self.lexer = lexer;
    self.ir = ir;
    self.pos = new CatspeakLocation(0, 0);
    self.token = CatspeakToken.BOF;
    self.tokenLexeme = undefined;
    self.tokenPeeked = lexer.next();
    self.stateStack = [CatspeakCompilerState.PROGRAM, undefined];
    self.loopStack = [];

    /// Stages a new compiler production. Optionally takes a single value
    /// which can be used to pass arguments into this compiler state.
    ///
    /// @param {Enum.CatspeakCompilerState} state
    ///   The production to insert. Since this is a FIFO data structure, take
    ///   care to queue up states in reverse order of the expected execution.
    ///
    /// @param {Any} value
    ///   The value to use as a parameter to this state.
    static addState = function(state, value) {
        array_push(stateStack, state, value);
    }

    /// Performs `n`-many steps of the parsing and code generation process.
    /// The steps are discrete so that compilation can be paused if necessary,
    /// e.g. to avoid freezing the game for large files.
    ///
    /// @param {Real} [n]
    ///   The number of steps of codegen to perform, defaults to 1. Use `-1`
    ///   to peform all steps in a single frame. (Not recommended since large
    ///   loads may cause your game to pause.)
    static generateCode = function(n) {
        var state, stateArg {
            var stateStack_ = stateStack;
            stateArg = array_pop(stateStack_);
            state = array_pop(stateStack_);
        }
        
    }
}