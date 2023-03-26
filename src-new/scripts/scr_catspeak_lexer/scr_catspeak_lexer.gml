//! Responsible for the lexical analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// A token in Catspeak is a series of characters with meaning, usually
/// separated by whitespace.
///
/// For example, these are all valid tokens:
///   - `if`   (is a `CatspeakToken.IF`)
///   - `else` (is a `CatspeakToken.ELSE`)
///   - `12.3` (is a `CatspeakToken.NUMBER`)
///   - `+`    (is a `CatspeakToken.OP_ADD`)
///
/// The following enum represents all possible token types understood by the
/// Catspeak language.
enum CatspeakToken {
    PAREN_LEFT, PAREN_RIGHT,
    BOX_LEFT, BOX_RIGHT,
    BRACE_LEFT, BRACE_RIGHT,
    DOT, COLON, COMMA, ASSIGN,
    DO, IT, IF, ELSE, WHILE, FOR, LOOP, LET, FUN, BREAK, CONTINUE, RETURN,
    AND, OR,
    NEW, IMPL, SELF,
    IDENT, STRING, NUMBER,
    WHITESPACE, COMMENT, BREAK_LINE, CONTINUE_LINE,
    EOL, BOF, EOF, OTHER,
    __OPERATORS_BEGIN__,
    OP_LOW,
    OP_OR,
    OP_AND,
    OP_COMP,
    OP_ADD,
    OP_MUL,
    OP_DIV,
    OP_HIGH,
    __OPERATORS_END__,
    __SIZE__
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
/// for syntax highlighting in a programming game which uses the Catspeak
/// engine.
///
/// NOTE: The lexer does not take ownership of this buffer, but it may mutate
///       it so beware. Therefore you should make sure to delete the buffer
///       once parsing is complete.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to use.
///
/// @param {Real} [offset]
///   The offset in the buffer to start parsing from. Defaults to 0, the
///   start of the buffer.
///
/// @param {Real} [size]
///   The length of the buffer input. Any characters beyond this limit will
///   be treated as the end of the file. Defaults to `infinity`.
function CatspeakLexer(buff, offset=0, size=infinity) constructor {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
        __catspeak_check_typeof_numeric("buff", buff);
        __catspeak_check_typeof_numeric("offset", offset);
        __catspeak_check_typeof_numeric("size", size);
    }

    self.buff = buff;
    self.buffAlignment = buffer_get_alignment(buff);
    self.buffCapacity = buffer_get_size(buff);
    self.offset = clamp(offset, 0, self.buffCapacity);
    self.size = clamp(size, 0, self.buffCapacity);
    self.row = 1;
    self.column = 1;
    self.lexemeStart = 0;
    self.lexemeEnd = 0;
    self.lexemePos = catspeak_location_create(self.row, self.column);
    self.lexeme = undefined;
    self.charCurr = -1;
    self.charNext = __nextUTF8Char();

    /// @ignore
    ///
    /// @return {Real}
    static __nextUTF8Char = function() {
        // TODO UTF8
        if (offset >= size) {
            return -1;
        }
        var byte = buffer_peek(buff, offset, buffer_u8);
        offset += 1;
        return byte;
    };

    /// @ignore
    static __advance = function() {
        lexemeEnd = offset;
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
    static __clearLexeme = function() {
        lexemeStart = lexemeEnd;
        lexemePos = catspeak_location_create(self.row, self.column);
        lexeme = undefined;
    }

    /// Returns the string representation of the most recent token emitted by
    /// the [next] or [nextWithWhitespace] methods.
    ///
    /// @example
    ///   Prints the string content of the first [CatspeakToken] emitted by a
    ///   lexer.
    ///
    /// ```gml
    /// lexer.next();
    /// show_debug_message(lexer.getLexeme());
    /// ```
    static getLexeme = function() {
        if (lexeme == undefined) {
            var buff_ = buff;
            // don't read outside bounds of `size`
            var clipStart = min(lexemeStart, size);
            var clipEnd = min(lexemeEnd, size);
            if (clipEnd <= clipStart) {
                // always an empty slice
                lexeme = "";
                if (CATSPEAK_DEBUG_MODE && clipEnd < clipStart) {
                    __catspeak_error_bug();
                }
            } else if (clipEnd >= buffCapacity) {
                // beyond the actual capacity of the buffer
                // not safe to use `buffer_string`, which expects a null char
                lexeme = buffer_peek(buff_, clipStart, buffer_text);
            } else {
                // quickly write a null terminator and then read the content
                var byte = buffer_peek(buff_, clipEnd, buffer_u8);
                buffer_poke(buff_, clipEnd, buffer_u8, 0x00);
                lexeme = buffer_peek(buff_, clipStart, buffer_string);
                buffer_poke(buff_, clipEnd, buffer_u8, byte);
            }
        }
        return lexeme;
    };

    /// Advances the lexer and returns the next type of [CatspeakToken]. This
    /// includes additional whitespace and control tokens, like:
    ///  - line breaks `;`          (`CatspeakToken.BREAK_LINE`)
    ///  - line continuations `...` (`CatspeakToken.CONTINUE_LINE`)
    ///  - comments `--`            (`CatspeakToken.COMMENT`)
    ///
    /// To get the string content of the token, you should use the [getLexeme]
    /// method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each non-whitespace token out as a debug message.
    ///
    /// ```gml
    /// var lexer = new CatspeakLexer(buff);
    /// do {
    ///   var token = lexer.nextWithWhitespace();
    ///   if (token != CatspeakToken.WHITESPACE) {
    ///     show_debug_message(lexer.getLexeme());
    ///   }
    /// } until (token == CatspeakToken.EOF);
    /// ```
    ///
    /// @return {Enum.CatspeakToken}
    static nextWithWhitespace = function() {
        // TODO
    };

    /// Advances the lexer and returns the next [CatspeakToken], ingoring
    /// any comments, whitespace, and line continuations.
    ///
    /// To get the string content of the token, you should use the [getLexeme]
    /// method.
    ///
    /// @example
    ///   Iterates through all tokens of a buffer containing Catspeak code,
    ///   printing each token out as a debug message.
    ///
    /// ```gml
    /// var lexer = new CatspeakLexer(buff);
    /// do {
    ///   var token = lexer.nextWithWhitespace();
    ///   show_debug_message(lexer.getLexeme());
    /// } until (token == CatspeakToken.EOF);
    /// ```
    ///
    /// @return {Enum.CatspeakToken}
    static next = function() {
        var skipSemicolon = skipNextSemicolon;
        skipNextSemicolon = false;
        while (true) {
            var token = nextWithWhitespace();
            if (token == CatspeakToken.WHITESPACE
                    || token == CatspeakToken.COMMENT) {
                continue;
            }
            if (token == CatspeakToken.CONTINUE_LINE) {
                skipSemicolon = true;
                continue;
            //} else if (catspeak_token_skips_newline(token)) {
            //    skipNextSemicolon = true;
            }
            if (skipSemicolon && token == CatspeakToken.BREAK_LINE) {
                continue;
            }
            return token;
        }
    };
}