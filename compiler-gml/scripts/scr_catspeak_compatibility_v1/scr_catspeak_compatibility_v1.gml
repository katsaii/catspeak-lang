//! Compatibility scripts from version 1.2.3. All functions are deprecated
//! and some have no implementations. There is no guarantee that old code
//! will behave exactly as it did in the past because of huge design changes.

//# feather use syntax-errors

// CATSPEAK 1 //

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
/// @deprecated
///
/// @param {Function} script_id_or_method
///   The id of the script to execute upon encountering an error.
function catspeak_set_error_script(script_id_or_method) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 3
}

/// Sets the maximum number of iterations a process can perform before being
/// stopped.
///
/// @deprecated
///
/// @param {Real} iteration_count
///   The number of maximum number of iterations to perform. Use `-1` for
///   unlimited.
function catspeak_set_max_iterations(iteration_count) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 3
}

/// Sets the maximum percentage of a game frame to spend processing.
///
/// @deprecated
///
/// @param {Real} amount
///   The amount in the range 0-1.
function catspeak_set_frame_allocation(amount) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 3
}

/// Sets the threshold for processing in the current frame. Processing will
/// not continue beyond this point.
///
/// @deprecated
///
/// @param {Real} amount
///   The amount in the range 0-1.
function catspeak_set_frame_threshold(amount) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Creates a new Catspeak session and returns its ID.
///
/// @deprecated
///
/// @return {Struct}
function catspeak_session_create() {
    gml_pragma("forceinline");
    return {
        env : new CatspeakEnvironment(),
        hir : undefined,
        main : undefined,
    };
}

/// Destroys an existing catspeak session.
///
/// @deprecated
///
/// @param {Real} session_id
///   The ID of the session to destroy.
function catspeak_session_destroy(session_id) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Sets the source code for this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {String} src
///   The source code to compile and evaluate.
function catspeak_session_set_source(session_id, src) {
    gml_pragma("forceinline");
    session_id.hir = session_id.env.parseString(src);
    session_id.main = session_id.env.compile(session_id.hir);
}

/// Enables access to global variables for this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
function catspeak_session_enable_global_access(session_id, enable) {
    gml_pragma("forceinline");
    session_id.env.interface.exposeConstant(
            "global", catspeak_special_to_struct(global));
}

/// Enables access to instance variables for this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
function catspeak_session_enable_instance_access(session_id, enable) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Enables implicit returns for this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
function catspeak_session_enable_implicit_return(session_id, enable) {
    gml_pragma("forceinline");
    // does nothing in catspeak 3
}

/// Makes all processes of this session use the same workspace.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {Bool} enable
///   Whether to enable this option.
function catspeak_session_enable_shared_workspace(session_id, enable) {
    gml_pragma("forceinline");
    // does nothing in Catspeak 2
}

/// Inserts a new global variable into the interface of this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {String} name
///   The name of the variable.
///
/// @param {Any} value
///   The value of the variable.
function catspeak_session_add_constant(session_id, name, value) {
    gml_pragma("forceinline");
    session_id.env.interface.exposeConstant(name, value);
}

/// Inserts a new function into to the interface of this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to update.
///
/// @param {String} name
///   The name of the function.
///
/// @param {Any} script_id_or_method
///   The reference to the function.
function catspeak_session_add_function(
    session_id, name, script_id_or_method
) {
    gml_pragma("forceinline");
    session_id.env.interface.exposeFunction(name, script_id_or_method);
}

/// Spawns a process from this session.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to spawn a process for.
///
/// @param {Function} [script_id_or_method]
///   The id of the script to execute upon completing the process.
///
/// @param {Array<Any>} [args]
///   The arguments to pass to the process.
function catspeak_session_create_process(
    session_id, script_id_or_method, args=[]
) {
    var result = catspeak_execute_ext(session_id.main, self, args);
    script_id_or_method(result);
}

/// Spawns a process from this session which is evaluated immediately.
///
/// @deprecated
///
/// @param {Struct} session_id
///   The ID of the session to spawn a process for.
///
/// @param {Array<Any>} [args]
///   The arguments to pass to the process.
///
/// @return {Any}
function catspeak_session_create_process_greedy(session_id, args=[]) {
    return catspeak_execute_ext(session_id.main, self, args);
}