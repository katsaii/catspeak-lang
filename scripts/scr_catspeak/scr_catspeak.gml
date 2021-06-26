/* Catspeak Compiler Interface
 * ---------------------------
 * Kat @katsaii
 */

#macro __CATSPEAK_UNIMPLEMENTED show_error("unimplemented Catspeak function", true)

/// @desc The container that manages the Catspeak compiler processes.
function __catspeak_manager() {
    static catspeak = {
        sessions : [],
        sessionEmpty : [],
        compilerProcesses : [],
        compilerProcessCurrent : undefined,
        runtimeProcesses : [],
        runtimeProcessCount : 0,
        runtimeProcessID : 0,
        errorScript : undefined,
        maxIterations : -1,
        frameAllocation : 0.5 // compute for 50% of frame time
    };
    return catspeak;
}

/// @desc Updates the catspeak manager.
/// @param {real} frame_start The time (in microseconds) when the frame started.
function catspeak_update(_frame_start) {
    static handle_catspeak_error = function(_e, _f) {
        if (_f != undefined) {
            _f(_e);
        } else {
            throw _e;
        }
    };
    var catspeak = __catspeak_manager();
    // update active processes
    var time_limit = _frame_start + catspeak.frameAllocation *
            game_get_speed(gamespeed_microseconds);
    var f = catspeak.errorScript;
    var runtime_processes = catspeak.runtimeProcesses;
    var compiler_processes = catspeak.compilerProcesses;
    do {
        var compiler_process = catspeak.compilerProcessCurrent;
        if (compiler_process != undefined) {
            // update compiler processes
            var compiler = compiler_process.compiler;
            try {
                compiler.generateCode();
            } catch (_e) {
                handle_catspeak_error(_e, f);
                continue;
            }
            if not (compiler.inProgress()) {
                // compiler process is complete, move onto the next
                buffer_delete(compiler_process.buff);
                if (array_length(compiler_processes) > 0) {
                    catspeak.compilerProcessCurrent = array_pop(compiler_processes);
                } else {
                    catspeak.compilerProcessCurrent = undefined;
                    show_message(catspeak);
                }
            }
        } else if (catspeak.runtimeProcessCount > 0) {
            // update runtime processes
            var process_id = catspeak.runtimeProcessID;
            var process = runtime_processes[process_id];
            static kill_process = function(_catspeak, _process_id) {
                array_delete(_catspeak.runtimeProcesses, _process_id, 1);
                _catspeak.runtimeProcessCount -= 1;
            };
            try {
                process.computeProgram();
            } catch (_e) {
                kill_process(catspeak, process_id);
                handle_catspeak_error(_e, f);
                continue;
            }
            if not (process.inProgress()) {
                kill_process(catspeak, process_id);
            }
            if (process_id < 1) {
                catspeak.runtimeProcessID = catspeak.runtimeProcessCount - 1;
            } else {
                catspeak.runtimeProcessID -= 1;
            }
        } else {
            break;
        }
    } until (get_timer() >= time_limit);
}

var sess = catspeak_session_create();
catspeak_session_set_source(sess, @'
print "hi"
');
catspeak_session_create_process(sess, function(_result) {
    show_message("what is up katsaii nation");
})

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
    var catspeak = __catspeak_manager();
    var session = {
        popScript : undefined,
        globalAccess : false,
        instanceAccess : false,
        sharedWorkspace : undefined,
        interface : { },
        chunk : new __CatspeakChunk()
    };
    var sessions = catspeak.sessions;
    var empty_sessions = catspeak.sessionEmpty;
    var pos;
    if (array_length(empty_sessions) > 0) {
        pos = array_pop(empty_sessions);
    } else {
        pos = array_length(sessions);
    }
    sessions[@ pos] = session;
    return pos;
}

/// @desc Destroys an existing catspeak session.
/// @param {real} session_id The ID of the session to destroy.
function catspeak_session_destroy(_session_id) {
    var catspeak = __catspeak_manager();
    var sessions = catspeak.sessions;
    var empty_sessions = catspeak.sessionEmpty;
    sessions[@ _session_id] = undefined;
    array_push(empty_sessions, _session_id);
}

/// @desc Sets the source code for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} src The source code to compile and evaluate.
function catspeak_session_set_source(_session_id, _src) {
    var catspeak = __catspeak_manager();
    var src_size = string_byte_length(_src);
    var buff = buffer_create(src_size, buffer_fixed, 1);
    buffer_write(buff, buffer_text, _src);
    buffer_seek(buff, buffer_seek_start, 0);
    var scanner = new __CatspeakScanner(buff);
    var lexer = new __CatspeakLexer(scanner);
    var chunk = new __CatspeakChunk();
    var compiler = new __CatspeakCompiler(lexer, chunk);
    var compiler_process = {
        buff : buff,
        compiler : compiler
    };
    var session = catspeak.sessions[_session_id];
    session.chunk = chunk;
    if (catspeak.compilerProcessCurrent == undefined) {
        catspeak.compilerProcessCurrent = compiler_process;
    } else {
        array_push(catspeak.compilerProcesses, compiler_process);
    }
}

/// @desc Sets the VM pop handler for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {script} script_id_or_method The id of the script to execute upon popping a value.
function catspeak_session_set_pop_script(_session_id, _f) {
    var sessions = __catspeak_manager().sessions;
    var session = sessions[@ _session_id];
    session.popScript = is_method(_f) || is_numeric(_f) && script_exists(_f) ? _f : undefined;
}

/// @desc Enables access to global variables for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_global_access(_session_id, _enable) {
    var sessions = __catspeak_manager().sessions;
    var session = sessions[@ _session_id];
    session.globalAccess = is_numeric(_enable) && _enable;
}

/// @desc Enables access to instance variables for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_instance_access(_session_id, _enable) {
    var sessions = __catspeak_manager().sessions;
    var session = sessions[@ _session_id];
    session.instanceAccess = is_numeric(_enable) && _enable;
}

/// @desc Makes all processes of this session use the same workspace.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_shared_workspace(_session_id, _enable) {
    var sessions = __catspeak_manager().sessions;
    var session = sessions[@ _session_id];
    session.sharedWorkspace = is_numeric(_enable) && _enable ? { } : undefined;
}

/// @desc Inserts a new read-only global variable into the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the variable.
/// @param {value} value The value of the variable.
function catspeak_session_add_constant(_session_id, _name, _value) {
    interface[$ _name] = _value;
}

/// @desc Inserts a new function into to the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the function.
/// @param {value} script_id_or_method The reference to the function.
function catspeak_session_add_function(_session_id, _name, _value) {
    var f = _value;
    if not (is_method(f)) {
        if not (is_numeric(_f) && script_exists(_f)) {
            return;
        }
        // this is so that unexposed functions cannot be enumerated
        // by a malicious user in order to access important functions
        f = method(undefined, f);
    }
    interface[$ _name] = f;
}

/// @desc Spawns a process from this session.
/// @param {real} session_id The ID of the session to spawn a process for.
/// @param {script} script_id_or_method The id of the script to execute upon completing the process.
function catspeak_session_create_process(_session_id, _callback_return) {
    var catspeak = __catspeak_manager();
    var session = catspeak.sessions[@ _session_id];
    var process = new __CatspeakVM(session.chunk, session.globalAccess,
            session.instanceAccess, session.popScript, _callback_return);
    array_push(catspeak.runtimeProcesses, process);
    catspeak.runtimeProcessCount += 1;
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
function catspeak_session_destroy(_session_id) {
    catspeak_session_delete_program(_session_id);
    variable_struct_remove(_session_id, "sourceQueue");
    variable_struct_remove(_session_id, "currentSource");
    variable_struct_remove(_session_id, "errorHandler");
    variable_struct_remove(_session_id, "runtime");
}

/// @desc Returns whether this Catspeak session is processing.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_in_progress(_session_id) {
    return _session_id.currentSource != undefined || _session_id.runtime.inProgress();
}

/// @desc Rewinds this Catspeak session back to the start of the program.
/// @param {struct} session The Catspeak session to rewind.
function catspeak_session_rewind_program(_session_id) {
    _session_id.runtime.rewind();
}

/// @desc Permanently removes the current program from this Catspeak session.
/// @param {struct} session The Catspeak session to rewind.
function catspeak_session_delete_program(_session_id) {
    if (_session_id.currentSource != undefined) {
        buffer_delete(_session_id.currentSource.buff);
        var source_queue = _session_id.sourceQueue;
        for (var i = array_length(source_queue) - 1; i >= 0; i -= 1) {
            var source = source_queue[i];
            buffer_delete(source.buff);
        }
    }
    _session_id.runtime.reset();
}

/// @desc Returns the current variable workspace for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_get_workspace(_session_id) {
    return _session_id.runtime.getWorkspace();
}

/// @desc Sets the current variable workspace for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {struct} workspace The variable workspace to assign.
function catspeak_session_set_workspace(_session_id, _vars) {
    _session_id.runtime.setWorkspace(_vars);
}

/// @desc Sets the error handler for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon receiving a Catspeak error.
function catspeak_session_add_error_handler(_session_id, _f) {
    _session_id.errorHandler.add(_f);
}

/// @desc Sets the error handler for this Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon receiving a result.
function catspeak_session_add_result_handler(_session_id, _f) {
    _session_id.runtime.setOption(__CatspeakVMOption.RESULT_HANDLER, _f);
}

/// @desc Sets a function to call on popped expression statementes.
/// @param {struct} session The Catspeak session to consider.
/// @param {script} method_or_script_id The id of the script to execute upon popping an expression statement.
function catspeak_session_add_expression_statement_handler(_session_id, _f) {
    _session_id.runtime.setOption(__CatspeakVMOption.POP_HANDLER, _f);
}

/// @desc Enables access to global variables from within Catspeak.
/// @param {struct} session The Catspeak session to consider.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_global_access(_session_id, _enable) {
    _session_id.runtime.setOption(__CatspeakVMOption.GLOBAL_VISIBILITY, _enable);
}

/// @desc Enables access to instance variables from within Catspeak.
/// @param {struct} session The Catspeak session to consider.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_instance_access(_session_id, _enable) {
    _session_id.runtime.setOption(__CatspeakVMOption.INSTANCE_VISIBILITY, _enable);
}

/// @desc Inserts a new read-only global variable into the interface.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} name The name of the variable.
/// @param {value} value The value of the variable.
function catspeak_session_add_constant(_session_id, _name, _value) {
    _session_id.runtime.addConstant(_name, _value);
}

/// @desc Inserts a new function into to the interface.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} name The name of the function.
/// @param {value} method_or_script_id The reference to the function.
function catspeak_session_add_function(_session_id, _name, _value) {
    _session_id.runtime.addFunction(_name, _value);
}

/// @desc Adds a new piece of source code to the current Catspeak session.
/// @param {struct} session The Catspeak session to consider.
/// @param {string} src The source code to compiler and evaluate.
function catspeak_session_add_source(_session_id, _src) {
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
    if (_session_id.currentSource == undefined) {
        _session_id.currentSource = source;
    } else {
        array_insert(_session_id.sourceQueue, 0, source);
    }
}

/// @desc Discards a recently queued piece of source code.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_discard_source(_session_id) {
    buffer_delete(_session_id.currentSource.buff);
    var source_queue = _session_id.sourceQueue;
    if (array_length(source_queue) > 0) {
        _session_id.currentSource = array_pop(source_queue);
    } else {
        _session_id.currentSource = undefined;
    }
}

/// @desc Performs a single update step for the compiler.
/// @param {struct} session The Catspeak session to consider.
function catspeak_session_update(_session_id) {
    static handle_catspeak_error = function(_e, _f) {
        if (instanceof(_e) == "__CatspeakError") {
            if not (_f.isEmpty()) {
                _f.run(_e);
                return;
            }
        }
        throw _e;
    };
    var source = _session_id.currentSource;
    var runtime = _session_id.runtime;
    if (source != undefined) {
        var compiler = source.compiler;
        try {
            compiler.generateCode();
        } catch (_e) {
            handle_catspeak_error(_e, _session_id.errorHandler);
            // discard this chunk since it's spicy
            catspeak_session_discard_source(_session_id);
        }
        if not (compiler.inProgress()) {
            // start progress on the new compiler
            runtime.addChunk(source.chunk);
            catspeak_session_discard_source(_session_id);
        }
    } else {
        try {
            runtime.computeProgram();
        } catch (_e) {
            handle_catspeak_error(_e, _session_id.errorHandler);
            // discard the current chunk
            runtime.terminateChunk();
        }
    }
}

/// @desc Eagerly compiles and evalutes the current Catspeak session.
/// @param {struct} session The Catspeak session to evaluate.
function catspeak_session_update_eager(_session_id) {
    while (catspeak_session_in_progress(_session_id)) {
        catspeak_session_update(_session_id);
    }
}
*/