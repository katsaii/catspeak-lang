//! Common language abstractions for implementing new language front-ends.
//!
//! @remark
//!   If you're not writing your own language front-end, then you can
//!   ignore this entire page! If you don't know what that means, then you
//!   can also ignore this page!

/// 0b00000000000011111111111111111111
///
/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_LOCATION_LINE_MASK 0x000FFFFF

/// 0b11111111111100000000000000000000
///
/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_LOCATION_COLUMN_MASK 0xFFF00000

/// Indicates a lack of location in a source file.
///
/// @return {Real}
#macro CATSPEAK_NOLOCATION 0

/// When compiling programs, diagnostic information can be added into
/// the generated IR. This information (such as the line and column numbers
/// of an expression or statement) can be used by failing Catspeak programs
/// to offer clearer error messages.
///
/// Encodes the line and column numbers of a source location into a 32-bit
/// integer. The first 20 least-significant bits are reserved for the row
/// number, with the remaining 12 bits used for the (less important)
/// column number.
///
/// Because a lot of diagnostic information may be created for any given
/// Catspeak program, it is important that this information has zero memory
/// impact; hence, the line and column numbers are encoded into a 32-bit
/// integer--which can be created and discarded without allocating
/// memory--instead of as a struct.
///
/// **Mask layout**
/// ```txt
/// | 00000000000011111111111111111111 |
/// | <--column--><-------line-------> |
/// ```
///
/// @remark
///   Because of this, the maximum line number is 1,048,576 and the maximum
///   column number is 4,096. Any line/column counts beyond this will 
///   be truncated to `CATSPEAK_NOLOCATION`
///
/// @param {Real} line
///   The line number of the source location.
///
/// @param {Real} column
///   The column number of the source location. This is the number of
///   Unicode codepoints since the previous new-line character. As a result,
///   tabs are considered a single column, not 2, 4, 8, etc. columns.
///
/// @return {Real}
function catspeak_location_create(line, column) {
    gml_pragma("forceinline");
    __catspeak_assert_typeof(line, is_numeric, "invalid line number");
    __catspeak_assert_typeof(column, is_numeric, "invalid column number");
    if (line < 1 || line > __CATSPEAK_LOCATION_LINE_MASK) {
        return CATSPEAK_NOLOCATION;
    }
    if (column < 1 || column > (__CATSPEAK_LOCATION_COLUMN_MASK >> 20)) {
        return CATSPEAK_NOLOCATION;
    }
    return line | (column << 20);
}

/// Gets the line component of a Catspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the supplied
/// Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_line(location) {
    gml_pragma("forceinline");
    __catspeak_assert_typeof(location, is_numeric, "invalid location");
    return location & __CATSPEAK_LOCATION_LINE_MASK;
}

/// Gets the column component of a Catspeak source location. This is stored
/// as a 12-bit unsigned integer within the most significant bits of the
/// supplied Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_column(location) {
    gml_pragma("forceinline");
    __catspeak_assert_typeof(location, is_numeric, "invalid location");
    return (location & __CATSPEAK_LOCATION_COLUMN_MASK) >> 20;
}

/// Displays the line and column numbers this location represents. Optionally
/// takes a filepath to associate this location information with.
///
/// @example
///   With both `location` and `filepath` passed:
///   ```
///   in mods/example.meow at (line 3, column 6)
///   ```
///
///   With only `location` passed:
///   ```
///   in a file at (line 3, column 6)
///   ```
///
///   With only `filepath` passed:
///   ```
///   in mods/example.meow
///   ```
///
///   With neither argument passed:
///   ```
///   in a file
///   ```
///
/// @param {Real} [location]
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @param {String} [filepath]
///   A path to a file to associate this diagnostic information with. A file
///   at the given path does not need to exist.
///
/// @returns {String}
function catspeak_location_show(location = CATSPEAK_NOLOCATION, filepath = "") {
    var msg = "in ";
    if (filepath != "") {
        msg += string(filepath);
    } else {
        msg += "a Catspeak file";
    }
    if (location != CATSPEAK_NOLOCATION) {
        msg += " at (line " + string(catspeak_location_get_row(location));
        msg += ", column " + string(catspeak_location_get_column(location)) + ")";
    }
    return msg;
}

/// Adds this location and file information to a given error struct, if it
/// is one.
///
/// @param {Struct} err
///   The GML error struct to attach this location to the callstack for, can be
///   any struct with a `longMessage` field.
///
/// @param {Real} [location]
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @param {String} [filepath]
///   A path to a file to associate this diagnostic information with. A file
///   at the given path does not need to exist.
function catspeak_location_trace(err, location = CATSPEAK_NOLOCATION, filepath = "") {
    if (is_struct(err) && variable_struct_exists(err, "longMessage")) {
        if (!is_string(err.longMessage)) {
            err.longMessage = string(err.longMessage);
        }
        err.longMessage += " " + catspeak_location_show(location, filepath) + "\n";
    }
}

/// A utility function that can be used to convert a string into a
/// Catspeak-compatible source buffer.
///
/// @experimental
///
/// @param {String} src
///   The string to transform into a buffer.
///
/// @return {Id.Buffer}
function catspeak_buffer_create_from_string(src) {
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
    __catspeak_assert(__catspeak_is_buffer(buff_), "buffer doesn't exist");
    __catspeak_assert_eq(1, buffer_get_alignment(buff_),
        "requires a buffer with alignment 1"
    );
    __catspeak_assert_typeof(offset, is_numeric, "offset must be a number");
    __catspeak_assert_typeof(size, is_numeric, "size must be a number");

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
            //__catspeak_error_v3("invalid UTF8 header codepoint '", byte, "'");
            return -1;
        }
        // parse UTF8 continuations (2 bit header, followed by 6 bits of data)
        var dataWidth = 6;
        var utf8Value = (byte & ~headerMask) << (codepointCount * dataWidth);
        for (var i = codepointCount - 1; i >= 0; i -= 1) {
            byte = buffer_peek(buff, buffOffset, buffer_u8);
            buffOffset += 1;
            if ((byte & 0x80) == 0) { // if ((byte & 0b10000000) == 0) {
                //__catspeak_error_v3("invalid UTF8 continuation codepoint '", byte, "'");
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

/// @ignore
function __catspeak_assert(expect, message_ = undefined) {
    gml_pragma("forceinline");
    if (!expect) {
        __catspeak_error(message_ ?? "assertion failed");
    }
}

/// @ignore
function __catspeak_assert_eq(expect, got, message_ = undefined) {
    gml_pragma("forceinline");
    if (expect != got) {
        __catspeak_error(__catspeak_cat(
            message_ ?? "values are not equal!",
            " (expected ", __catspeak_repr(expect),
            ", got ", __catspeak_repr(got), ")"
        ));
    }
}

/// @ignore
function __catspeak_infer_type_from_predicate(p) {
    switch (p) {
        case is_string: return "string"; break;
        case is_real: return "real"; break;
        case is_numeric: return "numeric"; break;
        case is_bool: return "bool"; break;
        case is_array: return "array"; break;
        case is_struct:
        case __catspeak_is_withable:
            return "struct";
            break;
        case is_method:
        case __catspeak_is_callable:
            return "callable";
            break;
        case is_ptr: return "pointer"; break;
        case is_int32: return "int32"; break;
        case is_int64: return "int64"; break;
        case is_undefined: return "undefined"; break;
        case is_nan: return "NaN"; break;
        case is_infinity: return "infinity"; break;
        case buffer_exists:
        case __catspeak_is_buffer:
            return "buffer";
            break;
    }
    return script_get_name(p);
}

/// @ignore
function __catspeak_assert_typeof(value, predicate, message_ = undefined) {
    gml_pragma("forceinline");
    if (!predicate(value)) {
        __catspeak_error(__catspeak_cat(
            message_ ?? "invalid type",
            " (expected type of ", __catspeak_infer_type_from_predicate(predicate),
            ", got ",  __catspeak_repr(value), ")"
        ));
    }
}

/// @ignore
function __catspeak_assert_instanceof(value, constructor_, message_ = undefined) {
    gml_pragma("forceinline");
    if (!is_struct(value) || instanceof(value) != script_get_name(constructor_)) {
        __catspeak_error(__catspeak_cat(
            message_ ?? "invalid type",
            " (expected instance of ", script_get_name(constructor_),
            ", got ",  __catspeak_repr(value), ")"
        ));
    }
}

/// @ignore
function __catspeak_assert_typeof_optional(value, predicate, message_ = undefined) {
    gml_pragma("forceinline");
    if (value != undefined) {
        __catspeak_assert_typeof(value, predicate, message_);
    }
}

/// @ignore
function __catspeak_assert_get(collection, idx) {
    if (is_array(collection) || is_numeric(idx)) {
        __catspeak_assert_typeof(collection, is_array);
        __catspeak_assert_typeof(idx, is_numeric);
        var len = array_length(collection);
        if (idx < 0 || idx >= len) {
            __catspeak_error(__catspeak_cat(
                "array index out of bounds, must be >= 0 and < ",
                __catspeak_repr(len)
            ));
        }
        return collection[idx];
    } else if (__catspeak_is_withable(collection) || is_string(idx)) {
        __catspeak_assert_typeof(collection, __catspeak_is_withable);
        __catspeak_assert_typeof(idx, is_string);
        if (!variable_struct_exists(collection, idx)) {
            __catspeak_error(__catspeak_cat(
                "struct does not contain a key with the name '",
                __catspeak_repr(idx), "'"
            ));
        }
        return collection[$ idx];
    }
    __catspeak_error_bug();
}

/// @ignore
function __catspeak_error_message(message_ = undefined) {
    var msg = "Catspeak v" + CATSPEAK_VERSION;
    if (message_ != undefined) {
        msg += ": " + message_;
    }
    return msg;
}

/// @ignore
function __catspeak_error(message_ = undefined) {
    gml_pragma("forceinline");
    show_error(__catspeak_error_message(message_), false);
}

/// @ignore
function __catspeak_error_silent(message_ = undefined) {
    gml_pragma("forceinline");
    show_debug_message(__catspeak_error_message(message_));
}

/// @ignore
function __catspeak_error_unimplemented(feature) {
    gml_pragma("forceinline");
    __catspeak_error(__catspeak_cat(
        "the feature '", feature, "' has not been implemented yet"
    ));
}

/// @ignore
function __catspeak_error_bug() {
    gml_pragma("forceinline");
    __catspeak_error(__catspeak_cat(
        "you have likely encountered a compiler bug! ",
        "please get in contact and report this as an issue on the official ",
        "GitHub page: https://github.com/katsaii/catspeak-lang/issues"
    ));
}

/// @ignore
function __catspeak_cat() {
    var msg = "";
    for (var i = 0; i < argument_count; i += 1) {
        var arg_ = argument[i];
        msg += is_string(arg_) ? arg_ : string(arg_);
    }
    return msg;
}

/// @ignore
function __catspeak_repr(value) {
    if (is_numeric(value)) {
        return string(value);
    } else if (is_string(value) && string_length(value) < 16) {
        return value;
    } else {
        return typeof(value);
    }
}

/// @ignore
function __catspeak_is_withable(val) {
    if (is_struct(val) || val == self || val == other) {
        return true;
    }
    // for non-LTS versions
    //if (is_handle(val) && (object_exists(val) || instance_exists(val)) {
    //    return true;
    //}
    if (is_numeric(val)) {
        // LTS-specific checks for numeric ids
        if (val < 0) {
            return false; // prevent accessing special instances like -5 or -3
        }
        var isInst = false;
        try {
            //isInst = !object_exists(val) && instance_exists(val);
            isInst = object_exists(val) || instance_exists(val);
        } catch (_) { }
        return isInst;
    }
    var type_ = typeof(val);
    return type_ == "struct" || type_ == "ref" && (object_exists(val) || instance_exists(val));
}

/// @ignore
function __catspeak_is_callable(val) {
    gml_pragma("forceinline");
    if (is_method(val)) {
        return true;
    }
    var isScript = false;
    try {
        isScript = script_exists(val);
    } catch (_) { }
    return isScript;
}

/// @ignore
function __catspeak_is_nullish(val) {
    gml_pragma("forceinline");
    return val == undefined || val == pointer_null;
}

function __catspeak_is_buffer(val) {
    gml_pragma("forceinline");
    var isBuff = false;
    try {
        isBuff = buffer_exists(val);
    } catch (_) { }
    return isBuff;
}