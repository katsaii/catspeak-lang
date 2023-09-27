//! Contains a simple compatibility layer for help with converting projects
//! from Catspeak 2 to Catspeak 3. There are many breaking changes between
//! these versions, so sorry!

//# feather use syntax-errors

/// @ignore
///
/// @param {Any} name
/// @param {Any} [alternative]
function __catspeak_deprecated(name, alternative=undefined) {
    if (__catspeak_is_nullish(alternative)) {
        __catspeak_error_silent("'", name, "' isn't supported anymore");
    } else {
        __catspeak_error_silent(
            "'", name, "' isn't supported anymore",
            ", use '", alternative, "' instead"
        );
    }
}

// CATSPEAK 2 //

/// Configures various global settings of the Catspeak compiler and runtime.
/// See the list in `scr_catspeak_config` for configuration values and their
/// usages.
///
/// @deprecated {3.0.0}
///
/// @return {Struct}
function catspeak_config() {
    catspeak_force_init();
    var config = global.__catspeakConfig;
    if (argument_count > 0 && is_struct(argument[0])) {
        // for compatibility
        var newConfig = argument[0];
        var keys = variable_struct_get_names(newConfig);
        for (var i = array_length(keys) - 1; i > 0; i -= 1) {
            var key = keys[i];
            if (variable_struct_exists(config, key)) {
                config[$ key] = newConfig[$ key];
            }
        }
    }
    return config;
}

/// Permanently adds a new Catspeak function to the default standard library.
///
/// @deprecated {3.0.0}
///   Use `Catspeak.interface.exposeFunction` instead.
///
/// @param {String} name
///   The name of the function to add.
///
/// @param {Function} f
///   The function to add, will be converted into a method if a script ID
///   is used.
///
/// @param {Any} ...
///   The remaining key-value pairs to add, in the same pattern as the two
///   previous arguments.
function catspeak_add_function() {
    __catspeak_deprecated("catspeak_add_function", "Catspeak.addFunction");
    catspeak_force_init();
    for (var i = 0; i < argument_count; i += 2) {
        Catspeak.addFunction(argument[i + 0], argument[i + 1]);
    }
}

/// Permanently adds a new Catspeak constant to the default standard library.
/// If you want to add a function, use the `catspeak_add_function` function
/// instead because it makes sure your value will be callable from within
/// Catspeak.
///
/// @deprecated {3.0.0}
///   Use `Catspeak.interface.exposeConstant` instead.
///
/// @param {String} name
///   The name of the constant to add.
///
/// @param {Any} value
///   The value to add.
///
/// @param {Any} ...
///   The remaining key-value pairs to add, in the same pattern as the two
///   previous arguments.
function catspeak_add_constant() {
    __catspeak_deprecated("catspeak_add_function", "Catspeak.addConstant");
    catspeak_force_init();
    for (var i = 0; i < argument_count; i += 2) {
        Catspeak.addConstant(argument[i + 0], argument[i + 1]);
    }
}

/// Creates a new Catspeak runtime process for this Catspeak function. This
/// function is also compatible with GML functions.
///
/// @deprecated {3.0.0}
///   Just invoke your script directly instead: `scr(args)`
///
/// @param {Function} scr
///   The GML or Catspeak function to execute.
///
/// @param {Array<Any>} [args]
///   The array of arguments to pass to the function call. Defaults to the
///   empty array.
///
/// @return {Struct.Future}
function catspeak_execute(scr, args) {
    __catspeak_deprecated("catspeak_execute");
    static noArgs = [];
    var args_ = args ?? noArgs;
    var argo = 0;
    var argc = array_length(args_);
    try {
        var result;
        with (method_get_self(scr) ?? self) {
            result = script_execute_ext(method_get_index(scr),
                    args_, argo, argc);
        }
        return future_ok(result);
    } catch (e) {
        return future_error(e);
    }
}

/// The old name of `catspeak_into_gml_function` from the compatibility
/// runtime for Catspeak.
///
/// @deprecated {2.3.3}
///   Use `Catspeak.compileGML` instead.
///
/// @param {Struct.CatspeakFunction} scr
///   The Catspeak function to execute.
///
/// @return {Function}
function catspeak_session_extern(scr) {
    __catspeak_deprecated("catspeak_session_extern");
    return catspeak_into_gml_function(scr);
}

/// Converts a Catspeak function into a GML function which is executed
/// immediately.
///
/// @deprecated {3.0.0}
///   Use `Catspeak.compileGML` instead.
///
/// @param {Function} scr
///   The Catspeak function to execute.
///
/// @return {Function}
function catspeak_into_gml_function(scr) {
    __catspeak_deprecated("catspeak_into_gml_function");
    return scr;
}

/// Creates a new Catspeak compiler process for a buffer containing Catspeak
/// code.
///
/// @deprecated {3.0.0}
///   Use `Catspeak.parse` instead.
///
/// @param {ID.Buffer} buff
///   A reference to the buffer containing the source code to compile.
///
/// @param {Bool} [consume]
///   Whether the buffer should be deleted after the compiler process is
///   complete. Defaults to `false`.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0, the
///   start of the buffer.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit will
///   be treated as the end of the file. Defaults to `infinity`.
///
/// @return {Struct.CatspeakProcess}
function catspeak_compile_buffer(buff, consume=false, offset=0, size=undefined) {
    __catspeak_deprecated("catspeak_compile_buffer", "Catspeak.parse");
    var ret;
    try {
        var f = Catspeak.compileGML(Catspeak.parse(buff, offset, size));
        ret = future_ok(f);
    } catch (e) {
        ret = future_error(e);
    } finally {
        if (consume) {
            buffer_delete(buff);
        }
    }
    return ret;
}

/// Creates a new Catspeak compiler process for a string containing Catspeak
/// code. This will allocate a new buffer to store the string, if that isn't
/// ideal then you will have to create and write to your own buffer, then
/// pass it into the `catspeak_compile_buffer` function instead.
///
/// @deprecated {3.0.0}
///   Use `Catspeak.parseString` instead.
///
/// @param {Any} src
///   The value containing the source code to compile.
///
/// @return {Struct.CatspeakProcess}
function catspeak_compile_string(src) {
    __catspeak_deprecated("catspeak_compile_buffer", "Catspeak.parseString");
    try {
        var f = Catspeak.compileGML(Catspeak.parseString(src));
        return future_ok(f);
    } catch (e) {
        return future_error(e);
    }
}

/// A helper function for creating a buffer from a string.
///
/// @deprecated {3.0.0}
///
/// @param {String} src
///   The source code to convert into a buffer.
///
/// @return {Id.Buffer}
function catspeak_create_buffer_from_string(src) {
    __catspeak_deprecated("catspeak_create_buffer_from_string");
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

// FUTURE //

/// The different progress states of a `Future`.
///
/// @deprecated {3.0.0}
enum FutureState {
    UNRESOLVED,
    ACCEPTED,
    REJECTED,
}

/// Constructs a new future, allowing for deferred execution of code depending
/// on whether it was accepted or rejected.
///
/// @deprecated {3.0.0}
function Future() constructor {
    /// @ignore
    self.state = FutureState.UNRESOLVED;
    /// @ignore
    self.result = undefined;
    /// @ignore
    self.thenFuncs = [];
    /// @ignore
    self.catchFuncs = [];
    /// @ignore
    self.finallyFuncs = [];
    /// @ignore
    self.__futureFlag__ = true;

    /// Accepts this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static accept = function(value) {
        __resolve(FutureState.ACCEPTED, value);
        var thenCount = array_length(thenFuncs);
        for (var i = 0; i < thenCount; i += 2) {
            // call then callbacks
            var callback = thenFuncs[i + 0];
            var nextFuture = thenFuncs[i + 1];
            var result = callback(value);
            if (is_future(result)) {
                // if the result returned from the callback is another future,
                // delay the next future until the result future has been
                // resolved
                result.andFinally(method(nextFuture, function(future) {
                    if (future.state == FutureState.ACCEPTED) {
                        accept(future.result);
                    } else {
                        reject(future.result);
                    }
                }));
            } else {
                nextFuture.accept(result);
            }
        }
        var catchCount = array_length(catchFuncs);
        for (var i = 0; i < catchCount; i += 2) {
            // accept catch futures
            var nextFuture = catchFuncs[i + 1];
            nextFuture.accept(value);
        }
        var finallyCount = array_length(finallyFuncs);
        for (var i = 0; i < finallyCount; i += 2) {
            // accept finally futures and call their callbacks
            var callback = finallyFuncs[i + 0];
            var nextFuture = finallyFuncs[i + 1];
            callback(self);
            nextFuture.accept(value);
        }
    };

    /// Rejects this future with the supplied argument.
    ///
    /// @param {Any} [value]
    ///   The value to reject.
    static reject = function(value) {
        __resolve(FutureState.REJECTED, value);
        var thenCount = array_length(thenFuncs);
        for (var i = 0; i < thenCount; i += 2) {
            // reject then futures
            var nextFuture = thenFuncs[i + 1];
            nextFuture.reject(value);
        }
        var catchCount = array_length(catchFuncs);
        for (var i = 0; i < catchCount; i += 2) {
            // call catch callbacks
            var callback = catchFuncs[i + 0];
            var nextFuture = catchFuncs[i + 1];
            var result = callback(value);
            if (is_future(result)) {
                // if the result returned from the callback is another future,
                // delay the next future until the result future has been
                // resolved
                result.andFinally(method(nextFuture, function(future) {
                    if (future.state == FutureState.ACCEPTED) {
                        accept(future.result);
                    } else {
                        reject(future.result);
                    }
                }));
            } else {
                nextFuture.accept(result);
            }
        }
        var finallyCount = array_length(finallyFuncs);
        for (var i = 0; i < finallyCount; i += 2) {
            // reject finally futures and call their callbacks
            var callback = finallyFuncs[i + 0];
            var nextFuture = finallyFuncs[i + 1];
            callback(self);
            nextFuture.reject(value);
        }
    };

    /// Returns whether this future has been resolved. A resolved future
    /// may be the result of being accepted OR rejected.
    ///
    /// @return {Bool}
    static resolved = function() {
        return state != FutureState.UNRESOLVED;
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andThen = function(callback) {
        var future;
        if (state == FutureState.UNRESOLVED) {
            future = new Future();
            array_push(thenFuncs, callback, future);
        } else if (state == FutureState.ACCEPTED) {
            future = future_ok(callback(result));
        }
        return future;
    };

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andCatch = function(callback) {
        var future;
        if (state == FutureState.UNRESOLVED) {
            future = new Future();
            array_push(catchFuncs, callback, future);
        } else if (state == FutureState.REJECTED) {
            future = future_ok(callback(result));
        }
        return future;
    };

    /// Sets the callback function to invoke if this promise is resolved.
    ///
    /// @param {Function} callback
    ///   The function to invoke.
    ///
    /// @return {Struct.Future}
    static andFinally = function(callback) {
        var future;
        if (state == FutureState.UNRESOLVED) {
            future = new Future();
            array_push(finallyFuncs, callback, future);
        } else {
            future = future_ok(callback(self));
        }
        return future;
    };

    /// @ignore
    static __resolve = function(newState, value) {
        if (state != FutureState.UNRESOLVED) {
            show_error(
                    "future has already been resolved with a value of " +
                    "'" + string(result) + "'", false);
            return;
        }
        result = value;
        state = newState;
    };
}

/// Creates a new `Future` which is accepted only when all other futures in an
/// array are accepted. If any future in the array is rejected, then the
/// resulting future is rejected with its value. If all futures are accepted,
/// then the resulting future is accepted with an array of their values.
///
/// @deprecated {3.0.0}
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_all(futures) {
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

/// Creates a new `Future` which is accepted if any of the futures in an
/// array are accepted. If all futures in the array are rejected, then the
/// resulting future is rejected with an array of their values.
///
/// @deprecated {3.0.0}
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_any(futures) {
    var count = array_length(futures);
    var newFuture = new Future();
    if (count == 0) {
        newFuture.reject([]);
    } else {
        var joinData = {
            future : newFuture,
            count : count,
            results : array_create(count, undefined),
        };
        for (var i = 0; i < count; i += 1) {
            var future = futures[i];
            future.andThen(method(joinData, function(result) {
                if (future.resolved()) {
                    return;
                }
                future.accept(result);
            }));
            future.andCatch(method({
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
                    future.reject(results);
                }
            }));
        }
    }
    return newFuture;
}

/// Creates a new `Future` which is accepted when all of the futures in an
/// array are either accepted or rejected.
///
/// @deprecated {3.0.0}
///
/// @param {Array<Struct.Future>} futures
///   The array of futures to await.
///
/// @return {Struct.Future}
function future_settled(futures) {
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
            future.andFinally(method({
                pos : i,
                joinData : joinData,
            }, function(thisFuture) {
                var future = joinData.future;
                if (future.resolved()) {
                    return;
                }
                var results = joinData.results;
                results[@ pos] = thisFuture;
                joinData.count -= 1;
                if (joinData.count <= 0) {
                    future.accept(results);
                }
            }));
        }
    }
    return newFuture;
}

/// Creates a new `Future` which is immediately accepted with a value.
/// If the value itself it an instance of `Future`, then it is returned
/// instead.
///
/// @deprecated {3.0.0}
///
/// @param {Any} value
///   The value to create a future from.
///
/// @return {Struct.Future}
function future_ok(value) {
    if (is_future(value)) {
        return value;
    }
    var future = new Future();
    future.accept(value);
    return future;
}

/// Creates a new `Future` which is immediately rejected with a value.
/// If the value itself it an instance of `Future`, then it is returned
/// instead.
///
/// @deprecated {3.0.0}
///
/// @param {Any} value
///   The value to create a future from.
///
/// @return {Struct.Future}
function future_error(value) {
    if (is_future(value)) {
        return value;
    }
    var future = new Future();
    future.reject(value);
    return future;
}

/// Returns whether this value represents a future instance.
///
/// @deprecated {3.0.0}
///
/// @param {Any} value
///   The value to check.
///
/// @return {Bool}
function is_future(value) {
    gml_pragma("forceinline");
    return is_struct(value) && variable_struct_exists(value, "__futureFlag__");
}