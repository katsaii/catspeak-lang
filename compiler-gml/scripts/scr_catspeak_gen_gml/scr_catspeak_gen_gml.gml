// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/templates/compiler-gml/scripts/scr_catspeak_gen_gml/scr_catspeak_gen_gml.gml

//! Transforms Catspeak IR into callable GML functions.
//!
//! This stage of the compiler is very unintelligent, and may produce bad
//! results if given invalid IR.
//!
//! @advanced
//! @experimental

//# feather use syntax-errors

/// A visitor to be used by `CatspeakCartReader` which lowers a Catspeak
/// cartridge into an executable GML method.
///
/// @param {Struct} [modules_]
///   A struct containing modules visible to this cartridge.
///
/// @param {Struct} [globals_]
///   The struct to use as global scope for unbound variables in Catspeak.
function CatspeakGenGML(modules_ = undefined, globals_ = undefined) constructor {
    /// @ignore
    exprStack = undefined;
    /// @ignore
    funcs = undefined;
    /// @ignore
    modules = modules_;
    /// @ignore
    globals = globals_;
    /// @ignore
    importsMap = undefined;
    /// @ignore
    importsCache = undefined;
    /// @ignore
    importsResults = undefined;
    /// @ignore
    ctx = undefined;
    /// @ignore
    localsN = 0;
    /// @ignore
    hasDebug = false;
    /// @ignore
    requiresScopes = false;
    /// @ignore
    isAlive = false;

    /// Frees any dynamically allocated resources managed by this generator.
    ///
    /// @warning
    ///   This **must** be called in a `finally` block if you expect exceptions.
    static destroy = function () {
        if (!isAlive) {
            return;
        }
        ds_stack_destroy(exprStack);
        exprStack = undefined;
        ds_list_destroy(funcs);
        funcs = undefined;
        isAlive = false;
    };

    /// Finalises the code generation of the current cartridge, returning the
    /// entrypoint function.
    ///
    /// This method will also free the memory allocated by this builder, and
    /// mark it for garbage collection.
    ///
    /// @return {Function}
    static finalise = function () {
        __catspeak_assert(isAlive, __catspeak_cat(
            "cannot call `finalise` method on empty cartridge ",
            "(check you haven't called `finalise` more than once!)"
        ));
        var program;
        try {
            __catspeak_assert_eq(0, ds_stack_size(exprStack),
                "unbalanced stack! this may be caused by malformed cartridge"
            );
            var programIdx = ds_list_size(funcs) - 1;
            __catspeak_assert(programIdx >= 0,
                "cartridge is missing an entry-point"
            );
            program = funcs[| programIdx];
        } finally {
            destroy();
        }
        return program;
    };

    /// @ignore
    static handleMeta = function (name, author, version, versionMinor, patch, path, date) {
        isAlive = true;
        exprStack = ds_stack_create();
        funcs = ds_list_create();
        importsMap = { };
        importsCache = { };
        importsResults = { };
        ctx = {
            globals : globals ?? { },
            binding : undefined,
            stack : [],
            stackN : 0, // current stack size
            callee_ : undefined,
            dbg : CATSPEAK_NOLOCATION,
            meta : {
                name : name,
                author : author,
                version : version,
                versionMinor : versionMinor,
                patch : patch,
                path : path,
                date : date,
            },
        };
    };

    /// @ignore
    static handleInclude = function (path, alias) {
        var module_ = undefined;
        var relPath = ctx.meta.path + "::" + path;
        if (variable_struct_exists(modules, relPath)) {
            module_ = modules[$ relPath];
            importsResults[$ relPath] = module_.result;
        } else if (variable_struct_exists(modules, path)) {
            module_ = modules[$ path];
        }
        if (module_ == undefined) {
            __catspeak_error(__catspeak_cat(
                "failed to import module '", path,
                "' (this could be caused by a cyclic dependency)"
            ));
        }
        importsResults[$ path] = module_.result;
        var candidates = importsMap[$ alias] ?? [];
        array_push(candidates, module_);
        importsMap[$ alias] = candidates;
    };

    /// @ignore
    static handleFunc = function (idx, argc) {
        var body = ds_stack_pop(exprStack);
        __catspeak_assert(body != undefined,
            "unbalanced stack! function is missing body"
        );
        if (hasDebug) {
            body = __genExpr({
                body : body,
            }, __catspeak_dbg_trace__);
        }
        if (requiresScopes) {
            body = __genExpr({
                body : body,
            }, __catspeak_scopes_init__);
        }
        var func;
        if (localsN > 0) {
            __catspeak_assert(localsN >= argc, "not enough room for function arguments");
            func = __genExpr({
                body : body,
                n : localsN,
                argc : argc,
            }, __catspeak_function__);
        } else {
            func = body;
        }
        funcs[| idx] = func;
        localsN = 0;
        hasDebug = false;
        requiresScopes = false;
    };

    /// @ignore
    static __attachDbg = function (dbg, expr) {
        if (dbg == CATSPEAK_NOLOCATION) {
            return expr;
        } else {
            // insert instruction to track debug info
            hasDebug = true;
            return __genExpr({
                dbg : dbg,
                body : expr,
            }, __catspeak_dbg__);
        }
    };

    if (!variable_global_exists("__catspeakSharedUnwindBox")) {
        // guarantee the special unwind box exists if we're generating code
        global.__catspeakSharedUnwindBox = [undefined, undefined];
    }

    /// @ignore
    static __genExpr = function (self_, func_) {
        self_ ??= { };
        self_.ctx = ctx;
        return method(self_, func_);
    };

    /// @ignore
    static __genExprClosure = function (idx) {
        return __genExpr({
            value : funcs[| idx],
        }, __catspeak_instr_fclo_simple__);
    };

    /// @ignore
    static __genExprSequence_vers = undefined;
    static __genExprSequence_versN = 0;
    if (__genExprSequence_vers == undefined) {
        __genExprSequence_vers = [
            __catspeak_instr_seq_0__,
            __catspeak_instr_seq_1__,
            __catspeak_instr_seq_2__,
            __catspeak_instr_seq_3__,
            __catspeak_instr_seq_4__,
            __catspeak_instr_seq_5__,
            __catspeak_instr_seq_6__,
            __catspeak_instr_seq_7__,
            __catspeak_instr_seq_8__,
            __catspeak_instr_seq_9__,
        ];
        __genExprSequence_versN = array_length(__genExprSequence_vers);
    }

    /// @ignore
    static __genExprSequence = function (n, stmts) {
        var nStatic = min(n, __genExprSequence_versN - 1);
        var closure_ = { };
        for (var i = 0; i < nStatic; i += 1) {
            closure_[$ "_" + string(i + 1)] = stmts[i];
        }
        if (n == nStatic) {
            return __genExpr(closure_, __genExprSequence_vers[n]);
        } else {
            // encode statments in reverse for (maybe) faster iteration
            var moreN = n - __genExprSequence_versN;
            var more = array_create(moreN);
            for (var i = 0; i < moreN; i += 1) {
                more[@ i] = stmts[n - 2 - i];
            }
            closure_.moreN = moreN;
            closure_.more = more;
            closure_.result = stmts[n - 1];
            return __genExpr(closure_, __catspeak_instr_seq__);
        }
    };

    /// @ignore
    static __localIdx2Offset = function (idx) { return -1 - idx }

    /// @ignore
    static __genExprGetLocal = function (idx) {
        localsN = max(localsN, idx + 1);
        return __genExpr({
            off : __localIdx2Offset(idx), // relative to the top of the stack
        }, __catspeak_instr_get_l__);
    };

    /// @ignore
    static __genExprSetLocal = function (flavour, idx, value) {
        localsN = max(localsN, idx + 1);
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_l__; break;
        case ord("+"): func = __catspeak_instr_set_l_add__; break;
        case ord("-"): func = __catspeak_instr_set_l_sub__; break;
        case ord("*"): func = __catspeak_instr_set_l_mul__; break;
        case ord("/"): func = __catspeak_instr_set_l_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            off : __localIdx2Offset(idx),
        }, func);
    };

    static __findModuleItem = function (name, path) {
        var cacheName = path + "::" + name;
        if (variable_struct_exists(importsCache, cacheName)) {
            return importsCache[$ cacheName];
        }
        var candidates = importsMap[$ path];
        var foundModule = undefined;
        var foundValue = undefined;
        for (var i = array_length(candidates) - 1; i >= 0; i -= 1) {
            // check modules for globals, otherwise fallback to the Catspeak global
            var module_ = candidates[i];
            if (module_.exists(name)) {
                if (foundModule != undefined) {
                    __catspeak_error(__catspeak_cat(
                        "ambiguous import: module item '", name, "' exists in both '",
                        module_.path, "' and '", foundModule.path, "'"
                    ));
                }
                foundModule = module_;
                foundValue = module_.get(name);
            }
        }
        var result = { hasValue : foundModule != undefined, value : foundValue };
        importsCache[$ cacheName] = result;
        return result;
    };

    /// @ignore
    static __genExprGetGlobal = function (name, path) {
        var result;
        result = __findModuleItem(name, path);
        if (result.hasValue) {
            return __genExpr({
                value : result.value,
            }, __catspeak_instr_module_value__);
        }
        result = __findModuleItem(name + "_get", path);
        if (result.hasValue) {
            // getters
            return __genExprCall(
                0, __genExpr({
                    value : result.value,
                }, __catspeak_instr_module_value__), []
            );
        }
        return __genExpr({ name : name }, __catspeak_instr_get_g__);
    };

    /// @ignore
    static __genExprSetGlobal = function (flavour, name, path, value) {
        // TODO :: setters on modules
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_g__; break;
        case ord("+"): func = __catspeak_instr_set_g_add__; break;
        case ord("-"): func = __catspeak_instr_set_g_sub__; break;
        case ord("*"): func = __catspeak_instr_set_g_mul__; break;
        case ord("/"): func = __catspeak_instr_set_g_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({ value : value, name : name }, func);
    };

    /// @ignore
    static __genExprSelf = function () {
        requiresScopes = true;
        return __genExpr(undefined, __catspeak_instr_self__);
    };

    /// @ignore
    static __genExprOther = function () {
        requiresScopes = true;
        return __genExpr(undefined, __catspeak_instr_othr__);
    };

    /// @ignore
    static __genExprGetIndexString = function (idx, data) {
        return __genExpr({
            data : data,
            idx : idx,
        }, __catspeak_instr_get_is__);
    };

    /// @ignore
    static __genExprSetIndexString = function (flavour, idx, data, value) {
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_is__; break;
        case ord("+"): func = __catspeak_instr_set_is_add__; break;
        case ord("-"): func = __catspeak_instr_set_is_sub__; break;
        case ord("*"): func = __catspeak_instr_set_is_mul__; break;
        case ord("/"): func = __catspeak_instr_set_is_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            data : data,
            idx : idx,
        }, func);
    };

    /// @ignore
    static __genExprGetIndexNumber = function (idx, data) {
        return __genExpr({
            data : data,
            idx : idx,
        }, __catspeak_instr_get_in__);
    };

    /// @ignore
    static __genExprSetIndexNumber = function (flavour, idx, data, value) {
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_in__; break;
        case ord("+"): func = __catspeak_instr_set_in_add__; break;
        case ord("-"): func = __catspeak_instr_set_in_sub__; break;
        case ord("*"): func = __catspeak_instr_set_in_mul__; break;
        case ord("/"): func = __catspeak_instr_set_in_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            data : data,
            idx : idx,
        }, func);
    };

    /// @ignore
    static __genExprGetIndex = function (data, idx) {
        return __genExpr({
            data : data,
            idx : idx,
        }, __catspeak_instr_get_i__);
    };

    /// @ignore
    static __genExprSetIndex = function (flavour, data, idx, value) {
        var func;
        switch (flavour) {
        case ord("="): func = __catspeak_instr_set_i__; break;
        case ord("+"): func = __catspeak_instr_set_i_add__; break;
        case ord("-"): func = __catspeak_instr_set_i_sub__; break;
        case ord("*"): func = __catspeak_instr_set_i_mul__; break;
        case ord("/"): func = __catspeak_instr_set_i_div__; break;
        default:
            __catspeak_error_bug();
            break;
        }
        return __genExpr({
            value : value,
            data : data,
            idx : idx,
        }, func);
    };

    /// @ignore
    static __genExprThrow = function (value) {
        return __genExpr({
            value : value,
        }, __catspeak_instr_thrw__);
    };

    /// @ignore
    static __genExprCatch = function (idx, eager, lazy) {
        localsN = max(localsN, idx + 1);
        return __genExpr({
            magicBox : global.__catspeakSharedUnwindBox,
            off : __localIdx2Offset(idx),
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_cat__);
    };

    /// @ignore
    static __genExprUnwind = function (label, value) {
        return __genExpr({
            magicBox : global.__catspeakSharedUnwindBox,
            label : label,
            value : value,
        }, __catspeak_instr_uwnd__);
    };

    /// @ignore
    static __genExprUnwindLanding = function (label, body) {
        return __genExpr({
            magicBox : global.__catspeakSharedUnwindBox,
            label : label,
            body : body,
        }, __catspeak_instr_land__);
    };

    /// @ignore
    static __genExprLoopInf = function (body) {
        return __genExpr({
            body : body,
        }, __catspeak_instr_loop_inf__);
    };

    /// @ignore
    static __genExprLoop = function (cond, body) {
        return __genExpr({
            cond : cond,
            body : body,
        }, __catspeak_instr_loop__);
    };

    /// @ignore
    static __genExprLoopStep = function (cond, step, body) {
        return __genExpr({
            cond : cond,
            step : step,
            body : body,
        }, __catspeak_instr_loop_s__);
    };

    /// @ignore
    static __genExprLoopWith = function (cond, body) {
        requiresScopes = true;
        return __genExpr({
            cond : cond,
            body : body,
        }, __catspeak_instr_loop_w__);
    };

    /// @ignore
    static __genExprArray_vers = undefined;
    static __genExprArray_versN = 0;
    if (__genExprArray_vers == undefined) {
        __genExprArray_vers = [
            __catspeak_instr_arr_0__,
            __catspeak_instr_arr_1__,
            __catspeak_instr_arr_2__,
            __catspeak_instr_arr_3__,
            __catspeak_instr_arr_4__,
            __catspeak_instr_arr_5__,
            __catspeak_instr_arr_6__,
            __catspeak_instr_arr_7__,
            __catspeak_instr_arr_8__,
            __catspeak_instr_arr_9__,
        ];
        __genExprArray_versN = array_length(__genExprArray_vers);
    }

    /// @ignore
    static __genExprArray = function (n, values) {
        var nStatic = min(n, __genExprArray_versN - 1);
        var closure_ = { };
        for (var i = 0; i < nStatic; i += 1) {
            closure_[$ "_" + string(i + 1)] = values[i];
        }
        if (n == nStatic) {
            return __genExpr(closure_, __genExprArray_vers[n]);
        } else {
            var moreN = n - __genExprArray_versN + 1;
            var more = array_create(moreN);
            for (var i = 0; i < moreN; i += 1) {
                more[@ i] = values[__genExprArray_versN + i];
            }
            closure_.moreN = moreN;
            closure_.more = more;
            return __genExpr(closure_, __catspeak_instr_arr__);
        }
    };

    /// @ignore
    static __genExprStruct_vers = undefined;
    static __genExprStruct_versN = 0;
    if (__genExprStruct_vers == undefined) {
        __genExprStruct_vers = [
            __catspeak_instr_obj_0__,
            __catspeak_instr_obj_1__,
            __catspeak_instr_obj_2__,
            __catspeak_instr_obj_3__,
            __catspeak_instr_obj_4__,
        ];
        __genExprStruct_versN = array_length(__genExprStruct_vers);
    }

    /// @ignore
    static __genExprStruct = function (n, values) {
        __catspeak_assert(n % 2 == 0,
            "'obj' instructions must have an even number of 'values'"
        );
        n = n div 2;
        var nStatic = min(n, __genExprStruct_versN - 1);
        var closure_ = { };
        for (var i = 0; i < nStatic; i += 1) {
            closure_[$ "_k" + string(i + 1)] = values[i * 2];
            closure_[$ "_v" + string(i + 1)] = values[i * 2 + 1];
        }
        if (n == nStatic) {
            return __genExpr(closure_, __genExprStruct_vers[n]);
        } else {
            // encode values in reverse for (maybe) faster iteration
            var moreN = n - __genExprStruct_versN + 1;
            var more = array_create(moreN * 2);
            for (var i = 0; i < moreN; i += 1) {
                more[@ i * 2] = values[n - 2 - i];
                more[@ i * 2 + 1] = values[n - 1 - i];
            }
            closure_.moreN = moreN;
            closure_.more = more;
            return __genExpr(closure_, __catspeak_instr_obj__);
        }
    };

    /// @ignore
    static __genExprCall_vers = undefined;
    static __genExprCall_versN = 0;
    if (__genExprCall_vers == undefined) {
        __genExprCall_vers = [
            __catspeak_instr_call_0__,
            __catspeak_instr_call_1__,
            __catspeak_instr_call_2__,
            __catspeak_instr_call_3__,
            __catspeak_instr_call_4__,
            __catspeak_instr_call_5__,
            __catspeak_instr_call_6__,
            __catspeak_instr_call_7__,
            __catspeak_instr_call_8__,
        ];
        __genExprCall_versN = array_length(__genExprCall_vers);
    }

    /// @ignore
    static __genExprCall = function (n, callee, args) {
        requiresScopes = true;
        var closure_ = { callee : callee };
        if (n < __genExprCall_versN) {
            for (var i = 0; i < n; i += 1) {
                closure_[$ "_" + string(i + 1)] = args[i];
            }
            return __genExpr(closure_, __genExprCall_vers[n]);
        } else {
            closure_.argsN = n;
            closure_.args = args;
            return __genExpr(closure_, __catspeak_instr_call__);
        }
    };

    /// @ignore
    static __genExprCallIndex = function (n, data, idx, args) {
        requiresScopes = true;
        return __genExpr({
            data : data,
            idx : idx,
            argsN : n,
            args : args
        }, __catspeak_instr_call_i__);
    };

    /// @ignore
    static __genExprConstImport = function (path) {
        if (!variable_struct_exists(importsResults, path)) {
            __catspeak_error(__catspeak_cat(
                "cannot find module result with path '", path, "'"
            ));
        }
        return __genExpr({
            value : importsResults[$ path],
        }, __catspeak_instr_module_value__);
    };

    // automatically generated code generation functions (here be dragons)

    /// @ignore
    static handleInstrCall = function (dbg, n) {
        var exprStack_ = exprStack;
        var args__n = n;
        var args__nGot = ds_stack_size(exprStack_);
        if (args__nGot < args__n) {
            __catspeak_error(__catspeak_cat(
                "not enough stack space for 'args' argument of 'call' instruction (expected ",
                args__n, ", got ", args__nGot, ")"
            ));
        }
        var args = array_create(args__n);
        for (var i = args__n - 1; i >= 0; i -= 1) {
            args[@ i] = ds_stack_pop(exprStack_);
        }
        var callee = ds_stack_pop(exprStack_);
        __catspeak_assert(callee != undefined,
            "not enough stack space for 'callee' argument of 'call' instruction"
        );
        var expr;
        expr = __genExprCall(n, callee, args);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrCallIndex = function (dbg, n) {
        var exprStack_ = exprStack;
        var args__n = n;
        var args__nGot = ds_stack_size(exprStack_);
        if (args__nGot < args__n) {
            __catspeak_error(__catspeak_cat(
                "not enough stack space for 'args' argument of 'call_i' instruction (expected ",
                args__n, ", got ", args__nGot, ")"
            ));
        }
        var args = array_create(args__n);
        for (var i = args__n - 1; i >= 0; i -= 1) {
            args[@ i] = ds_stack_pop(exprStack_);
        }
        var idx = ds_stack_pop(exprStack_);
        __catspeak_assert(idx != undefined,
            "not enough stack space for 'idx' argument of 'call_i' instruction"
        );
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'call_i' instruction"
        );
        var expr;
        expr = __genExprCallIndex(n, data, idx, args);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrArray = function (dbg, n) {
        var exprStack_ = exprStack;
        var values__n = n;
        var values__nGot = ds_stack_size(exprStack_);
        if (values__nGot < values__n) {
            __catspeak_error(__catspeak_cat(
                "not enough stack space for 'values' argument of 'arr' instruction (expected ",
                values__n, ", got ", values__nGot, ")"
            ));
        }
        var values = array_create(values__n);
        for (var i = values__n - 1; i >= 0; i -= 1) {
            values[@ i] = ds_stack_pop(exprStack_);
        }
        var expr;
        expr = __genExprArray(n, values);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrStruct = function (dbg, n) {
        var exprStack_ = exprStack;
        var values__n = n;
        var values__nGot = ds_stack_size(exprStack_);
        if (values__nGot < values__n) {
            __catspeak_error(__catspeak_cat(
                "not enough stack space for 'values' argument of 'obj' instruction (expected ",
                values__n, ", got ", values__nGot, ")"
            ));
        }
        var values = array_create(values__n);
        for (var i = values__n - 1; i >= 0; i -= 1) {
            values[@ i] = ds_stack_pop(exprStack_);
        }
        var expr;
        expr = __genExprStruct(n, values);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLoopInf = function (dbg) {
        var exprStack_ = exprStack;
        var body = ds_stack_pop(exprStack_);
        __catspeak_assert(body != undefined,
            "not enough stack space for 'body' argument of 'loop_inf' instruction"
        );
        var expr;
        expr = __genExprLoopInf(body);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLoop = function (dbg) {
        var exprStack_ = exprStack;
        var body = ds_stack_pop(exprStack_);
        __catspeak_assert(body != undefined,
            "not enough stack space for 'body' argument of 'loop' instruction"
        );
        var cond = ds_stack_pop(exprStack_);
        __catspeak_assert(cond != undefined,
            "not enough stack space for 'cond' argument of 'loop' instruction"
        );
        var expr;
        expr = __genExprLoop(cond, body);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLoopStep = function (dbg) {
        var exprStack_ = exprStack;
        var body = ds_stack_pop(exprStack_);
        __catspeak_assert(body != undefined,
            "not enough stack space for 'body' argument of 'loop_s' instruction"
        );
        var step = ds_stack_pop(exprStack_);
        __catspeak_assert(step != undefined,
            "not enough stack space for 'step' argument of 'loop_s' instruction"
        );
        var cond = ds_stack_pop(exprStack_);
        __catspeak_assert(cond != undefined,
            "not enough stack space for 'cond' argument of 'loop_s' instruction"
        );
        var expr;
        expr = __genExprLoopStep(cond, step, body);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLoopWith = function (dbg) {
        var exprStack_ = exprStack;
        var body = ds_stack_pop(exprStack_);
        __catspeak_assert(body != undefined,
            "not enough stack space for 'body' argument of 'loop_w' instruction"
        );
        var cond = ds_stack_pop(exprStack_);
        __catspeak_assert(cond != undefined,
            "not enough stack space for 'cond' argument of 'loop_w' instruction"
        );
        var expr;
        expr = __genExprLoopWith(cond, body);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrUnwind = function (dbg, label) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'uwnd' instruction"
        );
        var expr;
        expr = __genExprUnwind(label, value);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrUnwindLanding = function (dbg, label) {
        var exprStack_ = exprStack;
        var body = ds_stack_pop(exprStack_);
        __catspeak_assert(body != undefined,
            "not enough stack space for 'body' argument of 'land' instruction"
        );
        var expr;
        expr = __genExprUnwindLanding(label, body);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrThrow = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'thrw' instruction"
        );
        var expr;
        expr = __genExprThrow(value);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrCatch = function (dbg, idx) {
        var exprStack_ = exprStack;
        var lazy = ds_stack_pop(exprStack_);
        __catspeak_assert(lazy != undefined,
            "not enough stack space for 'lazy' argument of 'cat' instruction"
        );
        var eager = ds_stack_pop(exprStack_);
        __catspeak_assert(eager != undefined,
            "not enough stack space for 'eager' argument of 'cat' instruction"
        );
        var expr;
        expr = __genExprCatch(idx, eager, lazy);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGetLocal = function (dbg, idx) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprGetLocal(idx);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSetLocal = function (dbg, flavour, idx) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'set_l' instruction"
        );
        var expr;
        expr = __genExprSetLocal(flavour, idx, value);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGetGlobal = function (dbg, name, path) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprGetGlobal(name, path);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSetGlobal = function (dbg, flavour, name, path) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'set_g' instruction"
        );
        var expr;
        expr = __genExprSetGlobal(flavour, name, path, value);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSelf = function (dbg) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprSelf();
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrOther = function (dbg) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprOther();
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGetIndexString = function (dbg, idx) {
        var exprStack_ = exprStack;
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'get_is' instruction"
        );
        var expr;
        expr = __genExprGetIndexString(idx, data);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSetIndexString = function (dbg, flavour, idx) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'set_is' instruction"
        );
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'set_is' instruction"
        );
        var expr;
        expr = __genExprSetIndexString(flavour, idx, data, value);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGetIndexNumber = function (dbg) {
        var exprStack_ = exprStack;
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'get_in' instruction"
        );
        var expr;
        expr = __genExprGetIndexNumber(data);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSetIndexNumber = function (dbg, flavour, idx) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'set_in' instruction"
        );
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'set_in' instruction"
        );
        var expr;
        expr = __genExprSetIndexNumber(flavour, idx, data, value);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGetIndex = function (dbg) {
        var exprStack_ = exprStack;
        var idx = ds_stack_pop(exprStack_);
        __catspeak_assert(idx != undefined,
            "not enough stack space for 'idx' argument of 'get_i' instruction"
        );
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'get_i' instruction"
        );
        var expr;
        expr = __genExprGetIndex(data, idx);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSetIndex = function (dbg, flavour) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'set_i' instruction"
        );
        var idx = ds_stack_pop(exprStack_);
        __catspeak_assert(idx != undefined,
            "not enough stack space for 'idx' argument of 'set_i' instruction"
        );
        var data = ds_stack_pop(exprStack_);
        __catspeak_assert(data != undefined,
            "not enough stack space for 'data' argument of 'set_i' instruction"
        );
        var expr;
        expr = __genExprSetIndex(flavour, data, idx, value);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSequence = function (dbg, n) {
        var exprStack_ = exprStack;
        var stmts__n = n;
        var stmts__nGot = ds_stack_size(exprStack_);
        if (stmts__nGot < stmts__n) {
            __catspeak_error(__catspeak_cat(
                "not enough stack space for 'stmts' argument of 'seq' instruction (expected ",
                stmts__n, ", got ", stmts__nGot, ")"
            ));
        }
        var stmts = array_create(stmts__n);
        for (var i = stmts__n - 1; i >= 0; i -= 1) {
            stmts[@ i] = ds_stack_pop(exprStack_);
        }
        var expr;
        expr = __genExprSequence(n, stmts);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrClosure = function (dbg, idx) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprClosure(idx);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrIfThenElse = function (dbg) {
        var exprStack_ = exprStack;
        var ifFalse = ds_stack_pop(exprStack_);
        __catspeak_assert(ifFalse != undefined,
            "not enough stack space for 'ifFalse' argument of 'ifte' instruction"
        );
        var ifTrue = ds_stack_pop(exprStack_);
        __catspeak_assert(ifTrue != undefined,
            "not enough stack space for 'ifTrue' argument of 'ifte' instruction"
        );
        var condition = ds_stack_pop(exprStack_);
        __catspeak_assert(condition != undefined,
            "not enough stack space for 'condition' argument of 'ifte' instruction"
        );
        var expr;
        expr = __genExpr({
            condition : condition,
            ifTrue : ifTrue,
            ifFalse : ifFalse,
        }, __catspeak_instr_ifte__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrOr = function (dbg) {
        var exprStack_ = exprStack;
        var lazy = ds_stack_pop(exprStack_);
        __catspeak_assert(lazy != undefined,
            "not enough stack space for 'lazy' argument of 'or' instruction"
        );
        var eager = ds_stack_pop(exprStack_);
        __catspeak_assert(eager != undefined,
            "not enough stack space for 'eager' argument of 'or' instruction"
        );
        var expr;
        expr = __genExpr({
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_or__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrXor = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'xor' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'xor' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_xor__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrAnd = function (dbg) {
        var exprStack_ = exprStack;
        var lazy = ds_stack_pop(exprStack_);
        __catspeak_assert(lazy != undefined,
            "not enough stack space for 'lazy' argument of 'and' instruction"
        );
        var eager = ds_stack_pop(exprStack_);
        __catspeak_assert(eager != undefined,
            "not enough stack space for 'eager' argument of 'and' instruction"
        );
        var expr;
        expr = __genExpr({
            eager : eager,
            lazy : lazy,
        }, __catspeak_instr_and__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrEqual = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'eq' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'eq' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_eq__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrNotEqual = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'neq' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'neq' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_neq__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLessThan = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'lt' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'lt' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_lt__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrLessThanOrEqualTo = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'leq' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'leq' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_leq__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGreaterThan = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'gt' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'gt' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_gt__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrGreaterThanOrEqualTo = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'geq' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'geq' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_geq__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseAnd = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'band' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'band' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_band__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseOr = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'bor' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'bor' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bor__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseXor = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'bxor' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'bxor' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_bxor__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseShiftLeft = function (dbg) {
        var exprStack_ = exprStack;
        var amount = ds_stack_pop(exprStack_);
        __catspeak_assert(amount != undefined,
            "not enough stack space for 'amount' argument of 'lshift' instruction"
        );
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'lshift' instruction"
        );
        var expr;
        expr = __genExpr({
            value : value,
            amount : amount,
        }, __catspeak_instr_lshift__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseShiftRight = function (dbg) {
        var exprStack_ = exprStack;
        var amount = ds_stack_pop(exprStack_);
        __catspeak_assert(amount != undefined,
            "not enough stack space for 'amount' argument of 'rshift' instruction"
        );
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'rshift' instruction"
        );
        var expr;
        expr = __genExpr({
            value : value,
            amount : amount,
        }, __catspeak_instr_rshift__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrAdd = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'add' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'add' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_add__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrSubtract = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'sub' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'sub' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_sub__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrMultiply = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'mult' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'mult' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_mult__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrDivide = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'div' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'div' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_div__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrDivideInt = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'idiv' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'idiv' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_idiv__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrRemainder = function (dbg) {
        var exprStack_ = exprStack;
        var rhs = ds_stack_pop(exprStack_);
        __catspeak_assert(rhs != undefined,
            "not enough stack space for 'rhs' argument of 'rem' instruction"
        );
        var lhs = ds_stack_pop(exprStack_);
        __catspeak_assert(lhs != undefined,
            "not enough stack space for 'lhs' argument of 'rem' instruction"
        );
        var expr;
        expr = __genExpr({
            lhs : lhs,
            rhs : rhs,
        }, __catspeak_instr_rem__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrPositive = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'pos' instruction"
        );
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_pos__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrNegative = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'neg' instruction"
        );
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_neg__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrNot = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'not' instruction"
        );
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_not__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrBitwiseNot = function (dbg) {
        var exprStack_ = exprStack;
        var value = ds_stack_pop(exprStack_);
        __catspeak_assert(value != undefined,
            "not enough stack space for 'value' argument of 'bnot' instruction"
        );
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_bnot__);
        expr = __attachDbg(dbg, expr);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstNumber = function (dbg, value) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_const_n__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstString = function (dbg, value) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExpr({
            value : value,
        }, __catspeak_instr_const_s__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExpr({
        }, __catspeak_instr_const_u__);
        ds_stack_push(exprStack_, expr);
    };

    /// @ignore
    static handleInstrConstImport = function (dbg, path) {
        var exprStack_ = exprStack;
        var expr;
        expr = __genExprConstImport(path);
        ds_stack_push(exprStack_, expr);
    };
}

/// @ignore
function __catspeak_function__() {
    var ctx_ = ctx;
    var n_ = n;
    ctx_.stackN += n_;
    var stack = ctx_.stack;
    var stackN = ctx_.stackN;
    array_resize(stack, stackN);
    for (var i = argc - 1; i >= 0; i -= 1) {
        var value = i < argument_count ? argument[i] : undefined;
        stack[@ stackN - n + i] = value;
    }
    var result;
    try {
        result = body();
    } finally {
        ctx_.stackN -= n_;
        array_resize(stack, ctx_.stackN);
    }
    return result;
}

/// @ignore
function __catspeak_scopes_init__() {
    var scopes = __catspeak_scope_get();
    var oldSelf = scopes.self_;
    var oldOther = scopes.other_;
    var result;
    try {
        scopes.self_ ??= ctx.globals;
        scopes.other_ ??= ctx.globals;
        result = body();
    } finally {
        scopes.self_ = oldSelf;
        scopes.other_ = oldOther;
    }
    return result;
}

/// @ignore
function __catspeak_dbg__() {
    var ctx_ = ctx;
    var dbgPrev = ctx_.dbg;
    ctx_.dbg = dbg;
    var result = body();
    // don't want to use `finally` here, because we want to track the error
    // location when an exception occurs
    ctx_.dbg = dbgPrev;
    return result;
}

/// @ignore
function __catspeak_dbg_trace__() {
    var ctx_ = ctx;
    var result;
    var dbgPrev = ctx_.dbg;
    try {
        result = body();
    } catch (ex) {
        catspeak_location_trace(ex, ctx_.dbg, ctx_.meta.path);
        ctx_.dbg = dbgPrev; // recover debug info for parent call expression
        throw ex;
    }
    return result;
}

/// @ignore
function __catspeak_instr_module_value__() {
    return value;
}

/// @ignore
function __catspeak_instr_fclo_simple__() {
    return value;
}

/** @ignore */ function __catspeak_instr_seq_0__() { return undefined }
/** @ignore */ function __catspeak_instr_seq_1__() { return _1() }
/** @ignore */ function __catspeak_instr_seq_2__() { _1(); return _2() }
/** @ignore */ function __catspeak_instr_seq_3__() { _1(); _2(); return _3() }
/** @ignore */ function __catspeak_instr_seq_4__() { _1(); _2(); _3(); return _4() }
/** @ignore */ function __catspeak_instr_seq_5__() { _1(); _2(); _3(); _4(); return _5() }
/** @ignore */ function __catspeak_instr_seq_6__() { _1(); _2(); _3(); _4(); _5(); return _6() }
/** @ignore */ function __catspeak_instr_seq_7__() { _1(); _2(); _3(); _4(); _5(); _6(); return _7() }
/** @ignore */ function __catspeak_instr_seq_8__() { _1(); _2(); _3(); _4(); _5(); _6(); _7(); return _8() }
/** @ignore */ function __catspeak_instr_seq_9__() { _1(); _2(); _3(); _4(); _5(); _6(); _7(); _8(); return _9() }

/// @ignore
function __catspeak_instr_seq__() {
    _1(); _2(); _3(); _4(); _5(); _6(); _7(); _8(); _9();
    var more_ = more;
    for (var i = moreN - 1; i >= 0; i -= 1) {
        var comp = more_[i];
        comp();
    }
    return result();
}

/// @ignore
function __catspeak_instr_get_l__() {
    var ctx_ = ctx;
    return ctx_.stack[ctx_.stackN + off];
}

/// @ignore
function __catspeak_instr_set_l__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[@ ctx_.stackN + off] = value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_add__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[@ ctx_.stackN + off] += value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_sub__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[@ ctx_.stackN + off] -= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_mul__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[@ ctx_.stackN + off] *= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_l_div__() {
    var ctx_ = ctx;
    var value_ = value();
    ctx_.stack[@ ctx_.stackN + off] /= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_get_g__() {
    return ctx.globals[$ name];
}

/// @ignore
function __catspeak_instr_set_g__() {
    var value_ = value();
    ctx.globals[$ name] = value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_add__() {
    var value_ = value();
    ctx.globals[$ name] += value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_sub__() {
    var value_ = value();
    ctx.globals[$ name] -= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_mul__() {
    var value_ = value();
    ctx.globals[$ name] *= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_g_div__() {
    var value_ = value();
    ctx.globals[$ name] /= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_self__() { return __catspeak_scope_get().self_ }

/// @ignore
function __catspeak_instr_othr__() { return __catspeak_scope_get().other_ }

/// @ignore
function __catspeak_instr_get_is__() {
    var data_ = data();
    if (!__catspeak_is_withable(data_)) {
        __catspeak_error(__catspeak_cat(
            "(string) index '[]' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    return data_[$ idx];
}

/// @ignore
function __catspeak_instr_set_is__() {
    var data_ = data();
    if (!__catspeak_is_withable(data_)) {
        __catspeak_error(__catspeak_cat(
            "(string) index '[]=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    var value_ = value();
    data_[$ idx] = value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_is_add__() {
    var data_ = data();
    if (!__catspeak_is_withable(data_)) {
        __catspeak_error(__catspeak_cat(
            "(string) index '[]+=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    var value_ = value();
    data_[$ idx] += value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_is_sub__() {
    var data_ = data();
    if (!__catspeak_is_withable(data_)) {
        __catspeak_error(__catspeak_cat(
            "(string) index '[]-=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    var value_ = value();
    data_[$ idx] -= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_is_mul__() {
    var data_ = data();
    if (!__catspeak_is_withable(data_)) {
        __catspeak_error(__catspeak_cat(
            "(string) index '[]*=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    var value_ = value();
    data_[$ idx] *= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_is_div__() {
    var data_ = data();
    if (!__catspeak_is_withable(data_)) {
        __catspeak_error(__catspeak_cat(
            "(string) index '[]/=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    var value_ = value();
    data_[$ idx] /= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_get_in__() {
    var data_ = data();
    return data_[idx];
}

/// @ignore
function __catspeak_instr_set_in__() {
    var data_ = data();
    var value_ = value();
    data_[@ idx] = value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_in_add__() {
    var data_ = data();
    var value_ = value();
    data_[@ idx] += value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_in_sub__() {
    var data_ = data();
    var value_ = value();
    data_[@ idx] -= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_in_mul__() {
    var data_ = data();
    var value_ = value();
    data_[@ idx] *= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_set_in_div__() {
    var data_ = data();
    var value_ = value();
    data_[@ idx] /= value_;
    return value_;
}

/// @ignore
function __catspeak_instr_get_i__() {
    var data_ = data();
    var idx_ = idx();
    if (is_array(data_)) {
        return data_[idx_];
    } else if (__catspeak_is_withable(data_)) {
        return data_[$ idx_];
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
}

/// @ignore
function __catspeak_instr_set_i__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[@ idx_] = value_;
    } else if (__catspeak_is_withable(data_)) {
        data_[$ idx_] = value_;
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_add__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[@ idx_] += value_;
    } else if (__catspeak_is_withable(data_)) {
        data_[$ idx_] += value_;
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]+=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_sub__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[@ idx_] -= value_;
    } else if (__catspeak_is_withable(data_)) {
        data_[$ idx_] -= value_;
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]-=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_mul__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[@ idx_] *= value_;
    } else if (__catspeak_is_withable(data_)) {
        data_[$ idx_] *= value_;
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]*=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    return value_;
}

/// @ignore
function __catspeak_instr_set_i_div__() {
    var data_ = data();
    var idx_ = idx();
    var value_ = value();
    if (is_array(data_)) {
        data_[@ idx_] /= value_;
    } else if (__catspeak_is_withable(data_)) {
        data_[$ idx_] /= value_;
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]/=' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    return value_;
}

/// @ignore
function __catspeak_instr_thrw__() {
    throw value();
}

/// @ignore
function __catspeak_instr_cat__() {
    var ctx_ = ctx;
    var result;
    try {
        result = eager();
    } catch (ex) {
        if (ex == magicBox) {
            throw ex;
        }
        ctx_.stack[ctx_.stackN + off] = ex;
        result = lazy();
    }
    return result;
}

/// @ignore
function __catspeak_instr_uwnd__() {
    var box_ = magicBox;
    var value_ = value();
    box_[@ 0] = label;
    box_[@ 1] = value_;
    throw box_;
}

/// @ignore
function __catspeak_instr_land__() {
    var box_ = magicBox;
    var result;
    try {
        result = body();
    } catch (ex) {
        if (ex == box_ && box_[0] == label) {
            result = box_[1];
        } else {
            throw ex;
        }
    }
    return result;
}

/// @ignore
function __catspeak_instr_loop_inf__() {
    var body_ = body;
    while (true) {
        body_();
    }
}

/// @ignore
function __catspeak_instr_loop__() {
    var cond_ = cond;
    var body_ = body;
    while (cond_()) {
        body_();
    }
}

/// @ignore
function __catspeak_instr_loop_s__() {
    var cond_ = cond;
    var body_ = body;
    var step_ = step;
    while (cond_()) {
        body_();
        step_();
    }
}

/// @ignore
function __catspeak_instr_loop_w__() {
    var cond_ = cond();
    var body_ = body;
    var scopes = __catspeak_scope_get();
    var oldOther = scopes.other_;
    var oldSelf = scopes.self_;
    try {
        scopes.other_ = scopes.self_;
        with (cond_) {
            scopes.self_ = self;
            body_();
        }
    } finally {
        scopes.other_ = oldOther;
        scopes.self_ = oldSelf;
    }
}

/// @ignore
function __catspeak_instr_arr_0__() { return [] }

/// @ignore
function __catspeak_instr_arr_1__() { return [_1()] }

/// @ignore
function __catspeak_instr_arr_2__() {
    var a1 = _1();
    return [a1, _2()];
}

/// @ignore
function __catspeak_instr_arr_3__() {
    var a1 = _1(); var a2 = _2();
    return [a1, a2, _3()];
}

/// @ignore
function __catspeak_instr_arr_4__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3();
    return [a1, a2, a3, _4()];
}

/// @ignore
function __catspeak_instr_arr_5__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    return [a1, a2, a3, a4, _5()];
}

/// @ignore
function __catspeak_instr_arr_6__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5();
    return [a1, a2, a3, a4, a5, _6()];
}

/// @ignore
function __catspeak_instr_arr_7__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6();
    return [a1, a2, a3, a4, a5, a6, _7()];
}

/// @ignore
function __catspeak_instr_arr_8__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7();
    return [a1, a2, a3, a4, a5, a6, a7, _8()];
}

/// @ignore
function __catspeak_instr_arr_9__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7(); var a8 = _8();
    return [a1, a2, a3, a4, a5, a6, a7, a8, _9()];
}

/// @ignore
function __catspeak_instr_arr__() {
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7(); var a8 = _8();
    var arr = [a1, a2, a3, a4, a5, a6, a7, a8, _9()];
    var more_ = more;
    var moreN_ = moreN;
    for (var i = 0; i < moreN_; i += 1) {
        var value = more_[i];
        arr[@ 10 + i] = value();
    }
    return arr;
}

/// @ignore
function __catspeak_instr_obj_0__() { return { } }

/// @ignore
function __catspeak_instr_obj_1__() {
    var k1 = _k1(); var v1 = _v1();
    var obj = { };
    obj[$ k1] = v1;
    return obj;
}

/// @ignore
function __catspeak_instr_obj_2__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    return obj;
}

/// @ignore
function __catspeak_instr_obj_3__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var k3 = _k3(); var v3 = _v3();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    obj[$ k3] = v3;
    return obj;
}

/// @ignore
function __catspeak_instr_obj_4__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var k3 = _k3(); var v3 = _v3(); var k4 = _k4(); var v4 = _v4();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    obj[$ k3] = v3;
    obj[$ k4] = v4;
    return obj;
}

/// @ignore
function __catspeak_instr_obj__() {
    var k1 = _k1(); var v1 = _v1(); var k2 = _k2(); var v2 = _v2();
    var k3 = _k3(); var v3 = _v3(); var k4 = _k4(); var v4 = _v4();
    var obj = { };
    obj[$ k1] = v1;
    obj[$ k2] = v2;
    obj[$ k3] = v3;
    obj[$ k4] = v4;
    var more_ = more;
    for (var i = moreN - 1; i >= 0; i -= 1) {
        var key = more_[i * 2];
        var value = more_[i * 2 + 1];
        var key_ = key();
        obj[$ key_] = value();
    }
    return obj;
}

/** @ignore */ function __catspeak_seef_0 (callee_, args_) { return callee_() }
/** @ignore */ function __catspeak_seef_1 (callee_, args_) { return callee_(args_[0]) }
/** @ignore */ function __catspeak_seef_2 (callee_, args_) { return callee_(args_[0], args_[1]) }
/** @ignore */ function __catspeak_seef_3 (callee_, args_) { return callee_(args_[0], args_[1], args_[2]) }
/** @ignore */ function __catspeak_seef_4 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3]) }
/** @ignore */ function __catspeak_seef_5 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4]) }
/** @ignore */ function __catspeak_seef_6 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5]) }
/** @ignore */ function __catspeak_seef_7 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6]) }
/** @ignore */ function __catspeak_seef_8 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7]) }
/** @ignore */ function __catspeak_seef_9 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8]) }
/** @ignore */ function __catspeak_seef_10 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9]) }
/** @ignore */ function __catspeak_seef_11 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10]) }
/** @ignore */ function __catspeak_seef_12 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11]) }
/** @ignore */ function __catspeak_seef_13 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12]) }
/** @ignore */ function __catspeak_seef_14 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12], args_[13]) }
/** @ignore */ function __catspeak_seef_15 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12], args_[13], args_[14]) }
/** @ignore */ function __catspeak_seef_16 (callee_, args_) { return callee_(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7], args_[8], args_[9], args_[10], args_[11], args_[12], args_[13], args_[14], args_[15]) }

/// @ignore
function __catspeak_script_execute_ext_fixed(callee_, args_) {
    static variants = undefined;
    if (variants == undefined) {
        variants = [
            __catspeak_seef_0,  __catspeak_seef_1,  __catspeak_seef_2,  __catspeak_seef_3,
            __catspeak_seef_4,  __catspeak_seef_5,  __catspeak_seef_6,  __catspeak_seef_7,
            __catspeak_seef_8,  __catspeak_seef_9,  __catspeak_seef_10, __catspeak_seef_11,
            __catspeak_seef_12, __catspeak_seef_13, __catspeak_seef_14, __catspeak_seef_15,
            __catspeak_seef_16, script_execute_ext
        ];
    }
    // LTS has issues with calling functions that have many args, so fix that here
    var variant = variants[min(17, array_length(args_))];
    return variant(callee_, args_);
}

/// @ignore
function __catspeak_instr_call_0__() {
    var callee_ = callee();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_();
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_1__() {
    var callee_ = callee();
    var a1 = _1();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_2__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_3__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2(); var a3 = _3();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2, a3);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_4__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2, a3, a4);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_5__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2, a3, a4, a5);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_6__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2, a3, a4, a5, a6);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_7__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2, a3, a4, a5, a6, a7);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call_8__() {
    var callee_ = callee();
    var a1 = _1(); var a2 = _2(); var a3 = _3(); var a4 = _4();
    var a5 = _5(); var a6 = _6(); var a7 = _7(); var a8 = _8();
    var scopes = __catspeak_scope_get();
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        result = callee_(a1, a2, a3, a4, a5, a6, a7, a8);
    }
    return result;
}

/// @ignore
function __catspeak_instr_call__() {
    static argsComplete = [];
    var callee_ = callee();
    // build args array
    var argsN_ = argsN;
    var args_ = args;
    array_resize(argsComplete, argsN_);
    for (var i = 0; i < argsN_; i += 1) {
        var arg = args_[i];
        argsComplete[@ i] = arg();
    }
    var scopes = __catspeak_scope_get_bound(method_get_self(callee_));
    var result = undefined;
    with (scopes.other_) with (scopes.self_) {
        var calleeUnbound = method_get_index(callee_);
        result = __catspeak_script_execute_ext_fixed(calleeUnbound, args_);
    }
    array_resize(argsComplete, 0);
    return result;
}

/// @ignore
function __catspeak_instr_call_i__() {
    static argsComplete = [];
    var data_ = data();
    var idx_ = idx();
    var callee_ = undefined;
    if (is_array(data_)) {
        callee_ = data_[idx_];
    } else if (__catspeak_is_withable(data_)) {
        callee_ = data_[$ idx_];
    } else {
        __catspeak_error(__catspeak_cat(
            "index '[]()' expression is not allowed for values of type '",
            typeof(data_), "'"
        ));
    }
    // build args array
    var argsN_ = argsN;
    var args_ = args;
    array_resize(argsComplete, argsN_);
    for (var i = 0; i < argsN_; i += 1) {
        var arg = args_[i];
        argsComplete[@ i] = arg();
    }
    // modify scope
    var scopes = __catspeak_scope_get();
    var oldSelf = scopes.self_;
    var oldOther = scopes.other_;
    var result = undefined;
    try {
        if (!is_array(data_)) {
            scopes.other_ = scopes.self_;
            scopes.self_ = catspeak_special_to_struct(data_);
        }
        var scopes2 = __catspeak_scope_get_bound(method_get_self(callee_));
        with (scopes2.other_) with (scopes2.self_) {
            var calleeUnbound = method_get_index(callee_);
            result = __catspeak_script_execute_ext_fixed(calleeUnbound, args_);
        }
    } finally {
        scopes.self_ = oldSelf;
        scopes.other_ = oldOther;
    }
    array_resize(argsComplete, 0);
    return result;
}

// automatically generated instructions below (here be dragons)

/** @ignore */ function __catspeak_instr_ifte__() { return condition() ? ifTrue() : ifFalse() }
/** @ignore */ function __catspeak_instr_or__() { return eager() || lazy() }
/** @ignore */ function __catspeak_instr_xor__() { return lhs() ^^ rhs() }
/** @ignore */ function __catspeak_instr_and__() { return eager() && lazy() }
/** @ignore */ function __catspeak_instr_eq__() { return lhs() == rhs() }
/** @ignore */ function __catspeak_instr_neq__() { return lhs() != rhs() }
/** @ignore */ function __catspeak_instr_lt__() { return lhs() < rhs() }
/** @ignore */ function __catspeak_instr_leq__() { return lhs() <= rhs() }
/** @ignore */ function __catspeak_instr_gt__() { return lhs() > rhs() }
/** @ignore */ function __catspeak_instr_geq__() { return lhs() >= rhs() }
/** @ignore */ function __catspeak_instr_band__() { return lhs() & rhs() }
/** @ignore */ function __catspeak_instr_bor__() { return lhs() | rhs() }
/** @ignore */ function __catspeak_instr_bxor__() { return lhs() ^ rhs() }
/** @ignore */ function __catspeak_instr_lshift__() { return value() << amount() }
/** @ignore */ function __catspeak_instr_rshift__() { return value() >> amount() }
/** @ignore */ function __catspeak_instr_add__() { return lhs() + rhs() }
/** @ignore */ function __catspeak_instr_sub__() { return lhs() - rhs() }
/** @ignore */ function __catspeak_instr_mult__() { return lhs() * rhs() }
/** @ignore */ function __catspeak_instr_div__() { return lhs() / rhs() }
/** @ignore */ function __catspeak_instr_idiv__() { return lhs() div rhs() }
/** @ignore */ function __catspeak_instr_rem__() { return lhs() % rhs() }
/** @ignore */ function __catspeak_instr_pos__() { return +value() }
/** @ignore */ function __catspeak_instr_neg__() { return -value() }
/** @ignore */ function __catspeak_instr_not__() { return !value() }
/** @ignore */ function __catspeak_instr_bnot__() { return ~value() }
/** @ignore */ function __catspeak_instr_const_n__() { return value }
/** @ignore */ function __catspeak_instr_const_s__() { return value }
/** @ignore */ function __catspeak_instr_const_u__() { return undefined }
