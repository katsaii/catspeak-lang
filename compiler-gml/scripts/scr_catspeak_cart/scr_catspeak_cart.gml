// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/template/compiler-gml/scripts/scr_catspeak_cart/scr_catspeak_cart.gml

//! Responsible for the reading and writing of Catspeak IR (Intermediate
//! Representation). Catspeak IR is a binary format that can be saved and
//! loaded from a file, or treated like a "ROM" or "cartridge".
//!
//! Cartridge code is stored in reverse-polish notation, where each
//! instruction may push (or pop) intermediate values onto a virtual stack.
//!
//! Depending on the export, this may literally be a stack--such as with a
//! so-called "stack machine" VM. Other times the "stack" may be an
//! abstraction (e.g. the GML export), where Catspeak cartridges are
//! transformed into recursive GML function calls. (This ends up being faster
//! for reasons I won't detail here.)
//!
//! Each instruction may also be associated with zero or more static
//! parameters.

//# feather use syntax-errors

/// Handles the creation of Catspeak cartridges
///
/// @experimental
function CatspeakCartWriter() constructor {
    /// The name of this cartridge.
    ///
    /// @returns {String}
    name = undefined;
    /// The author of this cartridge.
    ///
    /// @returns {String}
    author = undefined;
    /// The major version of this cartridge.
    ///
    /// @returns {Real}
    version = undefined;
    /// The minor version of this cartridge.
    ///
    /// @returns {Real}
    version-minor = undefined;
    /// The patch number of this cartridge.
    ///
    /// @returns {Real}
    patch = undefined;
    /// The path to the file containing source code for this cartridge.
    ///
    /// @returns {String}
    path = undefined;
    /// The date this cartridge was compiled, in Unix time.
    ///
    /// @returns {Real}
    date = undefined;
    /// @ignore
    isAlive = true;
    /// @ignore
    chunks = ds_list_create();
    /// @ignore
    chunkTop = -1;
    /// @ignore
    funcCount = 0;

    /// Frees any dynamically allocated resources managed by this writer.
    ///
    /// @warning
    ///   This **must** be called in a `finally` block if you expect exceptions.
    static destroy = function () {
        if (!isAlive) {
            return;
        }
        for (var i = ds_list_size(chunks) - 1; i >= 0; i -= 1) {
            var chunk = chunks[| i];
            buffer_delete(chunk);
        }
        isAlive = false;
    };

    /// Writes the contents of this builder to the given buffer. If no buffer
    /// is supplied then a new, fresh buffer is allocated and returned.
    ///
    /// This method will also free the memory allocated by this builder, and
    /// mark it for garbage collection.
    ///
    /// @warning
    ///   Continuing to use the builder after this method has been called is
    ///   considered invalid, and may result in strange behaviour or crashes.
    ///
    /// @param {Id.Buffer} [buff]
    ///   The buffer to write the cartridge to. Must be a `buffer_grow` type
    ///   buffer with an alignment of 1.
    ///
    /// @return {Id.Buffer}
    static finalise = function (buff = undefined) {
        __catspeak_assert(isAlive, "cannot call `finalise` method twice");
        try {
            var cart;
            if (buff == undefined) {
                cart = buffer_create(1, buffer_grow, 1);
            } else {
                __catspeak_assert_typeof(buff, __catspeak_is_buffer,
                    "argument `buff` must be a buffer"
                );
                __catspeak_assert_eq(buffer_grow, buffer_get_type(buff),
                    "requires a grow buffer (buffer_grow)"
                );
                __catspeak_assert_eq(1, buffer_get_alignment(buff),
                    "requires a buffer with alignment 1"
                );
                cart = buff;
            }
            // write header
            buffer_write(cart, buffer_u32, 13063246); // signal-w
            buffer_write(cart, buffer_u32, 5994585); // signal-f
            buffer_write(cart, buffer_string, "CATSPEAK CART"); // title
            buffer_write(cart, buffer_u8, 1); // cart-version
            // write metadata
            buffer_write(cart, buffer_string, name ?? "untitled");
            buffer_write(cart, buffer_string, author ?? "");
            buffer_write(cart, buffer_u8, version ?? 1);
            buffer_write(cart, buffer_u8, version-minor ?? 0);
            buffer_write(cart, buffer_u8, patch ?? 0);
            buffer_write(cart, buffer_string, path ?? "");
            buffer_write(cart, buffer_u32, date ?? 0);
            // write functions
            __catspeak_assert(chunkTop < 0,
                "missing call to `popFunction` after calling `pushFunction`"
            );
            var offset = buffer_tell(cart);
            for (var i = ds_list_size(chunks) - 1; i >= 0; i -= 1) {
                var chunk = chunks[| i];
                var chunkSize = buffer_tell(chunk);
                buffer_copy(chunk, 0, chunkSize, cart, offset);
                offset += chunkSize;
            }
            buffer_seek(cart, buffer_seek_start, offset);
            // 0xFF indicates the end of the program section
            buffer_write(cart, buffer_u8, 255);
        } finally {
            destroy();
        }
        return cart;
    };

    /// Starts a new function.
    static pushFunction = function () {
        chunkTop += 1;
        if (chunks[| chunkTop] == undefined) {
            chunks[| chunkTop] = buffer_create(1, buffer_grow, 1);
        }
    };

    /// Ends the current function, returning its id.
    ///
    /// @return {Real}
    static popFunction = function () {
        __catspeak_assert(chunkTop >= 0,
            "unbalanced function stack! too many calls to `popFunction`"
        );
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, 0);
        var idx = funcCount;
        funcCount += 1;
        chunkTop -= 1;
        return idx;
    };

    /// Evaluates n-many expressions, implicitly returning the final expression.
    ///
    /// @param {Real} n
    ///   The number of expressions to evaluate.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSequence = function (n, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SEQ);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u32, n);
    };

    /// Return a reference to a function.
    ///
    /// @param {Real} idx
    ///   The numeric id of the function to get.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitClosure = function (idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.FCLO);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u32, idx);
    };

    /// Evaluate one of two expressions, depending on whether a condition is true or false.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitIfThenElse = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.IFTE);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the logical OR of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitOr = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.OR);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the logical XOR of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitXor = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.XOR);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the logical AND of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitAnd = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.AND);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Check whether two values are equal.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitEqual = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.EQ);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Check whether two values are NOT equal.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitNotEqual = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.NEQ);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Check whether a value is less than another.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitLessThan = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Check whether a value is less than or equal to another.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitLessThanOrEqualTo = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LEQ);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Check whether a value is greater than another.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGreaterThan = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Check whether a value is greater than or equal to another.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGreaterThanOrEqualTo = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GEQ);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the bitwise AND of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitBitwiseAnd = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.BAND);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the bitwise OR of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitBitwiseOr = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.BOR);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the bitwise XOR of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitBitwiseXor = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.BXOR);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the bitwise left shift of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitBitwiseShiftLeft = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LSHIFT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the bitwise right shift of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitBitwiseShiftRight = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.RSHIFT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the sum of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitAdd = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.ADD);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the difference of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSubtract = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SUB);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the product of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitMultiply = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.MULT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the division of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitDivide = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.DIV);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the integer division of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitDivideInt = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.IDIV);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the remainder of two values.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitRemainder = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.REM);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the positive of a value.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitPositive = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.POS);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the negative of a value.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitNegative = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.NEG);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the logical negation of a value.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitNot = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.NOT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Calculate the bitwise negation of a value.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitBitwiseNot = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.BNOT);
        buffer_write(chunk, buffer_u32, dbg);
    };

    /// Get a numeric constant.
    ///
    /// @param {Real} value
    ///   The number to emit.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitConstNumber = function (value, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_N);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_f64, value);
    };

    /// Get a string constant.
    ///
    /// @param {String} value
    ///   The string to emit.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitConstString = function (value, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_S);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_string, value);
    };

    /// Get the undefined constant.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitConstUndefined = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_U);
        buffer_write(chunk, buffer_u32, dbg);
    };
}

/// Returns the version number of this Catspeak cartridge, or `0` if the
/// given buffer isn't a valid cartridge.
///
/// @param {Id.Buffer} cart
///   The buffer to read cartridge info from.
///
/// @return {Real}
function catspeak_cart_version(cart) {
    if (!__catspeak_is_buffer(cart)) {
        return 0;
    }
    var currSeek = buffer_tell(cart);
    var val;
    try {
        // signal-w
        val = buffer_read(cart, buffer_u32);
        if (val != 13063246) {
            buffer_seek(cart, buffer_seek_start, currSeek);
            return 0;
        }
        // signal-f
        val = buffer_read(cart, buffer_u32);
        if (val != 5994585) {
            buffer_seek(cart, buffer_seek_start, currSeek);
            return 0;
        }
        // title
        val = buffer_read(cart, buffer_string);
        if (val != "CATSPEAK CART") {
            buffer_seek(cart, buffer_seek_start, currSeek);
            return 0;
        }
        // cart-version
        val = buffer_read(cart, buffer_u8);
        buffer_seek(cart, buffer_seek_start, currSeek);
        return val;
    } catch (ex) {
        buffer_seek(cart, buffer_seek_start, currSeek);
    }
    return 0;
}

/// Handles the parsing of Catspeak cartridges.
///
/// @experimental
///
/// @remark
///   Immediately reads and calls the handlers for the "data" section of the
///   Catspeak cartridge.
///
/// @param {Id.Buffer} cart_
///   The buffer to read cartridge info from.
///
/// @param {Struct} visitor_
///   A struct containing methods for handling each of the following cases:
///
///   - `.handleMeta(name, author, version, version-minor, patch, path, date)` (always invoked first)
///   - `.handleFunc(idx)`
///   - `.handleInstrSequence(dbg, n)`
///   - `.handleInstrClosure(dbg, idx)`
///   - `.handleInstrIfThenElse(dbg)`
///   - `.handleInstrOr(dbg)`
///   - `.handleInstrXor(dbg)`
///   - `.handleInstrAnd(dbg)`
///   - `.handleInstrEqual(dbg)`
///   - `.handleInstrNotEqual(dbg)`
///   - `.handleInstrLessThan(dbg)`
///   - `.handleInstrLessThanOrEqualTo(dbg)`
///   - `.handleInstrGreaterThan(dbg)`
///   - `.handleInstrGreaterThanOrEqualTo(dbg)`
///   - `.handleInstrBitwiseAnd(dbg)`
///   - `.handleInstrBitwiseOr(dbg)`
///   - `.handleInstrBitwiseXor(dbg)`
///   - `.handleInstrBitwiseShiftLeft(dbg)`
///   - `.handleInstrBitwiseShiftRight(dbg)`
///   - `.handleInstrAdd(dbg)`
///   - `.handleInstrSubtract(dbg)`
///   - `.handleInstrMultiply(dbg)`
///   - `.handleInstrDivide(dbg)`
///   - `.handleInstrDivideInt(dbg)`
///   - `.handleInstrRemainder(dbg)`
///   - `.handleInstrPositive(dbg)`
///   - `.handleInstrNegative(dbg)`
///   - `.handleInstrNot(dbg)`
///   - `.handleInstrBitwiseNot(dbg)`
///   - `.handleInstrConstNumber(dbg, value)`
///   - `.handleInstrConstString(dbg, value)`
///   - `.handleInstrConstUndefined(dbg)`
function CatspeakCartReader(cart_, visitor_) constructor {
    __catspeak_assert_typeof(cart_, __catspeak_is_buffer,
        "buffer doesn't exist"
    );
    __catspeak_assert_eq(1, buffer_get_alignment(cart_),
        "requires a buffer with alignment 1"
    );
    __catspeak_assert_typeof(visitor_, is_struct,
        "visitor must be a struct"
    );
    // read header
    var val;
    val = buffer_read(cart_, buffer_u32);
    if (val != 13063246) {
        __catspeak_error(__catspeak_cat(
            @'signal-w 13063246 of type `u32` missing from cartridge header, got ', val
        ));
    }
    val = buffer_read(cart_, buffer_u32);
    if (val != 5994585) {
        __catspeak_error(__catspeak_cat(
            @'signal-f 5994585 of type `u32` missing from cartridge header, got ', val
        ));
    }
    val = buffer_read(cart_, buffer_string);
    if (val != "CATSPEAK CART") {
        __catspeak_error(__catspeak_cat(
            @'title "CATSPEAK CART" of type `string` missing from cartridge header, got ', val
        ));
    }
    val = buffer_read(cart_, buffer_u8);
    if (val != 1) {
        __catspeak_error(__catspeak_cat(
            @'cart-version 1 of type `u8` missing from cartridge header, got ', val
        ));
    }
    // read metadata
    var name = buffer_read(cart_, buffer_string);
    var author = buffer_read(cart_, buffer_string);
    var version = buffer_read(cart_, buffer_u8);
    var version-minor = buffer_read(cart_, buffer_u8);
    var patch = buffer_read(cart_, buffer_u8);
    var path = buffer_read(cart_, buffer_string);
    var date = buffer_read(cart_, buffer_u32);
    visitor_.handleMeta(name, author, version, version-minor, patch, path, date);

    /// @ignore
    cart = cart_;
    /// @ignore
    visitor = visitor_;
    /// @ignore
    funcIdx = 0;

    /// Reads the next instruction if it exists, calling its handler.
    ///
    /// If there are more instructions left to be read, then this function will
    /// return `true`. If all instructions have been read, then `false` is
    /// returned, and the buffer seek is set to the **end of the Cartidge**.
    ///
    /// @return {Bool}
    static readInstr = function () {
        var cart_ = cart;
        __catspeak_assert(cart_ != undefined,
            "called `readInstr` after reaching end of cartridge"
        );
        var opcode = buffer_read(cart_, buffer_u8);
        if (opcode == 255) {
            // we've reached the end
            cart_ = undefined;
            return false;
        }
        __catspeak_assert(opcode >= 0 && opcode < __CatspeakInstr.__SIZE__,
            "invalid cartridge instruction: " + string(opcode)
        );
        var instrReader = __readerLookup[opcode];
        instrReader();
        return true;
    };

    /// @ignore
    static __readFunc = function () {
        visitor.handleFunc(funcIdx);
        funcIdx += 1;
    };

    /// @ignore
    static __readISequence = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var n = buffer_read(cart_, buffer_u32);
        visitor.handleInstrSequence(dbg, n);
    };

    /// @ignore
    static __readIClosure = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var idx = buffer_read(cart_, buffer_u32);
        visitor.handleInstrClosure(dbg, idx);
    };

    /// @ignore
    static __readIIfThenElse = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrIfThenElse(dbg);
    };

    /// @ignore
    static __readIOr = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrOr(dbg);
    };

    /// @ignore
    static __readIXor = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrXor(dbg);
    };

    /// @ignore
    static __readIAnd = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrAnd(dbg);
    };

    /// @ignore
    static __readIEqual = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrEqual(dbg);
    };

    /// @ignore
    static __readINotEqual = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrNotEqual(dbg);
    };

    /// @ignore
    static __readILessThan = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrLessThan(dbg);
    };

    /// @ignore
    static __readILessThanOrEqualTo = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrLessThanOrEqualTo(dbg);
    };

    /// @ignore
    static __readIGreaterThan = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrGreaterThan(dbg);
    };

    /// @ignore
    static __readIGreaterThanOrEqualTo = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrGreaterThanOrEqualTo(dbg);
    };

    /// @ignore
    static __readIBitwiseAnd = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrBitwiseAnd(dbg);
    };

    /// @ignore
    static __readIBitwiseOr = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrBitwiseOr(dbg);
    };

    /// @ignore
    static __readIBitwiseXor = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrBitwiseXor(dbg);
    };

    /// @ignore
    static __readIBitwiseShiftLeft = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrBitwiseShiftLeft(dbg);
    };

    /// @ignore
    static __readIBitwiseShiftRight = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrBitwiseShiftRight(dbg);
    };

    /// @ignore
    static __readIAdd = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrAdd(dbg);
    };

    /// @ignore
    static __readISubtract = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrSubtract(dbg);
    };

    /// @ignore
    static __readIMultiply = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrMultiply(dbg);
    };

    /// @ignore
    static __readIDivide = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrDivide(dbg);
    };

    /// @ignore
    static __readIDivideInt = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrDivideInt(dbg);
    };

    /// @ignore
    static __readIRemainder = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrRemainder(dbg);
    };

    /// @ignore
    static __readIPositive = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrPositive(dbg);
    };

    /// @ignore
    static __readINegative = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrNegative(dbg);
    };

    /// @ignore
    static __readINot = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrNot(dbg);
    };

    /// @ignore
    static __readIBitwiseNot = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrBitwiseNot(dbg);
    };

    /// @ignore
    static __readIConstNumber = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var value = buffer_read(cart_, buffer_f64);
        visitor.handleInstrConstNumber(dbg, value);
    };

    /// @ignore
    static __readIConstString = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var value = buffer_read(cart_, buffer_string);
        visitor.handleInstrConstString(dbg, value);
    };

    /// @ignore
    static __readIConstUndefined = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrConstUndefined(dbg);
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(__CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ 0] = __readFunc;
        __readerLookup[@ __CatspeakInstr.SEQ] = __readISequence;
        __readerLookup[@ __CatspeakInstr.FCLO] = __readIClosure;
        __readerLookup[@ __CatspeakInstr.IFTE] = __readIIfThenElse;
        __readerLookup[@ __CatspeakInstr.OR] = __readIOr;
        __readerLookup[@ __CatspeakInstr.XOR] = __readIXor;
        __readerLookup[@ __CatspeakInstr.AND] = __readIAnd;
        __readerLookup[@ __CatspeakInstr.EQ] = __readIEqual;
        __readerLookup[@ __CatspeakInstr.NEQ] = __readINotEqual;
        __readerLookup[@ __CatspeakInstr.LT] = __readILessThan;
        __readerLookup[@ __CatspeakInstr.LEQ] = __readILessThanOrEqualTo;
        __readerLookup[@ __CatspeakInstr.GT] = __readIGreaterThan;
        __readerLookup[@ __CatspeakInstr.GEQ] = __readIGreaterThanOrEqualTo;
        __readerLookup[@ __CatspeakInstr.BAND] = __readIBitwiseAnd;
        __readerLookup[@ __CatspeakInstr.BOR] = __readIBitwiseOr;
        __readerLookup[@ __CatspeakInstr.BXOR] = __readIBitwiseXor;
        __readerLookup[@ __CatspeakInstr.LSHIFT] = __readIBitwiseShiftLeft;
        __readerLookup[@ __CatspeakInstr.RSHIFT] = __readIBitwiseShiftRight;
        __readerLookup[@ __CatspeakInstr.ADD] = __readIAdd;
        __readerLookup[@ __CatspeakInstr.SUB] = __readISubtract;
        __readerLookup[@ __CatspeakInstr.MULT] = __readIMultiply;
        __readerLookup[@ __CatspeakInstr.DIV] = __readIDivide;
        __readerLookup[@ __CatspeakInstr.IDIV] = __readIDivideInt;
        __readerLookup[@ __CatspeakInstr.REM] = __readIRemainder;
        __readerLookup[@ __CatspeakInstr.POS] = __readIPositive;
        __readerLookup[@ __CatspeakInstr.NEG] = __readINegative;
        __readerLookup[@ __CatspeakInstr.NOT] = __readINot;
        __readerLookup[@ __CatspeakInstr.BNOT] = __readIBitwiseNot;
        __readerLookup[@ __CatspeakInstr.GET_N] = __readIConstNumber;
        __readerLookup[@ __CatspeakInstr.GET_S] = __readIConstString;
        __readerLookup[@ __CatspeakInstr.GET_U] = __readIConstUndefined;
    }
}

/// @ignore
enum __CatspeakInstr {
    SEQ = 2,
    FCLO = 27,
    IFTE = 28,
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
    __SIZE__ = 36,
}