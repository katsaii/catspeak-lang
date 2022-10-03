//! Handles the creation of asynchronous Catspeak processes. Execution time
//! is divided between them so each gets a chance to progress.

//# feather use syntax-errors

function catspeak_futures_join(futures) {
    // TODO
}

/// Constructs a new Catspeak process. It accepts a single parameter; a
/// struct containing the following fields:
///
///  - "update" should be a function which performs the necessary operations
///    to progress the process. This should not attempt to perform all of the
///    tasks in a single go, otherwise you risk freezing the game. This
///    function should return `true` if the process is complete, or any other
///    value otherwise.
///
///  - "getResult" should be a function which returns the final result of the
///    process.
///
/// @param {Function} resolver
///   A function which performs the necessary operations to progress the state
///   of this future. It accepts two parameters: the first parameter is the
///   `success` callback; the second is the `reject` callback. It will be called repetitively until either 
function CatspeakFuture(methods) constructor {
    var manager = global.__catspeakProcessManager;
    self.methods = methods;
    self.callbacks = [];
    self.catchHandler = undefined;
    self.timeSpent = 0;
    self.timeLimit = manager.processTimeLimit;

    // invoke the process
    ds_list_add(manager.processes, self);
    if (manager.inactive) {
        manager.inactive = false;
        time_source_start(manager.timeSource);
    }

    /// Sets the time limit for this process, overrides the default time limit
    /// defined using [catspeak_config].
    ///
    /// @param {Real} t
    ///   The time limit (in seconds) the process is allowed to run for before
    ///   it is assumed unresponsive and terminated. Set this to `undefined` to
    ///   use the default time limit.
    ///
    /// @return {Struct.CatspeakFuture}
    static withTimeLimit = function(t) {
        timeLimit = t;
        return self;
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andThen = function(callback) {
        self.catchHandler = callback;
        return self;
    };

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andCatch = function(callback) {
        self.catchHandler = callback;
        return self;
    };
}