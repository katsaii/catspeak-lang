// AUTO GENERATED, DO NOT MODIFY THIS FILE
// see:
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/def-catspeak-ir.yaml
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/build-ir.py
//  - https://github.com/katsaii/catspeak-lang/blob/main/compiler-compiler/templates/compiler-gml/scripts/scr_catspeak_cart/scr_catspeak_cart.gml

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
//!
//! @advanced
//! @experimental

//# feather use syntax-errors

/// The empty string represents the current Catspeak module. In `.meow` files
/// this may appear as `self::module_item`.
///
/// @return {String}
#macro CATSPEAK_CURRENT_MODULE "*"

/// Handles the creation of Catspeak cartridges. Performs little to no
/// optimisations on the output. What you emit is what you get!
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
    /// The module path of this cartridge, used for symbol resolution.
    ///
    /// @returns {String}
    path = undefined;
    /// The date this cartridge was compiled, in Unix time.
    ///
    /// @returns {Real}
    date = undefined;
    /// @ignore
    includes = ds_list_create();
    /// @ignore
    isAlive = true;
    /// @ignore
    chunks = ds_list_create();
    /// @ignore
    chunkTop = -1;
    /// @ignore
    funcCount = 0;
    /// @ignore
    prevChunkStates = ds_stack_create();
    /// @ignore
    stackSize = 0;
    /// @ignore
    varCount = 0;

    /// Returns the number of expressions on the stack.
    ///
    /// Useful when working with instructions which don't take a constant
    /// number of stackargs. (e.g. `emitSequence`)
    ///
    /// @return {Real}
    static getStackSize = function () { return stackSize };

    /// Returns a new fresh local variable id for the current function.
    /// Intended for use with `emitGetLocal` and `emitSetLocal`.
    ///
    /// @return {Real}
    static getFreshVar = function () {
        var idx = varCount;
        varCount += 1;
        return idx;
    };

    /// Adds a new module include to this cartridge. So long as the given
    /// module is loaded, this gives this cartridge permission to read global
    /// variables from that module.
    ///
    /// @param {String} path
    ///   The path of the module, either absolute or relative to this
    ///   cartridge in the virtual filesystem.
    ///
    /// @param {String} [alias]
    ///   The short alias to use for this module. Defaults to the last identifier
    ///   following the special `::` path separator.
    ///
    /// @example
    ///   ```meow
    ///   import common::utils::math
    ///   --                    ^^^^ alias (short for `import abc::xyz as xyz`)
    ///   --     ^^^^^^^^^^^^^^^^^^^ path
    ///
    ///   import gml::unsafe as u
    ///   --     ^^^^^^^^^^^    ^ alias
    ///   --     path
    ///   ```
    ///
    /// @param
    static addInclude = function (path, alias = undefined) {
        __catspeak_assert(path != "", "include path cannot be an empty string");
        __catspeak_assert(alias != "", "include alias cannot be an empty string");
        if (alias == undefined) {
            var delim = string_last_pos("::", path);
            alias = delim > 0 ? string_delete(path, 1, delim + 1) : path;
        }
        ds_list_add(includes, path, alias);
    };

    /// Frees any dynamically allocated resources managed by this writer.
    ///
    /// @warning
    ///   This **must** be called in a `finally` block if you expect exceptions.
    static destroy = function () {
        if (!isAlive) {
            return;
        }
        var chunks_ = chunks;
        for (var i = ds_list_size(chunks_) - 1; i >= 0; i -= 1) {
            var chunk = chunks_[| i];
            buffer_delete(chunk);
        }
        ds_list_destroy(chunks_);
        ds_stack_destroy(prevChunkStates);
        ds_list_destroy(includes);
        isAlive = false;
    };

    /// Writes the contents of this builder to the given buffer. If no buffer
    /// is supplied then a new, fresh buffer is allocated and returned.
    ///
    /// This method will also free the memory allocated by this builder, and
    /// mark it for garbage collection. **This means you cannot use the same
    /// builder twice to write to different buffers**, you should use
    /// `buffer_copy` for that!
    ///
    /// @warning
    ///   Continuing to use the builder after this method has been called is
    ///   considered invalid, and may result in strange behaviour or crashes.
    ///
    /// @param {Id.Buffer} [buff]
    ///   The buffer to write the cartridge to. Must be a `buffer_grow` type
    ///   buffer with an alignment of 1.
    ///
    /// @param {Bool} [rewind]
    ///   Whether to rewind the buffer once the cart is finalised. Defaults to
    ///   `true`.
    ///
    /// @return {Id.Buffer}
    static finalise = function (buff = undefined, rewind = true) {
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
            var cartStart = buffer_tell(cart);
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
            // write includes
            for (var i = ds_list_size(includes) - 2; i >= 0; i -= 2) {
                buffer_write(cart, buffer_string, includes[| i + 0]);
                buffer_write(cart, buffer_string, includes[| i + 1]);
            }
            buffer_write(cart, buffer_string, ""); // end of program
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
            buffer_write(cart, buffer_u8, 0x00); // end of program
            if (rewind) {
                buffer_seek(cart, buffer_seek_start, cartStart);
            }
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
        var prevChunkStates_ = prevChunkStates;
        ds_stack_push(prevChunkStates_, stackSize);
        ds_stack_push(prevChunkStates_, varCount);
        stackSize = 0;
        varCount = 0;
    };

    /// Ends the current function, returning its id.
    ///
    /// @param {Real} argc
    ///   The number of named arguments this function accepts.
    ///
    /// @return {Real}
    static popFunction = function (argc) {
        __catspeak_assert(chunkTop >= 0,
            "unbalanced function stack! too many calls to `popFunction`"
        );
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, 0); // end of instructions
        buffer_write(chunk, buffer_u16, argc);
        var idx = funcCount;
        funcCount += 1;
        chunkTop -= 1;
        // revert to previous state
        var prevChunkStates_ = prevChunkStates;
        varCount = ds_stack_pop(prevChunkStates_);
        stackSize = ds_stack_pop(prevChunkStates_);
        return idx;
    };

    /// Call a function expression.
    ///
    /// @param {Real} n
    ///   The number of arguments in this call.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitCall = function (n, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CALL);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u16, n);
        // <result> - callee - args
        stackSize += 1 - 1 - n;
    };

    /// Call a method expression.
    ///
    /// @param {Real} n
    ///   The number of arguments in this call.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitCallIndex = function (n, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CALL_I);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u16, n);
        // <result> - data - idx - args
        stackSize += 1 - 1 - 1 - n;
    };

    /// Construct an array.
    ///
    /// @param {Real} n
    ///   The size of this array literal.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitArray = function (n, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.ARR);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u16, n);
        // <result> - values
        stackSize += 1 - n;
    };

    /// Construct a struct literal.
    ///
    /// @param {Real} n
    ///   The size of this struct literal, must be a multiple of 2.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitStruct = function (n, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.OBJ);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u16, n);
        // <result> - values
        stackSize += 1 - n;
    };

    /// Loop infinitely.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitLoopInf = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LOOP_INF);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - body
        //stackSize += 1 - 1;
    };

    /// Loop whilst a condition is true.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitLoop = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LOOP);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - cond - body
        stackSize += 1 - 1 - 1;
    };

    /// Loop whilst a condition is true, evaluating an expression every iteration.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitLoopStep = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LOOP_S);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - cond - step - body
        stackSize += 1 - 1 - 1 - 1;
    };

    /// Perform a GML-style `with` loop over all instances of an object.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitLoopWith = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LOOP_W);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - cond - body
        stackSize += 1 - 1 - 1;
    };

    /// Jump to the end of a landing block.
    ///
    /// @param {Real} label
    ///   The label to unwind to.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitUnwind = function (label, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.UWND);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u32, label);
        // <result> - value
        //stackSize += 1 - 1;
    };

    /// Catch the result of an `unwind` instruction.
    ///
    /// @param {Real} label
    ///   The label of this expression.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitUnwindLanding = function (label, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.LAND);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u32, label);
        // <result> - body
        //stackSize += 1 - 1;
    };

    /// Throw a value as an exception.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitThrow = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.THRW);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - value
        //stackSize += 1 - 1;
    };

    /// Catch an exception.
    ///
    /// @param {Real} idx
    ///   The id of the local variable to assign the exception value to.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitCatch = function (idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CAT);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u32, idx);
        // <result> - eager - lazy
        stackSize += 1 - 1 - 1;
    };

    /// Get a value of the local variable with the given id.
    ///
    /// @param {Real} idx
    ///   The id of the local variable to get.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGetLocal = function (idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_L);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u32, idx);
        // <result>
        stackSize += 1;
    };

    /// Assign a value to the local variable with the given id.
    ///
    /// @param {Real} flavour
    ///   The flavour of assignment to use.
    ///
    /// @param {Real} idx
    ///   The id of the local variable to set.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSetLocal = function (flavour, idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SET_L);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u8, flavour);
        buffer_write(chunk, buffer_u32, idx);
        // <result> - value
        //stackSize += 1 - 1;
    };

    /// Get a value of the global variable with the given name.
    ///
    /// @param {String} name
    ///   The name of the global variable to get.
    ///
    /// @param {String} path
    ///   The path of the module to search for this global variable in.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGetGlobal = function (name, path, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_G);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_string, name);
        buffer_write(chunk, buffer_string, path);
        // <result>
        stackSize += 1;
    };

    /// Assign a value to the global variable with the given name.
    ///
    /// @param {Real} flavour
    ///   The flavour of assignment to use.
    ///
    /// @param {String} name
    ///   The name of the global variable to set.
    ///
    /// @param {String} path
    ///   The path of the module to search for this global variable in.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSetGlobal = function (flavour, name, path, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SET_G);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u8, flavour);
        buffer_write(chunk, buffer_string, name);
        buffer_write(chunk, buffer_string, path);
        // <result> - value
        //stackSize += 1 - 1;
    };

    /// Get a reference to the current 'self' scope.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSelf = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SELF);
        buffer_write(chunk, buffer_u32, dbg);
        // <result>
        stackSize += 1;
    };

    /// Get a reference to the current 'other' scope.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitOther = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.OTHR);
        buffer_write(chunk, buffer_u32, dbg);
        // <result>
        stackSize += 1;
    };

    /// Get a value from a collection at the given string index.
    ///
    /// @param {String} idx
    ///   The index of the collection.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGetIndexString = function (idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_IS);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_string, idx);
        // <result> - data
        //stackSize += 1 - 1;
    };

    /// Assign a value to a collection at the given index.
    ///
    /// @param {Real} flavour
    ///   The flavour of assignment to use.
    ///
    /// @param {String} idx
    ///   The index of the collection.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSetIndexString = function (flavour, idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SET_IS);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u8, flavour);
        buffer_write(chunk, buffer_string, idx);
        // <result> - data - value
        stackSize += 1 - 1 - 1;
    };

    /// Get a value from a collection at the given numeric index.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGetIndexNumber = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_IN);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - data
        //stackSize += 1 - 1;
    };

    /// Assign a value to a collection at the given numeric index.
    ///
    /// @param {Real} flavour
    ///   The flavour of assignment to use.
    ///
    /// @param {Real} idx
    ///   The index of the collection.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSetIndexNumber = function (flavour, idx, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SET_IN);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u8, flavour);
        buffer_write(chunk, buffer_f64, idx);
        // <result> - data - value
        stackSize += 1 - 1 - 1;
    };

    /// Get a value from a collection at the given index.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitGetIndex = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.GET_I);
        buffer_write(chunk, buffer_u32, dbg);
        // <result> - data - idx
        stackSize += 1 - 1 - 1;
    };

    /// Assign a value to a collection at the given index.
    ///
    /// @param {Real} flavour
    ///   The flavour of assignment to use.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitSetIndex = function (flavour, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.SET_I);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_u8, flavour);
        // <result> - data - idx - value
        stackSize += 1 - 1 - 1 - 1;
    };

    /// Evaluate n-many expressions, implicitly returning the final expression.
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
        // <result> - stmts
        stackSize += 1 - n;
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
        // <result>
        stackSize += 1;
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
        // <result> - condition - ifTrue - ifFalse
        stackSize += 1 - 1 - 1 - 1;
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
        // <result> - eager - lazy
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - eager - lazy
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - value - amount
        stackSize += 1 - 1 - 1;
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
        // <result> - value - amount
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - lhs - rhs
        stackSize += 1 - 1 - 1;
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
        // <result> - value
        //stackSize += 1 - 1;
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
        // <result> - value
        //stackSize += 1 - 1;
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
        // <result> - value
        //stackSize += 1 - 1;
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
        // <result> - value
        //stackSize += 1 - 1;
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
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CONST_N);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_f64, value);
        // <result>
        stackSize += 1;
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
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CONST_S);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_string, value);
        // <result>
        stackSize += 1;
    };

    /// Get the undefined constant.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitConstUndefined = function (dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CONST_U);
        buffer_write(chunk, buffer_u32, dbg);
        // <result>
        stackSize += 1;
    };

    /// Get the result of an imported module.
    ///
    /// @param {String} path
    ///   The path of the module to find.
    ///
    /// @param {Real} [dbg]
    ///   The approximate location of this instruction in the source code.
    ///   Defaults to `CATSPEAK_NOLOCATION`.
    static emitConstImport = function (path, dbg = CATSPEAK_NOLOCATION) {
        __catspeak_assert(chunkTop >= 0, "function stack empty");
        var chunk = chunks[| chunkTop];
        buffer_write(chunk, buffer_u8, __CatspeakInstr.CONST_M);
        buffer_write(chunk, buffer_u32, dbg);
        buffer_write(chunk, buffer_string, path);
        // <result>
        stackSize += 1;
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
/// @remark
///   Immediately reads and calls the handlers for the "data" section of the
///   given Catspeak cartridge.
///
/// @param {Id.Buffer} cart_
///   The buffer to read cartridge info from.
///
/// @param {Struct} visitor_
///   A struct containing methods for handling each of the following cases:
///
///   - `.handleMeta(name, author, version, versionMinor, patch, path, date)` (always invoked first)
///   - `.handleInclude(path, alias)` (always invoked second)
///   - `.handleFunc(idx, argc)`
///   - `.handleInstrCall(dbg, n)`
///   - `.handleInstrCallIndex(dbg, n)`
///   - `.handleInstrArray(dbg, n)`
///   - `.handleInstrStruct(dbg, n)`
///   - `.handleInstrLoopInf(dbg)`
///   - `.handleInstrLoop(dbg)`
///   - `.handleInstrLoopStep(dbg)`
///   - `.handleInstrLoopWith(dbg)`
///   - `.handleInstrUnwind(dbg, label)`
///   - `.handleInstrUnwindLanding(dbg, label)`
///   - `.handleInstrThrow(dbg)`
///   - `.handleInstrCatch(dbg, idx)`
///   - `.handleInstrGetLocal(dbg, idx)`
///   - `.handleInstrSetLocal(dbg, flavour, idx)`
///   - `.handleInstrGetGlobal(dbg, name, path)`
///   - `.handleInstrSetGlobal(dbg, flavour, name, path)`
///   - `.handleInstrSelf(dbg)`
///   - `.handleInstrOther(dbg)`
///   - `.handleInstrGetIndexString(dbg, idx)`
///   - `.handleInstrSetIndexString(dbg, flavour, idx)`
///   - `.handleInstrGetIndexNumber(dbg)`
///   - `.handleInstrSetIndexNumber(dbg, flavour, idx)`
///   - `.handleInstrGetIndex(dbg)`
///   - `.handleInstrSetIndex(dbg, flavour)`
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
///   - `.handleInstrConstImport(dbg, path)`
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
    // read includes
    for (var includeLimit = 1028; includeLimit >= 0; includeLimit -= 1) {
        var path = buffer_read(cart_, buffer_string);
        if (path == "") {
            break;
        }
        var alias = buffer_read(cart_, buffer_string);
        visitor_.handleInclude(path, alias);
        if (includeLimit < 1) {
            __catspeak_error("exceeded include limit of 1028");
        }
    }

    /// @ignore
    cart = cart_;
    /// @ignore
    visitor = visitor_;
    /// @ignore
    funcIdx = 0;
    /// @ignore
    instrIdx = 0;

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
        if (opcode == 0x00) {
            if (instrIdx == 0) {
                // end of program
                __catspeak_assert(funcIdx > 0,
                    "cartridge cannot contain 0 functions"
                );
                return false;
            } else {
                // end of function
                var argc = buffer_read(cart, buffer_u16);
                visitor.handleFunc(funcIdx, argc);
                funcIdx += 1;
                instrIdx = 0;
                return true;
            }
        }
        instrIdx += 1;
        __catspeak_assert(opcode >= 0 && opcode < __CatspeakInstr.__SIZE__,
            "invalid cartridge instruction: " + string(opcode)
        );
        var instrReader = __readerLookup[opcode];
        instrReader();
        return true;
    };

    /// @ignore
    static __readICall = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var n = buffer_read(cart_, buffer_u16);
        visitor.handleInstrCall(dbg, n);
    };

    /// @ignore
    static __readICallIndex = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var n = buffer_read(cart_, buffer_u16);
        visitor.handleInstrCallIndex(dbg, n);
    };

    /// @ignore
    static __readIArray = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var n = buffer_read(cart_, buffer_u16);
        visitor.handleInstrArray(dbg, n);
    };

    /// @ignore
    static __readIStruct = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var n = buffer_read(cart_, buffer_u16);
        visitor.handleInstrStruct(dbg, n);
    };

    /// @ignore
    static __readILoopInf = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrLoopInf(dbg);
    };

    /// @ignore
    static __readILoop = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrLoop(dbg);
    };

    /// @ignore
    static __readILoopStep = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrLoopStep(dbg);
    };

    /// @ignore
    static __readILoopWith = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrLoopWith(dbg);
    };

    /// @ignore
    static __readIUnwind = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var label = buffer_read(cart_, buffer_u32);
        visitor.handleInstrUnwind(dbg, label);
    };

    /// @ignore
    static __readIUnwindLanding = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var label = buffer_read(cart_, buffer_u32);
        visitor.handleInstrUnwindLanding(dbg, label);
    };

    /// @ignore
    static __readIThrow = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrThrow(dbg);
    };

    /// @ignore
    static __readICatch = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var idx = buffer_read(cart_, buffer_u32);
        visitor.handleInstrCatch(dbg, idx);
    };

    /// @ignore
    static __readIGetLocal = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var idx = buffer_read(cart_, buffer_u32);
        visitor.handleInstrGetLocal(dbg, idx);
    };

    /// @ignore
    static __readISetLocal = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var flavour = buffer_read(cart_, buffer_u8);
        var idx = buffer_read(cart_, buffer_u32);
        visitor.handleInstrSetLocal(dbg, flavour, idx);
    };

    /// @ignore
    static __readIGetGlobal = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var name = buffer_read(cart_, buffer_string);
        var path = buffer_read(cart_, buffer_string);
        visitor.handleInstrGetGlobal(dbg, name, path);
    };

    /// @ignore
    static __readISetGlobal = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var flavour = buffer_read(cart_, buffer_u8);
        var name = buffer_read(cart_, buffer_string);
        var path = buffer_read(cart_, buffer_string);
        visitor.handleInstrSetGlobal(dbg, flavour, name, path);
    };

    /// @ignore
    static __readISelf = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrSelf(dbg);
    };

    /// @ignore
    static __readIOther = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrOther(dbg);
    };

    /// @ignore
    static __readIGetIndexString = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var idx = buffer_read(cart_, buffer_string);
        visitor.handleInstrGetIndexString(dbg, idx);
    };

    /// @ignore
    static __readISetIndexString = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var flavour = buffer_read(cart_, buffer_u8);
        var idx = buffer_read(cart_, buffer_string);
        visitor.handleInstrSetIndexString(dbg, flavour, idx);
    };

    /// @ignore
    static __readIGetIndexNumber = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrGetIndexNumber(dbg);
    };

    /// @ignore
    static __readISetIndexNumber = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var flavour = buffer_read(cart_, buffer_u8);
        var idx = buffer_read(cart_, buffer_f64);
        visitor.handleInstrSetIndexNumber(dbg, flavour, idx);
    };

    /// @ignore
    static __readIGetIndex = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        visitor.handleInstrGetIndex(dbg);
    };

    /// @ignore
    static __readISetIndex = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var flavour = buffer_read(cart_, buffer_u8);
        visitor.handleInstrSetIndex(dbg, flavour);
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
    static __readIConstImport = function () {
        var cart_ = cart;
        var dbg = buffer_read(cart_, buffer_u32);
        var path = buffer_read(cart_, buffer_string);
        visitor.handleInstrConstImport(dbg, path);
    };

    /// @ignore
    static __readerLookup = undefined;
    if (__readerLookup == undefined) {
        __readerLookup = array_create(__CatspeakInstr.__SIZE__, undefined);
        __readerLookup[@ __CatspeakInstr.CALL] = __readICall;
        __readerLookup[@ __CatspeakInstr.CALL_I] = __readICallIndex;
        __readerLookup[@ __CatspeakInstr.ARR] = __readIArray;
        __readerLookup[@ __CatspeakInstr.OBJ] = __readIStruct;
        __readerLookup[@ __CatspeakInstr.LOOP_INF] = __readILoopInf;
        __readerLookup[@ __CatspeakInstr.LOOP] = __readILoop;
        __readerLookup[@ __CatspeakInstr.LOOP_S] = __readILoopStep;
        __readerLookup[@ __CatspeakInstr.LOOP_W] = __readILoopWith;
        __readerLookup[@ __CatspeakInstr.UWND] = __readIUnwind;
        __readerLookup[@ __CatspeakInstr.LAND] = __readIUnwindLanding;
        __readerLookup[@ __CatspeakInstr.THRW] = __readIThrow;
        __readerLookup[@ __CatspeakInstr.CAT] = __readICatch;
        __readerLookup[@ __CatspeakInstr.GET_L] = __readIGetLocal;
        __readerLookup[@ __CatspeakInstr.SET_L] = __readISetLocal;
        __readerLookup[@ __CatspeakInstr.GET_G] = __readIGetGlobal;
        __readerLookup[@ __CatspeakInstr.SET_G] = __readISetGlobal;
        __readerLookup[@ __CatspeakInstr.SELF] = __readISelf;
        __readerLookup[@ __CatspeakInstr.OTHR] = __readIOther;
        __readerLookup[@ __CatspeakInstr.GET_IS] = __readIGetIndexString;
        __readerLookup[@ __CatspeakInstr.SET_IS] = __readISetIndexString;
        __readerLookup[@ __CatspeakInstr.GET_IN] = __readIGetIndexNumber;
        __readerLookup[@ __CatspeakInstr.SET_IN] = __readISetIndexNumber;
        __readerLookup[@ __CatspeakInstr.GET_I] = __readIGetIndex;
        __readerLookup[@ __CatspeakInstr.SET_I] = __readISetIndex;
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
        __readerLookup[@ __CatspeakInstr.CONST_N] = __readIConstNumber;
        __readerLookup[@ __CatspeakInstr.CONST_S] = __readIConstString;
        __readerLookup[@ __CatspeakInstr.CONST_U] = __readIConstUndefined;
        __readerLookup[@ __CatspeakInstr.CONST_M] = __readIConstImport;
    }
}

/// @ignore
enum __CatspeakInstr {
    CALL = 52,
    CALL_I = 53,
    ARR = 44,
    OBJ = 43,
    LOOP_INF = 38,
    LOOP = 39,
    LOOP_S = 40,
    LOOP_W = 41,
    UWND = 37,
    LAND = 36,
    THRW = 34,
    CAT = 42,
    GET_L = 4,
    SET_L = 29,
    GET_G = 47,
    SET_G = 54,
    SELF = 30,
    OTHR = 31,
    GET_IS = 48,
    SET_IS = 49,
    GET_IN = 50,
    SET_IN = 51,
    GET_I = 46,
    SET_I = 45,
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
    CONST_N = 1,
    CONST_S = 3,
    CONST_U = 35,
    CONST_M = 55,
    __SIZE__ = 56,
}