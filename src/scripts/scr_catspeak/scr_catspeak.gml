//! The primary user-facing interface for compiling and executing Catspeak
//! programs.

/// Creates a new Catspeak runtime process for this Catspeak function. This
/// function is also compatible with GML functions. Doing so, a dummy process
/// will be created which is immediately executed. You can use
///
/// @param {Function|Struct.CatspeakFunction} scr
///   The GML or Catspeak function to execute.
///
/// @param {Array<Any>} [args]
///   The array of arguments to pass to the function call. Defaults to the
///   empty array.
///
/// @return {Struct.CatspeakVMProcess|Struct.CatspeakDummyProcess}
function catspeak_execute(scr, args) {
    static noArgs = [];
    var args_ = args ?? noArgs;
    var argo = 0;
    var argc = array_length(args);
    var process;
    if (instanceof(scr) == "CatspeakFunction") {
        var vm = new CatspeakVM();
        vm.pushCallFrame(self, scr);
        process = new CatspeakVMProcess();
        process.vm = vm;
    } else {
        process = new CatspeakDummyProcess();
        process.value = __catspeak_vm_function_execute(
                self, scr, argc, argo, args);
    }
    return process;
}

/// Creates a new Catspeak compiler process for buffer containing Catspeak
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
    var process = new CatspeakCompilerProcess();
    process.compiler = compiler;
    process.consume = consume;
    return process;
}

/// Creates a new Catspeak compiler process for a string containing Catspeak
/// code. This will allocate a new buffer to store the string, if that isn't
/// ideal then you will have to create and write to your own buffer, then
/// pass it into the `catspeak_compile_buffer` function instead.
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