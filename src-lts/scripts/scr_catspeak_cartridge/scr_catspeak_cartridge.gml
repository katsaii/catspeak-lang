// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/catspeak-ir.yaml
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
function CatspeakCartWriter() constructor {
    /// @ignore
    self.buff = undefined;

    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
        __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
            "IR requires a grow buffer (buffer_grow)"
        );
        buffer_write(buff_, buffer_u32, 13063246);
        buffer_write(buff_, buffer_string, @'CATSPEAK CART');
        buffer_write(buff_, buffer_u8, 1);
        refMeta = buffer_tell(buff_);
        buffer_write(buff_, buffer_u32, 0);
        metaFilepath = "";
        metaReg = 0;
        metaGlobal = [];
        buff = buff_;
    };

    /// TODO
    static finaliseTarget = function () {
        var buff_ = buff;
        buff = undefined;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        buffer_poke(buff_, refMeta, buffer_u32, buffer_tell(buff_) - refMeta);
        buffer_write(buff_, buffer_string, metaFilepath);
        buffer_write(buff_, buffer_u32, metaReg);
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
    static emitConstNumber = function (n) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(n), "expected type of f64");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_NUMBER);
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
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_BOOL);
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
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_STRING);
        buffer_write(buff_, buffer_string, string_);
    };

    /// Pop the top value off of the stack, and return it from the current function.
    static emitReturn = function () {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.RETURN);
    };
}

/// TODO
function CatspeakCartReader() constructor {
    /// @ignore
    self.buff = undefined;

    /// TODO
    self.__handleMeta__ = undefined;

    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
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
        refMeta = buffer_tell(buff_);
        refMeta += buffer_read(buff_, buffer_u32);
        refInstrs = buffer_tell(buff_);
        buffer_seek(buff_, buffer_seek_start, refMeta);
        var filepath_ = buffer_read(buff_, buffer_string);
        var reg_ = buffer_read(buff_, buffer_u32);
        var global_N = buffer_read(buff_, buffer_u32);
        var global_ = array_create(global_N);
        for (var i = global_N - 1; i >= 0; i -= 1) {
            global_[@ i] = buffer_read(buff_, buffer_string);
        }
        refEndOfFile = buffer_tell(buff_);
        // rewind back to instructions
        buffer_seek(buff_, buffer_seek_start, refInstrs);
        buff = buff_;
        var handler = __handleMeta__;
        if (handler != undefined) {
            handler(filepath_, reg_, global_);
        }
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

    /// TODO
    self.__handleConstNumber__ = undefined;

    /// @ignore
    static __readConstNumber = function () {
        var buff_ = buff;
        var n = buffer_read(buff_, buffer_f64);
        var handler = __handleConstNumber__;
        if (handler != undefined) {
            handler(n);
        }
    };

    /// TODO
    self.__handleConstBool__ = undefined;

    /// @ignore
    static __readConstBool = function () {
        var buff_ = buff;
        var condition = buffer_read(buff_, buffer_u8);
        var handler = __handleConstBool__;
        if (handler != undefined) {
            handler(condition);
        }
    };

    /// TODO
    self.__handleConstString__ = undefined;

    /// @ignore
    static __readConstString = function () {
        var buff_ = buff;
        var string_ = buffer_read(buff_, buffer_string);
        var handler = __handleConstString__;
        if (handler != undefined) {
            handler(string_);
        }
    };

    /// TODO
    self.__handleReturn__ = undefined;

    /// @ignore
    static __readReturn = function () {
        var handler = __handleReturn__;
        if (handler != undefined) {
            handler();
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