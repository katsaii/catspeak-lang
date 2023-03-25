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
    DOT, COLON, COMMA, ASSIGN, BREAK_LINE, CONTINUE_LINE,
    DO, IT, IF, ELSE, WHILE, FOR, LOOP, LET, FUN, BREAK, CONTINUE, RETURN,
    AND, OR,
    NEW, IMPL, SELF,
    IDENT, STRING, NUMBER,
    WHITESPACE, COMMENT,
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
    self.alignment = buffer_get_alignment(buff);
    self.capacity = buffer_get_size(buff);
    self.offset = clamp(offset, 0, self.capacity);
    self.limit = clamp(size, 0, self.capacity);
    self.eof = false;
    self.cr = false;
    self.skipNextByte = false;
    self.skipNextSemicolon = false;
    self.lexemeLength = 0;
    self.line = 1;
    self.column = 1;
    self.posNext = self.pos.clone();

    /// @ignore
    ///
    /// @param {Id.Buffer} buff
    /// @param {Real} offset
    /// @return {Real}
    static __nextCodepoint = function(buff, offset) {
        // TODO
    };

    /// Returns the string representation of the most recent token emitted by
    /// the [nextWithWhitespace] method.
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
        // TODO
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