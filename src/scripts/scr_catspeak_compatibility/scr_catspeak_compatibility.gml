//! Compatibility scripts from version 1.2.3. All functions are deprecated
//! and some have no implementations. There is no guarantee that old code
//! will behave exactly as it did in the past because of huge design changes.

//# feather use syntax-errors

/// Updates the time limit for updating Catspeak processes.
///
/// @deprecated
function catspeak_start_frame() {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Updates the catspeak manager.
///
/// @deprecated
function catspeak_update() {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Sets the error handler for Catspeak errors.
///
/// @param {Function} script_id_or_method
///   The id of the script to execute upon encountering an error.
///
/// @deprecated
function catspeak_set_error_script(script_id_or_method) {
    gml_pragma("forceinline");
    catspeak_config({ "exceptionHandler" : script_id_or_method });
}

/// Sets the maximum number of iterations a process can perform before being
/// stopped.
///
/// @param {Real} iteration_count
///   The number of maximum number of iterations to perform. Use `-1` for
///   unlimited.
///
/// @deprecated
function catspeak_set_max_iterations(iteration_count) {
    gml_pragma("forceinline");
    // from my tests, it seems like Catspeak 2 can handle around this many
    // VM steps per second
    catspeak_config({ "processTimeLimit" : iteration_count / 50000 });
}

/// Sets the maximum percentage of a game frame to spend processing.
///
/// @param {Real} amount
///   The amount in the range 0-1.
///
/// @deprecated
function catspeak_set_frame_allocation(amount) {
    gml_pragma("forceinline");
    catspeak_config({ "frameAllocation" : amount });
}

/// Sets the threshold for processing in the current frame. Processing will
/// not continue beyond this point.
///
/// @param {Real} amount
///   The amount in the range 0-1.
///
/// @deprecated
function catspeak_set_frame_threshold(amount) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Creates a new Catspeak session and returns its ID.
///
/// @deprecated
/// @return {Struct}
function catspeak_session_create() {
    gml_pragma("forceinline");
    return {
        src : "",
        ir : undefined,
        implicitReturn : false,
        globalAccess : false,
        prelude : { },
        getSrc : function() {
            var src_ = src;
            if (implicitReturn) {
                src_ += "\nreturn";
            }
            return src_;
        },
        setupIR : function(ir) {
            self.ir = ir;
            var externFunc = method(undefined, __catspeak_session_extern);
            ir.setGlobal("extern", externFunc);
            ir.setGlobal("gml", prelude);
            if (globalAccess) {
                ir.setGlobal("global", global);
            }
        }
    }
}

/// Destroys an existing catspeak session.
///
/// @param {Real} session_id
///   The ID of the session to destroy.
///
/// @deprecated
function catspeak_session_destroy(session_id) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Sets the source code for this session.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {String} src
///   The source code to compile and evaluate.
///
/// @deprecated
function catspeak_session_set_source(session_id, src) {
    gml_pragma("forceinline");
    session_id.src = src;
    session_id.ir = undefined;
}

/// Enables access to global variables for this session.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
///
/// @deprecated
function catspeak_session_enable_global_access(session_id, enable) {
    gml_pragma("forceinline");
    session_id.globalAccess = enable;
    session_id.ir = undefined;
}

/// Enables access to instance variables for this session.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
///
/// @deprecated
function catspeak_session_enable_instance_access(session_id, enable) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Enables implicit returns for this session.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
///
/// @deprecated
function catspeak_session_enable_implicit_return(session_id, enable) {
    gml_pragma("forceinline");
    session_id.implicitReturn = enable;
    session_id.ir = undefined;
}

/// Makes all processes of this session use the same workspace.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
///
/// @deprecated
function catspeak_session_enable_shared_workspace(session_id, enable) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Inserts a new global variable into the interface of this session.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {String} name
///   The name of the variable.
///
/// @param {Any} value
///   The value of the variable.
///
/// @deprecated
function catspeak_session_add_constant(session_id, name, value) {
    gml_pragma("forceinline");
    session_id.prelude[$ name] = value;
}

/// Inserts a new function into to the interface of this session.
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {String} name
///   The name of the function.
///
/// @param {Any} script_id_or_method
///   The reference to the function.
///
/// @deprecated
function catspeak_session_add_function(
    session_id, name, script_id_or_method
) {
    gml_pragma("forceinline");
    var f = script_id_or_method;
    if (!is_method(f)) {
        if (!is_numeric(f)) {
            return;
        }
        // this is so that unexposed functions cannot be enumerated
        // by a malicious user in order to access important functions
        f = method(undefined, f);
    }
    session_id.prelude[$ name] = f;
}

/// Spawns a process from this session.
///
/// @param {Struct} session_id
///   The ID of the session to spawn a process for.
///
/// @param {Function} [script_id_or_method]
///   The id of the script to execute upon completing the process.
///
/// @param {Array<Any>} [args]
///   The arguments to pass to the process.
///
/// @deprecated
function catspeak_session_create_process(
    session_id, script_id_or_method, args=[]
) {
    var ir = session_id;
    if (ir == undefined) {
        var src = session_id.getSrc();
        var s = {
            session : session_id,
            args : args,
            callback : script_id_or_method,
            go : function(ir) {
                session.setupIR(ir);
                catspeak_execute(ir, args).andThen(callback);
            }
        };
        catspeak_compile_string(src).andThen(s.go);
    } else {
        catspeak_execute(ir, args).andThen(script_id_or_method);
    }
}

/// Spawns a process from this session which is evaluated immediately.
///
/// @param {Struct} session_id
///   The ID of the session to spawn a process for.
///
/// @param {Array<Any>} [args]
///   The arguments to pass to the process.
///
/// @deprecated
/// @return {Any}
function catspeak_session_create_process_greedy(session_id, args=[]) {
    var ir = session_id;
    if (ir == undefined) {
        var src = session_id.getSrc();
        var buff = catspeak_create_buffer_from_string(src);
        var lex = new CatspeakLexer(buff);
        var compiler = new CatspeakCompiler(lex);
        while (compiler.inProgress()) {
            compiler.emitProgram(10);
        }
        ir = comp.ir;
        buffer_delete(buff);
        // don't update session_id.ir since another process may update it
        // later... race conditions in GML baybee!!!
    }
    var vm = new CatspeakVM();
    vm.pushCallFrame(self, ir, args);
    while (vm.inProgress()) {
        vm.runProgram(10);
    }
    return vm.returnValue;
}

/// @deprecated
/// @ignore
function __catspeak_session_extern(ir) {
    var vm = new CatspeakVM();
    vm.pushCallFrame(self, ir);
    vm.popCallFrame();
    var s = {
        vm : vm,
        argc : ir.argCount,
        args : array_create(ir.argCount),
        go : function() {
            // extern functions compute everything in one go
            var vm_ = vm;
            var argc_ = argc;
            var args_ = args;
            for (var i = 0; i < argc_; i += 1) {
                args_[@ i] = argument[i];
            }
            vm_.reuseCallFrameWithArgs(args_, 0, argc_);
            var timeLimit = get_timer() + duration;
            while (vm_.inProgress()) {
                vm_.runProgram(10);
            }
            return vm_.returnValue;
        },
    };
    return s.go;
}