//! Compatibility scripts from version 1.2.3. All functions are deprecated
//! and some have no implementations. There is no guarantee that old code
//! will behave exactly as it did in the past because of huge design changes.

//# feather use syntax-errors

/// @desc Updates the time limit for updating Catspeak processes.
function catspeak_start_frame() {
    // TODO
}

/// @desc Updates the catspeak manager.
function catspeak_update() {
    // TODO
}

/// @desc Sets the error handler for Catspeak errors.
/// @param {script} script_id_or_method The id of the script to execute upon encountering an error.
function catspeak_set_error_script(_f) {
    // TODO
}

/// @desc Sets the maximum number of iterations a process can perform before being stopped.
/// @param {real} iteration_count The number of maximum number of iterations to perform. Use `-1` for unlimited.
function catspeak_set_max_iterations(_iteration_count) {
    // TODO
}

/// @desc Sets the maximum percentage of a game frame to spend processing.
/// @param {real} amount The amount in the range 0-1.
function catspeak_set_frame_allocation(_amount) {
    // TODO
}

/// @desc Sets the threshold for processing in the current frame. Processing will not continue beyond this point.
/// @param {real} amount The amount in the range 0-1.
function catspeak_set_frame_threshold(_amount) {
    // TODO
}

/// @desc Creates a new Catspeak session and returns its ID.
function catspeak_session_create() {
    // TODO
}

/// @desc Destroys an existing catspeak session.
/// @param {real} session_id The ID of the session to destroy.
function catspeak_session_destroy(_session_id) {
    // TODO
}

/// @desc Sets the source code for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} src The source code to compile and evaluate.
function catspeak_session_set_source(_session_id, _src) {
    // TODO
}

/// @desc Enables access to global variables for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_global_access(_session_id, _enable) {
    // TODO
}

/// @desc Enables access to instance variables for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_instance_access(_session_id, _enable) {
    // TODO
}

/// @desc Enables implicit returns for this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_implicit_return(_session_id, _enable) {
    // TODO
}

/// @desc Makes all processes of this session use the same workspace.
/// @param {struct} session_id The ID of the session to update.
/// @param {bool} enable Whether to enable this option.
function catspeak_session_enable_shared_workspace(_session_id, _enable) {
    // TODO
}

/// @desc Inserts a new read-only global variable into the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the variable.
/// @param {value} value The value of the variable.
function catspeak_session_add_constant(_session_id, _name, _value) {
    // TODO
}

/// @desc Inserts a new function into to the interface of this session.
/// @param {struct} session_id The ID of the session to update.
/// @param {string} name The name of the function.
/// @param {value} script_id_or_method The reference to the function.
function catspeak_session_add_function(_session_id, _name, _value) {
    // TODO
}

/// @desc Spawns a process from this session.
/// @param {real} session_id The ID of the session to spawn a process for.
/// @param {script} script_id_or_method The id of the script to execute upon completing the process.
/// @param {array} args The arguments to pass to the process.
function catspeak_session_create_process(_session_id, _callback_return, _args=[]) {
    // TODO
}

/// @desc Spawns a process from this session which is evaluated immediately.
/// @param {real} session_id The ID of the session to spawn a process for.
/// @param {array} args The arguments to pass to the process.
function catspeak_session_create_process_greedy(_session_id, _args=[]) {
    // TODO
}