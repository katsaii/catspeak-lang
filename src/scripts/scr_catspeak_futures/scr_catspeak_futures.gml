//! Handles the creation of asynchronous Catspeak processes. Execution time
//! is divided between them so each gets a chance to progress.

//# feather use syntax-errors

/// Creates a new [CatspeakFuture] which is resolved only when all other
/// futures in an array are resolved.
///
/// @param {Array<Struct.CatspeakFuture>} futures
///   The array of futures to await.
///
/// @return {Struct.CatspeakFuture}
function catspeak_futures_join(futures) {
    var count = array_length(futures);
    var newFuture = new CatspeakFuture();
    if (count == 0) {
        newFuture.accept([]);
    } else {
        var joinData = {
            future : newFuture,
            count : count,
            results : array_create(count, undefined),
        };
        for (var i = 0; i < count; i += 1) {
            var future = futures[i];
            future.andThen(method({
                pos : i,
                joinData : joinData,
            }, function(result) {
                var future = joinData.future;
                if (future.resolved()) {
                    return;
                }
                var results = joinData.results;
                results[@ pos] = result;
                joinData.count -= 1;
                if (joinData.count <= 0) {
                    future.accept(results);
                }
            }));
            future.andCatch(method(joinData, function(result) {
                if (future.resolved()) {
                    return;
                }
                future.reject(result);
            }));
        }
    }
    return newFuture;
}

/// The different progress states of a Catspeak future.
enum CatspeakFutureState {
    UNRESOLVED,
    RESOLVED,
}

/// Constructs a new Catspeak future, allowing for deferred execution of code
/// depending on whether the future was accepted or rejected.
function CatspeakFuture() constructor {
    self.state = CatspeakFutureState.UNRESOLVED;
    self.timeLimit = -1;
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

    /// Returns whether this future has been resolved. A resolved future
    /// may be the result of being accepted OR rejected.
    ///
    /// @return {Bool}
    static resolved = function() {
        return state == CatspeakFutureState.RESOLVED;
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andThen = function(callback) {
        var newFuture;
        if (state == CatspeakFutureState.UNRESOLVED) {
            newFuture = new CatspeakFuture();
            array_push(thenCallbacks, callback, newFuture);
            andCatch(method(newFuture, function(result) {
                reject(result);
            }));
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

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.CatspeakFuture}
    static andCatch = function(callback) {
        var newFuture;
        if (state == CatspeakFutureState.UNRESOLVED) {
            newFuture = new CatspeakFuture();
            array_push(catchCallbacks, callback, newFuture);
        }
        if (newFuture == undefined) {
            newFuture = new CatspeakFuture();
            newFuture.accept();
        }
        return newFuture;
    };

    /// Sets the time limit for this process, overrides the default time limit
    /// defined using [catspeak_config].
    ///
    /// NOTE: This method exists on [CatspeakFuture] for polymorphism reasons.
    ///       the time limit will only affect instances of [CatspeakProcess].
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
    };
}

/// Constructs a new Catspeak process. Instances of this struct will be
/// managed globally by the Catspeak execution engine.
///
/// @param {Function} resolver
///   A function which performs the necessary operations to progress the state
///   of this future. It accepts a single function as a parameter. Call this
///   function with the result of the future to complete the computation.
function CatspeakProcess(resolver) : CatspeakFuture() constructor {
    self.resolver = resolver;
    self.timeSpent = 0;
    self.acceptFunc = function(result_) { accept(result_) };

    // invoke the process
    var manager = global.__catspeakProcessManager;
    withTimeLimit(manager.processTimeLimit);
    var eh = manager.exceptionHandler;
    if (eh != undefined) {
        andCatch(eh);
    }
    ds_list_add(manager.processes, self);
    if (manager.inactive) {
        manager.inactive = false;
        time_source_start(manager.timeSource);
    }

    /// @ignore
    static __update = function() {
        try {
            resolver(acceptFunc);
        } catch (ex) {
            reject(ex);
        }
    };
}