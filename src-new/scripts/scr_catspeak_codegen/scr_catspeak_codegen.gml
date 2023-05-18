//! Responsible for the code generation stage of the Catspeak compiler.
//!
//! This stage converts the hierarchical representation of your Catspeak
//! programs, produced by [CatspeakParser] and [CatspeakASGBuilder], into
//! various lower-level formats. The most interesting of these formats is
//! the conversion of Catspeak programs into runnable GML functions.

//# feather use syntax-errors

/// Consumes an abstract syntax graph and converts it into a callable GML
/// function.
///
/// @param {Struct} asg
///   The syntax graph to compile.
function CatspeakGMLCompiler(asg) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_var_exists("asg", asg, "globals");
        __catspeak_check_var_exists("asg", asg, "root");
        __catspeak_check_var_exists("asg", asg, "terms");
        __catspeak_check_typeof("asg.globals", asg.globals, "array");
        __catspeak_check_typeof("asg.root", asg.root, "array");
        __catspeak_check_typeof("asg.terms", asg.terms, "array");
    }

    self.globals = asg.globals;
    self.root = asg.root;
    self.terms = asg.terms;
    self.gmlFunc = 

    /// Returns the compiled GML function.
    ///
    /// NOTE: If you attempt to call this function before compilation is
    ///       complete, then it will be undefined behaviour in release mode.
    ///
    /// @return {Function}
    static get = function () {
        return gmlFunc;
    };
}