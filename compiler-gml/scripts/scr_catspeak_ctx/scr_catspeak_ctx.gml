function CatspeakCtx() constructor {
    self.parserType = undefined;
    self.codegenType = undefined;

    self.fileHandler = undefined;
    self.asyncHandler = undefined;

    // the public global variables, used by top-level scripts
    self.globals = { };

    // maps from packages/filepaths -> IR or compiled entry points + globals
    self.modules = { };

    // uses parserType, fileHandler
    //
    // buildArgs : {
    //   path : string
    //   src : string | buffer
    //   srcOffset? : int
    //   srcLength? : int
    //   dest? : buffer
    //   destOffset? : int
    //   destLength? : int
    //   parserType : CatspeakParserV3
    //   flags : CatspeakBuildFlags
    // }
    static build = function (buildArgs) { };

    // uses parserType, fileHandler, asyncHandler
    //
    // buildArgs : (see above)
    // onComplete : function (ir : buffer | undefined) -> nothing
    static buildAsync = function (buildArgs, onComplete) { };

    // uses parserType, fileHandler, codegenType, globals
    //
    // runArgs : {
    //   codegenType : CatspeakCodegen
    //   globals : struct
    //   flags : CatspeakRunFlags
    // } <: buildArgs
    static run = function (runArgs) { };

    // uses parserType, fileHandler, codegenType, globals, asyncHandler
    //
    // runArgs : (see above)
    // onComplete : function (module : struct | undefined) -> nothing
    static runAsync = function (runArgs, onComplete) { };
}