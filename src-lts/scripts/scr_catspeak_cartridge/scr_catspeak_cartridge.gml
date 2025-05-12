// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/spec/build-ir.py

//# feather use syntax-errors

//! Responsible for the reading and writing of Catspeak HIR (Hierarchial
//! Intermediate Representation). HIR is a binary format that can be saved
//! and loaded from a file, or treated like a "ROM" or "cartridge".

/// The type of Catspeak HIR instruction.
enum CatspeakHIRInst {
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
function CatspeakHIRWriter() constructor {
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
            "HIR requires a grow buffer (buffer_grow)"
        );
        var buffOffset = buffer_tell(buff_);
        var headNum = 13063246;
        var headTitle = @'Catspeak Cartridge v1';
        var loadBuff = false;
        try {
            loadBuff = (
                buffer_read(buff_, buffer_u32) == headNum &&
                buffer_read(buff_, buffer_string) == headTitle
            );
        } catch (ex) {
            __catspeak_error_silent("failed to read buffer header:\n", ex.message);
        }
        if (loadBuff) {
            // patch existing HIR file
            refCountOffset = buffer_tell(buff_);
            __catspeak_error_unimplemented("patching HIR");
        } else {
            // new HIR file
            buffer_seek(buff_, buffer_seek_start, buffOffset);
            buffer_write(buff_, buffer_u32, headNum);
            buffer_write(buff_, buffer_string, headTitle);
            // pointer to number of local vars
            refCountOffset = buffer_tell(buff_);
            buffer_write(buff_, buffer_u32, 0);
        }
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
        __catspeak_assert(is_numeric(v), "expected type of number");
        buffer_write(buff, buffer_u8, CatspeakHIRInst.CONST_NUMBER);
        buffer_write(buff, buffer_f64, v);
    };
    
    /// Emit an instruction to push a boolean constant onto the stack.
    static emitConstBool = function (v) {
        __catspeak_assert(is_numeric(v), "expected type of bool");
        buffer_write(buff, buffer_u8, CatspeakHIRInst.CONST_BOOL);
        buffer_write(buff, buffer_u8, v);
    };
    
    /// Emit an instruction to push a string constant onto the stack.
    static emitConstString = function (v) {
        __catspeak_assert(is_string(v), "expected type of string");
        buffer_write(buff, buffer_u8, CatspeakHIRInst.CONST_STRING);
        buffer_write(buff, buffer_string, v);
    };
    
    /// Emit an instruction to pop the top value off of the stack, and return it from the current function.
    static emitReturn = function () {
        buffer_write(buff, buffer_u8, CatspeakHIRInst.RETURN);
    };
}

/// TODO
function CatspeakHIRReader() constructor {
    /// @ignore
    self.buff = undefined;
    
    /// TODO
    self.__handleHeader__ = undefined;
    
    /// TODO
    static setTarget = function (buff_) {
        buff = undefined;
        __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
        var headNum = 13063246;
        var headTitle = @'Catspeak Cartridge v1';
        if (
            buffer_read(buff_, buffer_u32) == headNum &&
            buffer_read(buff_, buffer_string) == headTitle
        ) {
            // successfully loaded HIR
            var refCount = buffer_read(buff_, buffer_u32);
            var handler = __handleHeader__;
            if (handler != undefined) {
                handler(refCount);
            }
        } else {
            __catspeak_error("failed to read Catspeak cartridge, it may be corrupted");
        }
        buff = buff_;
    }
    
    /// TODO
    static readChunk = function () {
        var instType = buffer_read(buff, buffer_u8);
        __catspeak_assert(instType >= 0 && instType < CatspeakHIRInst.__SIZE__,
            "invalid cartridge instruction"
        );
        var instReader = __readerLookup[instType];
        instReader();
    };
    
    /// TODO
    self.__handleConstNumber__ = undefined;
    
    /// @ignore
    static __readConstNumber = function () {
        var v = buffer_read(buff, buffer_f64);
        var handler = __handleConstNumber__;
        if (handler != undefined) {
            handler(v);
        }
    };
    
    /// TODO
    self.__handleConstBool__ = undefined;
    
    /// @ignore
    static __readConstBool = function () {
        var v = buffer_read(buff, buffer_u8);
        var handler = __handleConstBool__;
        if (handler != undefined) {
            handler(v);
        }
    };
    
    /// TODO
    self.__handleConstString__ = undefined;
    
    /// @ignore
    static __readConstString = function () {
        var v = buffer_read(buff, buffer_string);
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
    static __readerLookup = (function () {
        var lookupDB = array_create(CatspeakHIRInst.__SIZE__);
        lookupDB[@ CatspeakHIRInst.CONST_NUMBER] = __readConstNumber;
        lookupDB[@ CatspeakHIRInst.CONST_BOOL] = __readConstBool;
        lookupDB[@ CatspeakHIRInst.CONST_STRING] = __readConstString;
        lookupDB[@ CatspeakHIRInst.RETURN] = __readReturn;
        return lookupDB;
    })();
}

/// TODO
function __CatspeakDisassembler() : CatspeakHIRReader() constructor {
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
