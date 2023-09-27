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
/// @param {Any} value
///   The value to check is a Catspeak function.
///
/// @return {Bool}
function is_catspeak(value) {
    return is_method(value) && method_get_index(value) == __catspeak_function__;
}

/// Used by Catspeak code generators to expose foreign GML functions,
/// constants, and properties to the generated Catspeak programs.
function CatspeakForeignInterface() constructor {
    /// @ignore
    self.database = { };
    /// @ignore
    self.databaseDynConst = { }; // contains keywords marked as "dynamic constants"
    /// @ignore
    self.banList = { };

    /// Returns the value of a foreign symbol exposed to this interface.
    ///
    /// @param {String} name
    ///   The name of the symbol as it appears in Catspeak.
    ///
    /// @return {Any}
    static get = function (name) {
        if (variable_struct_exists(banList, name)) {
            // this function has been banned!
            return undefined;
        }
        return database[$ name];
    };

    /// Returns whether the foreign symbol is a "dynamic constant".
    /// If the symbol hasn't been added then this function returns `false`.
    ///
    /// @experimental
    ///
    /// @param {String} name
    ///   The name of the symbol as it appears in Catspeak.
    ///
    /// @return {Bool}
    static isDynamicConstant = function (name) {
        return databaseDynConst[$ name] ?? false;
    };

    /// Returns whether a foreign symbol is exposed to this interface.
    ///
    /// @param {String} name
    ///   The name of the symbol as it appears in Catspeak.
    ///
    /// @return {Bool}
    static exists = function (name) {
        if (variable_struct_exists(banList, name)) {
            // this function has been banned!
            return false;
        }
        return variable_struct_exists(database, name);
    };

    /// Bans an array of symbols from being used by this interface. Any
    /// symbols in this list will be treated as though they do not exist. To
    /// unban a set of symbols, you should use the `addPardonList` method.
    ///
    /// If a symbol was previously banned, this function will have no effect.
    ///
    /// @param {String} ban
    ///   The symbol to ban the usage of from within Catspeak.
    static addBanList = function () {
        var banList_ = banList;
        for (var i = 0; i < argument_count; i += 1) {
            var ban = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("ban", ban, is_string);
            }
            banList_[$ ban] = true;
        }
    };

    /// Pardons an array of symbols within this interface.
    ///
    /// If a symbol was not previously banned by `addBanList`, there will be
    /// no effect.
    ///
    /// @param {String} pardon
    ///   The symbol to pardon the usage of from within Catspeak.
    static addPardonList = function () {
        var banList_ = banList;
        for (var i = 0; i < argument_count; i += 1) {
            var pardon = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("pardon", pardon, is_string);
            }
            if (variable_struct_exists(banList_, pardon)) {
                variable_struct_remove(banList_, pardon);
            }
        }
    };

    /// Exposes a constant value to this interface.
    ///
    /// @remark
    ///   You cannot expose GML functions using this method. Instead you
    ///   should use one of `exposeDynamicConstant`, `exposeFunction`, or
    ///   `exposeMethod`.
    ///
    /// @param {String} name
    ///   The name of the constant as it will appear in Catspeak.
    ///
    /// @param {Any} value
    ///   The constant value to add.
    static exposeConstant = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var value = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
                //__catspeak_check_arg_not("value", value, __catspeak_is_callable);
            }
            database[$ name] = value;
        }
    };

    /// Exposes a "dynamic constant" to this interface. The value provided for
    /// the constant should be a script or method. When the dynamic constant
    /// is evaluated at runtime, the method will be executed with zero
    /// arguments and the return value used as the value of the constant.
    ///
    /// @experimental
    ///
    /// @param {String} name
    ///   The name of the constant as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script ID or function to add.
    static exposeDynamicConstant = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var func = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
                __catspeak_check_arg("func", func, is_method);
            }
            func = is_method(func) ? func : method(undefined, func);
            database[$ name] = func;
            databaseDynConst[$ name] = true;
        }
    };

    /// Exposes a new unbound function to this interface. When passed a bound
    /// method (i.e. a non-global function), it will be unbound before it is
    /// added to the interface.
    ///
    /// @remark
    ///   If you would prefer to keep the bound `self` of a method, you should
    ///   use the `exposeMethod` method instead.
    ///
    /// @param {String} name
    ///   The name of the function as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script ID or function to add.
    static exposeFunction = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var func = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
                //__catspeak_check_arg("func", func, __catspeak_is_callable);
            }
            func = is_method(func) ? method_get_index(func) : func;
            database[$ name] = method(undefined, func);
        }
    };

    /// Behaves similarly to `exposeFunction`, except the name of definition
    /// is inferred. There are three ways this name will be inferred:
    ///
    ///  1) If the value is a script resource, `script_get_name` is used.
    ///  2) If the value is a method and a `name` field exists, then the value
    ///     of this `name` field will be used as the name.
    ///  3) If the value is a method and a `name` field does not exist, then
    ///     `script_get_name` will be called on the underlying bound script
    ///     resource.
    ///
    /// @remark
    ///   If you would prefer to keep the bound `self` of a method, you should
    ///   use the `exposeMethodByName` method instead.
    ///
    /// @param {Function} func
    ///   The script ID or function to add.
    static exposeFunctionByName = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var func = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                //__catspeak_check_arg("func", func, __catspeak_is_callable);
            }
            var name = __catspeak_infer_function_name(func);
            func = is_method(func) ? method_get_index(func) : func;
            database[$ name] = method(undefined, func);
        }
    };

    /// Exposes many user-defined global GML functions to this interface which
    /// share a common prefix.
    ///
    /// @param {String} namespace
    ///   The common prefix for the set of functions you want to expose to
    ///   Catspeak.
    static exposeFunctionByPrefix = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var namespace = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("namespace", namespace, is_string);
            }
            // asset scanning for functions can be a lil weird, in my experience
            // i've came across a few variations
            //
            // their positions aren't always 100% known, except for anon
            // (which is always at the front)
            var database_ = database;
            for (var scriptID = 100001; script_exists(scriptID); scriptID += 1) {
                var name = script_get_name(scriptID);
                if (
                    string_starts_with(name, "anon") ||
                    string_count("gml_GlobalScript", name) > 0 ||
                    string_count("__struct__", name) > 0
                ) {
                    continue;
                }
                if (string_starts_with(name, namespace)) {
                    database_[$ name] = method(undefined, scriptID); 
                }
            }
        }
    };

    /// Exposes a new bound function to this interface.
    ///
    /// @remark
    ///   If you would prefer to ignore the bound `self` value of the function,
    ///   and treat it as a global script, you should use the `exposeFunction`
    ///   method instead.
    ///
    /// @param {String} name
    ///   The name of the method as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script ID or method to add.
    static exposeMethod = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var func = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
                //__catspeak_check_arg("func", func, __catspeak_is_callable);
            }
            func = is_method(func) ? func : method(undefined, func);
            database[$ name] = func;
        }
    };

    /// Behaves similarly to `exposeMethod`, except the name of definition
    /// is inferred. There are three ways a name will be inferred:
    ///
    ///  1) If the value is a script resource, `script_get_name` is used.
    ///  2) If the value is a method and a `name` field exists, then the value
    ///     of this `name` field will be used as the name.
    ///  3) If the value is a method and a `name` field does not exist, then
    ///     `script_get_name` will be called on the underlying bound script
    ///     resource.
    ///
    /// @remark
    ///   If you would prefer to ignore the bound `self` value of the function,
    ///   and treat it as a global script, you should use the
    ///   `exposeFunctionByName` method instead.
    ///
    /// @param {Function} func
    ///   The script ID or method to add.
    static exposeMethodByName = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var func = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                //__catspeak_check_arg("func", func, __catspeak_is_callable);
            }
            var name = __catspeak_infer_function_name(func);
            func = is_method(func) ? func : method(undefined, func);
            database[$ name] = func;
        }
    };

    /// Exposes a GameMaker asset from the resource tree to this interface.
    ///
    /// @param {String} name
    ///   The name of the GM asset that you wish to expose to Catspeak.
    static exposeAsset = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var name = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            var value = asset_get_index(name);
            var type = asset_get_type(name);
            // validate that it's an actual GM Asset
            if (value == -1) {
                __catspeak_error(
                    "invalid GMAsset: got '", value, "' from '", name, "'"
                );
            }
            if (type == asset_script) {
                // scripts must be coerced into methods
                value = method(undefined, value);
            }
            database[$ name] = value;
        }
    };

    /// Exposes a set of tagged GameMaker assets to this interface.
    ///
    /// @param {Any} tag
    ///   The name of a tag, or array of tags, of assets to expose to Catspeak.
    static exposeAssetByTag = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var assets = tag_get_assets(argument[i]);
            for (var j = array_length(assets) - 1; j >= 0; j -= 1) {
                exposeAsset(assets[j]);
            }
        }
    };
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
    static __compileUse = function (ctx, term) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg_struct("term", term,
                "condition", undefined,
                "body", undefined
            );
        }
        return method({
            dbgError : __dbgTerm(term.condition, "is not a function"),
            condition : __compileTerm(ctx, term.condition),
            body : __compileTerm(ctx, term.body),
        }, __catspeak_expr_use__);
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
                dbgError : __dbgTerm(term.callee, "is not a function"),
                collection : collection,
                key : key,
                args : exprs,
                shared : sharedData,
            }, __catspeak_expr_call_method__);
        } else {
            var callee = __compileTerm(ctx, term.callee);
            return method({
                dbgError : __dbgTerm(term.callee, "is not a function"),
                callee : callee,
                args : exprs,
                shared : sharedData,
            }, __catspeak_expr_call__);
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
                    args : [],
                    shared : sharedData,
                }, __catspeak_expr_call__);
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
        db[@ CatspeakTerm.WHILE] = __compileWhile;
        db[@ CatspeakTerm.MATCH] = __compileMatch;
        db[@ CatspeakTerm.USE] = __compileUse;
        db[@ CatspeakTerm.RETURN] = __compileReturn;
        db[@ CatspeakTerm.BREAK] = __compileBreak;
        db[@ CatspeakTerm.CONTINUE] = __compileContinue;
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
        db[@ CatspeakTerm.AND] = __compileAnd;
        db[@ CatspeakTerm.OR] = __compileOr;
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
///@return {Any}
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
function __catspeak_expr_use__() {
    var body_ = body;
    var open = condition();
    if (!is_method(open)) {
        __catspeak_error_got(dbgError, open);
    }
    var close = open();
    if (!is_method(close)) {
        __catspeak_error_got(dbgError, close);
    }
    var result;
    try {
        result = body_();
    } finally {
        close();
    }
    return result;
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
function __catspeak_expr_call_method__() {
    // TODO :: this method call stuff is crap, please figure out a better way
    var collection_ = collection();
    var key_ = key();
    var callee_;
    if (is_array(collection_)) {
        callee_ = collection_[key_];
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
    var shared_ = shared;
    with (method_get_self(callee_) ?? collection_) {
        var calleeIdx = method_get_index(callee_);
        return script_execute_ext(calleeIdx, args_);
    }
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