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
/// @return {Struct.CatspeakVMProcess|Struct.CatspeakGMLProcess}
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
        future = new CatspeakFuture();
        future.accept(result);
    }
    return future;
}

/// Creates a new Catspeak compiler process for a buffer containing Catspeak
/// code. The seek position of the buffer will not be set to the beginning of
/// the buffer, this is something you have to manage yourself:
/// ```
/// buffer_seek(buff, buffer_seek_start, 0); // reset seek
/// catspeak_compile_buffer(buff);           // then compile
/// ```
///
/// @param {ID.Buffer} buff
///   A reference to the buffer containing the source code to compile.
///
/// @param {Bool} [consume]
///   Whether the buffer should be deleted after the compiler process is
///   complete. Defaults to `false`.
///
/// @return {Struct.CatspeakCompilerProcess}
function catspeak_compile_buffer(buff, consume=false) {
    var lexer = new CatspeakLexer(buff);
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
/// @return {Struct.CatspeakCompilerProcess}
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

/// Configures various global settings of the Catspeak compiler and runtime.
/// Below is a list of configuration values available to be customised:
///
///  - "frameAllocation" should be a number in the range [0, 1]. Determines
///    what percentage of a game frame should be reserved for processing
///    Catspeak programs. Catspeak will only spend this time when necessary,
///    and will not sit idly wasting time. A value of 1 will cause Catspeak
///    to spend the whole frame processing, and a value of 0 will cause
///    Catspeak to only process a single instruction per frame. The default
///    setting is 0.5 (50% of a frame). This leaves enough time for the other
///    components of your game to complete, whilst also letting Catspeak be
///    speedy.
///
///  - "exceptionHandler" should be a script or method ID. This will set the
///    catch-all exception handler when no handler exists for a specific
///    process. Set to `undefined` to remove the handler.
///
///  - "processTimeLimit" should be a number greater than 0. Determines how
///    long (in seconds) a process can run for before it is assumed
///    unresponsive and terminated. The default value is 1 second. Setting
///    this to `infinity` is technically possible, but will not be officially
///    supported.
///
/// @param {Struct} configData
///   A struct which can contain any one of the fields mentioned above. Only
///   the fields which are passed will have their configuration changed, so
///   if you don't want a value to change, leave it blank.
function catspeak_config(configData) {
    catspeak_force_init();
    var processManager = global.__catspeakProcessManager;
    var frameAllocation = configData[$ "frameAllocation"];
    if (is_real(frameAllocation)) {
        processManager.frameAllocation = clamp(frameAllocation, 0, 1);
    }
    if (variable_struct_exists(configData, "exceptionHandler")) {
        var handler = configData[$ "exceptionHandler"];
        processManager.exceptionHandler = handler;
    }
    var processTimeLimit = configData[$ "processTimeLimit"];
    if (is_real(processTimeLimit)) {
        processManager.processTimeLimit = processTimeLimit;
    }
}

/// Permanently adds a new Catspeak function to the default standard library.
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
function catspeak_prelude_add_function() {
    catspeak_force_init();
    var db = global.__catspeakDatabasePrelude;
    for (var i = 0; i < argument_count; i += 2) {
        var f = argument[i + 1];
        if (!is_method(f)) {
            f = method(undefined, f);
        }
        db[$ argument[i + 0]] = f;
    }
}

/// Permanently adds a new Catspeak constant to the default standard library.
/// If you want to add a function, use the [catspeak_prelude_add_function]
/// function instead because it makes sure your value will be callable from
/// within Catspeak.
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
function catspeak_prelude_add_constant() {
    catspeak_force_init();
    var db = global.__catspeakDatabasePrelude;
    for (var i = 0; i < argument_count; i += 2) {
        db[$ argument[i + 0]] = argument[i + 1];
    }
}