// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/scr_catspeak_cart.gml

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
    /// Evaluates one of two expressions, depending on whether a condition is true or false.
    IFTE = 28,
    /// Return a value from the current function.
    RET = 4,
    /// Calculate the remainder of two values.
    REM = 6,
    /// Calculate the product of two values.
    MULT = 7,
    /// Calculate the division of two values.
    DIV = 8,
    /// Calculate the integer division of two values.
    IDIV = 9,
    /// Calculate the difference of two values.
    SUB = 10,
    /// Calculate the sum of two values.
    ADD = 5,
    /// Check whether two values are equal.
    EQ = 11,
    /// Check whether two values are NOT equal.
    NEQ = 12,
    /// Check whether a value is greater than another.
    GT = 13,
    /// Check whether a value is greater than or equal to another.
    GEQ = 14,
    /// Check whether a value is less than another.
    LT = 15,
    /// Check whether a value is less than or equal to another.
    LEQ = 16,
    /// Calculate the logical negation of a value.
    NOT = 17,
    /// Calculate the logical AND of two values.
    AND = 18,
    /// Calculate the logical OR of two values.
    OR = 19,
    /// Calculate the logical XOR of two values.
    XOR = 20,
    /// Calculate the bitwise negation of a value.
    BNOT = 21,
    /// Calculate the bitwise AND of two values.
    BAND = 22,
    /// Calculate the bitwise OR of two values.
    BOR = 23,
    /// Calculate the bitwise XOR of two values.
    BXOR = 24,
    /// Calculate the bitwise right shift of two values.
    RSHIFT = 25,
    /// Calculate the bitwise left shift of two values.
    LSHIFT = 26,
    /// @ignore
    __SIZE__ = 29,
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
    ///     The approximate location of the number in the source code.
    static emitConstBool = function (value, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(value), "expected type of u8");
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
    ///     The approximate location of the number in the source code.
    static emitConstString = function (value, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_string(value), "expected type of string");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GET_S);
        buffer_write(buff_, buffer_string, value);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Evaluates one of two expressions, depending on whether a condition is true or false.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitIfThenElse = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.IFTE);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Return a value from the current function.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitReturn = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.RET);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the remainder of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitRemainder = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.REM);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the product of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitMultiply = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.MULT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the division of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitDivide = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.DIV);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the integer division of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitDivideInt = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.IDIV);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the difference of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitSubtract = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.SUB);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the sum of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitAdd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.ADD);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether two values are equal.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitEqual = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.EQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether two values are NOT equal.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitNotEqual = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.NEQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is greater than another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGreaterThan = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is greater than or equal to another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGreaterThanOrEqualTo = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.GEQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is less than another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitLessThan = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.LT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is less than or equal to another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitLessThanOrEqualTo = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.LEQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical negation of a value.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitNot = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.NOT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical AND of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitAnd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.AND);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical OR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitOr = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.OR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical XOR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitXor = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.XOR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise negation of a value.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseNot = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.BNOT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise AND of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseAnd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.BAND);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise OR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseOr = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.BOR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise XOR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseXor = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.BXOR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise right shift of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseShiftRight = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.RSHIFT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise left shift of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseShiftLeft = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert(buff_ != undefined && buffer_exists(buff_), "no cartridge loaded");
        __catspeak_assert(is_numeric(dbg), "expected type of u32");
        buffer_write(buff_, buffer_u8, CatspeakInstr.LSHIFT);
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
    __catspeak_assert(is_method(visitor_[$ "handleInstrIfThenElse"]),
        "visitor is missing a handler for 'handleInstrIfThenElse'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrReturn"]),
        "visitor is missing a handler for 'handleInstrReturn'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrRemainder"]),
        "visitor is missing a handler for 'handleInstrRemainder'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrMultiply"]),
        "visitor is missing a handler for 'handleInstrMultiply'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrDivide"]),
        "visitor is missing a handler for 'handleInstrDivide'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrDivideInt"]),
        "visitor is missing a handler for 'handleInstrDivideInt'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrSubtract"]),
        "visitor is missing a handler for 'handleInstrSubtract'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrAdd"]),
        "visitor is missing a handler for 'handleInstrAdd'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrEqual"]),
        "visitor is missing a handler for 'handleInstrEqual'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrNotEqual"]),
        "visitor is missing a handler for 'handleInstrNotEqual'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrGreaterThan"]),
        "visitor is missing a handler for 'handleInstrGreaterThan'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrGreaterThanOrEqualTo"]),
        "visitor is missing a handler for 'handleInstrGreaterThanOrEqualTo'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrLessThan"]),
        "visitor is missing a handler for 'handleInstrLessThan'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrLessThanOrEqualTo"]),
        "visitor is missing a handler for 'handleInstrLessThanOrEqualTo'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrNot"]),
        "visitor is missing a handler for 'handleInstrNot'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrAnd"]),
        "visitor is missing a handler for 'handleInstrAnd'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrOr"]),
        "visitor is missing a handler for 'handleInstrOr'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrXor"]),
        "visitor is missing a handler for 'handleInstrXor'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrBitwiseNot"]),
        "visitor is missing a handler for 'handleInstrBitwiseNot'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrBitwiseAnd"]),
        "visitor is missing a handler for 'handleInstrBitwiseAnd'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrBitwiseOr"]),
        "visitor is missing a handler for 'handleInstrBitwiseOr'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrBitwiseXor"]),
        "visitor is missing a handler for 'handleInstrBitwiseXor'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrBitwiseShiftRight"]),
        "visitor is missing a handler for 'handleInstrBitwiseShiftRight'"
    );
    __catspeak_assert(is_method(visitor_[$ "handleInstrBitwiseShiftLeft"]),
        "visitor is missing a handler for 'handleInstrBitwiseShiftLeft'"
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
    static __readIfThenElse = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrIfThenElse(argDbg);
    };

    /// @ignore
    static __readReturn = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrReturn(argDbg);
    };

    /// @ignore
    static __readRemainder = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrRemainder(argDbg);
    };

    /// @ignore
    static __readMultiply = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrMultiply(argDbg);
    };

    /// @ignore
    static __readDivide = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrDivide(argDbg);
    };

    /// @ignore
    static __readDivideInt = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrDivideInt(argDbg);
    };

    /// @ignore
    static __readSubtract = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrSubtract(argDbg);
    };

    /// @ignore
    static __readAdd = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrAdd(argDbg);
    };

    /// @ignore
    static __readEqual = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrEqual(argDbg);
    };

    /// @ignore
    static __readNotEqual = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrNotEqual(argDbg);
    };

    /// @ignore
    static __readGreaterThan = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrGreaterThan(argDbg);
    };

    /// @ignore
    static __readGreaterThanOrEqualTo = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrGreaterThanOrEqualTo(argDbg);
    };

    /// @ignore
    static __readLessThan = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrLessThan(argDbg);
    };

    /// @ignore
    static __readLessThanOrEqualTo = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrLessThanOrEqualTo(argDbg);
    };

    /// @ignore
    static __readNot = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrNot(argDbg);
    };

    /// @ignore
    static __readAnd = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrAnd(argDbg);
    };

    /// @ignore
    static __readOr = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrOr(argDbg);
    };

    /// @ignore
    static __readXor = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrXor(argDbg);
    };

    /// @ignore
    static __readBitwiseNot = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseNot(argDbg);
    };

    /// @ignore
    static __readBitwiseAnd = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseAnd(argDbg);
    };

    /// @ignore
    static __readBitwiseOr = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseOr(argDbg);
    };

    /// @ignore
    static __readBitwiseXor = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseXor(argDbg);
    };

    /// @ignore
    static __readBitwiseShiftRight = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseShiftRight(argDbg);
    };

    /// @ignore
    static __readBitwiseShiftLeft = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseShiftLeft(argDbg);
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ CatspeakInstr.GET_N] = __readConstNumber;
        __readerLookup[@ CatspeakInstr.GET_B] = __readConstBool;
        __readerLookup[@ CatspeakInstr.GET_S] = __readConstString;
        __readerLookup[@ CatspeakInstr.IFTE] = __readIfThenElse;
        __readerLookup[@ CatspeakInstr.RET] = __readReturn;
        __readerLookup[@ CatspeakInstr.REM] = __readRemainder;
        __readerLookup[@ CatspeakInstr.MULT] = __readMultiply;
        __readerLookup[@ CatspeakInstr.DIV] = __readDivide;
        __readerLookup[@ CatspeakInstr.IDIV] = __readDivideInt;
        __readerLookup[@ CatspeakInstr.SUB] = __readSubtract;
        __readerLookup[@ CatspeakInstr.ADD] = __readAdd;
        __readerLookup[@ CatspeakInstr.EQ] = __readEqual;
        __readerLookup[@ CatspeakInstr.NEQ] = __readNotEqual;
        __readerLookup[@ CatspeakInstr.GT] = __readGreaterThan;
        __readerLookup[@ CatspeakInstr.GEQ] = __readGreaterThanOrEqualTo;
        __readerLookup[@ CatspeakInstr.LT] = __readLessThan;
        __readerLookup[@ CatspeakInstr.LEQ] = __readLessThanOrEqualTo;
        __readerLookup[@ CatspeakInstr.NOT] = __readNot;
        __readerLookup[@ CatspeakInstr.AND] = __readAnd;
        __readerLookup[@ CatspeakInstr.OR] = __readOr;
        __readerLookup[@ CatspeakInstr.XOR] = __readXor;
        __readerLookup[@ CatspeakInstr.BNOT] = __readBitwiseNot;
        __readerLookup[@ CatspeakInstr.BAND] = __readBitwiseAnd;
        __readerLookup[@ CatspeakInstr.BOR] = __readBitwiseOr;
        __readerLookup[@ CatspeakInstr.BXOR] = __readBitwiseXor;
        __readerLookup[@ CatspeakInstr.RSHIFT] = __readBitwiseShiftRight;
        __readerLookup[@ CatspeakInstr.LSHIFT] = __readBitwiseShiftLeft;
    }
}