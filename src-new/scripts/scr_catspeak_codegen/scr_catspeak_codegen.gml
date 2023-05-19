//! Responsible for the code generation stage of the Catspeak compiler.
//!
//! This stage converts the hierarchical representation of your Catspeak
//! programs, produced by [CatspeakParser] and [CatspeakASGBuilder], into
//! various lower-level formats. The most interesting of these formats is
//! the conversion of Catspeak programs into runnable GML functions.

//# feather use syntax-errors

/// The number of microseconds before a Catspeak program times out. The
/// default is 1 second.
#macro CATSPEAK_TIMEOUT 1000

/// @ignore
function __catspeak_timeout_check(t) {
    gml_pragma("forceinline");
    if (current_time - t > CATSPEAK_TIMEOUT) {
        __catspeak_error(
            "process exceeded allowed time of ", CATSPEAK_TIMEOUT, " ms"
        );
    }
}

/// Consumes an abstract syntax graph and converts it into a callable GML
/// function.
///
/// NOTE: Do not modify the the syntax graph whilst compilation is taking
///       place. This will cause undefined behaviour, potentially resulting
///       in hard to discover bugs!
///
/// @param {Struct} asg
///   The syntax graph to compile.
function CatspeakGMLCompiler(asg) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_var_exists("asg", asg, "globals");
        __catspeak_check_var_exists("asg", asg, "rootTerms");
        __catspeak_check_var_exists("asg", asg, "terms");
        __catspeak_check_typeof("asg.globals", asg.globals, "array");
        __catspeak_check_typeof("asg.rootTerms", asg.rootTerms, "array");
        __catspeak_check_typeof("asg.terms", asg.terms, "array");
    }

    self.globals = asg.globals;
    self.rootTerms = asg.rootTerms;
    self.rootCount = array_length(self.rootTerms);
    self.rootCurrent = 0;
    self.terms = asg.terms;
    self.program = array_create(rootCount);
    self.programContext = {
        startTime : -1,
        program : program,
        programCount : rootCount,
        self_ : undefined,
    };
    self.gmlFunc = method(self.programContext, __catspeak_function__);

    /// Returns `false` if the compiler has finished compiling, or `true` if
    /// there is still more left to compile.
    ///
    /// @return {Bool}
    static inProgress = function () {
        return rootCurrent < rootCount;
    };

    /// Compiles a single root term from the supplied syntax graph and writes
    /// it to the GML function.
    static update = function () {
        var term = terms[rootTerms[rootCurrent]];
        var expr = __compileValue(term.value);
        program[@ rootCurrent] = expr;
        rootCurrent += 1;
    };

    /// @ignore
    ///
    /// @param {Any} value
    static __compileValue = function(value) {
        return method({ value : value }, function() {
            return value;
        });
    };

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

/// @ignore
function __catspeak_function__() {
    var startTimer = startTime < 0;
    if (startTimer) {
        startTime = current_time;
    } else {
        __catspeak_timeout_check(startTime);
    }
    var oldSelf = self_;
    self_ = other;
    var lastValue = undefined;
    try {
        var i = 0;
        var program_ = program;
        repeat (programCount) {
            var f = program_[i];
            lastValue = f();
            i += 1;
        }
    } finally {
        self_ = oldSelf;
        if (startTimer) {
            // reset the timer
            startTime = -1;
        }
    }
    return lastValue;
}