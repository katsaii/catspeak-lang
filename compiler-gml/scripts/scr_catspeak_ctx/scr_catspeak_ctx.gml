function CatspeakCtx() constructor {
    parserType = undefined;
    codegenType = CatspeakCodegenGML;

    fileHandler = undefined;
    exceptionHandler = undefined;

    flags = CatspeakBuildFlags.NONE;

    // the public global variables, used by top-level scripts
    globals = { };

    // maps from packages/filepaths -> IR or compiled entry points + globals
    modules = { };

    // uses parserType, fileHandler, codegenType, globals
    //
    // args : {
    //   path : string
    //   src : string | buffer
    //   srcOffset? : int
    //   srcLength? : int
    //   cart : buffer
    //   cartOffset? : int
    //   globals : struct
    //   flags : CatspeakBuildFlags
    // } <: buildArgs
    //
    // return CatspeakModule
    static run = function (buildArgs) {
        var module = new CatspeakModule(self, buildArgs);
        var runFinished;
        do {
            runFinished = module.await_();
        } until (runFinished);
        return module;
    };

    // uses parserType, fileHandler, codegenType, globals, asyncHandler
    //
    // runArgs : (see above)
    // onComplete : function (module : CatspeakModule) -> nothing
    static runAsync = function (args, onSuccess, onFailure) {
        __catspeak_assert_typeof(onComplete, __catspeak_is_callable);
        __catspeak_error_unimplemented("async running");
    };
}

enum CatspeakBuildFlags {
    NONE = 0,
    KEEP_PATH = (1 << 0),
    KEEP_AUTHOR = (1 << 1),
    KEEP_SRC = (1 << 2),
    KEEP_SRC_BUFFER = (1 << 3),
    KEEP_CARTRIDGE = (1 << 4),
    KEEP_ENTRYPOINT = (1 << 5),
}

/*
- run test.meow
  - if the program already exists, return it
  - build test.meow
    - if the IR already exists, return it
    - convert to IR
  - find dependencies from IR
    - for each dependency
      - run dependency
        - if the program already exists, return it
        - build dependency
          - if the IR already exists, return it
          - convert to IR
        - find dependencies from IR
          - [...]
  - use dependencies to set globals during codegen
  - perform codegen
*/

function CatspeakModule(ctx_, buildArgs) constructor {
    var buildArgsIsStruct = is_struct(buildArgs);
    var buildArgsIsString = is_string(buildArgs);
    var buildArgsIsBuffer = __catspeak_is_buffer(buildArgs);
    var buildArgsIsCart = false;
    __catspeak_assert(
        buildArgsIsStruct || buildArgsIsString || buildArgsIsBuffer,
        "buildArgs must be a string, buffer, or GML struct"
    );
    var flags_ = undefined;
    var globals_ = undefined;
    if (buildArgsIsStruct) {
        flags_ = buildArgs[$ "flags"];
        globals_ = buildArgs[$ "globals"];
    }
    var path_ = undefined;
    var author_ = undefined;
    var src_ = undefined;
    if (buildArgsIsString) {
        src_ = buildArgs;
    } else if (buildArgsIsStruct) {
        path_ = buildArgs[$ "path"];
        author_ = buildArgs[$ "author"];
        src_ = buildArgs[$ "src"];
        if (__catspeak_is_buffer(src_)) {
            src_ = undefined;
        }
    }
    var srcBuff_ = undefined;
    var srcOffset_ = undefined;
    var srcLength_ = undefined;
    if (buildArgsIsBuffer && !buildArgsIsCart) {
        srcBuff_ = buildArgs;
    } else if (buildArgsIsStruct) {
        srcBuff_ = buildArgs[$ "src"];
        if (is_string(srcBuff_)) {
            srcBuff_ = undefined;
        }
        srcOffset_ = buildArgs[$ "srcOffset"];
        srcLength_ = buildArgs[$ "srcLength"];
    }
    var cart_ = undefined;
    var cartOffset_ = undefined;
    if (buildArgsIsBuffer && buildArgsIsCart) {
        cart_ = buildArgs;
    } else if (buildArgsIsStruct) {
        cart_ = buildArgs[$ "cart"];
        cartOffset_ = buildArgs[$ "cartOffset"];
    }
    /// TODO
    ctx = ctx_;
    __catspeak_assert_instanceof(ctx, CatspeakCtx);
    /// TODO
    flags = flags_ ?? ctx.flags;
    __catspeak_assert_typeof(flags, is_numeric, "flags must be a number");
    /// TODO
    globals = globals_ ?? { };
    __catspeak_assert_typeof(globals, is_struct, "globals must be a struct");
    /// TODO
    path = path_;
    __catspeak_assert_typeof_optional(path, is_string, "path must be a string");
    /// TODO
    author = author_;
    __catspeak_assert_typeof_optional(author, is_string, "author must be a string");
    /// TODO
    src = src_;
    __catspeak_assert_typeof_optional(src, is_string, "src must be a string");
    /// TODO
    srcBuff = srcBuff_;
    __catspeak_assert_typeof_optional(srcBuff, __catspeak_is_buffer, "src must be a buffer");
    /// TODO
    srcOffset = srcOffset_;
    __catspeak_assert_typeof_optional(srcOffset, is_numeric, "srcOffset must be a number");
    /// TODO
    srcLength = srcLength_;
    __catspeak_assert_typeof_optional(srcLength, is_numeric, "srcLength must be a number");
    /// TODO
    cart = cart_;
    __catspeak_assert_typeof_optional(cart, __catspeak_is_buffer, "cart must be a buffer");
    /// TODO
    cartOffset = cartOffset_;
    __catspeak_assert_typeof_optional(cartOffset, is_numeric, "cartOffset must be a number");
    /// TODO
    entry = undefined;
    /// TODO
    result = undefined;
    /// TODO
    completed = false;
    /// TODO
    failed = false;
    /// @ignore
    currentTaskIdx = 0;
    /// @ignore
    srcBuffIsOwned = false;
    /// @ignore
    cartIsOwned = false;
    /// @ignore
    parser = undefined;
    /// @ignore
    codegen = undefined;
    /// @ignore
    cartReader = undefined;

    /// TODO
    static cleanup = function () {
        if (!completed) {
            failed = true;
        }
        var flags_ = flags;
        if ((flags_ & CatspeakBuildFlags.KEEP_PATH) == 0) {
            path = undefined;
        }
        if ((flags_ & CatspeakBuildFlags.KEEP_AUTHOR) == 0) {
            author = undefined;
        }
        if ((flags_ & CatspeakBuildFlags.KEEP_SRC) == 0) {
            src = undefined;
        }
        if ((flags_ & CatspeakBuildFlags.KEEP_SRC_BUFFER) == 0) {
            if (srcBuffIsOwned && __catspeak_is_buffer(srcBuff)) {
                buffer_delete(srcBuff);
                srcBuffIsOwned = false;
                srcBuff = undefined;
            }
        }
        if ((flags_ & CatspeakBuildFlags.KEEP_CARTRIDGE) == 0) {
            if (cartIsOwned && __catspeak_is_buffer(cart)) {
                buffer_delete(cart);
                cartIsOwned = false;
                cart = undefined;
            }
        }
        if ((flags_ & CatspeakBuildFlags.KEEP_ENTRYPOINT) == 0) {
            entry = undefined;
        }
        parser = undefined;
        codegen = undefined;
        cartReader = undefined;
    };

    /// TODO
    static await_ = function (timeLimit = infinity) {
        __catspeak_assert(!failed, "build failed");
        __catspeak_assert(!completed, "build already completed");
        var currentTask = __tasks[currentTaskIdx];
        do {
            if (currentTask == undefined) {
                completed = true;
                cleanup(); // MUST be called after `completed` is set to `true`
                return true;
            }
            failed = true;
            if (currentTask(timeLimit)) {
                currentTaskIdx += 1;
                currentTask = __tasks[currentTaskIdx];
            }
            failed = false;
        } until (get_timer() > timeLimit);
        return false;
    };

    /// @ignore
    static __taskPrepareSourceBuffer = function (timeLimit) {
        if (srcBuff != undefined || cart != undefined) {
            // source buffer or cartridge already exists
            return true;
        }
        if (src != undefined) {
            // create from string
            srcBuffIsOwned = true;
            srcBuff = catspeak_util_buffer_create_from_string(src);
            return true;
        }
        if (path != undefined) {
            // create from file
            //if (file_exists(path)) {
            //    srcBuff = buffer_load(path);
            //}
            __catspeak_error_unimplemented("file parsing");
        }
        __catspeak_error_bug();
    };

    /// @ignore
    static __taskParseCartridge = function (timeLimit) {
        if (cart != undefined) {
            // cartridge already exists
            return true;
        }
        // create from source
        if (parser == undefined) {
            var parserType = ctx.parserType;
            __catspeak_assert(srcBuff != undefined);
            __catspeak_assert(cart == undefined);
            __catspeak_assert(cartOffset == undefined, "got cartOffset, but missing cart");
            __catspeak_assert(parserType != undefined, "invalid parser");
            cartIsOwned = true;
            cart = buffer_create(1, buffer_grow, 1);
            var cartWriter = new CatspeakCartWriterOld(cart);
            parser = new parserType(cartWriter, srcBuff, srcOffset, srcLength);
        }
        var continueParsing;
        do {
            continueParsing = parser.parseOnce();
        } until (!continueParsing || get_timer() > timeLimit);
        return !continueParsing;
    };

    /// @ignore
    static __taskCompileDependencies = function (timeLimit) {
        __catspeak_assert(cart != undefined);
        buffer_seek(cart, buffer_seek_start, cartOffset ?? 0); // rewind
        return true; // TODO
    };

    /// @ignore
    static __taskCompile = function (timeLimit) {
        __catspeak_assert(cart != undefined);
        if (codegen == undefined) {
            var codegenType = ctx.codegenType;
            __catspeak_assert(codegenType != undefined, "invalid code generator");
            codegen = new codegenType();
            cartReader = new CatspeakCartReaderOld(cart, codegen);
        }
        var continueCodegen;
        do {
            var continueCodegen = cartReader.readInstr();
        } until (!continueCodegen);
        return !continueCodegen;
    };

    /// @ignore
    static __taskRunEntrypoint = function (timeLimit) {
        __catspeak_assert(codegen != undefined);
        var entry_ = codegen.getProgram();
        var result_ = undefined;
        var globals_ = globals;
        with (globals_) {
            with (globals_) {
                result_ = catspeak_execute(entry_);
            }
        }
        entry = entry_;
        result = result_;
        return true;
    };

    /// @ignore
    static __taskCleanup = function (timeLimit) {
        cleanup();
        return true;
    };

    /// @ignore
    static __tasks = undefined;
    if (__tasks == undefined) {
        __tasks = [
            __taskPrepareSourceBuffer,
            __taskParseCartridge,
            __taskCompileDependencies,
            __taskCompile,
            __taskRunEntrypoint,
            __taskCleanup,
        ];
        array_push(__tasks, undefined);
    }
}