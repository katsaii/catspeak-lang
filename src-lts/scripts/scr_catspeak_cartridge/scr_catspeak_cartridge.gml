// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir.py

//# feather use syntax-errors

//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved
//! and loaded from a file, or treated like a "ROM" or "cartridge".

/// The type of Catspeak IR instruction.
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
    /// @ignore
    self.refCountOffset = undefined;

    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        refCountOffset = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
        __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_),
            "IR requires a grow buffer (buffer_grow)"
        );
        buffer_write(buff_, buffer_u32, 13063246);
        buffer_write(buff_, buffer_string, @'CATSPEAK CART');
        buffer_write(buff_, buffer_u8, 1);
        // pointer to number of local vars
        refCountOffset = buffer_tell(buff_);
        buffer_write(buff_, buffer_u32, 0);
        buff = buff_;
    }

    /// TODO
    static allocRef = function () {
        var refIdx = buffer_peek(buff, refCountOffset, buffer_u32);
        buffer_poke(buff, refCountOffset, buffer_u32, refIdx + 1);
        return refIdx;
    };

    /// Emit an instruction to push a numeric constant onto the stack.
    static emitConstNumber = function (v) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_),
            "no cartridge loaded"
        );
        __catspeak_assert(is_numeric(v), "expected type of f64");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_NUMBER);
        buffer_write(buff_, buffer_f64, v);
    };

    /// Emit an instruction to push a boolean constant onto the stack.
    static emitConstBool = function (v) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_),
            "no cartridge loaded"
        );
        __catspeak_assert(is_numeric(v), "expected type of u8");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_BOOL);
        buffer_write(buff_, buffer_u8, v);
    };

    /// Emit an instruction to push a string constant onto the stack.
    static emitConstString = function (v) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_),
            "no cartridge loaded"
        );
        __catspeak_assert(is_string(v), "expected type of string");
        buffer_write(buff_, buffer_u8, CatspeakCartInst.CONST_STRING);
        buffer_write(buff_, buffer_string, v);
    };

    /// Emit an instruction to pop the top value off of the stack, and return it from the current function.
    static emitReturn = function () {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_),
            "no cartridge loaded"
        );
        buffer_write(buff_, buffer_u8, CatspeakCartInst.RETURN);
    };
}

/// TODO
function CatspeakCartReader() constructor {
    /// @ignore
    self.buff = undefined;

    /// TODO
    self.__handleHeader__ = undefined;

    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
        var startOffset = buffer_tell(buff_);
        var hMagicNumber;
        hMagicNumber = buffer_read(buff_, buffer_u32);
        var hCartridgeTitle;
        hCartridgeTitle = buffer_read(buff_, buffer_string);
        var hCartridgeVersion;
        hCartridgeVersion = buffer_read(buff_, buffer_u8);
        if (
            hMagicNumber == 13063246 &&
            hCartridgeTitle == @'CATSPEAK CART' &&
            hCartridgeVersion == 1
        ) {
            // successfully loaded IR
            var refCount = buffer_read(buff_, buffer_u32);
            var handler = __handleHeader__;
            if (handler != undefined) {
                handler(refCount);
            }
        } else {
            buffer_seek(buff_, buffer_seek_start, startOffset);
            __catspeak_error("failed to read Catspeak cartridge, it may be corrupted");
        }
        buff = buff_;
    }

    /// TODO
    static readChunk = function () {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_),
            "no cartridge loaded"
        );
        var instType;
        instType = buffer_read(buff_, buffer_u8);
        __catspeak_assert(instType >= 0 && instType < CatspeakCartInst.__SIZE__,
            "invalid cartridge instruction"
        );
        var instReader = __readerLookup[instType];
        instReader();
    };

    /// TODO
    self.__handleConstNumber__ = undefined;

    /// @ignore
    static __readConstNumber = function () {
        var buff_ = buff;
        var v;
        v = buffer_read(buff_, buffer_f64);
        var handler = __handleConstNumber__;
        if (handler != undefined) {
            handler(v);
        }
    };

    /// TODO
    self.__handleConstBool__ = undefined;

    /// @ignore
    static __readConstBool = function () {
        var buff_ = buff;
        var v;
        v = buffer_read(buff_, buffer_u8);
        var handler = __handleConstBool__;
        if (handler != undefined) {
            handler(v);
        }
    };

    /// TODO
    self.__handleConstString__ = undefined;

    /// @ignore
    static __readConstString = function () {
        var buff_ = buff;
        var v;
        v = buffer_read(buff_, buffer_string);
        var handler = __handleConstString__;
        if (handler != undefined) {
            handler(v);
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

/// TODO
function __CatspeakDisassembler() : CatspeakCartReader() constructor {
    self.str = undefined;
    self.__handleHeader__ = function (refCount) {
        str = "[main, refs=" + string(refCount) + "]\nfun ():";
    };
    self.__handleConstNumber__ = function (v) {
        str += "\n  CONST_NUMBER";
        str += "  " + string(v);
    };
    self.__handleConstBool__ = function (v) {
        str += "\n  CONST_BOOL";
        str += "  " + string(v);
    };
    self.__handleConstString__ = function (v) {
        str += "\n  CONST_STRING";
        str += "  " + string(v);
    };
    self.__handleReturn__ = function () {
        str += "\n  RETURN";
    };
}
