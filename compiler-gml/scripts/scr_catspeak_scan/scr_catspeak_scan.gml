//! Common language abstraction for implementing lexers. Exposes utility
//! scanners that keep track of lexeme offsets, line and column numbers,
//! and character look-ahead.
//!
//! @remark
//!   If you're not writing your own language front-end, then you can
//!   ignore this entire page!

//# feather use syntax-errors

/// A utility function that can be used to convert a string into a
/// Catspeak-compatible source buffer.
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

/// Traverses the UTF8 codepoints of a GML buffer.
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
    ///
    /// @return {Real}
    static __nextChar = function () {
        if (buffOffset >= buffSize) {
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

    /// Advances the scanner to the next UTF8 encoded char.
    ///
    /// Also updates line and column information, as well as the current lexeme
    /// span.
    static advanceChar = function () {
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
    };

    /// Clears the current lexeme span.
    static clearLexeme = function () {
        lexemeStart = lexemeEnd;
        lexemeStartPos = catspeak_location_create(line, column);
        lexeme = undefined;
    };

    /// @ignore
    ///
    /// @param {Real} start
    /// @param {Real} end_
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
    /// @return {String}
    static getLexeme = function () {
        lexeme ??= __slice(lexemeStart, lexemeEnd);
        return lexeme;
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