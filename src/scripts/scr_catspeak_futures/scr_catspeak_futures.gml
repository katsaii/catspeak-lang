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
        if (state == CatspeakFutureState.UNRESOLVED) {
            var callbacks = thenCallbacks;
            for (var i = array_length(callbacks) - 1; i >= 0; i -= 1) {
                var callback = callbacks[i];
                callback(value);
            }
        }
        state = CatspeakFutureState.RESOLVED;
        result = value;
    }

    /// Rejects this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static reject = function(value) {
        if (state == CatspeakFutureState.UNRESOLVED) {
            var callbacks = catchCallbacks;
            for (var i = array_length(callbacks) - 1; i >= 0; i -= 1) {
                var callback = callbacks[i];
                callback(value);
            }
        }
        state = CatspeakFutureState.RESOLVED;
    }

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andThen = function(callback) {
        var newFuture;
        if (state == CatspeakFutureState.UNRESOLVED) {
            array_push(thenCallbacks, callback);
            // TODO
        } else {
            // evaluate immediately
            newFuture = callback(result);
        }
        if (newFuture == undefined) {
            newFuture = new CatspeakFuture();
            newFuture.accept();
        }
    };

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andCatch = function(callback) {
        if (state == CatspeakFutureState.UNRESOLVED) {
            array_push(catchCallbacks, callback);
            // TODO
        } else {
            // evaluate immediately
            var newFuture = callback(result);
            if (newFuture == undefined) {
                newFuture = new CatspeakFuture();
                newFuture.accept();
            }
        }
        if (newFuture == undefined) {
            newFuture = new CatspeakFuture();
            newFuture.accept();
        }
    };
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