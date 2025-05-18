// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/template/scr_catspeak_cartridge.gml

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
enum CatspeakInstr {
    /// @ignore
    END_OF_PROGRAM = 0,
    /// Push a numeric constant onto the stack.
    GET_N = 1,
    /// Push a boolean constant onto the stack.
    GET_B = 2,
    /// Push a string constant onto the stack.
    GET_S = 3,
    /// Pop the top value off of the stack, and return it from the current function.
    RET = 4,
    /// @ignore
    __SIZE__,
}

/// Handles the creation of Catspeak cartridges.
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

    /// Push a numeric constant onto the stack.
    ///
    /// @param {Real} n
    ///     The number to emit.
    static emitConstNumber = function (n) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(n), "expected type of f64");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_N);
        buffer_write(buff_, buffer_f64, n);
    };

    /// Push a boolean constant onto the stack.
    ///
    /// @param {Real} condition
    ///     The bool to emit.
    static emitConstBool = function (condition) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(condition), "expected type of u8");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_B);
        buffer_write(buff_, buffer_u8, condition);
    };

    /// Push a string constant onto the stack.
    ///
    /// @param {String} string_
    ///     The string to emit.
    static emitConstString = function (string_) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_string(string_), "expected type of string");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_S);
        buffer_write(buff_, buffer_string, string_);
    };

    /// Pop the top value off of the stack, and return it from the current function.
    static emitReturn = function () {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        buffer_write(buff_, buffer_u8, CatspeakInstr.RET);
    };
}

/// Handles the parsing of Catspeak cartridges.
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
    __catspeak_assert(is_method(visitor_[$ "handleFunc"]),
        "visitor is missing a handler for 'handleFunc'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleMeta"]),
        "visitor is missing a handler for 'handleMeta'"
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
        var argN = buffer_read(buff_, buffer_f64);
        visitor.handleInstrConstNumber(argN);
    };

    /// @ignore
    static __readConstBool = function () {
        var buff_ = buff;
        var argCondition = buffer_read(buff_, buffer_u8);
        visitor.handleInstrConstBool(argCondition);
    };

    /// @ignore
    static __readConstString = function () {
        var buff_ = buff;
        var argString_ = buffer_read(buff_, buffer_string);
        visitor.handleInstrConstString(argString_);
    };

    /// @ignore
    static __readReturn = function () {
        visitor.handleInstrReturn();
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ CatspeakInstr.GET_N] = __readConstNumber;
        __readerLookup[@ CatspeakInstr.GET_B] = __readConstBool;
        __readerLookup[@ CatspeakInstr.GET_S] = __readConstString;
        __readerLookup[@ CatspeakInstr.RET] = __readReturn;
    }
}