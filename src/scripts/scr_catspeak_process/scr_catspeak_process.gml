//! The primary user-facing interface for compiling and executing Catspeak
//! programs.

//# feather use syntax-errors

/// Creates a new Catspeak runtime process for this Catspeak function. This
/// function is also compatible with GML functions.
///
/// @param {Function|Struct.CatspeakFunction} scr
///   The GML or Catspeak function to execute.
///
/// @param {Array<Any>} [args]
///   The array of arguments to pass to the function call. Defaults to the
///   empty array.
///
/// @return {Struct.CatspeakProcess}
function catspeak_execute(scr, args) {
    static noArgs = [];
    var args_ = args ?? noArgs;
    var argo = 0;
    var argc = array_length(args);
    var future;
    if (instanceof(scr) == "CatspeakFunction") {
        var vm = new CatspeakVM();
        vm.pushCallFrame(self, scr, args, argo, argc);
        future = new CatspeakProcess(method(vm, function(accept) {
            if (inProgress()) {
                runProgram(10);
            } else {
                accept(returnValue);
            }
        }));
    } else {
        var result;
        with (method_get_self(scr) ?? self) {
            result = script_execute_ext(method_get_index(scr),
                    args_, argo, argc);
        }
        future = new Future();
        future.accept(result);
    }
    return future;
}

/// Creates a new Catspeak compiler process for a buffer containing Catspeak
/// code.
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
    var lexer = new CatspeakLexer(buff, size);
    var compiler = new CatspeakCompiler(lexer);
    var future = new CatspeakProcess(method(compiler, function(accept) {
        if (inProgress()) {
            emitProgram(5);
        } else {
            accept(ir);
        }
    }));
    if (consume) {
        var deleteBuff = method(compiler, function() {
            buffer_delete(lexer.buff);
        });
        future.andThen(deleteBuff);
        future.andCatch(deleteBuff);
    }
    return future;
}

/// Creates a new Catspeak compiler process for a string containing Catspeak
/// code. This will allocate a new buffer to store the string, if that isn't
/// ideal then you will have to create and write to your own buffer, then
/// pass it into the [catspeak_compile_buffer] function instead.
///
/// @param {Any} src
///   The value containing the source code to compile.
///
/// @return {Struct.CatspeakProcess}
function catspeak_compile_string(src) {
    var src_ = is_string(src) ? src : string(src);
    var buff = catspeak_create_buffer_from_string(src_);
    return catspeak_compile_buffer(buff, true);
}

/// A helper function for creating a buffer from a string.
///
/// @param {String} src
///   The source code to convert into a buffer.
///
/// @return {Id.Buffer}
function catspeak_create_buffer_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

/// Constructs a new asynchronous Catspeak process. Instances of this struct
/// will be managed globally by the Catspeak execution engine. Execution time
/// is divided between all active processes so each gets a chance to progress.
///
/// @param {Function} resolver
///   A function which performs the necessary operations to progress the state
///   of this future. It accepts a single function as a parameter. Call this
///   function with the result of the future to complete the computation.
function CatspeakProcess(resolver) : Future() constructor {
    self.resolver = resolver;
    self.timeSpent = 0;
    self.timeLimit = undefined;
    self.acceptFunc = function(result_) { accept(result_) };

    // invoke the process
    var manager = global.__catspeakProcessManager;
    self.timeLimit ??= global.__catspeakConfig.processTimeLimit;
    ds_list_add(manager.processes, self);
    if (manager.inactive) {
        manager.inactive = false;
        time_source_start(manager.timeSource);
    }

    /// @ignore
    static __update = function() {
        //try {
            resolver(acceptFunc);
        //} catch (ex) {
        //    reject(ex);
        //}
    };
}

/// @ignore
function __catspeak_init_process() {
    var info = {
        processes : ds_list_create(),
        dtRatioPrev : 1,
        inactive : true,
        update : function() {
            var frameAllocation = global.__catspeakConfig.frameAllocation;
            var oneSecond = frameAllocation * 1000000;
            var idealTime = game_get_speed(gamespeed_microseconds);
            var dtRatio = delta_time / idealTime;
            var dtRatioAvg = mean(dtRatioPrev, dtRatio);
            dtRatioPrev = dtRatio;
            var duration = frameAllocation * idealTime / dtRatioAvg;
            var timeLimit = get_timer() + min(idealTime, duration);
            var processes_ = processes;
            var processIdx = 0;
            var processCount = ds_list_size(processes_);
            do {
                var tStart = get_timer();
                if (processCount < 1) {
                    // don't waste time waiting for new processes to exist
                    time_source_stop(timeSource);
                    inactive = true;
                    break;
                }
                var process = processes_[| processIdx];
                if (!process.resolved()) {
                    process.__update();
                }
                if (process.resolved()) {
                    ds_list_delete(processes_, processIdx);
                } else {
                    var tSpent = process.timeSpent;
                    process.timeSpent = tSpent + (get_timer() - tStart);
                    if (tSpent > process.timeLimit * oneSecond) {
                        var err = new CatspeakError(undefined,
                                "exceeded process time limit");
                        process.reject(err);
                    }
                }
                processCount = ds_list_size(processes_);
                processIdx -= 1;
                if (processIdx < 0) {
                    processIdx = processCount - 1;
                }
            } until (get_timer() > timeLimit);
        },
    };
    info.timeSource = time_source_create(
                time_source_global, 1, time_source_units_frames,
                info.update, [], -1);
    // only compute Catspeak programs for half of a frame
    global.__catspeakConfig.frameAllocation = 0.5;
    global.__catspeakConfig.processTimeLimit = 1000;
    /// @ignore
    global.__catspeakProcessManager = info;
}