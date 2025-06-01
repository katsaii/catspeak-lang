
enum CatspeakBuildFlags {
    NONE = 0,
}

enum CatspeakRunFlags {
    NONE = 0,
}

function CatspeakCtx() constructor {
    parserType = undefined;
    codegenType = CatspeakCodegenGML;

    fileHandler = undefined;
    exceptionHandler = undefined;

    flags = CatspeakBuildFlags.NONE | CatspeakRunFlags.NONE;

    // the public global variables, used by top-level scripts
    globals = { };

    // maps from packages/filepaths -> IR or compiled entry points + globals
    modules = { };

    /// @ignore
    static __buildCommon = function (buildArgs) {
        // process build args
        var path = undefined;
        var author = undefined;
        var src = buildArgs;
        var srcOffset = undefined;
        var srcLength = undefined;
        var cartBuff = undefined;
        var parserType_ = parserType;
        var flags_ = flags;
        if (is_struct(buildArgs)) {
            // complex case
            path = buildArgs[$ "path"];
            author = buildArgs[$ "author"];
            src = __catspeak_assert_get(buildArgs, "src");
            srcOffset = buildArgs[$ "srcOffset"];
            srcLength = buildArgs[$ "srcLength"];
            cartBuff = buildArgs[$ "cart"];
            parserType_ = buildArgs[$ "parserType"] ?? parserType_;
            flags_ = buildArgs[$ "flags"] ?? flags_;
            __catspeak_assert_typeof_optional(path, is_string);
            __catspeak_assert_typeof_optional(author, is_string);
            __catspeak_assert_typeof_optional(srcOffset, is_numeric);
            __catspeak_assert_typeof_optional(srcLength, is_numeric);
            __catspeak_assert_typeof_optional(cartBuff, __catspeak_is_buffer);
        }
        __catspeak_assert_typeof(parserType_, __catspeak_is_callable);
        __catspeak_assert_typeof(flags_, is_numeric);
        // create the source buffer if it doesn't exist
        var srcBuffOwned = false;
        var srcBuff = src;
        if (is_string(src)) {
            srcBuff = catspeak_util_buffer_create_from_string(src);
            srcBuffOwned = true;
        } else {
            __catspeak_assert_typeof(srcBuff, __catspeak_is_buffer);
        }
        // create the cartridge buffer if it doesn't exist
        var cartBuffOwned = false;
        if (cartBuff == undefined) {
            cartBuff = buffer_create(1, buffer_grow, 1);
            cartBuffOwned = true;
        }
        var cartBuffStart = buffer_tell(cartBuff);
        // initialise the parser
        var failed = true;
        var throwValue = undefined;
        var srcParser;
        try {
            var cartWriter = new CatspeakCartWriter(cartBuff);
            if (path != undefined) { cartWriter.path = path }
            if (author != undefined) { cartWriter.author = author }
            srcParser = new parserType_(cartWriter, srcBuff, srcOffset, srcLength);
            __catspeak_assert_typeof(
                __catspeak_assert_get(srcParser, "parseOnce"),
                __catspeak_is_callable
            );
            failed = false;
        } catch (ex_) {
            throwValue = ex_;
        } finally {
            if (failed) {
                if (srcBuffOwned) {
                    buffer_delete(srcBuff);
                }
                if (cartBuffOwned) {
                    buffer_delete(cartBuff);
                } else {
                    buffer_seek(cartBuff, buffer_seek_start, cartBuffStart);
                }
            }
        }
        if (failed) {
            if (exceptionHandler == undefined) {
                throw throwValue;
            } else {
                __catspeak_assert_typeof(exceptionHandler, __catspeak_is_callable);
                exceptionHandler(throwValue);
                return undefined;
            }
        }
        // spawn a build task
        return new __CatspeakTaskBuild(
            self, srcParser,
            srcBuff, srcBuffOwned,
            cartBuff, cartBuffOwned, cartBuffStart
        );
    };

    // uses parserType, fileHandler
    //
    // buildArgs : {
    //   path : string
    //   src : string | buffer
    //   srcOffset? : int
    //   srcLength? : int
    //   cart? : buffer
    //   parserType : CatspeakParser
    //   flags : CatspeakBuildFlags
    // }
    static build = function (buildArgs) {
        var task = __buildCommon(buildArgs);
        if (task == undefined) {
            return undefined;
        }
        do {
            var more = task.__awaitOnce();
        } until (!more);
        return task.__complete();
    };

    // uses parserType, fileHandler, asyncHandler
    //
    // buildArgs : (see above)
    // onComplete : function (cart : buffer | undefined) -> nothing
    static buildAsync = function (buildArgs, onComplete) {
        __catspeak_assert_typeof(onComplete, __catspeak_is_callable);
        __catspeak_error_unimplemented("async building");
    };

    /// @ignore
    static __runCommon = function (runArgs) {
        // process run args
        var cartBuff = runArgs;
        var codegenType_ = codegenType;
        var flags_ = flags;
        if (is_struct(runArgs)) {
            // complex case
            cartBuff = buildArgs[$ "cart"];
            codegenType_ = buildArgs[$ "codegenType"] ?? codegenType_;
            flags_ = buildArgs[$ "flags"] ?? flags_;
        }
        __catspeak_assert_typeof(cartBuff, __catspeak_is_buffer);
        __catspeak_assert_typeof(codegenType_, __catspeak_is_callable);
        __catspeak_assert_typeof(flags_, is_numeric);
        var cartBuffStart = buffer_tell(cartBuff);
        // initialise the code generator
        var failed = true;
        var throwValue = undefined;
        var cartCodegen;
        // blruh...
    };

    // uses parserType, fileHandler, codegenType, globals
    //
    // runArgs : {
    //   codegenType : CatspeakCodegen
    //   globals : struct
    //   flags : CatspeakRunFlags
    // } <: buildArgs
    static run = function (runArgs) {
        var task = __runCommon(runArgs);
        if (task == undefined) {
            return undefined;
        }
        do {
            var more = task.__awaitOnce();
        } until (!more);
        return task.__complete();
    };

    // uses parserType, fileHandler, codegenType, globals, asyncHandler
    //
    // runArgs : (see above)
    // onComplete : function (module : struct | undefined) -> nothing
    static runAsync = function (runArgs, onComplete) {
        __catspeak_assert_typeof(onComplete, __catspeak_is_callable);
        __catspeak_error_unimplemented("async running");
    };
}

/// @ignore
function __CatspeakTaskBuild(ctx_, parser_, src_, srcOwned_, cart_, cartOwned_, cartStart_) constructor {
    /// @ignore
    ctx = ctx_;
    /// @ignore
    parser = parser_;
    /// @ignore
    src = src_;
    /// @ignore
    srcOwned = srcOwned_;
    /// @ignore
    cart = cart_;
    /// @ignore
    cartOwned = cartOwned_;
    /// @ignore
    cartStart = cartStart_;
    /// @ignore
    completed = false;

    /// @ignore
    static __awaitOnce = function () {
        var failed = true;
        var throwValue = undefined;
        var moreToParse = false;
        try {
            moreToParse = parser.parseOnce();
            failed = false;
        } catch (ex_) {
            throwValue = ex_;
        } finally {
            if (srcOwned) {
                buffer_delete(src);
            }
            if (failed && cartOwned) {
                buffer_delete(cart);
            } else {
                buffer_seek(cart, buffer_seek_start, cartStart);
            }
        }
        if (failed) {
            cart = undefined;
            if (ctx.exceptionHandler == undefined) {
                throw throwValue;
            } else {
                __catspeak_assert_typeof(ctx.exceptionHandler, __catspeak_is_callable);
                ctx.exceptionHandler(throwValue);
                moreToParse = false;
            }
        }
        if (!moreToParse) {
            completed = true;
        }
        return moreToParse;
    };

    /// @ignore
    static __complete = function () {
        __catspeak_assert(completed, "build task not completed");
        return cart;
    };
}

/// @ignore
function __CatspeakTaskRun(ctx_, codegen_, cart_, cartOwned_, cartStart_) constructor {
    /// @ignore
    ctx = ctx_;
    /// @ignore
    codegen = codegen_;
    /// @ignore
    completed = false;

    /// @ignore
    static __awaitOnce = function () {
        
    };

    /// @ignore
    static __complete = function () {
        __catspeak_assert(completed, "run task not completed");
    };
}