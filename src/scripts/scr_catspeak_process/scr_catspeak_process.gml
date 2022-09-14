//! Handles the creation of Catspeak processes, and divides execution time
//! between them so each gets a change to progress during the current tick.

//# feather use syntax-errors

/// An interface used by the Catspeak process manager.
///
/// The `update` field should be a function which performs the necessary
/// operations to progress the process. This should not attempt to perform
/// all of the tasks of the process in a single go, otherwise you risk
/// freezing the game.
///
/// The `isBusy` field should be a function which returns `true` or `false`
/// depending on whether the process is still busy with the task.
///
/// Finally, the `result` field should be a function which returns the final
/// result of the completed process.
function CatspeakProcess() constructor {
    self.update = undefined;
    self.isBusy = undefined;
    self.result = undefined;
    self.callback = undefined;
    self.callbackCatch = undefined;
    self.timeSpent = 0;
    self.timeLimit = undefined;
    self.used = false;

    /// Sets the time limit for this process, overrides the default time limit
    /// defined using `catspeak_config`.
    ///
    /// @param {Real} t
    ///   The time limit (in seconds) the process is allowed to run for before
    ///   it is assumed unresponsive and terminated. Set this to `undefined` to
    ///   use the default time limit.
    static withTimeLimit = function(t) {
        timeLimit = t;
        return self;
    };

    /// Sets the callback function to invoke once the process is complete.
    ///
    /// @param {Function} callback
    ///   The function to invoke once this process is complete.
    static andThen = function(callback) {
        self.callback = callback;
        return self;
    };

    /// Sets the callback function to invoke if an error occurrs whilst the
    /// process is running.
    ///
    /// @param {Function} callback
    ///   The function to invoke if an error occurrs.
    static catchError = function(callback) {
        self.callbackCatch = callback;
        return self;
    };

    /// Adds this process to the list of active processes in the next
    /// execution tick.
    static invoke = function() {
        if (used) {
            throw new CatspeakError(undefined,
                    "cannot invoke a Catspeak process more than once");
        }
        used = true;
        var manager = global.__catspeakProcessManager;
        timeSpent = 0;
        timeLimit ??= manager.processTimeLimit;
        ds_list_add(manager.processes, self);
        if (manager.inactive) {
            manager.inactive = false;
            time_source_start(manager.timeSource);
        }
    }
}

/// Handles the execution of a GML function.
function CatspeakGMLProcess() : CatspeakProcess() constructor {
    self.hasValue = false;
    self.value = undefined;
    self.self_ = undefined;
    self.f = undefined;
    self.argc = 0;
    self.argo = 0;
    self.args = undefined;
    self.update = function() {
        if (hasValue) {
            return;
        }
        hasValue = true;
        var f_ = f;
        var scrSelf = method_get_self(f_) ?? self_;
        var scr = method_get_index(f_);
        var result;
        with (scrSelf) {
            result = script_execute_ext(scr, args, argo, argc);
        }
        value = result;
    };
    self.isBusy = function() { return !hasValue };
    self.result = function() { return value };
}

/// Handles the exeuction of Catspeak compilation processes.
function CatspeakCompilerProcess() : CatspeakProcess() constructor {
    self.compiler = undefined;
    self.consume = undefined;
    self.update = function() { compiler.emitProgram(5) };
    self.isBusy = function() { return compiler.inProgress() };
    self.result = function() {
        if (consume) {
            consume = false;
            buffer_delete(compiler.lexer.buff);
        }
        return compiler.ir;
    };
}

/// Handles the exeuction of Catspeak runtime processes.
function CatspeakVMProcess() : CatspeakProcess() constructor {
    self.vm = undefined;
    self.update = function() { vm.runProgram(10) };
    self.isBusy = function() { return vm.inProgress() };
    self.result = function() { return vm.returnValue };
}