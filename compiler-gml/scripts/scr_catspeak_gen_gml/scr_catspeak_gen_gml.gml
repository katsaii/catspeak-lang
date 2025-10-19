// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/compiler-gml/scripts/scr_catspeak_gen_gml/scr_catspeak_gen_gml.gml

//! Transforms Catspeak IR into callable GML functions.
//!
//! This stage of the compiler is very unintelligent, and may produce bad
//! results if given invalid IR.

//# feather use syntax-errors

/// TODO
function CatspeakGenGML() constructor {
    /// @ignore
    exprStack = undefined;
    /// @ignore
    funcs = undefined;
    /// @ignore
    globals = undefined;
    /// @ignore
    ctx = undefined;
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
    static handleMeta = function (
        name, author, version, versionMinor, patch, path, date
    ) {
        isAlive = true;
        exprStack = ds_stack_create();
        funcs = ds_list_create();
        ctx = {
            globals : globals ?? { },
            callee_ : undefined,
            self_ : undefined,
            other_ : undefined,
            name : name,
            author : author,
            version : version,
            versionMinor : versionMinor,
            patch : patch,
            path : path,
            date : date,
        };
    };

    /// @ignore
    static handleFunc = function (idx) {
        var body = ds_stack_pop(exprStack);
        __catspeak_assert(body != undefined,
            "unbalanced stack! function is missing body"
        );
        var func;
        func = method({
            body : body,
        }, __catspeak_function_simple__);
        funcs[| idx] = func;
    };

    /// @ignore
    static handleInstrConstNumber = function (dbg, value) {
        var exec;
        if (value == 0) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_0__);
        } else
        if (value == 1) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_1__);
        } else
        if (value == 2) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_2__);
        } else
        if (value == 3) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_3__);
        } else
        if (value == 5) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_5__);
        } else
        if (value == 10) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_10__);
        } else
        if (value == 100) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_100__);
        } else
        if (value == 1000) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_1000__);
        } else
        if (value == 1000000) {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_n_1000000__);
        } else
        exec = method({
            ctx : ctx,
            value : value,
        }, __catspeak_instr_get_n__);
        // TODO :: debug information
        ds_stack_push(exprStack, exec);
    };

    /// @ignore
    static handleInstrConstString = function (dbg, value) {
        var exec;
        if (value == "") {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_s_empty__);
        } else
        if (value == "*") {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_s_star__);
        } else
        if (value == "/") {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_s_slash__);
        } else
        if (value == "x") {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_s_x__);
        } else
        if (value == "y") {
            exec = method({
                ctx : ctx,
            }, __catspeak_instr_get_s_y__);
        } else
        exec = method({
            ctx : ctx,
            value : value,
        }, __catspeak_instr_get_s__);
        // TODO :: debug information
        ds_stack_push(exprStack, exec);
    };

    /// @ignore
    static handleInstrConstUndefined = function (dbg) {
        var exec;
        exec = method({
            ctx : ctx,
        }, __catspeak_instr_get_u__);
        // TODO :: debug information
        ds_stack_push(exprStack, exec);
    };
}

/// @ignore
function __catspeak_function_simple__() {
    return body();
}

// automatically generated instructions below (here be dragons)

/// @ignore
function __catspeak_instr_get_n__() { return value }

/// @ignore
function __catspeak_instr_get_n_0__() { return 0 }

/// @ignore
function __catspeak_instr_get_n_1__() { return 1 }

/// @ignore
function __catspeak_instr_get_n_2__() { return 2 }

/// @ignore
function __catspeak_instr_get_n_3__() { return 3 }

/// @ignore
function __catspeak_instr_get_n_5__() { return 5 }

/// @ignore
function __catspeak_instr_get_n_10__() { return 10 }

/// @ignore
function __catspeak_instr_get_n_100__() { return 100 }

/// @ignore
function __catspeak_instr_get_n_1000__() { return 1000 }

/// @ignore
function __catspeak_instr_get_n_1000000__() { return 1000000 }

/// @ignore
function __catspeak_instr_get_s__() { return value }

/// @ignore
function __catspeak_instr_get_s_empty__() { return "" }

/// @ignore
function __catspeak_instr_get_s_star__() { return "*" }

/// @ignore
function __catspeak_instr_get_s_slash__() { return "/" }

/// @ignore
function __catspeak_instr_get_s_x__() { return "x" }

/// @ignore
function __catspeak_instr_get_s_y__() { return "y" }

/// @ignore
function __catspeak_instr_get_u__() { return undefined }
