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
enum CatspeakCartInst {
    /// Push a numeric constant onto the stack.
    CONST_NUMBER = 0,
    /// Push a boolean constant onto the stack.
    CONST_BOOL = 1,
    /// Push a string constant onto the stack.
    CONST_STRING = 2,
    /// Pop the top value off of the stack, and return it from the current function.
    RETURN = 3,
    /// @ignore
    __SIZE__,
}

/// TODO
function CatspeakCartWriter(buff_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
        "IR requires a grow buffer (buffer_grow)"
    );
    buffer_write(buff_, buffer_u32, 13063246);
    buffer_write(buff_, buffer_string, @'CATSPEAK CART');
    buffer_write(buff_, buffer_u8, 1);
    /// @ignore
    self.refMeta = buffer_tell(buff_);
    buffer_write(buff_, buffer_u32, 0);
    /// @ignore
    self.metaFilepath = "";
    /// @ignore
    self.metaGlobal = [];
    /// @ignore
    self.buff = buff_;

    /// TODO
    static finalise = function () {
        var buff_ = buff;
        buff = undefined;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        buffer_poke(buff_, refMeta, buffer_u32, buffer_tell(buff_) - refMeta);
        buffer_write(buff_, buffer_string, metaFilepath);
        var metaGlobal_ = metaGlobal;
        var metaGlobalN = array_length(metaGlobal_);
        buffer_write(buff_, buffer_u32, metaGlobalN);
        for (var i = metaGlobalN - 1; i >= 0; i -= 1) {
            buffer_write(buff_, buffer_string, metaGlobal_[i]);
        }
    };

    /// Push a numeric constant onto the stack.
    ///
    /// @param {Real} n
    ///     The number to emit.
    ///
    /// @param {Real} [location]
    ///     The approximate location of this instruction in the source code.
    static emitConstNumber = function (n, location) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(n), "expected type of f64");
        location ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(location), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_NUMBER);
        buffer_write(buff_, buffer_f64, n);
        buffer_write(buff_, buffer_u32, location);
    };

    /// Push a boolean constant onto the stack.
    ///
    /// @param {Real} condition
    ///     The bool to emit.
    ///
    /// @param {Real} [location]
    ///     The approximate location of this instruction in the source code.
    static emitConstBool = function (condition, location) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(condition), "expected type of u8");
        location ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(location), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_BOOL);
        buffer_write(buff_, buffer_u8, condition);
        buffer_write(buff_, buffer_u32, location);
    };

    /// Push a string constant onto the stack.
    ///
    /// @param {String} string_
    ///     The string to emit.
    ///
    /// @param {Real} [location]
    ///     The approximate location of this instruction in the source code.
    static emitConstString = function (string_, location) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_string(string_), "expected type of string");
        location ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(location), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_STRING);
        buffer_write(buff_, buffer_string, string_);
        buffer_write(buff_, buffer_u32, location);
    };

    /// Pop the top value off of the stack, and return it from the current function.
    ///
    /// @param {Real} [location]
    ///     The approximate location of this instruction in the source code.
    static emitReturn = function (location) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        location ??= CATSPEAK_NOLOCATION;
        __catspeak_assert(is_numeric(location), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.RETURN);
        buffer_write(buff_, buffer_u32, location);
    };
}

/// TODO
function CatspeakCartReader(buff_, visitor_) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert(is_struct(visitor_), "visitor must be a struct");
    __catspeak_assert(is_method(visitor_[$ "handleConstNumber"]),
        "visitor is missing a handler for 'handleConstNumber'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleConstBool"]),
        "visitor is missing a handler for 'handleConstBool'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleConstString"]),
        "visitor is missing a handler for 'handleConstString'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleReturn"]),
        "visitor is missing a handler for 'handleReturn'"
    );
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
    self.refMeta = buffer_tell(buff_);
    self.refMeta += buffer_read(buff_, buffer_u32);
    /// @ignore
    self.refInstrs = buffer_tell(buff_);
    buffer_seek(buff_, buffer_seek_start, self.refMeta);
    var filepath_ = buffer_read(buff_, buffer_string);
    var global_N = buffer_read(buff_, buffer_u32);
    var global_ = array_create(global_N);
    for (var i = global_N - 1; i >= 0; i -= 1) {
        global_[@ i] = buffer_read(buff_, buffer_string);
    }
    /// @ignore
    self.refEndOfFile = buffer_tell(buff_);
    // rewind back to instructions
    buffer_seek(buff_, buffer_seek_start, self.refInstrs);
    /// @ignore
    self.buff = buff_;
    /// @ignore
    self.visitor = visitor_;
    if (visitor_.handleMeta != undefined) {
        visitor_.handleMeta(filepath_, global_);
    }

    /// TODO
    static readInstr = function () {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        if (buffer_tell(buff_) >= refMeta) {
            // we've reached the end
            buffer_seek(buff_, buffer_seek_start, refEndOfFile);
            return false;
        }
        var instrType = buffer_read(buff_, buffer_u8);
        __catspeak_assert(instrType >= 0 && instrType < CatspeakCartInst.__SIZE__,
            "invalid cartridge instruction"
        );
        var instrReader = __readerLookup[instrType];
        instrReader();
        return true;
    };

    /// @ignore
    static __readConstNumber = function () {
        var buff_ = buff;
        var n = buffer_read(buff_, buffer_f64);
        var location = buffer_read(buff_, buffer_u32);
        var visitor_ = visitor;
        if (visitor_.handleConstNumber != undefined) {
            visitor_.handleConstNumber(n, location);
        }
    };

    /// @ignore
    static __readConstBool = function () {
        var buff_ = buff;
        var condition = buffer_read(buff_, buffer_u8);
        var location = buffer_read(buff_, buffer_u32);
        var visitor_ = visitor;
        if (visitor_.handleConstBool != undefined) {
            visitor_.handleConstBool(condition, location);
        }
    };

    /// @ignore
    static __readConstString = function () {
        var buff_ = buff;
        var string_ = buffer_read(buff_, buffer_string);
        var location = buffer_read(buff_, buffer_u32);
        var visitor_ = visitor;
        if (visitor_.handleConstString != undefined) {
            visitor_.handleConstString(string_, location);
        }
    };

    /// @ignore
    static __readReturn = function () {
        var buff_ = buff;
        var location = buffer_read(buff_, buffer_u32);
        var visitor_ = visitor;
        if (visitor_.handleReturn != undefined) {
            visitor_.handleReturn(location);
        }
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(CatspeakCartInst.__SIZE__);
        __readerLookup[@ CatspeakCartInst.CONST_NUMBER] = __readConstNumber;
        __readerLookup[@ CatspeakCartInst.CONST_BOOL] = __readConstBool;
        __readerLookup[@ CatspeakCartInst.CONST_STRING] = __readConstString;
        __readerLookup[@ CatspeakCartInst.RETURN] = __readReturn;
    }
}