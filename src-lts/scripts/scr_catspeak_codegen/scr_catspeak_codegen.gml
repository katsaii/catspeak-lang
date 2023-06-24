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

/// @ignore
///
/// @param {Any} val
function __catspeak_is_withable(val) {
    if (is_struct(val) || val == self || val == other) {
        return true;
    }
    var isInst = false;
    try {
        isInst = !object_exists(val) && instance_exists(val);
    } catch (_) { }
    return isInst;
}

/// Consumes an abstract syntax graph and converts it into a callable GML
/// function.
///
/// NOTE: Do not modify the the syntax graph whilst compilation is taking
///       place. This will cause undefined behaviour, potentially resulting
///       in hard to discover bugs!
///
/// @unstable
///
/// @param {Struct} asg
///   The syntax graph to compile.
///
/// @param {Struct} [interface]
///   The native interface to use.
function CatspeakGMLCompiler(asg, interface=undefined) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
        __catspeak_check_arg_struct("asg", asg,
            "functions", is_array,
            "entryPoints", is_array
        );
    }
    self.interface = interface ?? { };
    self.functions = asg.functions;
    self.sharedData = {
        globals : { },
        self_ : undefined,
    };
    //# feather disable once GM2043
    self.program = __compileFunctions(asg.entryPoints);
    self.finalised = false;

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
        if (CATSPEAK_DEBUG_MODE && finalised) {
            __catspeak_error(
                "attempting to update gml compiler after it has been finalised"
            );
        }
        finalised = true;
        return program;
    };

    /// @ignore
    ///
    /// @param {Array} entryPoints
    /// @return {Function}
    static __compileFunctions = function (entryPoints) {
        var functions_ = functions;
        var entryCount = array_length(entryPoints);
        var exprs = array_create(entryCount);
        for (var i = 0; i < entryCount; i += 1) {
            var entry = entryPoints[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("entry", entry, is_numeric);
            }
            exprs[@ i] = __compileFunction(functions_[entry]);
        }
        var rootCall = __emitBlock(exprs);
        __setupRootCall(rootCall);
        return rootCall;
    };

    static __setupRootCall = function (f) {
        f.setSelf = method(sharedData, function (selfInst) {
            self_ = catspeak_special_to_struct(selfInst);
        });
        f.setGlobals = method(sharedData, function (globalInst) {
            globals = catspeak_special_to_struct(globalInst);
        });
        f.getSelf = method(sharedData, function () { return self_ ?? globals });
        f.getGlobals = method(sharedData, function () { return globals });
    };

    /// @ignore
    ///
    /// @param {Struct} func
    /// @return {Function}
    static __compileFunction = function (func) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("func", func,
                "localCount", is_numeric,
                "argCount", is_numeric,
                "root", undefined
            );
            __catspeak_check_arg_struct("func.root", func.root,
                "type", is_numeric
            );
        }
        var ctx = {
            callTime : -1,
            program : undefined,
            locals : array_create(func.localCount),
            argCount : func.argCount,
        };
        ctx.program = __compileTerm(ctx, func.root);
        if (__catspeak_term_is_pure(func.root.type)) {
            // if there's absolutely no way this function could misbehave,
            // use the fast path
            return ctx.program;
        }
        return method(ctx, __catspeak_function__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileValue = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "value", undefined
            );
        }
        return method({ value : term.value }, __catspeak_expr_value__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileArray = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "values", is_array
            );
        }
        var values = term.values;
        var valueCount = array_length(values);
        var exprs = array_create(valueCount);
        for (var i = 0; i < valueCount; i += 1) {
            exprs[@ i] = __compileTerm(ctx, values[i]);
        }
        return method({
            values : exprs,
            n : array_length(exprs),
        }, __catspeak_expr_array__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileStruct = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "values", is_array
            );
        }
        var values = term.values;
        var valueCount = array_length(values);
        var exprs = array_create(valueCount);
        for (var i = 0; i < valueCount; i += 1) {
            exprs[@ i] = __compileTerm(ctx, values[i]);
        }
        return method({
            values : exprs,
            n : array_length(exprs) div 2,
        }, __catspeak_expr_struct__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileBlock = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "terms", is_array
            );
        }
        var terms = term.terms;
        var termCount = array_length(terms);
        var exprs = array_create(termCount);
        for (var i = 0; i < termCount; i += 1) {
            exprs[@ i] = __compileTerm(ctx, terms[i]);
        }
        return __emitBlock(exprs);
    };

    /// @ignore
    ///
    /// @param {Array} exprs
    /// @return {Function}
    static __emitBlock = function (exprs) {
        var exprCount = array_length(exprs);
        // hard-code some common block sizes
        if (exprCount == 1) {
            return exprs[0];
        } else if (exprCount == 2) {
            return method({
                _1st : exprs[0],
                _2nd : exprs[1],
            }, __catspeak_expr_block_2__);
        } else if (exprCount == 3) {
            return method({
                _1st : exprs[0],
                _2nd : exprs[1],
                _3rd : exprs[2],
            }, __catspeak_expr_block_3__);
        } else if (exprCount == 4) {
            return method({
                _1st : exprs[0],
                _2nd : exprs[1],
                _3rd : exprs[2],
                _4th : exprs[3],
            }, __catspeak_expr_block_4__);
        } else if (exprCount == 5) {
            return method({
                _1st : exprs[0],
                _2nd : exprs[1],
                _3rd : exprs[2],
                _4th : exprs[3],
                _5th : exprs[4],
            }, __catspeak_expr_block_5__);
        }
        // arbitrary size block
        return method({
            stmts : exprs,
            n : exprCount - 1,
            result : exprs[exprCount - 1],
        }, __catspeak_expr_block__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileIf = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "condition", undefined,
                "ifTrue", undefined,
                "ifFalse", undefined
            );
        }
        if (term.ifFalse == undefined) {
            return method({
                condition : __compileTerm(ctx, term.condition),
                ifTrue : __compileTerm(ctx, term.ifTrue),
            }, __catspeak_expr_if__);
        } else {
            return method({
                condition : __compileTerm(ctx, term.condition),
                ifTrue : __compileTerm(ctx, term.ifTrue),
                ifFalse : __compileTerm(ctx, term.ifFalse),
            }, __catspeak_expr_if_else__);
        }
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileWhile = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "condition", undefined,
                "body", undefined
            );
        }
        return method({
            ctx : ctx,
            condition : __compileTerm(ctx, term.condition),
            body : __compileTerm(ctx, term.body),
        }, __catspeak_expr_while__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileReturn = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "value", undefined
            );
        }
        return method({
            value : __compileTerm(ctx, term.value),
        }, __catspeak_expr_return__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileBreak = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "value", undefined
            );
        }
        return method({
            value : __compileTerm(ctx, term.value),
        }, __catspeak_expr_break__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileContinue = function (ctx, term) {
        return method(undefined, __catspeak_expr_continue__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileOpUnary = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "operator", is_numeric, // TODO :: add proper bounds check here
                "value", undefined
            );
        }
        return method({
            op : __catspeak_operator_get_unary(term.operator),
            value : __compileTerm(ctx, term.value),
        }, __catspeak_expr_op_1__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileOpBinary = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "operator", is_numeric, // TODO :: add proper bounds check here
                "lhs", undefined,
                "rhs", undefined
            );
        }
        return method({
            op : __catspeak_operator_get_binary(term.operator),
            lhs : __compileTerm(ctx, term.lhs),
            rhs : __compileTerm(ctx, term.rhs),
        }, __catspeak_expr_op_2__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileCall = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "callee", undefined,
                "args", undefined,
                "dbg", undefined
            );
        }
        var callee = __compileTerm(ctx, term.callee);
        var args = term.args;
        var argCount = array_length(args);
        var exprs = array_create(argCount);
        for (var i = 0; i < argCount; i += 1) {
            exprs[@ i] = __compileTerm(ctx, args[i]);
        }
        return method({
            dbgError : __dbgTerm(term.callee, "is not a function"),
            callee : callee,
            args : exprs,
            shared : sharedData,
        }, __catspeak_expr_call__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileSet = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "assignType", is_numeric,
                "target", undefined,
                "value", undefined,
            );
            __catspeak_check_arg_struct("term.target", term.target,
                "type", is_numeric
            );
        }
        var target = term.target;
        var targetType = target.type;
        var value = __compileTerm(ctx, term.value);
        if (targetType == CatspeakTerm.INDEX) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.target", target,
                    "collection", undefined,
                    "key", undefined
                );
            }
            var func = __assignLookupIndex[term.assignType];
            return method({
                dbgError : __dbgTerm(target.collection, "is not indexable"),
                collection : __compileTerm(ctx, target.collection),
                key : __compileTerm(ctx, target.key),
                value : value,
            }, func);
        } else if (targetType == CatspeakTerm.LOCAL) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.target", target,
                    "idx", is_numeric
                );
            }
            var func = __assignLookupLocal[term.assignType];
            return method({
                locals : ctx.locals,
                idx : target.idx,
                value : value,
            }, func);
        } else if (targetType == CatspeakTerm.GLOBAL) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.target", target,
                    "name", is_string
                );
            }
            var name = target.name;
            if (variable_struct_exists(interface, name)) {
                // cannot assign to interface values
                __catspeak_error(
                    __catspeak_location_show(target.dbg),
                    " -- invalid assignment target, ",
                    "cannot assign to built-in function or constant"
                );
            }

            var func = __assignLookupGlobal[term.assignType];
            return method({
                shared : sharedData,
                name : name,
                value : value,
            }, func);
        } else {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.target", target,
                    "dbg", undefined
                );
            }
            __catspeak_error(
                __catspeak_location_show(target.dbg),
                " -- invalid assignment target, ",
                "must be an identifier or accessor expression"
            );
        }
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileIndex = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "collection", undefined,
                "key", undefined
            );
        }
        return method({
            dbgError : __dbgTerm(term.collection, "is not indexable"),
            collection : __compileTerm(ctx, term.collection),
            key : __compileTerm(ctx, term.key),
        }, __catspeak_expr_index_get__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileGlobal = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "name", is_string
            );
        }
        var name = term.name;
        if (variable_struct_exists(interface, name)) {
            // user-defined interface
            return method({
                value : interface[$ name],
            }, __catspeak_expr_value__);
        } else {
            // global var
            return method({
                name : name,
                shared : sharedData,
            }, __catspeak_expr_global_get__);
        }
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileLocal = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "idx", is_numeric
            );
        }
        return method({
            locals : ctx.locals,
            idx : term.idx,
        }, __catspeak_expr_local_get__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileFunctionExpr = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "idx", is_numeric
            );
        }
        return method({
            value : __compileFunction(functions[term.idx]),
        }, __catspeak_expr_value__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileSelf = function (ctx, term) {
        return method(sharedData, __catspeak_expr_self__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileTerm = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "type", is_numeric
            );
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
        db[@ CatspeakTerm.ARRAY] = __compileArray;
        db[@ CatspeakTerm.STRUCT] = __compileStruct;
        db[@ CatspeakTerm.BLOCK] = __compileBlock;
        db[@ CatspeakTerm.IF] = __compileIf;
        db[@ CatspeakTerm.WHILE] = __compileWhile;
        db[@ CatspeakTerm.RETURN] = __compileReturn;
        db[@ CatspeakTerm.BREAK] = __compileBreak;
        db[@ CatspeakTerm.CONTINUE] = __compileContinue;
        db[@ CatspeakTerm.OP_BINARY] = __compileOpBinary;
        db[@ CatspeakTerm.OP_UNARY] = __compileOpUnary;
        db[@ CatspeakTerm.CALL] = __compileCall;
        db[@ CatspeakTerm.SET] = __compileSet;
        db[@ CatspeakTerm.INDEX] = __compileIndex;
        db[@ CatspeakTerm.GLOBAL] = __compileGlobal;
        db[@ CatspeakTerm.LOCAL] = __compileLocal;
        db[@ CatspeakTerm.FUNCTION] = __compileFunctionExpr;
        db[@ CatspeakTerm.SELF] = __compileSelf;
        return db;
    })();

    /// @ignore
    static __assignLookupIndex = (function () {
        var db = array_create(CatspeakAssign.__SIZE__, undefined);
        db[@ CatspeakAssign.VANILLA] = __catspeak_expr_index_set__;
        db[@ CatspeakAssign.MULTIPLY] = __catspeak_expr_index_set_mult__;
        db[@ CatspeakAssign.DIVIDE] = __catspeak_expr_index_set_div__;
        db[@ CatspeakAssign.SUBTRACT] = __catspeak_expr_index_set_sub__;
        db[@ CatspeakAssign.PLUS] = __catspeak_expr_index_set_plus__;
        return db;
    })();

    /// @ignore
    static __assignLookupLocal = (function () {
        var db = array_create(CatspeakAssign.__SIZE__, undefined);
        db[@ CatspeakAssign.VANILLA] = __catspeak_expr_local_set__;
        db[@ CatspeakAssign.MULTIPLY] = __catspeak_expr_local_set_mult__;
        db[@ CatspeakAssign.DIVIDE] = __catspeak_expr_local_set_div__;
        db[@ CatspeakAssign.SUBTRACT] = __catspeak_expr_local_set_sub__;
        db[@ CatspeakAssign.PLUS] = __catspeak_expr_local_set_plus__;
        return db;
    })();

    /// @ignore
    static __assignLookupGlobal = (function () {
        var db = array_create(CatspeakAssign.__SIZE__, undefined);
        db[@ CatspeakAssign.VANILLA] = __catspeak_expr_global_set__;
        db[@ CatspeakAssign.MULTIPLY] = __catspeak_expr_global_set_mult__;
        db[@ CatspeakAssign.DIVIDE] = __catspeak_expr_global_set_div__;
        db[@ CatspeakAssign.SUBTRACT] = __catspeak_expr_global_set_sub__;
        db[@ CatspeakAssign.PLUS] = __catspeak_expr_global_set_plus__;
        return db;
    })();

    /// @ignore
    static __dbgTerm = function (term, msg="is invalid in this context") {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "dbg", undefined
            );
        }
        var terminalName = __catspeak_term_get_terminal(term);
        return "runtime error " + __catspeak_location_show_ext(term.dbg,
            terminalName == undefined
                    ? "value"
                    : "variable '" + terminalName + "'",
            " ", msg
        );
    };
}

/// @ignore
/// @return {Any}
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
    } else {
        callTime = current_time;
    }
    for (var argI = argCount - 1; argI >= 0; argI -= 1) {
        locals[@ argI] = argument[argI];
    }
    var value;
    try {
        value = program();
    } catch (e) {
        if (e == global.__catspeakGmlReturnRef) {
            value = e[0];
        } else {
            throw e;
        }
    } finally {
        if (isRecursing) {
            // bad practice to use `localCount_` here, but it saves
            // a tiny bit of time so I'll be a bit evil
            //# feather disable once GM2043
            array_copy(locals, 0, oldLocals, 0, localCount);
        } else {
            // reset the timer
            callTime = -1;
        }
    }
    return value;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_value__() {
    return value;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_array__() {
	//return array_map(values, function(f) { return f() });
	var i = 0;
    var values_ = values;
    var n_ = n;
	var arr = array_create(n_);
    repeat (n_) {
        // not sure if this is even fast
        // but people will cry if I don't do it
        var value = values_[i];
        arr[@ i] = value();
        i += 1;
    }
    return arr;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_struct__() {
    var obj = { };
    var i = 0;
    var values_ = values;
    var n_ = n;
    repeat (n_) {
        // not sure if this is even fast
        // but people will cry if I don't do it
        var key = values_[i + 0];
        var value = values_[i + 1];
        obj[$ key()] = value();
        i += 2;
    }
    return obj;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_block__() {
    //array_foreach(stmts, function (stmt) { stmt() });
    var i = 0;
    var stmts_ = stmts;
    var n_ = n;
    repeat (n_) {
        // not sure if this is even fast
        // but people will cry if I don't do it
        var expr = stmts_[i];
        expr();
        i += 1;
    }
    return result();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_block_2__() {
    _1st();
    return _2nd();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_block_3__() {
    _1st();
    _2nd();
    return _3rd();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_block_4__() {
    _1st();
    _2nd();
    _3rd();
    return _4th();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_block_5__() {
    _1st();
    _2nd();
    _3rd();
    _4th();
    return _5th();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_if__() {
    return condition() ? ifTrue() : undefined;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_if_else__() {
    return condition() ? ifTrue() : ifFalse();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_while__() {
    var callTime = ctx.callTime;
    var condition_ = condition;
    var body_ = body;
    while (condition_()) {
        __catspeak_timeout_check(callTime);
        try {
            body_();
        } catch (e) {
            if (e == global.__catspeakGmlBreakRef) {
                return e[0];
            } else if (e != global.__catspeakGmlContinueRef) {
                throw e;
            }
        }
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_while_simple__() {
    var callTime = ctx.callTime;
    var condition_ = condition;
    var body_ = body;
    while (condition_()) {
        __catspeak_timeout_check(callTime);
        body_();
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_return__() {
    var box = global.__catspeakGmlReturnRef;
    box[@ 0] = value();
    throw box;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_break__() {
    var box = global.__catspeakGmlBreakRef;
    box[@ 0] = value();
    throw box;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_continue__() {
    throw global.__catspeakGmlContinueRef;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_op_1__() {
    var value_ = value();
    return op(value_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_op_2__() {
    var lhs_ = lhs();
    var rhs_ = rhs();
    return op(lhs_, rhs_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var args_;
    { //var args_ = array_map(args, function(f) { return f() });
        var i = 0;
        var values_ = args;
        var n_ = array_length(values_);
        args_ = array_create(n_);
        repeat (n_) {
            // not sure if this is even fast
            // but people will cry if I don't do it
            var value = values_[i];
            args_[@ i] = value();
            i += 1;
        }
    }
    var shared_ = shared;
    with (method_get_self(callee_) ?? (shared_.self_ ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return script_execute_ext(calleeIdx, args_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_get__() {
    var collection_ = collection();
    var key_ = key();
    if (is_array(collection_)) {
        return collection_[key_];
    } else if (is_struct(collection_)) {
        return collection_[$ key_];
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_set__() {
    var collection_ = collection();
    var key_ = key();
    var value_ = value();
    if (is_array(collection_)) {
        collection_[@ key_] = value_;
    } else if (is_struct(collection_)) {
        collection_[$ key_] = value_;
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_set_mult__() {
    var collection_ = collection();
    var key_ = key();
    var value_ = value();
    if (is_array(collection_)) {
        collection_[@ key_] *= value_;
    } else if (is_struct(collection_)) {
        collection_[$ key_] *= value_;
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_set_div__() {
    var collection_ = collection();
    var key_ = key();
    var value_ = value();
    if (is_array(collection_)) {
        collection_[@ key_] /= value_;
    } else if (is_struct(collection_)) {
        collection_[$ key_] /= value_;
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_set_sub__() {
    var collection_ = collection();
    var key_ = key();
    var value_ = value();
    if (is_array(collection_)) {
        collection_[@ key_] -= value_;
    } else if (is_struct(collection_)) {
        collection_[$ key_] -= value_;
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_set_plus__() {
    var collection_ = collection();
    var key_ = key();
    var value_ = value();
    if (is_array(collection_)) {
        collection_[@ key_] += value_;
    } else if (is_struct(collection_)) {
        collection_[$ key_] += value_;
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_global_get__() {
    return shared.globals[$ name];
}

/// @ignore
/// @return {Any}
function __catspeak_expr_global_set__() {
    shared.globals[$ name] = value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_global_set_mult__() {
    shared.globals[$ name] *= value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_global_set_div__() {
    shared.globals[$ name] /= value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_global_set_sub__() {
    shared.globals[$ name] -= value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_global_set_plus__() {
    shared.globals[$ name] += value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_local_get__() {
    return locals[idx];
}

/// @ignore
/// @return {Any}
function __catspeak_expr_local_set__() {
    locals[@ idx] = value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_local_set_mult__() {
    locals[@ idx] *= value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_local_set_div__() {
    locals[@ idx] /= value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_local_set_sub__() {
    locals[@ idx] -= value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_local_set_plus__() {
    locals[@ idx] += value();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_self__() {
    // will either access a user-defined self instance, or the internal
    // global struct
    return self_ ?? globals;
}

/// @ignore
function __catspeak_init_codegen() {
    /// @ignore
    global.__catspeakGmlReturnRef = [undefined];
    /// @ignore
    global.__catspeakGmlBreakRef = [undefined];
    /// @ignore
    global.__catspeakGmlContinueRef = [];
}