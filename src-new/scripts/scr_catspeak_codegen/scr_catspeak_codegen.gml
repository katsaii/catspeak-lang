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
        __catspeak_check_var_exists("asg", asg, "root");
        __catspeak_check_var_exists("asg", asg, "localCount");
        __catspeak_check_typeof_numeric("asg.localCount", asg.localCount);
    }

    var funcBase = __catspeak_function__;
    if (asg.localCount < 1) {
        funcBase = __catspeak_function_simple__;
    }

    self.context = {
        callTime : -1,
        program : undefined,
        self_ : undefined,
        localCount : asg.localCount,
        locals : undefined,
        globals : { },
    };
    self.gmlFunc = method(self.context, funcBase);
    //# feather disable once GM2043
    self.context.program = __compileTerm(asg.root);

    /// Updates the compiler by generating the code for a single term from the
    /// supplied syntax graph. Returns the result of the compilation if there
    /// are no more terms to compile, or `undefined` if there are still more
    /// terms left to compile.
    ///
    /// @example
    ///   Creates a new [CatspeakGMLCompiler] from the variable `asg` and
    ///   loops until the compiler is finished compiling. The final result is
    ///   assigned to the `result` local variable.
    ///
    /// ```gml
    /// var compiler = new CatspeakGMLCompiler(asg);
    /// var result;
    /// do {
    ///     result = compiler.update();
    /// } until (result != undefined);
    /// ```
    ///
    /// @return {Function}
    static update = function () {
        return gmlFunc;
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileValue = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "value");
        }

        return method({ value : term.value }, function() {
            return value;
        });
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileBlock = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "terms");
            __catspeak_check_var_exists("term", term, "result");
            __catspeak_check_typeof("term.terms", term.terms, "array");
            __catspeak_check_typeof("term.result", term.result, "struct");
        }

        var terms = term.terms;
        var termCount = array_length(terms);
        var exprs = array_create(termCount);
        for (var i = 0; i < termCount; i += 1) {
            exprs[@ i] = __compileTerm(terms[i]);
        }
        var resultExpr = __compileTerm(term.result);
        return method({
            exprs : exprs,
            n : termCount,
            result : resultExpr,
        }, function() {
            var i = 0;
            repeat (n) {
                // not sure if this is even fast
                // but people will cry if I don't do it
                var expr = exprs[i];
                expr();
                i += 1;
            }
            return result();
        });
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileGlobalGet = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "name");
            __catspeak_check_typeof("term.name", term.name, "string");
        }

        return method({
            name : term.name,
            globals : context.globals,
        }, function() {
            return globals[$ name];
        });
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileGlobalSet = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "name");
            __catspeak_check_var_exists("term", term, "value");
            __catspeak_check_typeof("term.name", term.name, "string");
        }

        return method({
            globals : context.globals,
            name : term.name,
            value : __compileTerm(term.value),
        }, function() {
            var val = value();
            globals[$ name] = val;
            return val;
        });
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileLocalGet = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "idx");
            __catspeak_check_typeof_numeric("term.idx", term.idx);
        }

        return method({
            context : context,
            idx : term.name,
        }, function() {
            return context.locals[idx];
        });
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileLocalSet = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "idx");
            __catspeak_check_var_exists("term", term, "value");
            __catspeak_check_typeof_numeric("term.idx", term.idx);
        }

        return method({
            context : context,
            idx : term.name,
            value : __compileTerm(term.value),
        }, function() {
            var val = value();
            context.locals[@ idx] = val;
            return val;
        });
    };

    /// @ignore
    ///
    /// @param {Any} value
    static __compileTerm = function(term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof("term", term, "struct");
            __catspeak_check_var_exists("term", term, "type");
            __catspeak_check_typeof_numeric("term.type", term.type);
        }

        var prod = __productionLookup[term.type];
        if (CATSPEAK_DEBUG_MODE && prod == undefined) {
            __catspeak_error_bug();
        }
        return prod(term);
    };

    static __productionLookup = (function () {
        var db = array_create(CatspeakTerm.__SIZE__, undefined);
        db[@ CatspeakTerm.VALUE] = __compileValue;
        db[@ CatspeakTerm.BLOCK] = __compileBlock;
        db[@ CatspeakTerm.GET_GLOBAL] = __compileGlobalGet;
        db[@ CatspeakTerm.SET_GLOBAL] = __compileGlobalSet;
        db[@ CatspeakTerm.GET_LOCAL] = __compileLocalGet;
        db[@ CatspeakTerm.SET_LOCAL] = __compileLocalSet;
        return db;
    })();
}

/// @ignore
function __catspeak_function__() {
    var startTimer = callTime < 0;
    if (startTimer) {
        callTime = current_time;
    } else {
        // if the program runs for too long, crash instead of hanging
        __catspeak_timeout_check(callTime);
    }
    var oldLocals = locals;
    var localCount_ = localCount;
    locals = localCount_ > 0 ? array_create(localCount_) : undefined;
    var oldSelf = self_;
    self_ = other;
    var value;
    try {
        value = program();
    } finally {
        self_ = oldSelf;
        locals = oldLocals;
        if (startTimer) {
            // reset the timer
            callTime = -1;
        }
    }
    return value;
}

/// @ignore
function __catspeak_function_simple__() {
    return program();
}