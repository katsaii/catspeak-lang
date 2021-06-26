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
    var frame_time = game_get_speed(gamespeed_microseconds);
    var time_limit = min(_frame_start + frame_time,
            get_timer() + catspeak.frameAllocation * frame_time);
    var f = catspeak.errorScript;
    var runtime_processes = catspeak.runtimeProcesses;
    var compiler_processes = catspeak.compilerProcesses;
    var max_iteration_count = catspeak.maxIterations;
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
                }
            }
        } else if (catspeak.runtimeProcessCount > 0) {
            // update runtime processes
            var process_id = catspeak.runtimeProcessID;
            var runtime_process = runtime_processes[process_id];
            var runtime = runtime_process.runtime;
            static kill_process = function(_catspeak, _process_id) {
                array_delete(_catspeak.runtimeProcesses, _process_id, 1);
                _catspeak.runtimeProcessCount -= 1;
            };
            try {
                runtime.computeProgram();
            } catch (_e) {
                kill_process(catspeak, process_id);
                handle_catspeak_error(_e, f);
                continue;
            }
            if not (runtime.inProgress()) {
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
    catspeak.maxIterations = is_numeric(_iteration_count) && _iteration_count >= 0 ? _iteration_count : -1;
}

/// @desc Creates a new Catspeak session and returns its ID.
function catspeak_session_create() {
    var catspeak = __catspeak_manager();
    var session = {
        globalAccess : false,
        instanceAccess : false,
        implicitReturn : false,
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

/// @desc Enables implicit returns for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_implicit_return(_session_id, _enable) {
    var sessions = __catspeak_manager().sessions;
    var session = sessions[@ _session_id];
    session.implicitReturn = is_numeric(_enable) && _enable;
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
    var catspeak = __catspeak_manager();
    var session = catspeak.sessions[@ _session_id];
    session.interface[$ _name] = _value;
}

/// @desc Inserts a new function into to the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the function.
/// @param {value} script_id_or_method The reference to the function.
function catspeak_session_add_function(_session_id, _name, _value) {
    var catspeak = __catspeak_manager();
    var session = catspeak.sessions[@ _session_id];
    var f = _value;
    if not (is_method(f)) {
        if not (is_numeric(f)) {
            return;
        }
        // this is so that unexposed functions cannot be enumerated
        // by a malicious user in order to access important functions
        f = method(undefined, f);
    }
    session.interface[$ _name] = f;
}

/// @desc Spawns a process from this session.
/// @param {real} session_id The ID of the session to spawn a process for.
/// @param {script} script_id_or_method The id of the script to execute upon completing the process.
function catspeak_session_create_process(_session_id, _callback_return) {
    var catspeak = __catspeak_manager();
    var session = catspeak.sessions[@ _session_id];
    var runtime = new __CatspeakVM(session.chunk, catspeak.maxIterations, session.globalAccess,
            session.instanceAccess, session.implicitReturn, session.interface,
            session.sharedWorkspace, _callback_return);
    var runtime_process = {
        runtime : runtime
    };
    array_push(catspeak.runtimeProcesses, runtime_process);
    catspeak.runtimeProcessCount += 1;
}

