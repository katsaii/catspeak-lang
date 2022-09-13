//! Compatibility scripts from version 1.2.3. All functions are deprecated
//! and some have no implementations. There is no guarantee that old code
//! will behave exactly as it did in the past because of huge design changes.

//# feather use syntax-errors

/// Updates the time limit for updating Catspeak processes.
///
/// @deprecated
function catspeak_start_frame() {
    // does nothing in Catspeak 2
}

/// Updates the catspeak manager.
///
/// @deprecated
function catspeak_update() {
    // does nothing in Catspeak 2
}

/// Sets the error handler for Catspeak errors.
///
/// @param {Function} script_id_or_method
///   The id of the script to execute upon encountering an error.
///
/// @deprecated
function catspeak_set_error_script(script_id_or_method) {
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
    catspeak_config({ "iterationLimit" : iteration_count });
}

/// Sets the maximum percentage of a game frame to spend processing.
///
/// @param {Real} amount
///   The amount in the range 0-1.
///
/// @deprecated
function catspeak_set_frame_allocation(amount) {
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
    // does nothing in Catspeak 2
}

/// Creates a new Catspeak session and returns its ID.
///
/// @deprecated
/// @return {Struct}
function catspeak_session_create() {
    // TODO
}

/// Destroys an existing catspeak session.
///
/// @param {Real} session_id
///   The ID of the session to destroy.
///
/// @deprecated
function catspeak_session_destroy(session_id) {
    // TODO
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
    // TODO
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
    // TODO
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
    // TODO
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
    // TODO
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
    // TODO
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
    // TODO
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
    // TODO
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
    // TODO
}