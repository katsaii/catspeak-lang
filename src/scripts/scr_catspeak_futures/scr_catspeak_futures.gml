//! Handles the creation of asynchronous Catspeak processes. Execution time
//! is divided between them so each gets a chance to progress.

//# feather use syntax-errors

function catspeak_futures_join(futures) {
    // TODO
}

/// Constructs a new Catspeak process.
///
/// @param {Function} resolver
///   A function which performs the necessary operations to progress the state
///   of this future. It accepts a single function as a parameter. Call this
///   function with the result of the future to complete the computation.
function CatspeakFuture(resolver) constructor {
    self.resolver = resolver;
    self.resolved = false;
    self.result = undefined;
    self.thenHandler = undefined;
    self.catchHandler = undefined;
    self.timeSpent = 0;
    self.timeLimit = 0;
    self.resolveFunc = function(result_) {
        resolved = true;
        result = result_;
        if (thenHandler != undefined) {
            thenHandler(result);
        }
    };

    // invoke the process
    var manager = global.__catspeakProcessManager;
    timeLimit = manager.processTimeLimit;
    ds_list_add(manager.processes, self);
    if (manager.inactive) {
        manager.inactive = false;
        time_source_start(manager.timeSource);
    }

    /// Updates this Catspeak future by calling its resolver once.
    static update = function() {
        resolver(resolveFunc);
    };

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
        self.callbacks = callback;
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