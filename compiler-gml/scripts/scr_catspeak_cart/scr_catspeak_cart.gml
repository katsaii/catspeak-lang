// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir-gml.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/scr_catspeak_cart.gml

//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved
//! and loaded from a file, or treated like a "ROM" or "cartridge".
//!
//! Cartridge code is stored in reverse-polish notation, where each
//! instruction may push (or pop) intermediate values onto a virtual stack.
//!
//! Depending on the export, this may literally be a stack--such as with a
//! so-called "stack machine" VM. Other times the "stack" may be an abstraction,
//! such as with the GML export, where Catspeak cartridges are transformed into
//! recursive GML function calls. (This ends up being faster for reasons I won't
//! detail here.)
//!
//! Each instruction may also be associated with zero or many static parameters.

//# feather use syntax-errors

/// Handles the creation of Catspeak cartridges.
///
/// @experimental
///
/// @param {Id.Buffer} buff_
///   The buffer to write the cartridge to. Must be a `buffer_grow` type buffer
///   with an alignment of 1.
function CatspeakCartWriter(buff_) constructor {
    __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "buffer doesn't exist");
    __catspeak_assert_eq(buffer_grow, buffer_get_type(buff_), "requires a grow buffer (buffer_grow)");
    __catspeak_assert_eq(1, buffer_get_alignment(buff_), "requires a buffer with alignment 1");
    /// @ignore
    cartStart = buffer_tell(buff_);
    /// @ignore
    hSignal = buffer_tell(buff_);
    // (signal will be patched to 5994585 when finalised)
    buffer_write(buff_, buffer_u32, 13063246); // signal header
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
    /// @ignore
    exprStack = array_create(32); // stores type info used for optimisations
    /// @ignore
    exprStackTop = 0;

    /// Returns the current value of the top in the stack.
    ///
    /// @remark
    ///   This can be used to perform optimisations, such as constant folding.
    ///
    /// @return {Any}
    static peekValue = function () {
        return exprStackTop > 0 ? exprStack[exprStackTop - 2] : undefined;
    };

    /// Returns the number of values currently pushed onto to the stack.
    ///
    /// @remark
    ///   This can be used to automatically figure out how many parameters an
    ///   instruction needs.
    ///
    /// @return {Any}
    static peekValueCount = function () {
        return exprStackTop div 2;
    };

    /// Finalises the creation of this Catspeak cartridge. Assumes the program
    /// section is well-formed, then writes the data section before patching
    /// any necessary references and in the header.
    static finalise = function () {
        var buff_ = buff;
        buff = undefined;
        __catspeak_assert_eq(2, exprStackTop, "expression stack unbalanced (did you call finalise too early?)");
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        buffer_write(buff_, buffer_u8, __CatspeakInstr.END_OF_PROGRAM);
        buffer_poke(buff_, chunkData, buffer_u32, buffer_tell(buff_) - cartStart); // patch data
        // write meta data
        buffer_write(buff_, buffer_string, path);
        buffer_write(buff_, buffer_string, author);
        buffer_poke(buff_, chunkEnd, buffer_u32, buffer_tell(buff_) - cartStart); // patch end
        buffer_poke(buff_, hSignal, buffer_u32, 5994585); // patch signal header
    };

    /// Throw a value as an exception.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitThrow = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.THRW);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Catch an exception.
    ///
    /// @param {Real} idx
    ///     The id of the local variable to assign the exception value to.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitCatch = function (idx, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(idx, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.CAT);
        buffer_write(buff_, buffer_u32, idx);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Throw a value to the first unwind block with the same id.
    ///
    /// @param {Real} label
    ///     The id of the label to unwind to.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitUnwind = function (label, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(label, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.UWND);
        buffer_write(buff_, buffer_u32, label);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Catch a labelled value thrown by the `uwnd` instruction.
    ///
    /// @param {Real} label
    ///     The id of the label to catch values of.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitCatchUnwind = function (label, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(label, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.CAT_UWND);
        buffer_write(buff_, buffer_u32, label);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Evaluates n-many expressions, implicitly returning the final expression.
    ///
    /// @param {Real} n
    ///     The number of expressions to evaluate, must be greater than 0.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitSequence = function (n, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(n, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        if (n == 0) {
            emitConstUndefined(dbg);
            return;
        }
        if (n == 1) {
            return;
        }
        __catspeak_assert(n > 0, "n must be greater than 0");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1 + (n - 1));
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.SEQ);
        buffer_write(buff_, buffer_u32, n);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Evaluates one of two expressions, depending on whether a condition is true or false.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitIfThenElse = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (3);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.IFTE);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Builds a function closure, updating any upvalues if they exist.
    ///
    /// @param {Real} locals
    ///     The number of local variables this function has allocated.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitClosure = function (locals, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(locals, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.FCLO);
        buffer_write(buff_, buffer_u32, locals);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical OR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitOr = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.OR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical XOR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitXor = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.XOR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical AND of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitAnd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.AND);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether two values are equal.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitEqual = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.EQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether two values are NOT equal.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitNotEqual = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.NEQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is less than another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitLessThan = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.LT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is less than or equal to another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitLessThanOrEqualTo = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.LEQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is greater than another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGreaterThan = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Check whether a value is greater than or equal to another.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGreaterThanOrEqualTo = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GEQ);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise AND of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseAnd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.BAND);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise OR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseOr = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.BOR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise XOR of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseXor = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.BXOR);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise left shift of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseShiftLeft = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.LSHIFT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise right shift of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseShiftRight = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.RSHIFT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the sum of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitAdd = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.ADD);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the difference of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitSubtract = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.SUB);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the product of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitMultiply = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.MULT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the division of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitDivide = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.DIV);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the integer division of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitDivideInt = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.IDIV);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the remainder of two values.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitRemainder = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (2);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.REM);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the positive of a value.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitPositive = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.POS);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the negative of a value.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitNegative = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.NEG);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the logical negation of a value.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitNot = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.NOT);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Calculate the bitwise negation of a value.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitBitwiseNot = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.BNOT);
        buffer_write(buff_, buffer_u32, dbg);
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
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(value, is_numeric, "expected type of f64");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (0);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GET_N);
        buffer_write(buff_, buffer_f64, value);
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
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(value, is_string, "expected type of string");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (0);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GET_S);
        buffer_write(buff_, buffer_string, value);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Get the undefined constant.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitConstUndefined = function (dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (0);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GET_U);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Gets the value of a local variable with this id.
    ///
    /// @param {Real} idx
    ///     The id of the local variable to get the value of.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGetLocal = function (idx, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(idx, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (0);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GET_L);
        buffer_write(buff_, buffer_u32, idx);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Sets the value of a local variable with this id.
    ///
    /// @param {Real} idx
    ///     The id of the local variable to set the value of.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitSetLocal = function (idx, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(idx, is_numeric, "expected type of u32");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.SET_L);
        buffer_write(buff_, buffer_u32, idx);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Gets the value of a global variable with this name.
    ///
    /// @param {String} name
    ///     The name of the global variable to get the value of.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGetGlobal = function (name, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(name, is_string, "expected type of string");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (0);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.GET_G);
        buffer_write(buff_, buffer_string, name);
        buffer_write(buff_, buffer_u32, dbg);
    };

    /// Sets the value of a global variable with this name.
    ///
    /// @param {String} name
    ///     The name of the global variable to set the value of.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitSetGlobal = function (name, dbg = CATSPEAK_NOLOCATION) {
        var buff_ = buff;
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        __catspeak_assert_typeof(name, is_string, "expected type of string");
        __catspeak_assert_typeof(dbg, is_numeric, "expected type of u32");
        var exprStack_ = exprStack;
        var exprStackTop_ = exprStackTop;
        exprStackTop_ -= 2 * (1);
        __catspeak_assert(exprStackTop_ >= 0);
        exprStack_[@ exprStackTop_ + 0] = undefined;
        exprStack_[@ exprStackTop_ + 1] = buffer_tell(buff_);
        exprStackTop = exprStackTop_ + 2;
        buffer_write(buff_, buffer_u8, __CatspeakInstr.SET_G);
        buffer_write(buff_, buffer_string, name);
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
    __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "buffer doesn't exist");
    __catspeak_assert_eq(1, buffer_get_alignment(buff_), "require a buffer with alignment 1");
    __catspeak_assert_typeof(visitor_, is_struct, "visitor must be a struct");
    __catspeak_assert_typeof(visitor_[$ "handleInstrThrow"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrThrow'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrCatch"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrCatch'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrUnwind"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrUnwind'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrCatchUnwind"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrCatchUnwind'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrSequence"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrSequence'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrIfThenElse"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrIfThenElse'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrClosure"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrClosure'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrOr"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrOr'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrXor"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrXor'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrAnd"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrAnd'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrEqual"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrEqual'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrNotEqual"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrNotEqual'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrLessThan"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrLessThan'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrLessThanOrEqualTo"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrLessThanOrEqualTo'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrGreaterThan"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrGreaterThan'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrGreaterThanOrEqualTo"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrGreaterThanOrEqualTo'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrBitwiseAnd"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrBitwiseAnd'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrBitwiseOr"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrBitwiseOr'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrBitwiseXor"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrBitwiseXor'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrBitwiseShiftLeft"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrBitwiseShiftLeft'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrBitwiseShiftRight"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrBitwiseShiftRight'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrAdd"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrAdd'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrSubtract"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrSubtract'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrMultiply"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrMultiply'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrDivide"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrDivide'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrDivideInt"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrDivideInt'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrRemainder"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrRemainder'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrPositive"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrPositive'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrNegative"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrNegative'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrNot"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrNot'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrBitwiseNot"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrBitwiseNot'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrConstNumber"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrConstNumber'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrConstString"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrConstString'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrConstUndefined"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrConstUndefined'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrGetLocal"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrGetLocal'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrSetLocal"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrSetLocal'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrGetGlobal"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrGetGlobal'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInstrSetGlobal"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInstrSetGlobal'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleMeta"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleMeta'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleInit"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleInit'"
    );
    __catspeak_assert_typeof(visitor_[$ "handleDeinit"], __catspeak_is_callable,
        "visitor is missing a handler for 'handleDeinit'"
    );
    /// @ignore
    cartStart = buffer_tell(buff_);
    var failedMessage = undefined;
    try {
        if (buffer_read(buff_, buffer_u32) != 5994585) {
            failedMessage = "failed to read Catspeak cartridge: '5994585' (u32) missing from header";
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
        __catspeak_assert_typeof(buff_, __catspeak_is_buffer, "no cartridge loaded");
        var instrType = buffer_read(buff_, buffer_u8);
        if (instrType == __CatspeakInstr.END_OF_PROGRAM) {
            // we've reached the end
            buff = undefined;
            buffer_seek(buff_, buffer_seek_start, cartStart + chunkEnd); // seek end
            visitor.handleDeinit();
            return false;
        }
        __catspeak_assert(instrType >= 0 && instrType < __CatspeakInstr.__SIZE__,
            "invalid cartridge instruction"
        );
        var instrReader = __readerLookup[instrType];
        instrReader();
        return true;
    };

    /// @ignore
    static __readThrow = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrThrow(argDbg);
    };

    /// @ignore
    static __readCatch = function () {
        var buff_ = buff;
        var argIdx = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrCatch(argIdx, argDbg);
    };

    /// @ignore
    static __readUnwind = function () {
        var buff_ = buff;
        var argLabel = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrUnwind(argLabel, argDbg);
    };

    /// @ignore
    static __readCatchUnwind = function () {
        var buff_ = buff;
        var argLabel = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrCatchUnwind(argLabel, argDbg);
    };

    /// @ignore
    static __readSequence = function () {
        var buff_ = buff;
        var argN = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrSequence(argN, argDbg);
    };

    /// @ignore
    static __readIfThenElse = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrIfThenElse(argDbg);
    };

    /// @ignore
    static __readClosure = function () {
        var buff_ = buff;
        var argLocals = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrClosure(argLocals, argDbg);
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
    static __readAnd = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrAnd(argDbg);
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
    static __readBitwiseShiftLeft = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseShiftLeft(argDbg);
    };

    /// @ignore
    static __readBitwiseShiftRight = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseShiftRight(argDbg);
    };

    /// @ignore
    static __readAdd = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrAdd(argDbg);
    };

    /// @ignore
    static __readSubtract = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrSubtract(argDbg);
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
    static __readRemainder = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrRemainder(argDbg);
    };

    /// @ignore
    static __readPositive = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrPositive(argDbg);
    };

    /// @ignore
    static __readNegative = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrNegative(argDbg);
    };

    /// @ignore
    static __readNot = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrNot(argDbg);
    };

    /// @ignore
    static __readBitwiseNot = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrBitwiseNot(argDbg);
    };

    /// @ignore
    static __readConstNumber = function () {
        var buff_ = buff;
        var argValue = buffer_read(buff_, buffer_f64);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrConstNumber(argValue, argDbg);
    };

    /// @ignore
    static __readConstString = function () {
        var buff_ = buff;
        var argValue = buffer_read(buff_, buffer_string);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrConstString(argValue, argDbg);
    };

    /// @ignore
    static __readConstUndefined = function () {
        var buff_ = buff;
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrConstUndefined(argDbg);
    };

    /// @ignore
    static __readGetLocal = function () {
        var buff_ = buff;
        var argIdx = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrGetLocal(argIdx, argDbg);
    };

    /// @ignore
    static __readSetLocal = function () {
        var buff_ = buff;
        var argIdx = buffer_read(buff_, buffer_u32);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrSetLocal(argIdx, argDbg);
    };

    /// @ignore
    static __readGetGlobal = function () {
        var buff_ = buff;
        var argName = buffer_read(buff_, buffer_string);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrGetGlobal(argName, argDbg);
    };

    /// @ignore
    static __readSetGlobal = function () {
        var buff_ = buff;
        var argName = buffer_read(buff_, buffer_string);
        var argDbg = buffer_read(buff_, buffer_u32);
        visitor.handleInstrSetGlobal(argName, argDbg);
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(__CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ __CatspeakInstr.THRW] = __readThrow;
        __readerLookup[@ __CatspeakInstr.CAT] = __readCatch;
        __readerLookup[@ __CatspeakInstr.UWND] = __readUnwind;
        __readerLookup[@ __CatspeakInstr.CAT_UWND] = __readCatchUnwind;
        __readerLookup[@ __CatspeakInstr.SEQ] = __readSequence;
        __readerLookup[@ __CatspeakInstr.IFTE] = __readIfThenElse;
        __readerLookup[@ __CatspeakInstr.FCLO] = __readClosure;
        __readerLookup[@ __CatspeakInstr.OR] = __readOr;
        __readerLookup[@ __CatspeakInstr.XOR] = __readXor;
        __readerLookup[@ __CatspeakInstr.AND] = __readAnd;
        __readerLookup[@ __CatspeakInstr.EQ] = __readEqual;
        __readerLookup[@ __CatspeakInstr.NEQ] = __readNotEqual;
        __readerLookup[@ __CatspeakInstr.LT] = __readLessThan;
        __readerLookup[@ __CatspeakInstr.LEQ] = __readLessThanOrEqualTo;
        __readerLookup[@ __CatspeakInstr.GT] = __readGreaterThan;
        __readerLookup[@ __CatspeakInstr.GEQ] = __readGreaterThanOrEqualTo;
        __readerLookup[@ __CatspeakInstr.BAND] = __readBitwiseAnd;
        __readerLookup[@ __CatspeakInstr.BOR] = __readBitwiseOr;
        __readerLookup[@ __CatspeakInstr.BXOR] = __readBitwiseXor;
        __readerLookup[@ __CatspeakInstr.LSHIFT] = __readBitwiseShiftLeft;
        __readerLookup[@ __CatspeakInstr.RSHIFT] = __readBitwiseShiftRight;
        __readerLookup[@ __CatspeakInstr.ADD] = __readAdd;
        __readerLookup[@ __CatspeakInstr.SUB] = __readSubtract;
        __readerLookup[@ __CatspeakInstr.MULT] = __readMultiply;
        __readerLookup[@ __CatspeakInstr.DIV] = __readDivide;
        __readerLookup[@ __CatspeakInstr.IDIV] = __readDivideInt;
        __readerLookup[@ __CatspeakInstr.REM] = __readRemainder;
        __readerLookup[@ __CatspeakInstr.POS] = __readPositive;
        __readerLookup[@ __CatspeakInstr.NEG] = __readNegative;
        __readerLookup[@ __CatspeakInstr.NOT] = __readNot;
        __readerLookup[@ __CatspeakInstr.BNOT] = __readBitwiseNot;
        __readerLookup[@ __CatspeakInstr.GET_N] = __readConstNumber;
        __readerLookup[@ __CatspeakInstr.GET_S] = __readConstString;
        __readerLookup[@ __CatspeakInstr.GET_U] = __readConstUndefined;
        __readerLookup[@ __CatspeakInstr.GET_L] = __readGetLocal;
        __readerLookup[@ __CatspeakInstr.SET_L] = __readSetLocal;
        __readerLookup[@ __CatspeakInstr.GET_G] = __readGetGlobal;
        __readerLookup[@ __CatspeakInstr.SET_G] = __readSetGlobal;
    }
}

/// @ignore
enum __CatspeakInstr {
    END_OF_PROGRAM = 0,
    THRW = 31,
    CAT = 42,
    UWND = 40,
    CAT_UWND = 41,
    SEQ = 27,
    IFTE = 28,
    FCLO = 34,
    OR = 19,
    XOR = 20,
    AND = 18,
    EQ = 11,
    NEQ = 12,
    LT = 15,
    LEQ = 16,
    GT = 13,
    GEQ = 14,
    BAND = 22,
    BOR = 23,
    BXOR = 24,
    LSHIFT = 26,
    RSHIFT = 25,
    ADD = 5,
    SUB = 10,
    MULT = 7,
    DIV = 8,
    IDIV = 9,
    REM = 6,
    POS = 33,
    NEG = 32,
    NOT = 17,
    BNOT = 21,
    GET_N = 1,
    GET_S = 3,
    GET_U = 35,
    GET_L = 36,
    SET_L = 37,
    GET_G = 38,
    SET_G = 39,
    __SIZE__ = 43,
}