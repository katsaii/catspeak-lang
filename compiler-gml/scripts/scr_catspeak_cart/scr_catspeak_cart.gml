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
    versionMinor = undefined;
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
    static finalise = function (buff = undefined) {
        try {
            __catspeak_assert(isAlive, "cannot call `finalise` method twice");
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
            buffer_write(cart, buffer_u8, versionMinor ?? 0);
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

    /// Get a numeric constant.
    ///
    /// @param {Real} value
    ///     
    static emitConstNumber = function (value, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_N);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_f64, value);
    };
}

/// Returns the version number of this Catspeak cartridge, or 0 if the
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
///   - `.handleMeta(name, author, version, versionMinor, patch, path, date)`
///   - `.handleFunc(idx)`
///   - `.handleInstrConstNumber(dbg, value)`
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
    var versionMinor = buffer_read(cart_, buffer_u8);
    var patch = buffer_read(cart_, buffer_u8);
    var path = buffer_read(cart_, buffer_string);
    var date = buffer_read(cart_, buffer_u32);
    visitor_.handleMeta(name, author, version, versionMinor, patch, path, date);

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
    static __readIConstNumber = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var value = buffer_read(cart_, buffer_f64);
        visitor.handleInstrConstNumber(dbg, value);
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(__CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ 0] = __readFunc;
        __readerLookup[@ __CatspeakInstr.GET_N] = __readIConstNumber;
    }
}

/// @ignore
enum __CatspeakInstr {
    GET_N = 1,
    __SIZE__ = 2,
}