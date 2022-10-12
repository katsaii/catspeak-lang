//! A [Future] is similar a way of organising asynchronous code in a more
//! manageable way than nested callbacks. This library contains methods of
//! creating and combining new futures.

//# feather use syntax-errors

/// Creates a new [Future] which is resolved only when all other
/// futures in an array are resolved.
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_join(futures) {
    var count = array_length(futures);
    var newFuture = new Future();
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

/// The different progress states of a [Future].
enum FutureState {
    UNRESOLVED,
    RESOLVED,
}

/// Constructs a new future, allowing for deferred execution of code
/// depending on whether it was accepted or rejected.
function Future() constructor {
    self.state = FutureState.UNRESOLVED;
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
        return state == FutureState.RESOLVED;
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andThen = function(callback) {
        var newFuture;
        if (state == FutureState.UNRESOLVED) {
            newFuture = new Future();
            array_push(thenCallbacks, callback, newFuture);
            andCatch(method(newFuture, function(result) {
                reject(result);
            }));
        } else {
            // evaluate immediately
            newFuture = callback(result);
        }
        if (newFuture == undefined) {
            newFuture = new Future();
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
    /// @return {Struct.Future}
    static andCatch = function(callback) {
        var newFuture;
        if (state == FutureState.UNRESOLVED) {
            newFuture = new Future();
            array_push(catchCallbacks, callback, newFuture);
        }
        if (newFuture == undefined) {
            newFuture = new Future();
            newFuture.accept();
        }
        return newFuture;
    };

    /// @ignore
    static __handleEvents = function(value, callbacks) {
        if (state == FutureState.UNRESOLVED) {
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
        state = FutureState.RESOLVED;
    };
}
