//! Responsible for the lexical analysis stage of the Catspeak compiler.
//! This stage converts UTF8 encoded text from individual characters into
//! discrete clusters of characters called [tokens](https://en.wikipedia.org/wiki/Lexical_analysis#Lexical_token_and_lexical_tokenization).

//# feather use syntax-errors

/// A token in Catspeak is a series of characters with meaning, usually
/// separated by whitespace. These meanings are represented by unique
/// elements of the `CatspeakToken` enum.
///
/// @example
///   Some examples of tokens in Catspeak, and their meanings:
///   - `if`   (is a `CatspeakToken.IF`)
///   - `else` (is a `CatspeakToken.ELSE`)
///   - `12.3` (is a `CatspeakToken.VALUE`)
///   - `+`    (is a `CatspeakToken.PLUS`)
enum CatspeakToken {
    /// The `(` character.
    PAREN_LEFT = 0,
    /// The `)` character.
    PAREN_RIGHT = 1,
    /// The `[` character.
    BOX_LEFT = 2,
    /// The `]` character.
    BOX_RIGHT = 3,
    /// The `{` character.
    BRACE_LEFT = 4,
    /// The `}` character.
    BRACE_RIGHT = 5,
    /// The `:` character.
    COLON = 6,
    /// The `;` character.
    SEMICOLON = 7,
    /// The `,` character.
    COMMA = 8,
    /// The `.` operator.
    DOT = 9,
    /// The `=>` operator.
    ARROW = 10,
    /// @ignore
    __OP_ASSIGN_BEGIN__ = 11,
    /// The `=` operator.
    ASSIGN = 12,
    /// The `*=` operator.
    ASSIGN_MULTIPLY = 13,
    /// The `/=` operator.
    ASSIGN_DIVIDE = 14,
    /// The `-=` operator.
    ASSIGN_SUBTRACT = 15,
    /// The `+=` operator.
    ASSIGN_PLUS = 16,
    /// @ignore
    __OP_BEGIN__ = 17,
    /// The remainder `%` operator.
    REMAINDER = 18,
    /// The `*` operator.
    MULTIPLY = 19,
    /// The `/` operator.
    DIVIDE = 20,
    /// The integer division `//` operator.
    DIVIDE_INT = 21,
    /// The `-` operator.
    SUBTRACT = 22,
    /// The `+` operator.
    PLUS = 23,
    /// The relational `==` operator.
    EQUAL = 24,
    /// The relational `!=` operator.
    NOT_EQUAL = 25,
    /// The relational `>` operator.
    GREATER = 26,
    /// The relational `>=` operator.
    GREATER_EQUAL = 27,
    /// The relational `<` operator.
    LESS = 28,
    /// The relational `<=` operator.
    LESS_EQUAL = 29,
    /// The logical negation `!` operator.
    NOT = 30,
    /// The bitwise negation `~` operator.
    BITWISE_NOT = 31,
    /// The bitwise right shift `>>` operator.
    SHIFT_RIGHT = 32,
    /// The bitwise left shift `<<` operator.
    SHIFT_LEFT = 33,
    /// The bitwise and `&` operator.
    BITWISE_AND = 34,
    /// The bitwise xor `^` operator.
    BITWISE_XOR = 35,
    /// The bitwise or `|` operator.
    BITWISE_OR = 36,
    /// The logical `and` operator.
    AND = 37,
    /// The logical `or` operator.
    OR = 38,
    /// The logical `xor` operator.
    XOR = 39,
    /// The functional pipe right `|>` operator.
    PIPE_RIGHT = 40,
    /// The functional pipe left `<|` operator.
    PIPE_LEFT = 41,
    /// The `do` keyword.
    DO = 42,
    /// The `if` keyword.
    IF = 43,
    /// The `else` keyword.
    ELSE = 44,
    /// The `catch` keyword.
    CATCH = 66,
    /// The `while` keyword.
    WHILE = 45,
    /// The `for` keyword.
    ///
    /// @experimental
    FOR = 46,
    /// The `loop` keyword.
    ///
    /// @experimental
    LOOP = 47,
    /// The `with` keyword.
    ///
    /// @experimental
    WITH = 48,
    /// The `match` keyword.
    ///
    /// @experimental
    MATCH = 49,
    /// The `let` keyword.
    LET = 50,
    /// The `fun` keyword.
    FUN = 51,
    /// The `break` keyword.
    BREAK = 52,
    /// The `continue` keyword.
    CONTINUE = 53,
    /// The `return` keyword.
    RETURN = 54,
    /// The `throw` keyword.
    THROW = 67,
    /// The `new` keyword.
    NEW = 55,
    /// The `impl` keyword.
    ///
    /// @experimental
    IMPL = 56,
    /// The `self` keyword.
    ///
    /// @experimental
    SELF = 57,
    /// The `params` keyword.
    ///
    /// @experimental
    PARAMS = 58,
    /// The `params_count` keyword.
    ///
    /// @experimental
    PARAMS_COUNT = 65,
    /// Represents a variable name.
    IDENT = 59,
    /// Represents a GML value. This could be one of:
    ///  - string literal:    `"hello world"`
    ///  - verbatim literal:  `@"\(0_0)/ no escapes!"`
    ///  - integer:           `1`, `2`, `5`
    ///  - float:             `1.25`, `0.5`
    ///  - character:         `'A'`, `'0'`, `'\n'`
    ///  - boolean:           `true` or `false`
    ///  - `undefined`
    VALUE = 60,
    /// Represents a sequence of non-breaking whitespace characters.
    WHITESPACE = 61,
    /// Represents a comment.
    COMMENT = 62,
    /// Represents the end of the file.
    EOF = 63,
    /// Represents any other unrecognised character.
    ///
    /// @remark
    ///   If the compiler encounters a token of this type, it will typically
    ///   raise an exception. This likely indicates that a Catspeak script has
    ///   a syntax error somewhere.
    OTHER = 64,
    /// @ignore
    __SIZE__ = 68,
}

/// @ignore
///
/// @param {Any} val
function __catspeak_is_token(val) {
    // the user can modify what keywords are, so just check
    // that they've used one of the enum types instead of a
    // random ass value
    return is_numeric(val) && (
        val >= 0 && val < CatspeakToken.__SIZE__
    );
}

/// @ignore
///
/// @param {String} src
/// @return {Id.Buffer}
function __catspeak_create_buffer_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

/// Responsible for tokenising the contents of a GML buffer. This can be used
/// for syntax highlighting in a programming game which uses Catspeak.
///
/// @warning
///   The lexer does not take ownership of its buffer, so you must make sure
///   to delete the buffer once the lexer is complete. Failure to do this will
///   result in leaking memory.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to use.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit
///   will be treated as the end of the file. Defaults to `infinity`.
///
/// @param {Struct} [keywords]
///   A struct whose keys map to the corresponding Catspeak tokens they
///   represent. Defaults to the vanilla set of Catspeak keywords.
function CatspeakLexer(
    buff, offset=0, size=infinity, keywords=undefined
) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
        __catspeak_check_arg("buff", buff, buffer_exists);
        __catspeak_check_arg("offset", offset, is_numeric);
        __catspeak_check_arg("size", size, is_numeric);
        if (keywords != undefined) {
            __catspeak_check_arg("keywords", keywords, is_struct);
        }
    }

    /// @ignore
    self.buff = buff;
    /// @ignore
    self.buffAlignment = buffer_get_alignment(buff);
    /// @ignore
    self.buffCapacity = buffer_get_size(buff);
    /// @ignore
    self.buffOffset = clamp(offset, 0, self.buffCapacity);
    /// @ignore
    self.buffSize = clamp(offset + size, 0, self.buffCapacity);
    /// @ignore
    self.row = 1;
    /// @ignore
    self.column = 1;
    /// @ignore
    self.lexemeStart = self.buffOffset;
    /// @ignore
    self.lexemeEnd = self.lexemeStart;
    /// @ignore
    self.lexemePos = catspeak_location_create(self.row, self.column);
    /// @ignore
    self.lexeme = undefined;
    /// @ignore
    self.value = undefined;
    /// @ignore
    self.hasValue = false;
    /// @ignore
    self.peeked = undefined;
    /// @ignore
    self.charCurr = 0;
    /// @ignore
    //# feather disable once GM2043
    self.charNext = __nextUTF8Char();
    /// @ignore
    self.keywords = keywords ?? global.__catspeakString2Token;

    /// @ignore
    ///
    /// @return {Real}
    static __nextUTF8Char = function () {
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

    /// @ignore
    static __advance = function () {
        lexemeEnd = buffOffset;
        if (charNext == ord("\r")) {
            column = 1;
            row += 1;
        } else if (charNext == ord("\n")) {
            column = 1;
            if (charCurr != ord("\r")) {
                row += 1;
            }
        } else {
            column += 1;
        }
        // actually update chars now
        charCurr = charNext;
        charNext = __nextUTF8Char();
    };

    /// @ignore
    static __clearLexeme = function () {
        lexemeStart = lexemeEnd;
        lexemePos = catspeak_location_create(self.row, self.column);
        lexeme = undefined;
        hasValue = false;
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
            if (CATSPEAK_DEBUG_MODE && clipEnd < clipStart) {
                __catspeak_error_bug();
            }
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

    /// Returns the string representation of the most recent token emitted by
    /// the `next` or `nextWithWhitespace` methods.
    ///
    /// @example
    ///   Prints the string content of the first `CatspeakToken` emitted by a
    ///   lexer.
    ///
    ///   ```gml
    ///   lexer.next();
    ///   show_debug_message(lexer.getLexeme());
    ///   ```
    ///
    /// @return {String}
    static getLexeme = function () {
        lexeme ??= __slice(lexemeStart, lexemeEnd);
        return lexeme;
    };

    /// @ignore
    ///
    /// @param {String} str
    static __getKeyword = function (str) {
        var keyword = keywords[$ str];
        if (CATSPEAK_DEBUG_MODE && keyword != undefined) {
            __catspeak_check_arg(
                    "keyword", keyword, __catspeak_is_token, "CatspeakToken");
        }
        return keyword;
    };

    /// Returns the actual value representation of the most recent token
    /// emitted by the `next` or `nextWithWhitespace` methods.
    ///
    /// @remark
    ///   Unlike `getLexeme` this value is not always a string. For numeric
    ///   literals, the value will be converted into an integer or real.
    ///
    /// @return {Any}
    static getValue = function () {
        if (hasValue) {
            return value;
        }
        value = getLexeme();
        hasValue = true;
        return value;
    };

    /// Returns the location information for the most recent token emitted by
    /// the `next` or `nextWithWhitespace` methods.
    ///
    /// @return {Real}
    static getLocation = function () {
        return catspeak_location_create(row, column);
    };

    /// Advances the lexer and returns the next type of `CatspeakToken`. This
    /// includes additional whitespace and comment tokens.
    ///
    /// @remark
    ///   To get the string content of the token, you should use the
    ///   `getLexeme` method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each non-whitespace token out as a debug message.
    ///
    ///   ```gml
    ///   var lexer = new CatspeakLexer(buff);
    ///   do {
    ///     var token = lexer.nextWithWhitespace();
    ///     if (token != CatspeakToken.WHITESPACE) {
    ///       show_debug_message(lexer.getLexeme());
    ///     }
    ///   } until (token == CatspeakToken.EOF);
    ///   ```
    ///
    /// @return {Enum.CatspeakToken}
    static nextWithWhitespace = function () {
        __clearLexeme();
        if (charNext == 0) {
            return CatspeakToken.EOF;
        }
        __advance();
        var token = CatspeakToken.OTHER;
        var charCurr_ = charCurr; // micro-optimisation, locals are faster
        if (charCurr_ >= 0 && charCurr_ < __CATSPEAK_CODEPAGE_SIZE) {
            token = global.__catspeakChar2Token[charCurr_];
        }
        if (
            charCurr_ == ord("\"") ||
            charCurr_ == ord("@") && charNext == ord("\"")
        ) {
            // strings
            var isRaw = charCurr_ == ord("@");
            if (isRaw) {
                token = CatspeakToken.VALUE; // since `@` is an operator
                __advance();
            }
            var skipNextChar = false;
            var processEscapes = false;
            while (true) {
                var charNext_ = charNext;
                if (charNext_ == 0) {
                    break;
                }
                if (skipNextChar) {
                    __advance();
                    skipNextChar = false;
                    continue;
                }
                if (!isRaw && charNext == ord("\\")) {
                    skipNextChar = true;
                    processEscapes = true;
                } else if (charNext_ == ord("\"")) {
                    break;
                }
                __advance();
            }
            var value_ = __slice(lexemeStart + (isRaw ? 2 : 1), lexemeEnd);
            if (charNext == ord("\"")) {
                __advance();
            }
            if (processEscapes) {
                // TODO :: may be very slow, figure out how to do it faster
                value_ = string_replace_all(value_, "\\\"", "\"");
                value_ = string_replace_all(value_, "\\t", "\t");
                value_ = string_replace_all(value_, "\\n", "\n");
                value_ = string_replace_all(value_, "\\v", "\v");
                value_ = string_replace_all(value_, "\\f", "\f");
                value_ = string_replace_all(value_, "\\r", "\r");
                value_ = string_replace_all(value_, "\\\\", "\\");
            }
            value = value_;
            hasValue = true;
        } else if (__catspeak_char_is_operator(charCurr_)) {
            // operators
            switch (charCurr) {
            case ord(";"): token = CatspeakToken.SEMICOLON; break;
            case ord(":"): token = CatspeakToken.COLON; break;
            case ord(","): token = CatspeakToken.COMMA; break;
            case ord("."): token = CatspeakToken.DOT; break;
            case ord("="):
                if (charNext == ord("=")) { // ==
                    __advance();
                    token = CatspeakToken.EQUAL;
                } else { // =
                    token = CatspeakToken.ASSIGN;
                }
                break;
            case ord("*"):
                if (charNext == ord("=")) { // *=
                    __advance();
                    token = CatspeakToken.ASSIGN_MULTIPLY;
                } else { // *
                    token = CatspeakToken.MULTIPLY;
                }
                break;
            case ord("/"):
                if (charNext == ord("=")) { // /=
                    __advance();
                    token = CatspeakToken.ASSIGN_DIVIDE;
                } else if (charNext == ord("/")) { // //
                    __advance();
                    token = CatspeakToken.DIVIDE_INT;
                } else { // /
                    token = CatspeakToken.DIVIDE;
                }
                break;
            case ord("%"): token = CatspeakToken.REMAINDER; break;
            case ord("+"):
                if (charNext == ord("=")) { // +=
                    __advance();
                    token = CatspeakToken.ASSIGN_PLUS;
                } else { // +
                    token = CatspeakToken.PLUS;
                }
                break;
            case ord("-"):
                if (charNext == ord("=")) { // -=
                    __advance();
                    token = CatspeakToken.ASSIGN_SUBTRACT;
                } else if (charNext == ord("-")) { // --
                    __advance();
                    token = CatspeakToken.COMMENT;
                } else { // -
                    token = CatspeakToken.SUBTRACT;
                }
                break;
            case ord("!"):
                if (charNext == ord("=")) { // !=
                    __advance();
                    token = CatspeakToken.NOT_EQUAL;
                } else { // !
                    token = CatspeakToken.NOT;
                }
                break;
            case ord(">"):
                if (charNext == ord("=")) { // >=
                    __advance();
                    token = CatspeakToken.GREATER_EQUAL;
                } else if (charNext == ord(">")) { // >>
                    __advance();
                    token = CatspeakToken.SHIFT_RIGHT;
                } else { // >
                    token = CatspeakToken.GREATER;
                }
                break;
            case ord("<"):
                if (charNext == ord("=")) { // <=
                    __advance();
                    token = CatspeakToken.LESS_EQUAL;
                } else if (charNext == ord("|")) { // <|
                    __advance();
                    token = CatspeakToken.PIPE_LEFT;
                } else if (charNext == ord("<")) { // <<
                    __advance();
                    token = CatspeakToken.SHIFT_LEFT;
                } else { // >
                    token = CatspeakToken.LESS;
                }
                break;
            case ord("~"): token = CatspeakToken.BITWISE_NOT; break;
            case ord("&"): token = CatspeakToken.BITWISE_AND; break;
            case ord("^"): token = CatspeakToken.BITWISE_XOR; break;
            case ord("|"):
                if (charNext == ord(">")) { // |>
                    __advance();
                    token = CatspeakToken.PIPE_RIGHT;
                } else { // |
                    token = CatspeakToken.BITWISE_OR;
                }
                break;
            }
            // comment
            if (token == CatspeakToken.COMMENT) {
                // consume the comment
                lexeme = undefined; // since the lexeme is now invalid
                                    // we have more work to do
                while (true) {
                    var charNext_ = charNext;
                    if (
                        charNext_ == ord("\n") ||
                        charNext_ == ord("\r") ||
                        charNext_ == 0
                    ) {
                        break;
                    }
                    __advance();
                }
            }
        } else if (charCurr_ == ord("`")) {
            // literal identifiers
            while (true) {
                var charNext_ = charNext;
                if (
                    charNext_ == ord("`") || charNext_ == 0 ||
                    __catspeak_char_is_whitespace(charNext_)
                ) {
                    break;
                }
                __advance();
            }
            value = __slice(lexemeStart + 1, lexemeEnd);
            hasValue = true;
            if (charNext == ord("`")) {
                __advance();
            }
        } else if (token == CatspeakToken.IDENT) {
            // alphanumeric identifiers
            while (__catspeak_char_is_alphanumeric(charNext)) {
                __advance();
            }
            var lexeme_ = getLexeme();
            var keyword = __getKeyword(lexeme_);
            // TODO :: optimise this into a lookup table?
            if (keyword != undefined) {
                token = keyword;
            } else if (lexeme_ == "true") {
                token = CatspeakToken.VALUE;
                value = true;
                hasValue = true;
            } else if (lexeme_ == "false") {
                token = CatspeakToken.VALUE;
                value = false;
                hasValue = true;
            } else if (lexeme_ == "undefined") {
                token = CatspeakToken.VALUE;
                value = undefined;
                hasValue = true;
            } else if (lexeme_ == "NaN") {
                token = CatspeakToken.VALUE;
                value = NaN;
                hasValue = true;
            } else if (lexeme_ == "infinity") {
                token = CatspeakToken.VALUE;
                value = infinity;
                hasValue = true;
            }
        } else if (charCurr_ == ord("'")) {
            // character literals
            __advance();
            value = charCurr;
            hasValue = true;
            if (charNext == ord("'")) {
                __advance();
            }
        } else if (
            charCurr_ == ord("0") &&
            (charNext == ord("x") || charNext == ord("X"))
        ) {
            // hexadecimal literals
            __advance();
            var digitStack = ds_stack_create();
            while (true) {
                var charNext_ = charNext;
                if (__catspeak_char_is_digit_hex(charNext_)) {
                    ds_stack_push(digitStack,
                            __catspeak_char_hex_to_dec(charNext_));
                    __advance();
                } else if (charNext_ == ord("_")) {
                    __advance();
                } else {
                    break;
                }
            }
            value = 0;
            var pow = 0;
            while (!ds_stack_empty(digitStack)) {
                value += power(16, pow) * ds_stack_pop(digitStack);
                pow += 1;
            }
            ds_stack_destroy(digitStack);
            hasValue = true;
        } else if (
            charCurr_ == ord("0") &&
            (charNext == ord("b") || charNext == ord("B"))
        ) {
            // TODO :: avoid code duplication here
            // binary literals
            __advance();
            var digitStack = ds_stack_create();
            while (true) {
                var charNext_ = charNext;
                if (__catspeak_char_is_digit_binary(charNext_)) {
                    ds_stack_push(digitStack,
                            __catspeak_char_binary_to_dec(charNext_));
                    __advance();
                } else if (charNext_ == ord("_")) {
                    __advance();
                } else {
                    break;
                }
            }
            value = 0;
            var pow = 0;
            while (!ds_stack_empty(digitStack)) {
                value += power(2, pow) * ds_stack_pop(digitStack);
                pow += 1;
            }
            ds_stack_destroy(digitStack);
            hasValue = true;
        } else if (charCurr_ == ord("#")) {
            // colour literals
            token = CatspeakToken.VALUE;
            var digitStack = ds_stack_create();
            while (true) {
                var charNext_ = charNext;
                if (__catspeak_char_is_digit_hex(charNext_)) {
                    ds_stack_push(digitStack,
                            __catspeak_char_hex_to_dec(charNext_));
                    __advance();
                } else if (charNext_ == ord("_")) {
                    __advance();
                } else {
                    break;
                }
            }
            var digitCount = ds_stack_size(digitStack);
            var cR = 0;
            var cG = 0;
            var cB = 0;
            var cA = 0;
            if (digitCount == 3) {
                // #RGB
                cB = ds_stack_pop(digitStack);
                cB = cB | (cB << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (cG << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (cR << 4);
            } else if (digitCount == 4) {
                // #RGBA
                cA = ds_stack_pop(digitStack);
                cA = cA | (cA << 4);
                cB = ds_stack_pop(digitStack);
                cB = cB | (cB << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (cG << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (cR << 4);
            } else if (digitCount == 6) {
                // #RRGGBB
                cB = ds_stack_pop(digitStack);
                cB = cB | (ds_stack_pop(digitStack) << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (ds_stack_pop(digitStack) << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (ds_stack_pop(digitStack) << 4);
            } else if (digitCount == 8) {
                // #RRGGBBAA
                cA = ds_stack_pop(digitStack);
                cA = cA | (ds_stack_pop(digitStack) << 4);
                cB = ds_stack_pop(digitStack);
                cB = cB | (ds_stack_pop(digitStack) << 4);
                cG = ds_stack_pop(digitStack);
                cG = cG | (ds_stack_pop(digitStack) << 4);
                cR = ds_stack_pop(digitStack);
                cR = cR | (ds_stack_pop(digitStack) << 4);
            } else {
                // invalid
                token = CatspeakToken.OTHER;
            }
            ds_stack_destroy(digitStack);
            value = cR | (cG << 8) | (cB << 16) | (cA << 24);
            hasValue = true;
        } else if (token == CatspeakToken.VALUE) {
            // numeric literals
            var hasUnderscores = false;
            var hasDecimal = false;
            while (true) {
                var charNext_ = charNext;
                if (__catspeak_char_is_digit(charNext_)) {
                    __advance();
                } else if (charNext_ == ord("_")) {
                    __advance();
                    hasUnderscores = true;
                } else if (!hasDecimal && charNext_ == ord(".")) {
                    __advance();
                    hasDecimal = true;
                } else {
                    break;
                }
            }
            var digits = getLexeme();
            if (hasUnderscores) {
                digits = string_replace_all(digits, "_", "");
            }
            value = real(digits);
            hasValue = true;
        }
        return token;
    };

    /// Advances the lexer and returns the next `CatspeakToken`, ignoring any
    /// comments, whitespace, and line continuations.
    ///
    /// @remark
    ///   To get the string content of the token, you should use the
    ///   `getLexeme` method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    ///   ```gml
    ///   var lexer = new CatspeakLexer(buff);
    ///   do {
    ///     var token = lexer.next();
    ///     show_debug_message(lexer.getLexeme());
    ///   } until (token == CatspeakToken.EOF);
    ///   ```
    ///
    /// @return {Enum.CatspeakToken}
    static next = function () {
        if (peeked != undefined) {
            var token = peeked;
            peeked = undefined;
            return token;
        }
        while (true) {
            var token = nextWithWhitespace();
            if (token == CatspeakToken.WHITESPACE
                    || token == CatspeakToken.COMMENT) {
                continue;
            }
            return token;
        }
    };

    /// Peeks at the next non-whitespace character without advancing the lexer.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    ///   ```gml
    ///   var lexer = new CatspeakLexer(buff);
    ///   while (lexer.peek() != CatspeakToken.EOF) {
    ///     lexer.next();
    ///     show_debug_message(lexer.getLexeme());
    ///   }
    ///   ```
    ///
    /// @return {Enum.CatspeakToken}
    static peek = function () {
        peeked ??= next();
        return peeked;
    };
}

/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_CODEPAGE_SIZE 256

/// @ignore
function __catspeak_init_lexer() {
    // initialise map from character to token type
    /// @ignore
    global.__catspeakChar2Token = __catspeak_init_lexer_codepage();
    /// @ignore
    global.__catspeakString2Token = __catspeak_init_lexer_keywords();
}

/// @ignore
function __catspeak_char_is_digit(char) {
    gml_pragma("forceinline");
    return char >= ord("0") && char <= ord("9");
}

/// @ignore
function __catspeak_char_is_digit_binary(char) {
    gml_pragma("forceinline");
    return char == ord("0") || char == ord("1");
}

/// @ignore
function __catspeak_char_binary_to_dec(char) {
    gml_pragma("forceinline");
    return char == ord("0") ? 0 : 1;
}

/// @ignore
function __catspeak_char_is_digit_hex(char) {
    gml_pragma("forceinline");
    return char >= ord("a") && char <= ord("f") ||
            char >= ord("A") && char <= ord("F") ||
            char >= ord("0") && char <= ord("9");
}

/// @ignore
function __catspeak_char_hex_to_dec(char) {
    if (char >= ord("0") && char <= ord("9")) {
        return char - ord("0");
    }
    if (char >= ord("a") && char <= ord("f")) {
        return char - ord("a") + 10;
    }
    return char - ord("A") + 10;
}

/// @ignore
function __catspeak_char_is_alphanumeric(char) {
    gml_pragma("forceinline");
    return char >= ord("a") && char <= ord("z") ||
            char >= ord("A") && char <= ord("Z") ||
            char >= ord("0") && char <= ord("9") ||
            char == ord("_");
}

/// @ignore
function __catspeak_char_is_operator(char) {
    gml_pragma("forceinline");
    return char >= ord("!") && char <= ord("&") && char != ord("\"") && char != ord("#") ||
            char >= ord("*") && char <= ord("/") && char != ord(",") ||
            char >= ord(":") && char <= ord("@") ||
            char == ord("\\") || char == ord("^") ||
            char == ord("|") || char == ord("~");
}

/// @ignore
function __catspeak_char_is_whitespace(char) {
    gml_pragma("forceinline");
    return char >= 0x09 && char <= 0x0D || char == 0x20 || char == 0x85;
}

/// @ignore
function __catspeak_codepage_value(code) {
    gml_pragma("forceinline");
    return is_string(code) ? ord(code) : code;
}

/// @ignore
function __catspeak_codepage_range(code, minCode, maxCode) {
    gml_pragma("forceinline");
    var codeVal = __catspeak_codepage_value(code);
    var minVal = __catspeak_codepage_value(minCode);
    var maxVal = __catspeak_codepage_value(maxCode);
    return codeVal >= minVal && codeVal <= maxVal;
}

/// @ignore
function __catspeak_codepage_set(code) {
    gml_pragma("forceinline");
    var codeVal = __catspeak_codepage_value(code);
    for (var i = 1; i < argument_count; i += 1) {
        if (codeVal == __catspeak_codepage_value(argument[i])) {
            return true;
        }
    }
    return false;
}

/// @ignore
function __catspeak_init_lexer_codepage() {
    var page = array_create(__CATSPEAK_CODEPAGE_SIZE, CatspeakToken.OTHER);
    for (var code = 0; code < __CATSPEAK_CODEPAGE_SIZE; code += 1) {
        var tokenType;
        if (__catspeak_codepage_set(code,
            0x09, // CHARACTER TABULATION ('\t')
            0x0A, // LINE FEED            ('\n')
            0x0B, // LINE TABULATION      ('\v')
            0x0C, // FORM FEED            ('\f')
            0x0D, // CARRIAGE RETURN      ('\r')
            0x20, // SPACE                (' ')
            0x85  // NEXT LINE
        )) {
            tokenType = CatspeakToken.WHITESPACE;
        } else if (
            __catspeak_codepage_range(code, "a", "z") ||
            __catspeak_codepage_range(code, "A", "Z") ||
            __catspeak_codepage_set(code, "_", "`") // identifier literals
        ) {
            tokenType = CatspeakToken.IDENT;
        } else if (
            __catspeak_codepage_range(code, "0", "9") ||
            __catspeak_codepage_set(code, "'") // character literals
        ) {
            tokenType = CatspeakToken.VALUE;
        } else if (__catspeak_codepage_set(code, "\"")) {
            tokenType = CatspeakToken.VALUE;
        } else if (__catspeak_codepage_set(code, "(")) {
            tokenType = CatspeakToken.PAREN_LEFT;
        } else if (__catspeak_codepage_set(code, ")")) {
            tokenType = CatspeakToken.PAREN_RIGHT;
        } else if (__catspeak_codepage_set(code, "[")) {
            tokenType = CatspeakToken.BOX_LEFT;
        } else if (__catspeak_codepage_set(code, "]")) {
            tokenType = CatspeakToken.BOX_RIGHT;
        } else if (__catspeak_codepage_set(code, "{")) {
            tokenType = CatspeakToken.BRACE_LEFT;
        } else if (__catspeak_codepage_set(code, "}")) {
            tokenType = CatspeakToken.BRACE_RIGHT;
        } else if (__catspeak_codepage_set(code, ",")) {
            tokenType = CatspeakToken.COMMA;
        } else {
            continue;
        }
        page[@ code] = tokenType;
    }
    return page;
}

/// @ignore
///
/// @return {Struct}
function __catspeak_keywords_create() {
    var keywords = { };
    keywords[$ "and"] = CatspeakToken.AND;
    keywords[$ "or"] = CatspeakToken.OR;
    keywords[$ "xor"] = CatspeakToken.XOR;
    keywords[$ "do"] = CatspeakToken.DO;
    keywords[$ "if"] = CatspeakToken.IF;
    keywords[$ "else"] = CatspeakToken.ELSE;
    keywords[$ "catch"] = CatspeakToken.CATCH;
    keywords[$ "while"] = CatspeakToken.WHILE;
    keywords[$ "for"] = CatspeakToken.FOR;
    keywords[$ "loop"] = CatspeakToken.LOOP;
    keywords[$ "with"] = CatspeakToken.WITH;
    keywords[$ "match"] = CatspeakToken.MATCH;
    keywords[$ "let"] = CatspeakToken.LET;
    keywords[$ "fun"] = CatspeakToken.FUN;
    keywords[$ "params"] = CatspeakToken.PARAMS;
    keywords[$ "break"] = CatspeakToken.BREAK;
    keywords[$ "continue"] = CatspeakToken.CONTINUE;
    keywords[$ "return"] = CatspeakToken.RETURN;
    keywords[$ "throw"] = CatspeakToken.THROW;
    keywords[$ "new"] = CatspeakToken.NEW;
    keywords[$ "impl"] = CatspeakToken.IMPL;
    keywords[$ "self"] = CatspeakToken.SELF;
    keywords[$ "other"] = CatspeakToken.OTHER;
    return keywords;
}

/// @ignore
///
/// @param {Struct} keywords
/// @param {String} currentName
/// @param {String} newName
function __catspeak_keywords_rename(keywords, currentName, newName) {
    if (!variable_struct_exists(keywords, currentName)) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_error_silent(
                "no keyword with the name '", currentName, "' exists"
            );
        }
        return;
    }
    var token = keywords[$ currentName];
    variable_struct_remove(keywords, currentName);
    keywords[$ newName] = token;
}

/// @ignore
///
/// @remark
///   This is an O(n) operation. This means that it's slow, and should only
///   be used for debugging purposes.
///
/// @param {Struct} keywords
/// @param {Enum.CatspeakToken} token
///
/// @return {String}
function __catspeak_keywords_find_name(keywords, token) {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg("keywords", keywords, is_struct);
        __catspeak_check_arg(
                "token", token, __catspeak_is_token, "CatspeakToken");
    }
    var variables = variable_struct_get_names(keywords);
    var variableCount = array_length(variables);
    for (var i = 0; i < variableCount; i += 1) {
        var variable = variables[i];
        if (keywords[$ variable] == token) {
            return variable;
        }
    }
    return undefined;
}

/// @ignore
function __catspeak_init_lexer_keywords() {
    var keywords = __catspeak_keywords_create();
    global.__catspeakConfig.keywords = keywords;
    return keywords;
}

//! Responsible for the syntax analysis stage of the Catspeak compiler.
//!
//! This stage uses `CatspeakIRBuilder` to create a hierarchical
//! representation of your Catspeak programs, called an abstract syntax graph
//! (or ASG for short). These graphs are encoded as a JSON object, making it
//! possible for you to cache the result of parsing a mod to a file, instead
//! of re-parsing each time the game loads.

//# feather use syntax-errors

/// Consumes tokens produced by a `CatspeakLexer`, transforming the program
/// they represent into Catspeak IR. This Catspeak IR can be further compiled
/// down into a callable GML function using `CatspeakGMLCompiler`.
///
/// @experimental
///
/// @param {Struct.CatspeakLexer} lexer
///   The lexer to consume tokens from.
///
/// @param {Struct.CatspeakIRBuilder} builder
///   The Catspeak IR builder to write the program to.
function CatspeakParser(lexer, builder) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_arg_struct_instanceof(
                "lexer", lexer, "CatspeakLexer");
        __catspeak_check_arg_struct_instanceof(
                "builder", builder, "CatspeakIRBuilder");
    }
    /// @ignore
    self.lexer = lexer;
    /// @ignore
    self.ir = builder;
    /// @ignore
    self.finalised = false;
    builder.pushFunction();

    /// Parses a top-level Catspeak statement from the supplied lexer, adding
    /// any relevant parse information to the supplied IR.
    ///
    /// @example
    ///   Creates a new `CatspeakParser` from the variables `lexer` and
    ///   `builder`, then loops until there is nothing left to parse.
    ///
    ///   ```gml
    ///   var parser = new CatspeakParser(lexer, builder);
    ///   var moreToParse;
    ///   do {
    ///       moreToParse = parser.update();
    ///   } until (!moreToParse);
    ///   ```
    ///
    /// @return {Bool}
    ///   `true` if there is still more data left to parse, and `false`
    ///   if the parser has reached the end of the file.
    static update = function () {
        if (lexer.peek() == CatspeakToken.EOF) {
            if (!finalised) {
                ir.popFunction();
                finalised = true;
            }
            return false;
        }
        if (CATSPEAK_DEBUG_MODE && finalised) {
            __catspeak_error(
                "attempting to update parser after it has been finalised"
            );
        }
        __parseStatement();
        return true;
    };

    /// @ignore
    static __parseStatement = function () {
        var result;
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.SEMICOLON) {
            lexer.next();
            return;
        } else if (peeked == CatspeakToken.LET) {
            lexer.next();
            if (lexer.next() != CatspeakToken.IDENT) {
                __ex("expected identifier after 'let' keyword");
            }
            var localName = lexer.getValue();
            var location = lexer.getLocation();
            var valueTerm;
            if (lexer.peek() == CatspeakToken.ASSIGN) {
                lexer.next();
                valueTerm = __parseExpression();
            } else {
                valueTerm = ir.createValue(undefined, location);
            }
            var getter = ir.allocLocal(localName, location);
            result = ir.createAssign(
                CatspeakAssign.VANILLA,
                getter,
                valueTerm,
                lexer.getLocation()
            );
        } else {
            result = __parseExpression();
        }
        ir.createStatement(result);
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseExpression = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.RETURN) {
            lexer.next();
            peeked = lexer.peek();
            var value;
            if (
                peeked == CatspeakToken.SEMICOLON ||
                peeked == CatspeakToken.BRACE_RIGHT ||
                peeked == CatspeakToken.LET
            ) {
                value = ir.createValue(undefined, lexer.getLocation());
            } else {
                value = __parseExpression();
            }
            return ir.createReturn(value, lexer.getLocation());
        } else if (peeked == CatspeakToken.CONTINUE) {
            lexer.next();
            return ir.createContinue(lexer.getLocation());
        } else if (peeked == CatspeakToken.BREAK) {
            lexer.next();
            peeked = lexer.peek();
            var value;
            if (
                peeked == CatspeakToken.SEMICOLON ||
                peeked == CatspeakToken.BRACE_RIGHT ||
                peeked == CatspeakToken.LET
            ) {
                value = ir.createValue(undefined, lexer.getLocation());
            } else {
                value = __parseExpression();
            }
            return ir.createBreak(value, lexer.getLocation());
        } else if (peeked == CatspeakToken.THROW) {
            lexer.next();
            peeked = lexer.peek();
            var value = __parseExpression();
            return ir.createThrow(value, lexer.getLocation());
        } else {
            return __parseAssign();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseAssign = function () {
        var lhs = __parseCatch();
        var peeked = lexer.peek();
        if (
            peeked == CatspeakToken.ASSIGN ||
            peeked == CatspeakToken.ASSIGN_MULTIPLY ||
            peeked == CatspeakToken.ASSIGN_DIVIDE ||
            peeked == CatspeakToken.ASSIGN_SUBTRACT ||
            peeked == CatspeakToken.ASSIGN_PLUS
        ) {
            lexer.next();
            var assignType = __catspeak_operator_assign_from_token(peeked);
            lhs = ir.createAssign(
                assignType,
                lhs,
                __parseExpression(),
                lexer.getLocation()
            );
        }
        return lhs;
    };
    
    /// @ignore
    ///
    /// @return {Struct}
    static __parseCatch = function () {
        var result = __parseExpressionBlock();
        while (true) {
            if (lexer.peek() == CatspeakToken.CATCH) {
                lexer.next();
                ir.pushBlock();
                var localRef = undefined;
                if (lexer.peek() == CatspeakToken.IDENT) {
                    lexer.next();
                    var localName = lexer.getValue();
                    localRef = ir.allocLocal(localName, lexer.getLocation());
                }
                __parseStatements("catch");
                var catchBlock_ = ir.popBlock();
                result = ir.createCatch(result, catchBlock_, localRef, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseExpressionBlock = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.DO) {
            lexer.next();
            ir.pushBlock(true);
            __parseStatements("do");
            return ir.popBlock();
        } else if (peeked == CatspeakToken.IF) {
            lexer.next();
            var condition = __parseCondition();
            ir.pushBlock();
            __parseStatements("if")
            var ifTrue = ir.popBlock();
            var ifFalse;
            if (lexer.peek() == CatspeakToken.ELSE) {
                lexer.next();
                ir.pushBlock();
                if (lexer.peek() == CatspeakToken.IF) {
                    // for `else if` support
                    var elseIf = __parseExpression();
                    ir.createStatement(elseIf);
                } else {
                    __parseStatements("else");
                }
                ifFalse = ir.popBlock();
            } else {
                ifFalse = ir.createValue(undefined, lexer.getLocation());
            }
            return ir.createIf(condition, ifTrue, ifFalse, lexer.getLocation());
        } else if (peeked == CatspeakToken.WHILE) {
            lexer.next();
            var condition = __parseCondition();
            ir.pushBlock();
            __parseStatements("while");
            var body = ir.popBlock();
            return ir.createWhile(condition, body, lexer.getLocation());
        } else if (peeked == CatspeakToken.WITH) {
            lexer.next();
            var scope = __parseCondition();
            ir.pushBlock();
            __parseStatements("with");
            var body = ir.popBlock();
            return ir.createWith(scope, body, lexer.getLocation());
        } else if (peeked == CatspeakToken.MATCH) {
            lexer.next();
            var value = __parseExpression();
            var conditions = __parseMatchArms();
            return ir.createMatch(value, conditions, lexer.getLocation());
        } else if (peeked == CatspeakToken.FUN) {
            lexer.next();
            ir.pushFunction();
            if (lexer.peek() != CatspeakToken.BRACE_LEFT) {
                if (lexer.next() != CatspeakToken.PAREN_LEFT) {
                    __ex("expected opening '(' after 'fun' keyword");
                }
                while (__isNot(CatspeakToken.PAREN_RIGHT)) {
                    if (lexer.next() != CatspeakToken.IDENT) {
                        __ex("expected identifier in function arguments");
                    }
                    ir.allocArg(lexer.getValue(), lexer.getLocation());
                    if (lexer.peek() == CatspeakToken.COMMA) {
                        lexer.next();
                    }
                }
                if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                    __ex("expected closing ')' after function arguments");
                }
            }
            __parseStatements("fun");
            return ir.popFunction();
        } else {
            return __parseCondition();
        }
    };

    /// @ignore
    ///
    /// @param {String} keyword
    /// @return {Struct}
    static __parseStatements = function (keyword) {
        if (lexer.next() != CatspeakToken.BRACE_LEFT) {
            __ex("expected opening '{' at the start of '", keyword, "' block");
        }
        while (__isNot(CatspeakToken.BRACE_RIGHT)) {
            __parseStatement();
        }
        if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
            __ex("expected closing '}' after '", keyword, "' block");
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseCondition = function () {
        return __parseOpLogicalOR();
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpLogicalOR = function () {
        var result = __parseOpLogicalAND();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.OR) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpLogicalAND();
                result = ir.createOr(lhs, rhs, lexer.getLocation());
            } else if (peeked == CatspeakToken.XOR) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpLogicalAND();
                result = ir.createBinary(CatspeakOperator.XOR, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpLogicalAND = function () {
        var result = __parseOpPipe();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.AND) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpPipe();
                result = ir.createAnd(lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpPipe = function () {
        var result = __parseOpEquality();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.PIPE_RIGHT) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpEquality();
                result = ir.createCall(rhs, [lhs], lexer.getLocation());
            } else if (peeked == CatspeakToken.PIPE_LEFT) {
                lexer.next();
                var lhs = result;
                var rhs = __parseOpEquality();
                result = ir.createCall(lhs, [rhs], lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpEquality = function () {
        var result = __parseOpRelational();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakToken.EQUAL ||
                peeked == CatspeakToken.NOT_EQUAL
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpRelational();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpRelational = function () {
        var result = __parseOpBitwise();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakToken.LESS ||
                peeked == CatspeakToken.LESS_EQUAL ||
                peeked == CatspeakToken.GREATER ||
                peeked == CatspeakToken.GREATER_EQUAL
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpBitwise();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };


    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpBitwise = function () {
        var result = __parseOpAdd();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakToken.BITWISE_AND ||
                peeked == CatspeakToken.BITWISE_XOR ||
                peeked == CatspeakToken.BITWISE_OR ||
                peeked == CatspeakToken.SHIFT_LEFT ||
                peeked == CatspeakToken.SHIFT_RIGHT
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpAdd();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };
    
    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpAdd = function () {
        var result = __parseOpMultiply();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakToken.PLUS ||
                peeked == CatspeakToken.SUBTRACT
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpMultiply();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpMultiply = function () {
        var result = __parseOpUnary();
        while (true) {
            var peeked = lexer.peek();
            if (
                peeked == CatspeakToken.MULTIPLY ||
                peeked == CatspeakToken.DIVIDE ||
                peeked == CatspeakToken.DIVIDE_INT ||
                peeked == CatspeakToken.REMAINDER
            ) {
                lexer.next();
                var op = __catspeak_operator_from_token(peeked);
                var lhs = result;
                var rhs = __parseOpUnary();
                result = ir.createBinary(op, lhs, rhs, lexer.getLocation());
            } else {
                return result;
            }
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseOpUnary = function () {
        var peeked = lexer.peek();
        if (
            peeked == CatspeakToken.NOT ||
            peeked == CatspeakToken.BITWISE_NOT ||
            peeked == CatspeakToken.SUBTRACT ||
            peeked == CatspeakToken.PLUS
        ) {
            lexer.next();
            var op = __catspeak_operator_from_token(peeked);
            var value = __parseIndex();
            return ir.createUnary(op, value, lexer.getLocation());
        //} else if (peeked == CatspeakToken.COLON) {
        //    // `:property` syntax
        //    lexer.next();
        //    return ir.createProperty(__parseTerminal(), lexer.getLocation());
        } else {
            return __parseIndex();
        }
    };
    
    /// @ignore
    ///
    /// @return {Array}
    static __parseMatchArms = function () {
        if (lexer.next() != CatspeakToken.BRACE_LEFT) {
            __ex("expected opening '{' before 'match' arms");
        }
        var conditions = [];
        while (__isNot(CatspeakToken.BRACE_RIGHT)) {
            var value;
            var prefix = lexer.next();
            if (prefix == CatspeakToken.ELSE) {
                value = undefined;
            } else if (lexer.getLexeme() != "case") {
                __ex("expected 'case' keyword before non-default match arm");
            } else {
                value = __parseExpression();
            }
            ir.pushBlock();
            __parseStatements("case");
            var result = ir.popBlock();
            array_push(conditions, [value, result]);
        }
        if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
            __ex("expected closing '}' after 'match' arm");
        }
        return conditions;
    }

    /// @ignore
    ///
    /// @return {Struct}
    static __parseIndex = function () {
        var callNew = lexer.peek() == CatspeakToken.NEW;
        if (callNew) {
            lexer.next();
        }
        var result = __parseTerminal();
        while (true) {
            var peeked = lexer.peek();
            if (peeked == CatspeakToken.PAREN_LEFT) {
                // function call syntax
                lexer.next();
                var args = [];
                while (__isNot(CatspeakToken.PAREN_RIGHT)) {
                    array_push(args, __parseExpression());
                    if (lexer.peek() == CatspeakToken.COMMA) {
                        lexer.next();
                    }
                }
                if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                    __ex("expected closing ')' after function arguments");
                }
                result = callNew
                        ? ir.createCallNew(result, args, lexer.getLocation())
                        : ir.createCall(result, args, lexer.getLocation());
                callNew = false;
            } else if (peeked == CatspeakToken.BOX_LEFT) {
                // accessor syntax
                lexer.next();
                var collection = result;
                var key = __parseExpression();
                if (lexer.next() != CatspeakToken.BOX_RIGHT) {
                    __ex("expected closing ']' after accessor expression");
                }
                result = ir.createAccessor(collection, key, lexer.getLocation());
            } else if (peeked == CatspeakToken.DOT) {
                // dot accessor syntax
                lexer.next();
                var collection = result;
                if (lexer.next() != CatspeakToken.IDENT) {
                    __ex("expected identifier after '.' operator");
                }
                var key = ir.createValue(lexer.getValue(), lexer.getLocation());
                result = ir.createAccessor(collection, key, lexer.getLocation());
            } else {
                break;
            }
        }
        if (callNew) {
            // implicit new: `let t = new Thing;`
            result = ir.createCallNew(result, [], lexer.getLocation());
        }
        return result;
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseTerminal = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.VALUE) {
            lexer.next();
            return ir.createValue(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.IDENT) {
            lexer.next();
            return ir.createGet(lexer.getValue(), lexer.getLocation());
        } else if (peeked == CatspeakToken.SELF) {
            lexer.next();
            return ir.createSelf(lexer.getLocation());
        } else if (peeked == CatspeakToken.OTHER) {
            lexer.next();
            return ir.createOther(lexer.getLocation());
        } else {
            return __parseGrouping();
        }
    };

    /// @ignore
    ///
    /// @return {Struct}
    static __parseGrouping = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.PAREN_LEFT) {
            lexer.next();
            var inner = __parseExpression();
            if (lexer.next() != CatspeakToken.PAREN_RIGHT) {
                __ex("expected closing ')' after group expression");
            }
            return inner;
        } else if (peeked == CatspeakToken.BOX_LEFT) {
            lexer.next();
            var values = [];
            while (__isNot(CatspeakToken.BOX_RIGHT)) {
                array_push(values, __parseExpression());
                if (lexer.peek() == CatspeakToken.COMMA) {
                    lexer.next();
                }
            }
            if (lexer.next() != CatspeakToken.BOX_RIGHT) {
                __ex("expected closing ']' after array literal");
            }
            return ir.createArray(values, lexer.getLocation());
        } else if (peeked == CatspeakToken.BRACE_LEFT) {
            lexer.next();
            var values = [];
            while (__isNot(CatspeakToken.BRACE_RIGHT)) {
                var key;
                var keyToken = lexer.next();
                if (keyToken == CatspeakToken.BOX_LEFT) {
                    key = __parseExpression();
                    if (lexer.next() != CatspeakToken.BOX_RIGHT) {
                        __ex(
                            "expected closing ']' after computed struct key"
                        );
                    }
                } else if (
                    keyToken == CatspeakToken.IDENT ||
                    keyToken == CatspeakToken.VALUE
                ) {
                    key = ir.createValue(lexer.getValue(), lexer.getLocation());
                } else {
                    __ex("expected identifier or value as struct key");
                }
                var value;
                if (lexer.peek() == CatspeakToken.COLON) {
                    lexer.next();
                    value = __parseExpression();
                } else if (keyToken == CatspeakToken.IDENT) {
                    value = ir.createGet(key.value, lexer.getLocation());
                } else {
                    __ex(
                        "expected ':' between key and value ",
                        "of struct literal"
                    );
                }
                if (lexer.peek() == CatspeakToken.COMMA) {
                    lexer.next();
                }
                array_push(values, key, value);
            }
            if (lexer.next() != CatspeakToken.BRACE_RIGHT) {
                __ex("expected closing '}' after struct literal");
            }
            return ir.createStruct(values, lexer.getLocation());
        } else {
            __ex("malformed expression, expected: '(', '[' or '{'");
        }
    };

    /// @ignore
    ///
    /// @param {String} ...
    static __ex = function () {
        var dbg = __catspeak_location_show(lexer.getLocation(), ir.filepath) + " when parsing";
        if (argument_count < 1) {
            __catspeak_error(dbg);
        } else {
            var msg = "";
            for (var i = 0; i < argument_count; i += 1) {
                msg += __catspeak_string(argument[i]);
            }
            __catspeak_error(dbg, " -- ", msg, ", got ", __tokenDebug());
        }
    };

    /// @ignore
    ///
    /// @return {String}
    static __tokenDebug = function () {
        var peeked = lexer.peek();
        if (peeked == CatspeakToken.EOF) {
            return "end of file";
        } else if (peeked == CatspeakToken.SEMICOLON) {
            return "line break ';'";
        }
        return "token '" + lexer.getLexeme() + "' (" + string(peeked) + ")";
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __isNot = function (expect) {
        var peeked = lexer.peek();
        return peeked != expect && peeked != CatspeakToken.EOF;
    };

    /// @ignore
    ///
    /// @param {Enum.CatspeakToken} expect
    /// @return {Bool}
    static __is = function (expect) {
        var peeked = lexer.peek();
        return peeked == expect && peeked != CatspeakToken.EOF;
    };
}