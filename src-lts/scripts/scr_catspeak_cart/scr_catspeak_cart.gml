// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/template/scr_catspeak_cart.gml

//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved
//! and loaded from a file, or treated like a "ROM" or "cartridge".

//# feather use syntax-errors


/// The type of Catspeak IR instruction.
/// 
/// Catspeak stores cartridge code in reverse-polish notation, where each
/// instruction may push (or pop) intermediate values onto a virtual stack.
/// 
/// Depending on the export, this may literally be a stack--such as with a
/// so-called "stack machine" VM. Other times the "stack" may be an abstraction,
/// such as with the GML export, where Catspeak cartridges are transformed into
/// recursive GML function calls. (This ends up being faster for reasons I won't
/// detail here.)
/// 
/// Each instruction may also be associated with zero or many static parameters.
///
/// @experimental
enum CatspeakInstr {
    /// @ignore
    END_OF_PROGRAM = 0,
    /// Get a numeric constant.
    GET_N = 1,
    /// Get a boolean constant.
    GET_B = 2,
    /// Get a string constant.
    GET_S = 3,
    /// Return a value from the current function.
    RET = 4,
    /// Calculate the sum of two values.
    ADD = 4,
    /// @ignore
    __SIZE__,
}

/// Handles the creation of Catspeak cartridges.
///
/// @experimental
///
/// @param {Id.Buffer} buff_
///   The buffer to write the cartridge to. Must be a `buffer_grow` type buffer
///   with an alignment of 1.
function CatspeakCartWriter(buff_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
        "Catspeak cartridges require a grow buffer (buffer_grow)"
    );
    cartStart = buffer_tell(buff_);
    hSignal = buffer_tell(buff_);
    // (signal will be patched to 13063246 when finalised)
    buffer_write(buff_, buffer_u32, 5994585); // signal header
    buffer_write(buff_, buffer_string, @'CATSPEAK CART'); // title header
    buffer_write(buff_, buffer_u8, 1); // version header
    /// @ignore
    chunkInstr = buffer_tell(buff_);
    buffer_write(buff_, buffer_u32, 0);
    /// @ignore
    chunkData = buffer_tell(buff_);
    buffer_write(buff_, buffer_u32, 0);
    /// @ignore
    chunkEnd = buffer_tell(buff_);
    buffer_write(buff_, buffer_u32, 0);
    buffer_poke(buff_, chunkInstr, buffer_u32, buffer_tell(buff_) - cartStart); // patch instr
    /// @ignore
    fvLocals = 0;
    /// @ignore
    fvStack = array_create(8);
    /// @ignore
    fvTop = 0;
    /// @ignore
    fvFuncs = [];
    /// @ignore
    fvFuncsCount = 1;
    /// The path to the file containing source code for this Cartridge.
    ///
    /// @returns {String}
    path = "";
    /// The author of this Cartridge.
    ///
    /// @returns {String}
    author = "";
    /// @ignore
    buff = buff_;

    /// Finalises the creation of this Catspeak cartridge. Assumes the program
    /// section is well-formed, then writes the data section before patching
    /// any necessary references and in the header.
    static finalise = function () {
        var buff_ = buff;
        buff = undefined;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        var fvTop_ = fvTop;
        __catspeak_assert(fvTop_ < 0.5,
            "'.beginFunction' called with no associated '.endFunction' call"
        );
        buffer_write(buff_, buffer_u8, CatspeakInstr.END_OF_PROGRAM);
        buffer_poke(buff_, chunkData, buffer_u32, buffer_tell(buff_) - cartStart); // patch data
        // write func data
        buffer_write(buff_, buffer_u32, fvFuncsCount);
        buffer_write(buff_, buffer_u32, fvLocals);
        var fvI = 0;
        var fvFuncs_ = fvFuncs;
        while (fvI < fvTop_) {
            buffer_write(buff_, buffer_u32, fvFuncs_[fvI]);
            fvI += 1;
        }
        // write meta data
        buffer_write(buff_, buffer_string, path);
        buffer_write(buff_, buffer_string, author);
        buffer_poke(buff_, chunkEnd, buffer_u32, buffer_tell(buff_) - cartStart); // patch end
        buffer_poke(buff_, hSignal, buffer_u32, 13063246); // patch signal header
    };

    /// Begins a new Catspeak function scope.
    static beginFunction = function () {
        __catspeak_assert(buff != undefined && buffer_exists(buff), "no cartridge loaded");
        var fvTop_ = fvTop;
        var fvStack_ = fvStack;
        fvStack_[@ fvTop_] = fvLocals;
        fvTop_ += 1;
        fvTop = fvTop_;
    };

    /// Ends the current Catspeak function scope, returning its id.
    ///
    /// @returns {Real}
    static endFunction = function () {
        __catspeak_assert(buff != undefined && buffer_exists(buff), "no cartridge loaded");
        var fvTop_ = fvTop;
        __catspeak_assert(fvTop_ > 0.5, "function stack underflow");
        var fvFuncs_ = fvFuncs;
        var fvStack_ = fvStack;
        array_push(fvFuncs_, fvLocals);
        fvLocals = fvStack_[fvTop_];
        fvTop_ -= 1;
        fvTop = fvTop_;
        var functionIdx = fvFuncsCount;
        fvFuncsCount += 1;
        return functionIdx;
    };

    /// Allocate space for a new local variable, returning its id.
    ///
    /// @returns {Real}
    static allocLocal = function () {
        __catspeak_assert(buff != undefined && buffer_exists(buff), "no cartridge loaded");
        var localIdx = fvLocals;
        fvLocals += 1;
        return localIdx;
    };

    /// Get a numeric constant.
    ///
    /// @param {Real} value
    ///     The number to emit.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitConstNumber = function (value, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(value), "expected type of f64");
        dbg ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_N);
        buffer_write(buff_, buffer_f64, value);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Get a boolean constant.
    ///
    /// @param {Real} value
    ///     The bool to emit.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the bool in the source code.
    static emitConstBool = function (value, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(value), "expected type of u8");
        dbg ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_B);
        buffer_write(buff_, buffer_u8, value);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Get a string constant.
    ///
    /// @param {String} value
    ///     The string to emit.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the string in the source code.
    static emitConstString = function (value, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_string(value), "expected type of string");
        dbg ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_S);
        buffer_write(buff_, buffer_string, value);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Return a value from the current function.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the `return` keyword in the source code.
    static emitReturn = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        dbg ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.RET);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the sum of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the expression in the source code.
    static emitAdd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        dbg ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.ADD);
        buffer_write(buff_, buffer_u32, dbg);
    };
}

/// Handles the parsing of Catspeak cartridges.
///
/// @experimental
///
/// @remark
///   Immediately reads and calls the handlers for the "data" section of the
///   Catspeak cartridge.
///
/// @param {Id.Buffer} buff_
///   The buffer to read cartridge info from.
///
/// @param {Struct} visitor_
///   A struct containing methods for handling each of the following cases:
///
///   - TODO
function CatspeakCartReader(buff_, visitor_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert(is_struct(visitor_), "visitor must be a struct");
    __catspeak_assert(is_method(visitor_[$ "handleInstrConstNumber"]),
        "visitor is missing a handler for 'handleInstrConstNumber'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrConstBool"]),
        "visitor is missing a handler for 'handleInstrConstBool'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrConstString"]),
        "visitor is missing a handler for 'handleInstrConstString'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrReturn"]),
        "visitor is missing a handler for 'handleInstrReturn'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrAdd"]),
        "visitor is missing a handler for 'handleInstrAdd'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleFunc"]),
        "visitor is missing a handler for 'handleFunc'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleMeta"]),
        "visitor is missing a handler for 'handleMeta'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInit"]),
        "visitor is missing a handler for 'handleInit'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleDeinit"]),
        "visitor is missing a handler for 'handleDeinit'"
    );
    cartStart = buffer_tell(buff_);
    var failedMessage = undefined;
    try {
        if (buffer_read(buff_, buffer_u32) != 13063246) {
            failedMessage = "failed to read Catspeak cartridge: '13063246' (u32) missing from header";
        }
        if (buffer_read(buff_, buffer_string) != @'CATSPEAK CART') {
            failedMessage = "failed to read Catspeak cartridge: 'CATSPEAK CART' (string) missing from header";
        }
        if (buffer_read(buff_, buffer_u8) != 1) {
            failedMessage = "failed to read Catspeak cartridge: '1' (u8) missing from header";
        }
    } catch (ex_) {
        __catspeak_error("error occurred when trying to read Catspeak cartridge: ", ex_.message);
    }
    if (failedMessage != undefined) {
        __catspeak_error(failedMessage);
    }
    visitor_.handleInit();
    /// @ignore
    chunkInstr = buffer_read(buff_, buffer_u32);
    /// @ignore
    chunkData = buffer_read(buff_, buffer_u32);
    /// @ignore
    chunkEnd = buffer_read(buff_, buffer_u32);
    buffer_seek(buff_, buffer_seek_start, cartStart + chunkData); // seek data
    // read func data
    var fvFuncCount = buffer_read(buff_, buffer_u32);
    var fvLocals = buffer_read(buff_, buffer_u32);
    visitor_.handleFunc(0, fvLocals);
    for (var i = 1; i < fvFuncCount; i += 1) {
        fvLocals = buffer_read(buff_, buffer_u32);
        visitor_.handleFunc(fvI, fvLocals);
    }
    // read meta data
    var metaPath = buffer_read(buff_, buffer_string);
    var metaAuthor = buffer_read(buff_, buffer_string);
    visitor_.handleMeta(metaPath, metaAuthor);
    buffer_seek(buff_, buffer_seek_start, cartStart + chunkInstr); // seek instr
    /// @ignore
    buff = buff_;
    /// @ignore
    visitor = visitor_;

    /// Reads the next instruction if it exists, calling its handler.
    ///
    /// If there are more instructions left to be read, then this function will
    /// return `true`. If all functions have been read, then `false` is
    /// returned, and the buffers seek is set to the end of the Cartidge.
    ///
    /// @return {Bool}
    static readInstr = function () {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        var instrType = buffer_read(buff_, buffer_u8);
        if (instrType == CatspeakInstr.END_OF_PROGRAM) {
            // we've reached the end
            buff = undefined;
            buffer_seek(buff_, buffer_seek_start, cartStart + chunkEnd); // seek end
            visitor.handleDeinit();
            return false;
        }
        __catspeak_assert(instrType >= 0 && instrType < CatspeakInstr.__SIZE__,
            "invalid cartridge instruction"
        );
        var instrReader = __readerLookup[instrType];
        instrReader();
        return true;
    };

    /// @ignore
    static __readConstNumber = function () {
        var buff_ = buff;
        var argValue = buffer_read(buff_, buffer_f64);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrConstNumber(argValue, argDbg);
    };

    /// @ignore
    static __readConstBool = function () {
        var buff_ = buff;
        var argValue = buffer_read(buff_, buffer_u8);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrConstBool(argValue, argDbg);
    };

    /// @ignore
    static __readConstString = function () {
        var buff_ = buff;
        var argValue = buffer_read(buff_, buffer_string);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrConstString(argValue, argDbg);
    };

    /// @ignore
    static __readReturn = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrReturn(argDbg);
    };

    /// @ignore
    static __readAdd = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrAdd(argDbg);
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ CatspeakInstr.GET_N] = __readConstNumber;
        __readerLookup[@ CatspeakInstr.GET_B] = __readConstBool;
        __readerLookup[@ CatspeakInstr.GET_S] = __readConstString;
        __readerLookup[@ CatspeakInstr.RET] = __readReturn;
        __readerLookup[@ CatspeakInstr.ADD] = __readAdd;
    }
}