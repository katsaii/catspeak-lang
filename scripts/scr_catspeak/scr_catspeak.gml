/* Catspeak Compiler Interface
 * ---------------------------
 * Kat @katsaii
 */

#macro __CATSPEAK_UNIMPLEMENTED show_error("unimplemented Catspeak function", true)

/// @desc The container that manages the Catspeak compiler processes.
function __catspeak_manager() {
    static catspeak = {
        sessions : [],
        sessionCount : 0,
        processes : [],
        processCount : 0,
        processID : 0,
        errorScript : undefined,
        maxIterations : -1,
        frameAllocation : 0.5 // compute for 50% of frame time
    };
    return catspeak;
}

/// @desc Updates the catspeak manager.
/// @param {real} frame_start The time (in microseconds) when the frame started.
function catspeak_update(_frame_start) {
    var catspeak = __catspeak_manager();
    // update active processes
    var time_limit = _frame_start + catspeak.frameAllocation *
            game_get_speed(gamespeed_microseconds);
    do {
        if (catspeak.processCount < 1) {
            break;
        }
    } until (get_timer() >= time_limit);
}

/// @desc Sets the error handler for Catspeak errors.
/// @param {script} script_id_or_method The id of the script to execute upon encountering an error.
function catspeak_set_error_script(_f) {
    var catspeak = __catspeak_manager();
    catspeak.errorScript = is_method(_f) || is_numeric(_f) && script_exists(_f) ? _f : undefined;
}

/// @desc Sets the maximum number of iterations a process can perform before being stopped.
/// @param {real} iteration_count The number of maximum number of iterations to perform. Use `-1` for unlimited.
function catspeak_set_max_iterations(_iteration_count) {
    var catspeak = __catspeak_manager();
    catspeak.maxIterations = is_numeric(_f) && _f >= 0 ? _f : -1;
}

/// @desc Creates a new Catspeak session and returns its ID.
function catspeak_session_create() {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Destroys an existing catspeak session.
/// @param {real} session_id The ID of the session to destroy.
function catspeak_session_destroy(_session) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Sets the source code for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} src The source code to compile and evaluate.
function catspeak_session_set_source(_session, _str) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Sets the VM pop handler for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {script} script_id_or_method The id of the script to execute upon popping a value.
function catspeak_session_set_pop_script(_session, _f) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Enables access to global variables for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_global_access(_session, _enable) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Enables access to instance variables for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_instance_access(_session, _enable) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Makes all processes of this session use the same workspace.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_shared_workspace(_session, _enable) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Inserts a new read-only global variable into the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the variable.
/// @param {value} value The value of the variable.
function catspeak_session_add_constant(_session, _name, _value) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Inserts a new function into to the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the function.
/// @param {value} script_id_or_method The reference to the function.
function catspeak_session_add_function(_session, _name, _value) {
    __CATSPEAK_UNIMPLEMENTED;
}

/// @desc Spawns a process from this session.
/// @param {real} session_id The ID of the session to spawn a process for.
/// @param {script} script_id_or_method The id of the script to execute upon completing the process.
function catspeak_session_create_process(_session, _callback_return) {
    __CATSPEAK_UNIMPLEMENTED;
}

/*
/// @desc Creates a new Catspeak session.
function catspeak_session_create() {
    return {
        sourceQueue : [],
        currentSource : undefined,
        errorHandler : new __CatspeakEventList(),
        runtime : new __CatspeakVM()
    };
}

/// @desc Destroys an existing catspeak session.
/// @param {struct} session The Catspeak session to destroy.
function catspeak_session_destroy(_session) {
    catspeak_session_delete_program(_session);
    variable_struct_remove(_session, "sourceQueue");
    variable_struct_remove(_session, "currentSource");
    variable_struct_remove(_session, "errorHandler");
    variable_struct_remove(_session, "runtime");
}

/// @desc Returns whether this Catspeak session is processing.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_in_progress(_session) {
    return _session.currentSource != undefined || _session.runtime.inProgress();
}

/// @desc Rewinds this Catspeak session back to the start of the program.
/// @param {struct} session The Catspeak session to rewind.
function catspeak_session_rewind_program(_session) {
    _session.runtime.rewind();
}

/// @desc Permanently removes the current program from this Catspeak session.
/// @param {struct} session The Catspeak session to rewind.
function catspeak_session_delete_program(_session) {
    if (_session.currentSource != undefined) {
        buffer_delete(_session.currentSource.buff);
        var source_queue = _session.sourceQueue;
        for (var i = array_length(source_queue) - 1; i >= 0; i -= 1) {
            var source = source_queue[i];
            buffer_delete(source.buff);
        }
    }
    _session.runtime.reset();
}

/// @desc Returns the current variable workspace for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_get_workspace(_session) {
    return _session.runtime.getWorkspace();
}

/// @desc Sets the current variable workspace for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {struct} workspace The variable workspace to assign.
function catspeak_session_set_workspace(_session, _vars) {
    _session.runtime.setWorkspace(_vars);
}

/// @desc Sets the error handler for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon receiving a Catspeak error.
function catspeak_session_add_error_handler(_session, _f) {
    _session.errorHandler.add(_f);
}

/// @desc Sets the error handler for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon receiving a result.
function catspeak_session_add_result_handler(_session, _f) {
    _session.runtime.setOption(__CatspeakVMOption.RESULT_HANDLER, _f);
}

/// @desc Sets a function to call on popped expression statementes.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon popping an expression statement.
function catspeak_session_add_expression_statement_handler(_session, _f) {
    _session.runtime.setOption(__CatspeakVMOption.POP_HANDLER, _f);
}

/// @desc Enables access to global variables from within Catspeak.
/// @param {struct} session The Catspeak session to consider.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_global_access(_session, _enable) {
    _session.runtime.setOption(__CatspeakVMOption.GLOBAL_VISIBILITY, _enable);
}

/// @desc Enables access to instance variables from within Catspeak.
/// @param {struct} session The Catspeak session to consider.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_instance_access(_session, _enable) {
    _session.runtime.setOption(__CatspeakVMOption.INSTANCE_VISIBILITY, _enable);
}

/// @desc Inserts a new read-only global variable into the interface.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} name The name of the variable.
/// @param {value} value The value of the variable.
function catspeak_session_add_constant(_session, _name, _value) {
    _session.runtime.addConstant(_name, _value);
}

/// @desc Inserts a new function into to the interface.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} name The name of the function.
/// @param {value} method_or_script_id The reference to the function.
function catspeak_session_add_function(_session, _name, _value) {
    _session.runtime.addFunction(_name, _value);
}

/// @desc Adds a new piece of source code to the current Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} src The source code to compiler and evaluate.
function catspeak_session_add_source(_session, _src) {
    var src_size = string_byte_length(_src);
    var src_buff = buffer_create(src_size, buffer_fixed, 1);
    buffer_write(src_buff, buffer_text, _src);
    buffer_seek(src_buff, buffer_seek_start, 0);
    var src_scanner = new __CatspeakScanner(src_buff);
    var src_lexer = new __CatspeakLexer(src_scanner);
    var src_chunk = new __CatspeakChunk();
    var src_compiler = new __CatspeakCompiler(src_lexer, src_chunk);
    var source = {
        buff : src_buff,
        chunk : src_chunk,
        compiler : src_compiler
    };
    if (_session.currentSource == undefined) {
        _session.currentSource = source;
    } else {
        array_insert(_session.sourceQueue, 0, source);
    }
}

/// @desc Discards a recently queued piece of source code.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_discard_source(_session) {
    buffer_delete(_session.currentSource.buff);
    var source_queue = _session.sourceQueue;
    if (array_length(source_queue) > 0) {
        _session.currentSource = array_pop(source_queue);
    } else {
        _session.currentSource = undefined;
    }
}

/// @desc Performs a single update step for the compiler.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_update(_session) {
    static handle_catspeak_error = function(_e, _f) {
        if (instanceof(_e) == "__CatspeakError") {
            if not (_f.isEmpty()) {
                _f.run(_e);
                return;
            }
        }
        throw _e;
    };
    var source = _session.currentSource;
    var runtime = _session.runtime;
    if (source != undefined) {
        var compiler = source.compiler;
        try {
            compiler.generateCode();
        } catch (_e) {
            handle_catspeak_error(_e, _session.errorHandler);
            // discard this chunk since it's spicy
            catspeak_session_discard_source(_session);
        }
        if not (compiler.inProgress()) {
            // start progress on the new compiler
            runtime.addChunk(source.chunk);
            catspeak_session_discard_source(_session);
        }
    } else {
        try {
            runtime.computeProgram();
        } catch (_e) {
            handle_catspeak_error(_e, _session.errorHandler);
            // discard the current chunk
            runtime.terminateChunk();
        }
    }
}

/// @desc Eagerly compiles and evalutes the current Catspeak session.
/// @param {struct} session The Catspeak session to evaluate.
function catspeak_session_update_eager(_session) {
    while (catspeak_session_in_progress(_session)) {
        catspeak_session_update(_session);
    }
}
*/