//! Common language abstractions for implementing new language front-ends.
//!
//! @remark
//!   If you're not writing your own language front-end, then you can
//!   ignore this entire page! If you don't know what that means, then you
//!   can also ignore this page!

//# feather use syntax-errors

/// A utility function that can be used to convert a string into a
/// Catspeak-compatible source buffer.
///
/// @experimental
///
/// @param {String} src
///   The string to transform into a buffer.
///
/// @return {Id.Buffer}
function catspeak_util_buffer_create_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

/// Traverses the UTF8 codepoints of a GML buffer. Keeps track of lexemes,
/// line/column numbers, and a single character look-ahead.
///
/// @experimental
///
/// @warning
///   The scanner does not take ownership of its buffer, so you must make sure
///   to delete the buffer once the scanner is complete. Failure to do this will
///   result in leaking memory.
///
/// @param {Id.Buffer} buff_
///   The ID of the GML buffer to scan.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit
///   will be treated as the end of the file. Defaults to `infinity`.
function CatspeakUTF8Scanner(buff_, offset=0, size=infinity) constructor {
    __catspeak_assert(buffer_exists(buff_), "buffer doesn't exist");
    __catspeak_assert_eq(1, buffer_get_alignment(buff_),
        "requires a buffer with alignment 1"
    );
    __catspeak_assert(is_numeric(offset), "offset must be a number");
    __catspeak_assert(is_numeric(size), "size must be a number");
    /// @ignore
    buff = buff_;
    /// @ignore
    buffCapacity = buffer_get_size(buff_);
    /// @ignore
    buffOffset = clamp(offset, 0, buffCapacity);
    /// @ignore
    buffSize = clamp(offset + size, 0, buffCapacity);
    /// @ignore
    line = 1;
    /// @ignore
    column = 1;
    /// @ignore
    lexemeStart = buffOffset;
    /// @ignore
    lexemeEnd = lexemeStart;
    /// @ignore
    lexemeStartPos = catspeak_location_create(line, column);
    /// @ignore
    lexeme = undefined;
    /// Whether this scanner has reached the end of its input.
    ///
    /// @return {Bool}
    isEndOfFile = false;
    /// The current character in the buffer.
    ///
    /// @return {Real}
    charCurr = 0;
    /// The next character in the buffer. Null character may indicate the
    /// end of the scanner, or there may just be a null character in your
    /// source code. That's up to you to decide, have fun!
    ///
    /// @return {Real}
    charNext = __nextChar();

    /// @ignore
    static __nextChar = function () {
        var isEndOfFile_ = buffOffset >= buffSize || isEndOfFile;
        if (isEndOfFile_) {
            isEndOfFile = true;
            return 0;
        }
        var byte = buffer_peek(buff, buffOffset, buffer_u8);
        buffOffset += 1;
        if ((byte & 0x80) == 0) { // if ((byte & 0b10000000) == 0) {
            // ASCII digit
            return byte;
        }
        var codepointCount;
        var headerMask;
        // parse UTF8 header, could maybe hand-roll a binary search
        if ((byte & 0xFC) == 0xFC) { // if ((byte & 0b11111100) == 0b11111100) {
            codepointCount = 5;
            headerMask = 0xFC;
        } else if ((byte & 0xF8) == 0xF8) { // } else if ((byte & 0b11111000) == 0b11111000) {
            codepointCount = 4;
            headerMask = 0xF8;
        } else if ((byte & 0xF0) == 0xF0) { // } else if ((byte & 0b11110000) == 0b11110000) {
            codepointCount = 3;
            headerMask = 0xF0;
        } else if ((byte & 0xE0) == 0xE0) { // } else if ((byte & 0b11100000) == 0b11100000) {
            codepointCount = 2;
            headerMask = 0xE0;
        } else if ((byte & 0xC0) == 0xC0) { // } else if ((byte & 0b11000000) == 0b11000000) {
            codepointCount = 1;
            headerMask = 0xC0;
        } else {
            //__catspeak_error("invalid UTF8 header codepoint '", byte, "'");
            return -1;
        }
        // parse UTF8 continuations (2 bit header, followed by 6 bits of data)
        var dataWidth = 6;
        var utf8Value = (byte & ~headerMask) << (codepointCount * dataWidth);
        for (var i = codepointCount - 1; i >= 0; i -= 1) {
            byte = buffer_peek(buff, buffOffset, buffer_u8);
            buffOffset += 1;
            if ((byte & 0x80) == 0) { // if ((byte & 0b10000000) == 0) {
                //__catspeak_error("invalid UTF8 continuation codepoint '", byte, "'");
                return -1;
            }
            utf8Value |= (byte & ~0xC0) << (i * dataWidth); // utf8Value |= (byte & ~0b11000000) << (i * dataWidth);
        }
        return utf8Value;
    };

    /// Advances the scanner to the next UTF8 encoded char, returning the
    /// number of bytes since the start of the lexeme.
    ///
    /// Also updates line and column information, as well as the current lexeme
    /// span.
    ///
    /// @return {Real}
    static advanceChar = function () {
        lexeme = undefined;
        lexemeEnd = buffOffset;
        var charNext_ = charNext;
        if (charNext_ == ord("\r")) {
            column = 1;
            line += 1;
        } else if (charNext_ == ord("\n")) {
            column = 1;
            if (charCurr != ord("\r")) {
                line += 1;
            }
        } else {
            column += 1;
        }
        // actually update chars now
        charCurr = charNext_;
        charNext = __nextChar();
        return lexemeEnd - lexemeStart;
    };

    /// Clears the current lexeme span.
    static clearLexeme = function () {
        lexemeStart = lexemeEnd;
        lexemeStartPos = catspeak_location_create(line, column);
        lexeme = undefined;
    };

    /// @ignore
    static __slice = function (start, end_) {
        var buff_ = buff;
        // don't read outside bounds of `buffSize`
        var clipStart = min(start, buffSize);
        var clipEnd = min(end_, buffSize);
        if (clipEnd <= clipStart) {
            // always an empty slice
            __catspeak_assert(clipEnd == clipStart, "inside-out scanner span");
            return "";
        } else if (clipEnd >= buffCapacity) {
            // beyond the actual capacity of the buffer
            // not safe to use `buffer_string`, which expects a null char
            return buffer_peek(buff_, clipStart, buffer_text);
        } else {
            // quickly write a null terminator and then read the content
            var byte = buffer_peek(buff_, clipEnd, buffer_u8);
            buffer_poke(buff_, clipEnd, buffer_u8, 0x00);
            var result = buffer_peek(buff_, clipStart, buffer_string);
            buffer_poke(buff_, clipEnd, buffer_u8, byte);
            return result;
        }
    };

    /// Returns the string representation of the current scanned span.
    ///
    /// @example
    ///   Prints the string content of the first 5 characters parsed by
    ///   a scanner.
    ///
    ///   ```gml
    ///   repeat (5) {
    ///     scanner.advanceChar();
    ///   }
    ///   show_debug_message(scanner.getLexeme());
    ///   ```
    ///
    /// @warning
    ///   Passing incorrect values for `trimStart` and `trimEnd` may cause
    ///   incorrect string rendering if the trimmed bytes made up the start
    ///   or end of a unicode codepoint. Take care when using this function,
    ///   and only trim characters you are certain are ASCII.
    ///
    /// @param {Real} [trimStart]
    ///   The number of bytes to trim from the left-hand-side of the lexeme.
    ///
    /// @param {Real} [trimEnd]
    ///   The number of bytes to trim from the right-hand-side of the lexeme.
    ///
    /// @return {String}
    static getLexeme = function (trimStart = 0, trimEnd = 0) {
        if (trimStart == 0 && trimEnd == 0) {
            lexeme ??= __slice(lexemeStart, lexemeEnd);
            return lexeme;
        } else {
            return __slice(lexemeStart + trimStart, lexemeEnd - trimEnd);
        }
    };

    /// Returns the location information of the current scanned span.
    ///
    /// @return {Real}
    static getLocation = function () {
        return catspeak_location_create(line, column);
    };

    /// Returns the start location information of the current scanned span.
    ///
    /// @return {Real}
    static getLocationStart = function () {
        return lexemeStartPos;
    };
}

/// TODO
///
/// @param {Struct.CatspeakCartWriter} cart_
///   The cartridge to modify.
function CatspeakScopeStack(cart_) constructor {
    __catspeak_assert_eq(instanceof(cart_), "CatspeakCartWriter", "invalid cartridge");
    /// @ignore
    cart = cart_;
    /// @ignore
    funcTop = -1;
    /// @ignore
    funcs = array_create(8);
    /// @ignore
    func = undefined;
    /// @ignore
    block = undefined;
    array_resize(funcs, 0);
    beginFunction();

    /// Begins a new function scope.
    static beginFunction = function () {
        var func_;
        funcTop += 1;
        if (funcTop >= array_length(funcs)) {
            func_ = {
                localCount : 0,
                localTop : 0,
                blockTop : -1,
                blocks : array_create(8),
            };
            array_resize(func_.blocks, 0);
            funcs[@ funcTop] = func_;
        } else {
            func_ = funcs[funcTop];
            func_.localCount = 0;
            func_.localTop = 0;
            func_.blockTop = -1;
        }
        func = func_;
        beginBlock();
    };

    /// Ends the current function scope, writing its instruction to the supplied
    /// cartridge.
    static endFunction = function () {
        __catspeak_assert(funcTop > 0.1, "function stack underflow");
        __endBlock(false);
        cart.emitClosure(func.localCount);
        funcTop -= 1;
        func = funcs[funcTop];
        block = func.blocks[func.blockTop];
    };

    /// Begins a new block scope.
    static beginBlock = function () {
        var func_ = func;
        func_.blockTop += 1;
        var block_;
        if (func_.blockTop >= array_length(func_.blocks)) {
            block_ = {
                localCount : 0,
                locals : undefined,
                stmtCount : 0,
            };
            func_.blocks[@ func_.blockTop] = block_;
        } else {
            block_ = func_.blocks[func_.blockTop];
            block_.localCount = 0;
            block_.locals = undefined;
        }
        block = block_;
    };

    /// Prepares a new statement to be written to the current block.
    static prepareStatement = function () {
        block.stmtCount += 1;
    };

    /// @ignore
    static __endBlock = function (assert = true) {
        var block_ = block;
        var func_ = func;
        if (assert) {
            __catspeak_assert(func_.blockTop > 0.1, "block stack underflow");
        }
        func_.localTop -= block.localCount;
        func_.blockTop -= 1;
        if (assert) {
            block = func_.blocks[func_.blockTop];
        }
        cart.emitBlock(block.stmtCount);
    };

    /// Ends the current block scope, writing its instruction to the supplied
    /// cartridge.
    static endBlock = function () {
        __endBlock();
    };

    /// Allocate space for a new local variable, returning `true` if the local
    /// variable was allocataed, or `false` if a local variable with that name
    /// already exists in the current block.
    ///
    /// @param {String} name
    ///   The name of the local variable to define in this block.
    ///
    /// @returns {Bool}
    static allocLocal = function (name) {
        var block_ = block;
        block_.locals ??= { };
        if (variable_struct_exists(block_.locals, name)) {
            return false;
        }
        var func_ = func;
        block_.locals[$ name] = func_.localTop;
        block_.localCount += 1;
        func_.localCount += 1;
        func_.localTop += 1;
        return true;
    };

    /// Emit an instruction to get a variable with a given name.
    ///
    /// @param {String} name
    ///   The name of the variable to search for.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitGet = function (name, dbg = CATSPEAK_NOLOCATION) {
        var func_ = func;
        for (var iBlock = func_.blockTop; iBlock >= 0; iBlock -= 1) {
            // find local variables
            var block_ = func_.blocks[iBlock];
            if (block_.locals == undefined) {
                continue;
            }
            var localVarIdx = block_.locals[$ name];
            if (localVarIdx != undefined) {
                cart.emitGetLocal(localVarIdx, dbg);
                return;
            }
        }
        for (var iFunc = funcTop - 1; iFunc >= 1; iFunc -= 1) {
            var func_ = funcs[iFunc];
            for (var iBlock = func_.blockTop; iBlock >= 0; iBlock -= 1) {
                // find upvalues
                // TODO
            }
        }
        cart.emitGetGlobal(name, dbg);
    };

    /// Emit an instruction to assign a value to a variable with a
    /// given name.
    ///
    /// @param {String} name
    ///   The name of the variable to search for.
    ///
    /// @param {Real} [dbg]
    ///     The approximate location of the number in the source code.
    static emitSet = function (name, dbg = CATSPEAK_NOLOCATION) {
        var func_ = func;
        for (var iBlock = func_.blockTop; iBlock >= 0; iBlock -= 1) {
            // find local variables
            var block_ = func_.blocks[iBlock];
            var localVarIdx = block_.locals[$ name];
            if (localVarIdx != undefined) {
                cart.emitSetLocal(localVarIdx, dbg);
                return;
            }
        }
        for (var iFunc = funcTop - 1; iFunc >= 1; iFunc -= 1) {
            var func_ = funcs[iFunc];
            for (var iBlock = func_.blockTop; iBlock >= 0; iBlock -= 1) {
                // find upvalues
                // TODO
            }
        }
        cart.emitSetGlobal(name, dbg);
    };
}