//! Handles the creation of asynchronous Catspeak processes. Execution time
//! is divided between them so each gets a chance to progress.

//# feather use syntax-errors

/// The different progress states of a Catspeak future.
enum CatspeakFutureState {
    UNRESOLVED,
    RESOLVED,
}

/// Constructs a new Catspeak future, allowing for deferred execution of code
/// depending on whether the future was accepted or rejected.
function CatspeakFuture() constructor {
    self.state = CatspeakFutureState.UNRESOLVED;
    self.result = undefined;
    self.thenCallbacks = [];
    self.catchCallbacks = [];

    /// Accepts this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static accept = function(value) {
        __handleEvents(value, thenCallbacks);
        result = value;
    };

    /// Rejects this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static reject = function(value) {
        __handleEvents(value, catchCallbacks);
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andThen = function(callback) {
        return __addEvent(thenCallbacks, callback);
    };

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andCatch = function(callback) {
        return __addEvent(catchCallbacks, callback);
    };

    /// @ignore
    static __addEvent = function(callbacks, callback) {
        var newFuture;
        if (state == CatspeakFutureState.UNRESOLVED) {
            newFuture = new CatspeakFuture();
            array_push(callbacks, callback, newFuture);
        } else {
            // evaluate immediately
            newFuture = callback(result);
        }
        if (newFuture == undefined) {
            newFuture = new CatspeakFuture();
            newFuture.accept();
        }
        return newFuture;
    };

    /// @ignore
    static __handleEvents = function(value, callbacks) {
        if (state == CatspeakFutureState.UNRESOLVED) {
            var count = array_length(callbacks);
            for (var i = 0; i < count; i += 2) {
                var callback = callbacks[i];
                var future = callbacks[i + 1];
                var result = callback(value);
                if (result == undefined) {
                    future.accept();
                } else {
                    result.andThen(method({
                        future : future,
                    }, function(value) {
                        future.accept(value);
                    }));
                }
            }
        }
        state = CatspeakFutureState.RESOLVED;
        result = value;
    };
}
/*
/// Constructs a new Catspeak process.
///
/// @param {Function} resolver
///   A function which performs the necessary operations to progress the state
///   of this future. It accepts a single function as a parameter. Call this
///   function with the result of the future to complete the computation.
function CatspeakProcess(resolver) : CatspeakFuture() constructor {
    self.resolver = resolver;
    self.timeSpent = 0;
    self.timeLimit = 0;
    self.acceptFunc = function(result_) { accept(result_) };

    // invoke the process
    var manager = global.__catspeakProcessManager;
    timeLimit = manager.processTimeLimit;
    ds_list_add(manager.processes, self);
    if (manager.inactive) {
        manager.inactive = false;
        time_source_start(manager.timeSource);
    }

    /// Updates this Catspeak process by calling its resolver once.
    static update = function() {
        try {
            resolver(acceptFunc);
        } catch (ex) {
            reject(ex);
        }
    };

    /// Sets the time limit for this process, overrides the default time limit
    /// defined using [catspeak_config].
    ///
    /// @deprecated
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
}
*/