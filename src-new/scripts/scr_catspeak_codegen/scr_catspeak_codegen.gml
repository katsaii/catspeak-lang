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
        __catspeak_check_var_exists("asg", asg, "functions");
        __catspeak_check_var_exists("asg", asg, "entryPoints");
        __catspeak_check_typeof("asg.functions", asg.functions, "array");
        __catspeak_check_typeof("asg.entryPoints", asg.entryPoints, "array");
    }

    self.functions = asg.functions;
    self.globals = { };
    //# feather disable once GM2043
    self.program = __compileFunctions(asg.entryPoints);

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
        return program;
    };


    /// @ignore
    ///
    /// @param {Array} entryPoints
    static __compileFunctions = function(entryPoints) {
        var n = array_length(entryPoints);
        if (n == 1) {
            return __compileFunction(functions[0]);
        } else {
            __catspeak_error_unimplemented("multiple-entry-points");
        }
    };

    /// @ignore
    ///
    /// @param {Struct} func
    static __compileFunction = function(func) {
        var ctx = {
            callTime : -1,
            program : undefined,
            self_ : undefined,
            locals : array_create(func.localCount),
            globals : globals,
        };
        ctx.program = __compileTerm(ctx, func.root);
        return method(ctx, __catspeak_function__);
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileValue = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "value");
        }

        return method({ value : term.value }, __catspeak_expr_value__);
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileBlock = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "terms");
            __catspeak_check_typeof("term.terms", term.terms, "array");
        }

        var terms = term.terms;
        var termCount = array_length(terms);
        if (termCount == 2) {
            return method({
                lhs : __compileTerm(ctx, terms[0]),
                rhs : __compileTerm(ctx, terms[1]),
            }, __catspeak_expr_seq__);
        }
        
        var exprs = array_create(termCount);
        for (var i = 0; i < termCount - 1; i += 1) {
            exprs[@ i] = __compileTerm(ctx, terms[i]);
        }
        var resultExpr = __compileTerm(ctx, terms[termCount - 1]);
        return method({
            exprs : exprs,
            n : termCount,
            result : resultExpr,
        }, __catspeak_expr_block__);
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileGlobalGet = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "name");
            __catspeak_check_typeof("term.name", term.name, "string");
        }

        return method({
            name : term.name,
            globals : globals,
        }, __catspeak_expr_global_get__);
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileGlobalSet = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "name");
            __catspeak_check_var_exists("term", term, "value");
            __catspeak_check_typeof("term.name", term.name, "string");
        }

        return method({
            globals : globals,
            name : term.name,
            value : __compileTerm(ctx, term.value),
        }, __catspeak_expr_global_set__);
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileLocalGet = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "idx");
            __catspeak_check_typeof_numeric("term.idx", term.idx);
        }

        return method({
            locals : ctx.locals,
            idx : term.idx,
        }, __catspeak_expr_local_get__);
    };

    /// @ignore
    ///
    /// @param {Struct} term
    static __compileLocalSet = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_var_exists("term", term, "idx");
            __catspeak_check_var_exists("term", term, "value");
            __catspeak_check_typeof_numeric("term.idx", term.idx);
        }

        return method({
            locals : ctx.locals,
            idx : term.idx,
            value : __compileTerm(ctx, term.value),
        }, __catspeak_expr_local_set__);
    };

    /// @ignore
    ///
    /// @param {Any} value
    static __compileTerm = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_typeof("term", term, "struct");
            __catspeak_check_var_exists("term", term, "type");
            __catspeak_check_typeof_numeric("term.type", term.type);
        }

        var prod = __productionLookup[term.type];
        if (CATSPEAK_DEBUG_MODE && prod == undefined) {
            __catspeak_error_bug();
        }
        return prod(ctx, term);
    };

    /// @ignore
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
    var isRecursing = callTime >= 0;
    if (isRecursing) {
        // catch unbound recursion
        __catspeak_timeout_check(callTime);
        // store the previous local variable array
        // this will make function recursion quite expensive, but
        // hopefully that's uncommon enough for it to not matter
        var localCount = array_length(locals);
        var oldLocals = array_create(localCount);
        array_copy(oldLocals, 0, locals, 0, localCount);
        // store previous self
        var oldSelf = self_;
    } else {
        callTime = current_time;
    }
    self_ = other;
    var value;
    try {
        value = program();
    } finally {
        if (isRecursing) {
            // bad practice to use `localCount_` here, but it saves
            // a tiny bit of time so I'll be a bit evil
            //# feather disable once GM2043
            array_copy(locals, 0, oldLocals, 0, localCount);
            //# feather disable once GM2043
            self_ = oldSelf;
        } else {
            // reset the timer
            callTime = -1;
        }
    }
    return value;
}

/// @ignore
function __catspeak_expr_value__() {
    return value;
}

/// @ignore
function __catspeak_expr_block__() {
    var i = 0;
    var exprs_ = exprs;
    var n_ = n;
    repeat (n_) {
        // not sure if this is even fast
        // but people will cry if I don't do it
        var expr = exprs_[i];
        expr();
        i += 1;
    }
    return result();
}

/// @ignore
function __catspeak_expr_seq__() {
    lhs();
    return rhs();
}

/// @ignore
function __catspeak_expr_global_get__() {
    return globals[$ name];
}

/// @ignore
function __catspeak_expr_global_set__() {
    globals[$ name] = value();
}

/// @ignore
function __catspeak_expr_local_get__() {
    return locals[idx];
}

/// @ignore
function __catspeak_expr_local_set__() {
    locals[@ idx] = value();
}