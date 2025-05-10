//! Responsible for the code generation stage of the Catspeak compiler.
//!
//! This stage converts Catspeak IR, produced by `CatspeakParser` or
//! `CatspeakIRBuilder`, into various lower-level formats. The most
//! interesting of these formats is the conversion of Catspeak programs into
//! native GML functions.

//# feather use syntax-errors

/// @ignore
///
/// @param {Function} func
/// @return {String}
function __catspeak_infer_function_name(func) {
    if (is_method(func)) {
        var name = func[$ "name"];
        if (is_string(name)) {
            return name;
        }
        func = method_get_index(func);
    }
    return script_get_name(func);
}

/// Checks whether a value is a valid Catspeak function compiled through
/// `CatspeakGMLCompiler`.
///
/// @warning
///   Internally, this actually just checks whether the methods name starts
///   with `__catspeak_`. Because of this, you should avoid giving your
///   functions that prefix to prevent false positives.
///
/// @param {Any} value
///   The value to check is a Catspeak function.
///
/// @return {Bool}
function is_catspeak(value) {
    if (!is_method(value)) {
        return false;
    }
    var scr = method_get_index(value);
    if (scr == __catspeak_function__) {
        return true;
    }
    var scrName = script_get_name(scr);
    return string_starts_with(scrName, "__catspeak_");
}

/// The number of microseconds before a Catspeak program times out. The
/// default is 1 second.
///
/// @return {Real}
#macro CATSPEAK_TIMEOUT 1000

/// @ignore
///
/// @param {Real} t
function __catspeak_timeout_check(t) {
    gml_pragma("forceinline");
    if (current_time - t > CATSPEAK_TIMEOUT) {
        __catspeak_error(
            "process exceeded allowed time of ", CATSPEAK_TIMEOUT, " ms"
        );
    }
}

/// Takes a reference to a Catspeak IR and converts it into a callable GML
/// function.
///
/// @experimental
///
/// @warning
///   Do not modify the the Catspeak IR whilst compilation is taking place.
///   This will cause **undefined behaviour**, potentially resulting in hard
///   to discover bugs!
///
/// @param {Struct} ir
///   The Catspeak IR to compile.
///
/// @param {Struct} [interface]
///   The native interface to use.
function CatspeakGMLCompiler(ir, interface=undefined) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
        __catspeak_check_arg_struct("ir", ir,
            "functions", is_array,
            "entryPoints", is_array
        );
    }
    /// @ignore
    self.interface = interface;
    /// @ignore
    self.functions = ir.functions;
    /// @ignore
    self.sharedData = {
        globals : { },
        self_ : undefined,
    };
    //# feather disable once GM2043
    /// @ignore
    self.program = __compileFunctions(ir.entryPoints);
    /// @ignore
    self.finalised = false;

    /// @ignore
    ///
    /// @param {String} name
    /// @return {Any}
    static __get = function (name) {
        if (__catspeak_is_nullish(interface)) {
            return undefined;
        }
        return interface.get(name);
    }

    /// @ignore
    ///
    /// @param {String} name
    /// @return {Any}
    static __exists = function (name) {
        if (__catspeak_is_nullish(interface)) {
            return undefined;
        }
        return interface.exists(name);
    }

    /// @ignore
    ///
    /// @param {String} name
    /// @return {Bool}
    static __isDynamicConstant = function (name) {
        if (__catspeak_is_nullish(interface)) {
            return false;
        }
        return interface.isDynamicConstant(name);
    }

    /// Generates the code for a single term from the supplied Catspeak IR.
    ///
    /// @example
    ///   Creates a new `CatspeakGMLCompiler` from the variable `ir` and
    ///   loops until the compiler is finished compiling. The final result is
    ///   assigned to the `result` local variable.
    ///
    ///   ```gml
    ///   var compiler = new CatspeakGMLCompiler(ir);
    ///   var result;
    ///   do {
    ///       result = compiler.update();
    ///   } until (result != undefined);
    ///   ```
    ///
    /// @return {Function}
    ///   The final compiled Catspeak function if there are no more terms left
    ///   to compile, or `undefined` if there is still more left to compile.
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
        __setupCatspeakFunctionMethods(rootCall);
        return rootCall;
    };

    /// @ignore
    static __setupCatspeakFunctionMethods = function (f) {
        f.setSelf = method(sharedData, function (selfInst) {
            self_ = selfInst == undefined
                    ? undefined
                    : catspeak_special_to_struct(selfInst);
        });
        f.setGlobals = method(sharedData, function (globalInst) {
            var newGlobals = catspeak_special_to_struct(globalInst);
            if (newGlobals != undefined) {
                globals = newGlobals;
            }
        });
        f.getSelf = method(sharedData, function () { return self_ });
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
            args : array_create(func.argCount),
            currentArgCount: 0,
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
        if (__catspeak_is_nullish(term.ifFalse)) {
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
    static __compileCatch = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "eager", undefined,
                "lazy", undefined,
                "localRef", undefined
            );
        }
        if (term.localRef == undefined) {
            return method({
                eager : __compileTerm(ctx, term.eager),
                lazy : __compileTerm(ctx, term.lazy),
            }, __catspeak_expr_catch_simple__);
        } else {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.localRef", term.localRef,
                    "idx", is_numeric
                );
            }
            return method({
                eager : __compileTerm(ctx, term.eager),
                lazy : __compileTerm(ctx, term.lazy),
                locals : ctx.locals,
                idx : term.localRef.idx,
            }, __catspeak_expr_catch__);
        }
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileLoop = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "preCondition", undefined,
                "postCondition", undefined,
                "step", undefined,
                "body", undefined
            );
        }
        var preCondition_ = term.preCondition == undefined
                ? undefined : __compileTerm(ctx, term.preCondition);
        var body_ = term.body == undefined
                ? undefined : __compileTerm(ctx, term.body);
        var postCondition_ = term.postCondition == undefined
                ? undefined : __compileTerm(ctx, term.postCondition);
        var step_ = term.step == undefined
                ? undefined : __compileTerm(ctx, term.step);
        if (
            preCondition_ != undefined &&
            postCondition_ == undefined
        ) {
            if (term.step == undefined) {
                return method({
                    ctx : ctx,
                    condition : preCondition_,
                    body : body_,
                }, __catspeak_expr_loop_while__);
            } else {
                return method({
                    ctx : ctx,
                    condition : preCondition_,
                    body : body_,
                    step : step_,
                }, __catspeak_expr_loop_for__);
            }
        }
        if (
            preCondition_ == undefined &&
            postCondition_ != undefined &&
            step_ == undefined
        ) {
            return method({
                ctx : ctx,
                condition : postCondition_,
                body : body_,
            }, __catspeak_expr_loop_do__);
        }
        
        return method({
            ctx : ctx,
            preCondition : preCondition_,
            postCondition : postCondition_,
            step : step_,
            body : body_,
        }, __catspeak_expr_loop_general__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileWith = function(ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "scope", undefined,
                "body", undefined
            );
        }
        return method({
            scope : __compileTerm(ctx, term.scope),
            body : __compileTerm(ctx, term.body),
            dbgError : __dbgTerm(term.scope, "is not valid in 'with' contexts")
        }, __catspeak_expr_loop_with__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileMatch = function(ctx, term) {
        var i = 0;
        var n = array_length(term.arms);
        repeat n {
            var pair = term.arms[i];
            var condition = __catspeak_is_nullish(pair[0])
                    ? undefined
                    : __compileTerm(ctx, pair[0]);
            term.arms[i] = {
                condition : condition,
                result : __compileTerm(ctx, pair[1]),
            };
            i += 1;
        }
        return method({
            value: __compileTerm(ctx, term.value),
            arms: term.arms,
        }, __catspeak_expr_match__);
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
    static __compileThrow = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "value", undefined
            );
        }
        return method({
            value : __compileTerm(ctx, term.value),
        }, __catspeak_expr_throw__);
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
    static __compileAnd = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "eager", undefined,
                "lazy", undefined
            );
        }
        return method({
            eager : __compileTerm(ctx, term.eager),
            lazy : __compileTerm(ctx, term.lazy),
        }, __catspeak_expr_and__);
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileOr = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "eager", undefined,
                "lazy", undefined
            );
        }
        return method({
            eager : __compileTerm(ctx, term.eager),
            lazy : __compileTerm(ctx, term.lazy),
        }, __catspeak_expr_or__);
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
                "args", undefined
            );
            __catspeak_check_arg_struct("term.callee", term.callee,
                "type", is_numeric
            );
        }
        var args = term.args;
        var argCount = array_length(args);
        var exprs = array_create(argCount);
        for (var i = 0; i < argCount; i += 1) {
            exprs[@ i] = __compileTerm(ctx, args[i]);
        }
        var dbgError = __dbgTerm(term.callee, "is not a function");
        if (term.callee.type == CatspeakTerm.INDEX) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.callee", term.callee,
                    "collection", undefined,
                    "key", undefined
                );
            }
            var collection = __compileTerm(ctx, term.callee.collection);
            var key = __compileTerm(ctx, term.callee.key);
            return method({
                dbgError : dbgError,
                collection : collection,
                key : key,
                args : exprs,
                shared : sharedData,
            }, __catspeak_expr_call_method__);
        } else {
            var callee = __compileTerm(ctx, term.callee);
            var func = __catspeak_expr_call__;
            switch (array_length(exprs)) {
            case 0: func = __catspeak_expr_call_0__; break;
            case 1: func = __catspeak_expr_call_1__; break;
            case 2: func = __catspeak_expr_call_2__; break;
            case 3: func = __catspeak_expr_call_3__; break;
            case 4: func = __catspeak_expr_call_4__; break;
            case 5: func = __catspeak_expr_call_5__; break;
            }
            return method({
                dbgError : dbgError,
                callee : callee,
                args : exprs,
                shared : sharedData,
            }, func);
        }
    };

    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileCallNew = function (ctx, term) {
        // NOTE :: blehhh ugly code pls pls refactor fr fr ong no cap
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "callee", undefined,
                "args", undefined
            );
            __catspeak_check_arg_struct("term.callee", term.callee,
                "type", is_numeric
            );
        }
        var args = term.args;
        var argCount = array_length(args);
        var exprs = array_create(argCount);
        for (var i = 0; i < argCount; i += 1) {
            exprs[@ i] = __compileTerm(ctx, args[i]);
        }
        var callee = __compileTerm(ctx, term.callee);
        return method({
            dbgError : __dbgTerm(term.callee, "is not constructible"),
            callee : callee,
            args : exprs,
        }, __catspeak_expr_call_new__);
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
        } else if (targetType == CatspeakTerm.PROPERTY) {
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg_struct("term.target", target,
                    "property", undefined
                );
            }
            var func = __assignLookupProperty[term.assignType];
            return method({
                dbgError : __dbgTerm(target.property, "is not a function"),
                property : __compileTerm(ctx, target.property),
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
            if (__exists(name)) {
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
    static __compileProperty = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "property", undefined
            );
        }
        return method({
            dbgError : __dbgTerm(term.property, "is not a function"),
            property : __compileTerm(ctx, term.property),
        }, __catspeak_expr_property_get__);
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
        if (__exists(name)) {
            var _callee = method({
                value : __get(name),
            }, __catspeak_expr_value__);
            if (__isDynamicConstant(name)) {
                // dynamic constant
                return method({
                    dbgError : __dbgTerm(term, "is not a function"),
                    callee : _callee,
                    shared : sharedData,
                }, __catspeak_expr_call_0__);
            } else {
                // user-defined interface
                return _callee;
            }
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
    static __compileParams = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "key", is_struct
            );
        }
        return method({
            args : ctx.args,
            key : __compileTerm(ctx, term.key),
        }, __catspeak_expr_params_get__);
    };
    
    /// @ignore
    ///
    /// @param {Struct} ctx
    /// @param {Struct} term
    /// @return {Function}
    static __compileParamsCount = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term);
        }
        return method(ctx, __catspeak_expr_params_count_get__);
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
        var funcExpr = __compileFunction(functions[term.idx]);
        __setupCatspeakFunctionMethods(funcExpr);
        return method({
            value : funcExpr,
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
    static __compileOther = function (ctx, term) {
        return method(sharedData, __catspeak_expr_other__);
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
        if (CATSPEAK_DEBUG_MODE && __catspeak_is_nullish(prod)) {
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
        db[@ CatspeakTerm.CATCH] = __compileCatch;
        db[@ CatspeakTerm.LOOP] = __compileLoop;
        db[@ CatspeakTerm.WITH] = __compileWith;
        db[@ CatspeakTerm.MATCH] = __compileMatch;
        db[@ CatspeakTerm.RETURN] = __compileReturn;
        db[@ CatspeakTerm.BREAK] = __compileBreak;
        db[@ CatspeakTerm.CONTINUE] = __compileContinue;
        db[@ CatspeakTerm.THROW] = __compileThrow;
        db[@ CatspeakTerm.OP_BINARY] = __compileOpBinary;
        db[@ CatspeakTerm.OP_UNARY] = __compileOpUnary;
        db[@ CatspeakTerm.CALL] = __compileCall;
        db[@ CatspeakTerm.CALL_NEW] = __compileCallNew;
        db[@ CatspeakTerm.SET] = __compileSet;
        db[@ CatspeakTerm.INDEX] = __compileIndex;
        db[@ CatspeakTerm.PROPERTY] = __compileProperty;
        db[@ CatspeakTerm.GLOBAL] = __compileGlobal;
        db[@ CatspeakTerm.LOCAL] = __compileLocal;
        db[@ CatspeakTerm.FUNCTION] = __compileFunctionExpr;
        db[@ CatspeakTerm.SELF] = __compileSelf;
        db[@ CatspeakTerm.OTHER] = __compileOther;
        db[@ CatspeakTerm.AND] = __compileAnd;
        db[@ CatspeakTerm.OR] = __compileOr;
        db[@ CatspeakTerm.PARAMS] = __compileParams;
        db[@ CatspeakTerm.PARAMS_COUNT] = __compileParamsCount;
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
    static __assignLookupProperty = (function () {
        var db = array_create(CatspeakAssign.__SIZE__, undefined);
        db[@ CatspeakAssign.VANILLA] = __catspeak_expr_property_set__;
        db[@ CatspeakAssign.MULTIPLY] = __catspeak_expr_property_set_mult__;
        db[@ CatspeakAssign.DIVIDE] = __catspeak_expr_property_set_div__;
        db[@ CatspeakAssign.SUBTRACT] = __catspeak_expr_property_set_sub__;
        db[@ CatspeakAssign.PLUS] = __catspeak_expr_property_set_plus__;
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
            __catspeak_is_nullish(terminalName)
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
    var localCount = array_length(locals);
    if (isRecursing) {
        // catch unbound recursion
        __catspeak_timeout_check(callTime);
        // store the previous local variable array
        // this will make function recursion quite expensive, but
        // hopefully that's uncommon enough for it to not matter
        var oldLocals = array_create(localCount);
        array_copy(oldLocals, 0, locals, 0, localCount);
        // store the previous argument array
        // this requires a fair bit more work to ensure nothing 
        // is leaked to recursive calls
        var oldArgsCount = currentArgCount;
        var oldArgs = array_create(oldArgsCount);
        array_copy(oldArgs, 0, args, 0, oldArgsCount);
        array_resize(args, argument_count);
    } else {
        callTime = current_time;
    }
    // used for params_count, to reflect current argument count
    currentArgCount = argument_count;
    for (var argI = argCount - 1; argI >= 0; argI -= 1) {
        locals[@ argI] = argument[argI];
    }
    for(var argI = argument_count - 1; argI >= 0; argI -= 1) {
        args[@ argI] = argument[argI];	
    }
    var value = undefined;
    var throwValue = undefined;
    var doThrowValue = false;
    // the finally block doesn't execute sometimes if there's a `break`,
    // `throw`, or `continue` in the try/catch blocks
    try {
        value = program();
    } catch (e) {
        if (e == global.__catspeakGmlReturnRef) {
            value = e[0];
        } else {
            throwValue = e;
            doThrowValue = true;
        }
    } finally {
        if (isRecursing) {
            // bad practice to use `localCount_` here, but it saves
            // a tiny bit of time so I'll be a bit evil
            //# feather disable GM2043
            array_copy(locals, 0, oldLocals, 0, localCount);
            // resetting arguments
            currentArgCount = oldArgsCount;
            array_resize(args, currentArgCount);
            array_copy(args, 0, oldArgs, 0, currentArgCount);
            //# feather enable GM2043
        } else {
            // reset the timer
            callTime = -1;
            // Clear locals
            // Gone with array_resize, as it's faster to resize than to loop
            array_resize(locals, 0);
            array_resize(locals, localCount);
            array_resize(args, 0);
            array_resize(args, argCount);
        }
    }
    if (doThrowValue) {
        throw throwValue;
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
function __catspeak_expr_catch__() {
    var result;
    try {
        result = eager();
    } catch (exValue) {
        locals[@ idx] = exValue;
        result = lazy();
    }
    return result;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_catch_simple__() {
    var result;
    try {
        result = eager();
    } catch (exValue) {
        result = lazy();
    }
    return result;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_and__() {
    return eager() && lazy();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_or__() {
    return eager() || lazy();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_loop_while__() {
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
    return undefined;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_loop_for__() {
    var callTime = ctx.callTime;
    var condition_ = condition;
    var step_ = step;
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
        step_();
    }
    return undefined;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_loop_do__() {
    var callTime = ctx.callTime;
    var condition_ = condition;
    var body_ = body;
    do {
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
    } until (!condition_());
    return undefined;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_loop_general__() {
    var callTime = ctx.callTime;
    var preCondition_ = preCondition;
    var postCondition_ = postCondition;
    var step_ = step;
    var body_ = body;
    while (true) {
        __catspeak_timeout_check(callTime);
        if (preCondition_ != undefined && !preCondition_()) {
            break;
        }
        try {
            body_();
        } catch (e) {
            if (e == global.__catspeakGmlBreakRef) {
                return e[0];
            } else if (e != global.__catspeakGmlContinueRef) {
                throw e;
            }
        }
        if (postCondition_ != undefined && !postCondition_()) {
            break;
        }
        if (step_ != undefined) {
            step_();
        }
    }
    return undefined;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_loop_with__() {
    var scope_ = scope();
    if (scope_ == noone) {
        return undefined;
    }
    var body_ = body;
    var throwValue = undefined;
    var doThrowValue = false;
    var returnValue = undefined;
    var doReturnValue = false;
    if (!__catspeak_is_withable(scope_)) {
        __catspeak_error(dbgError, ": ", scope_);
        return undefined;
    }
    with (scope_) {
        // the finally block doesn't execute sometimes if there's a `break`,
        // `throw`, or `continue` in the try/catch blocks
        __CATSPEAK_BEGIN_SELF = self;
        try {
            body_();
        } catch (e) {
            if (e == global.__catspeakGmlBreakRef) {
                returnValue = e[0];
                doReturnValue = true;
            } else if (e != global.__catspeakGmlContinueRef) {
                throwValue = e;
                doThrowValue = true;
            }
        }
        __CATSPEAK_END_SELF;
        if (doThrowValue) {
            throw throwValue;
        }
        if (doReturnValue) {
            return returnValue;
        }
    }
    return undefined;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_match__() {
    var value_ = value();
    var i = 0;
    var len = array_length(arms);
    repeat (len) {
        var arm = arms[i];
        // TODO :: remove this `__catspeak_is_nullish` check, try optimise it so
        //         there's a fall-through at the end instead of returning
        //         `undefined`
        if (__catspeak_is_nullish(arm.condition) ||
                value_ == arm.condition()) {
            return arm.result();
        }
        i += 1;
    }
    return undefined; // <-- (see above)
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
    return undefined;
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
function __catspeak_expr_throw__() {
    throw value();
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

function __catspeak_script_execute_ext_fixed(callee_, args_) {
    // LTS has issues with calling functions that have many args, so fix that here
    var n = array_length(args_);
    switch (n) {
        // triangle of doom gets a free pass on line length restrictions
        // as a treat
        // TODO :: slow as hell
    case 0: return callee_();
    case 1: return callee_(args_[0]);
    case 2: return callee_(args_[0], args_[1]);
    case 3: return callee_(args_[0], args_[1], args_[2]);
    case 4: return callee_(args_[0], args_[1], args_[2], args_[3]);
    case 5: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4]);
    case 6: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5]);
    case 7: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6]);
    case 8: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7]);
    case 9: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8]);
    case 10: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9]);
    case 11: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10]);
    case 12: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11]);
    case 13: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12]);
    case 14: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12], args_[13]);
    case 15: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12], args_[13], args_[14]);
    case 16: return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12], args_[13], args_[14], args_[15]);
    }
    return script_execute_ext(callee_, args_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_method__() {
    // TODO :: this method call stuff is crap, please figure out a better way
    var collection_ = collection();
    var key_ = key();
    var callee_;
    if (is_array(collection_)) {
        callee_ = collection_[key_];
        var shared_ = shared;
        // since arrays cannot be used in with statements, let's use something else
        collection_ = global.__catspeakGmlSelf ?? (shared_.self_ ?? shared_.globals);
    } else if (__catspeak_is_withable(collection_)) {
        callee_ = collection_[$ key_];
    } else {
        // TODO :: bad error message
        __catspeak_error_got(dbgError, collection_);
    }
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
    var result = undefined;
    // a weird sharp edge here means that `__CATSPEAK_BEGIN_SELF` needs
    // to use `catspeak_get_self`, but the actual with loop needs to use
    // `method_get_self` (see test "get-self-method")
    __CATSPEAK_BEGIN_SELF = catspeak_get_self(callee_) ?? collection_;
    with (method_get_self(callee_) ?? collection_) {
        var calleeIdx = method_get_index(callee_);
        result = __catspeak_script_execute_ext_fixed(calleeIdx, args_);
        break;
    }
    __CATSPEAK_END_SELF;
    return result;
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
    with (method_get_self(callee_) ?? 
        (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals))
    ) {
        var calleeIdx = method_get_index(callee_);
        return __catspeak_script_execute_ext_fixed(calleeIdx, args_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_0__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var shared_ = shared;
	
    if (method_get_self(callee_) != undefined) {
        return callee_();
    }
	
    with (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return calleeIdx();
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_1__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var values_ = args;
    var arg1 = values_[0]();
    var shared_ = shared;
	
    if (method_get_self(callee_) != undefined) {
        return callee_(arg1);
    }
	
    with (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return calleeIdx(arg1);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_2__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var values_ = args;
    var arg1 = values_[0]();
    var arg2 = values_[1]();
    var shared_ = shared;
	
    if (method_get_self(callee_) != undefined) {
        return callee_(arg1, arg2);
    }
	
    with (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return calleeIdx(arg1, arg2);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_3__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var values_ = args;
    var arg1 = values_[0]();
    var arg2 = values_[1]();
    var arg3 = values_[2]();
    var shared_ = shared;
	
    if (method_get_self(callee_) != undefined) {
        return callee_(arg1, arg2, arg3);
    }
	
    with (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return calleeIdx(arg1, arg2, arg3);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_4__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var values_ = args;
    var arg1 = values_[0]();
    var arg2 = values_[1]();
    var arg3 = values_[2]();
    var arg4 = values_[3]();
    var shared_ = shared;

    if (method_get_self(callee_) != undefined) {
        return callee_(arg1, arg2, arg3, arg4);
    }

    with (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return calleeIdx(arg1, arg2, arg3, arg4);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_call_5__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    var values_ = args;
    var arg1 = values_[0]();
    var arg2 = values_[1]();
    var arg3 = values_[2]();
    var arg4 = values_[3]();
    var arg5 = values_[4]();
    var shared_ = shared;

    if (method_get_self(callee_) != undefined) {
        return callee_(arg1, arg2, arg3, arg4, arg5);
    }

    with (shared_.self_ ?? (global.__catspeakGmlSelf ?? shared_.globals)) {
        var calleeIdx = method_get_index(callee_);
        return calleeIdx(arg1, arg2, arg3, arg4, arg5);
    }
}



/// @ignore
/// @return {Any}
function __catspeak_expr_call_new__() {
    var callee_ = callee();
    if (!is_method(callee_)) {
        __catspeak_error_got(dbgError, callee_);
    }
    // TODO :: optimise :: SUPER SLOW, DO THIS AT COMPILE TIME
    var args_ = args;
    switch (array_length(args_)) {
        // triangle of doom gets a free pass on line length restrictions
        // as a treat
    case 0: return new callee_();
    case 1: return new callee_(args_[0]());
    case 2: return new callee_(args_[0](), args_[1]());
    case 3: return new callee_(args_[0](), args_[1](), args_[2]());
    case 4: return new callee_(args_[0](), args_[1](), args_[2](), args_[3]());
    case 5: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4]());
    case 6: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5]());
    case 7: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6]());
    case 8: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7]());
    case 9: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8]());
    case 10: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9]());
    case 11: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9](), args_[10]());
    case 12: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9](), args_[10](), args_[11]());
    case 13: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9](), args_[10](), args_[11](), args_[12]());
    case 14: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9](), args_[10](), args_[11](), args_[12](), args_[13]());
    case 15: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9](), args_[10](), args_[11](), args_[12](), args_[13](), args_[14]());
    case 16: return new callee_(args_[0](), args_[1](), args_[2](), args_[3](), args_[4](), args_[5](), args_[6](), args_[7](), args_[8](), args_[9](), args_[10](), args_[11](), args_[12](), args_[13](), args_[14](), args_[15]());
    default:
        __catspeak_error_got(
            "cannot exceed 16 arguments in 'new' expression"
        );
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_index_get__() {
    var collection_ = collection();
    var key_ = key();
    if (is_array(collection_)) {
        return collection_[key_];
    } else if (__catspeak_is_withable(collection_)) {
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
    } else if (__catspeak_is_withable(collection_)) {
        var specialSet = global.__catspeakGmlSpecialVars[$ key_];
        if (specialSet != undefined) {
            specialSet(collection_, value_);
            return;
        }
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
    } else if (__catspeak_is_withable(collection_)) {
        var specialSet = global.__catspeakGmlSpecialVars[$ key_];
        if (specialSet != undefined) {
            specialSet(collection_, collection_[$ key_] * value_);
            return;
        }
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
    } else if (__catspeak_is_withable(collection_)) {
        var specialSet = global.__catspeakGmlSpecialVars[$ key_];
        if (specialSet != undefined) {
            specialSet(collection_, collection_[$ key_] / value_);
            return;
        }
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
    } else if (__catspeak_is_withable(collection_)) {
        var specialSet = global.__catspeakGmlSpecialVars[$ key_];
        if (specialSet != undefined) {
            specialSet(collection_, collection_[$ key_] - value_);
            return;
        }
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
    } else if (__catspeak_is_withable(collection_)) {
        var specialSet = global.__catspeakGmlSpecialVars[$ key_];
        if (specialSet != undefined) {
            specialSet(collection_, collection_[$ key_] + value_);
            return;
        }
        collection_[$ key_] += value_;
    } else {
        __catspeak_error_got(dbgError, collection_);
    }
}

/// @ignore
/// @return {Any}
function __catspeak_expr_property_get__() {
    var property_ = property();
    if (!is_method(property_)) {
        __catspeak_error_got(dbgError, property_);
    }
    return property_();
}

/// @ignore
/// @return {Any}
function __catspeak_expr_property_set__() {
    var property_ = property();
    var value_ = value();
    if (!is_method(property_)) {
        __catspeak_error_got(dbgError, property_);
    }
    return property_(value_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_property_set_mult__() {
    var property_ = property();
    var value_ = value();
    if (!is_method(property_)) {
        __catspeak_error_got(dbgError, property_);
    }
    return property_(property_() * value_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_property_set_div__() {
    var property_ = property();
    var value_ = value();
    if (!is_method(property_)) {
        __catspeak_error_got(dbgError, property_);
    }
    return property_(property_() / value_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_property_set_sub__() {
    var property_ = property();
    var value_ = value();
    if (!is_method(property_)) {
        __catspeak_error_got(dbgError, property_);
    }
    return property_(property_() - value_);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_property_set_plus__() {
    var property_ = property();
    var value_ = value();
    if (!is_method(property_)) {
        __catspeak_error_got(dbgError, property_);
    }
    return property_(property_() + value_);
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
    return self_ ?? (global.__catspeakGmlSelf ?? globals);
}

/// @ignore
/// @return {Any}
function __catspeak_expr_other__() {
    return global.__catspeakGmlOther ?? globals;
}

/// @ignore
/// @return {Any}
function __catspeak_expr_params_get__() {
    var key_ = key();
    return args[key_];
}

/// @ignore
/// @return {Any}
function __catspeak_expr_params_count_get__() {
    return currentArgCount;
}

/// @ignore
function __catspeak_init_codegen() {
    /// @ignore
    global.__catspeakGmlReturnRef = [undefined];
    /// @ignore
    global.__catspeakGmlBreakRef = [undefined];
    /// @ignore
    global.__catspeakGmlContinueRef = [];
    /// @ignore
    global.__catspeakGmlSelf = undefined;
    /// @ignore
    global.__catspeakGmlOther = undefined;
    /// @ignore
    global.__catspeakGmlSpecialVars = { };
    var db = global.__catspeakGmlSpecialVars;
    // addresses an LTS bug where self[$ name] = val doesn't work for internal properties
    db[$ "enabled"] = function (s, v) { s.enabled = v };
    db[$ "left"] = function (s, v) { s.left = v };
    db[$ "right"] = function (s, v) { s.right = v };
    db[$ "top"] = function (s, v) { s.top = v };
    db[$ "bottom"] = function (s, v) { s.bottom = v };
    db[$ "tilemode"] = function (s, v) { s.tilemode = v };
    db[$ "frame"] = function (s, v) { s.frame = v };
    db[$ "length"] = function (s, v) { s.length = v };
    db[$ "stretch"] = function (s, v) { s.stretch = v };
    db[$ "channels"] = function (s, v) { s.channels = v };
    db[$ "channel"] = function (s, v) { s.channel = v };
    db[$ "sequence"] = function (s, v) { s.sequence = v };
    db[$ "headPosition"] = function (s, v) { s.headPosition = v };
    db[$ "headDirection"] = function (s, v) { s.headDirection = v };
    db[$ "speedScale"] = function (s, v) { s.speedScale = v };
    db[$ "volume"] = function (s, v) { s.volume = v };
    db[$ "paused"] = function (s, v) { s.paused = v };
    db[$ "finished"] = function (s, v) { s.finished = v };
    db[$ "activeTracks"] = function (s, v) { s.activeTracks = v };
    db[$ "elementID"] = function (s, v) { s.elementID = v };
    db[$ "name"] = function (s, v) { s.name = v };
    db[$ "loopmode"] = function (s, v) { s.loopmode = v };
    db[$ "playbackSpeed"] = function (s, v) { s.playbackSpeed = v };
    db[$ "playbackSpeedType"] = function (s, v) { s.playbackSpeedType = v };
    db[$ "xorigin"] = function (s, v) { s.xorigin = v };
    db[$ "yorigin"] = function (s, v) { s.yorigin = v };
    db[$ "tracks"] = function (s, v) { s.tracks = v };
    db[$ "messageEventKeyframes"] = function (s, v) { s.messageEventKeyframes = v };
    db[$ "momentKeyframes"] = function (s, v) { s.momentKeyframes = v };
    db[$ "event_create"] = function (s, v) { s.event_create = v };
    db[$ "event_destroy"] = function (s, v) { s.event_destroy = v };
    db[$ "event_clean_up"] = function (s, v) { s.event_clean_up = v };
    db[$ "event_step"] = function (s, v) { s.event_step = v };
    db[$ "event_step_begin"] = function (s, v) { s.event_step_begin = v };
    db[$ "event_step_end"] = function (s, v) { s.event_step_end = v };
    db[$ "event_async_system"] = function (s, v) { s.event_async_system = v };
    db[$ "event_broadcast_message"] = function (s, v) { s.event_broadcast_message = v };
    db[$ "type"] = function (s, v) { s.type = v };
    db[$ "subType"] = function (s, v) { s.subType = v };
    db[$ "traits"] = function (s, v) { s.traits = v };
    db[$ "interpolation"] = function (s, v) { s.interpolation = v };
    db[$ "visible"] = function (s, v) { s.visible = v };
    db[$ "linked"] = function (s, v) { s.linked = v };
    db[$ "linkedTrack"] = function (s, v) { s.linkedTrack = v };
    db[$ "keyframes"] = function (s, v) { s.keyframes = v };
    db[$ "disabled"] = function (s, v) { s.disabled = v };
    db[$ "spriteIndex"] = function (s, v) { s.spriteIndex = v };
    db[$ "soundIndex"] = function (s, v) { s.soundIndex = v };
    db[$ "emitterIndex"] = function (s, v) { s.emitterIndex = v };
    db[$ "playbackMode"] = function (s, v) { s.playbackMode = v };
    db[$ "imageIndex"] = function (s, v) { s.imageIndex = v };
    db[$ "value"] = function (s, v) { s.value = v };
    db[$ "colour"] = function (s, v) { s.colour = v };
    db[$ "color"] = function (s, v) { s.color = v };
    db[$ "curve"] = function (s, v) { s.curve = v };
    db[$ "objectIndex"] = function (s, v) { s.objectIndex = v };
    db[$ "text"] = function (s, v) { s.text = v };
    db[$ "events"] = function (s, v) { s.events = v };
    db[$ "event"] = function (s, v) { s.event = v };
    db[$ "graphType"] = function (s, v) { s.graphType = v };
    db[$ "iterations"] = function (s, v) { s.iterations = v };
    db[$ "points"] = function (s, v) { s.points = v };
    db[$ "posx"] = function (s, v) { s.posx = v };
    db[$ "matrix"] = function (s, v) { s.matrix = v };
    db[$ "posy"] = function (s, v) { s.posy = v };
    db[$ "rotation"] = function (s, v) { s.rotation = v };
    db[$ "scalex"] = function (s, v) { s.scalex = v };
    db[$ "scaley"] = function (s, v) { s.scaley = v };
    db[$ "gain"] = function (s, v) { s.gain = v };
    db[$ "pitch"] = function (s, v) { s.pitch = v };
    db[$ "width"] = function (s, v) { s.width = v };
    db[$ "height"] = function (s, v) { s.height = v };
    db[$ "imagespeed"] = function (s, v) { s.imagespeed = v };
    db[$ "colormultiply"] = function (s, v) { s.colormultiply = v };
    db[$ "colourmultiply"] = function (s, v) { s.colourmultiply = v };
    db[$ "coloradd"] = function (s, v) { s.coloradd = v };
    db[$ "colouradd"] = function (s, v) { s.colouradd = v };
    db[$ "instanceID"] = function (s, v) { s.instanceID = v };
    db[$ "track"] = function (s, v) { s.track = v };
    db[$ "parent"] = function (s, v) { s.parent = v };
    db[$ "objects_touched"] = function (s, v) { s.objects_touched = v };
    db[$ "objects_collected"] = function (s, v) { s.objects_collected = v };
    db[$ "traversal_time"] = function (s, v) { s.traversal_time = v };
    db[$ "collection_time"] = function (s, v) { s.collection_time = v };
    db[$ "gc_frame"] = function (s, v) { s.gc_frame = v };
    db[$ "generation_collected"] = function (s, v) { s.generation_collected = v };
    db[$ "num_generations"] = function (s, v) { s.num_generations = v };
    db[$ "num_objects_in_generation"] = function (s, v) { s.num_objects_in_generation = v };
    db[$ "ref"] = function (s, v) { s.ref = v };
}