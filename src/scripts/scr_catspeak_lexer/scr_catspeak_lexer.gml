//! Handles the lexical analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// Tokenises the contents of a GML buffer. The lexer does not take ownership
/// of this buffer, but it may mutate it so beware. Therefore you should make
/// sure to delete the buffer once parsing is complete.
///
/// @param {Id.Buffer} buff
///   The ID of the GML buffer to use.
function CatspeakLexer(buff) constructor {
    self.buff = buff;
    self.alignment = buffer_get_alignment(buff);
    self.limit = buffer_get_size(buff);
    self.eof = false;
    self.cr = false;
    self.skipNextByte = false;
    self.skipNextSemicolon = false;
    self.lexemeLength = 0;
    self.pos = new CatspeakLocation(1, 1);
    self.posNext = self.pos.clone();

    /// Updates the line and column numbers of the lexer, also updates the.
    /// current length of the lexeme, in bytes.
    ///
    /// @param {Real} byte
    ///   The byte to consider.
    static registerByte = function(byte) {
        lexemeLength += 1;
        if (byte == ord("\r")) {
            cr = true;
            posNext.column = 1;
            posNext.line += 1;
        } else if (byte == ord("\n")) {
            posNext.column = 1;
            if (cr) {
                cr = false;
            } else {
                posNext.line += 1;
            }
        } else {
            posNext.column += 1;
            cr = false;
        }
    };

    /// Registers the current lexeme as a string.
    static registerLexeme = function() {
        if (lexemeLength < 1) {
            // always an empty slice
            pos.lexeme = "";
            return;
        }
        var buff_ = buff;
        var offset = buffer_tell(buff_);
        var byte = buffer_peek(buff_, offset, buffer_u8);
        buffer_poke(buff_, offset, buffer_u8, 0x00);
        buffer_seek(buff_, buffer_seek_start, offset - lexemeLength);
        pos.lexeme = buffer_read(buff_, buffer_string);
        buffer_seek(buff_, buffer_seek_relative, -1);
        buffer_poke(buff_, offset, buffer_u8, byte);
    };

    /// Resets the current lexeme.
    static clearLexeme = function() {
        lexemeLength = 0;
        pos.reflect(posNext);
    };

    /// @desc Advances the scanner and returns the current byte.
    ///
    /// @return {Real}
    static advance = function() {
        var seek = buffer_tell(buff);
        if (seek + 1 >= limit) {
            eof = true;
        }
        var byte = buffer_read(buff, buffer_u8);
        registerByte(byte);
        return byte;
    };

    /// @desc Peeks `n` bytes ahead of the current buffer offset.
    ///
    /// @param {Real} n
    ///   The number of bytes to look ahead.
    ///
    /// @return {Real}
    static peek = function(n) {
        var offset = buffer_tell(buff) + n - 1;
        if (offset >= limit) {
            return -1;
        }
        return buffer_peek(buff, offset, buffer_u8);
    };

    /// @desc Advances the lexer whilst a bytes contain some expected ASCII
    /// descriptor, or until the end of the file is reached.
    ///
    /// @param {Enum.CatspeakASCIIDesc} desc
    ///   The descriptor to check for.
    ///
    /// @param {Bool} [condition]
    ///   The condition to expect. Defaults to `true`, set the `false` to
    ///   invert the condition.
    ///
    /// @return {Real}
    static advanceWhile = function(desc, condition=true) {
        var byte = undefined;
        var seek = buffer_tell(buff);
        while (seek < limit) {
            byte = buffer_peek(buff, seek, buffer_u8);
            if (condition != catspeak_ascii_desc_contains(
                    catspeak_byte_to_ascii_desc(byte), desc)) {
                break;
            }
            registerByte(byte);
            seek += alignment;
        }
        if (seek >= limit) {
            eof = true;
        }
        buffer_seek(buff, buffer_seek_start, seek);
        return byte;
    };

    /// Advances the lexer and returns the next [CatspeakToken]. This includes
    /// additional whitespace and control tokens, like: line breaks `;`, line
    /// continuations `...`, and comments `--`.
    ///
    /// @return {Enum.CatspeakToken}
    static nextWithWhitespace = function() {
        clearLexeme();
        if (limit == 0 || eof) {
            return CatspeakToken.EOF;
        }
        if (skipNextByte) {
            advance();
            skipNextByte = false;
            return next();
        }
        var byte = advance();
        if (byte == 0) {
            eof = true;
            return CatspeakToken.EOF;
        }
        var token = catspeak_byte_to_token(byte);
        var desc = catspeak_byte_to_ascii_desc(byte);
        if (byte == ord("\"") || byte == ord("@") && peek(1) == ord("\"")) {
            // this needs to be first in order to support the `@` prefix
            var rawString = byte == ord("@");
            if (rawString) {
                token = CatspeakToken.STRING; // since `@` is an operator
                advance();
            }
            clearLexeme();
            var escape = false;
            while (true) {
                var peeked = peek(1);
                if (peeked == -1) {
                    break;
                }
                if (escape) {
                    escape = false;
                } else if (peeked == ord("\"")) {
                    break;
                } else if (peeked == ord("\\")) {
                    escape = true;
                }
                advance();
            }
            registerLexeme();
            if (!rawString) {
                // TODO :: this is very slow, figure do it with buffers
                var lexeme = pos.lexeme;
                lexeme = string_replace_all(lexeme, "\\\"", "\"");
                lexeme = string_replace_all(lexeme, "\\\r\n", "");
                lexeme = string_replace_all(lexeme, "\\\n", "");
                lexeme = string_replace_all(lexeme, "\\\r", "");
                lexeme = string_replace_all(lexeme, "\\\\", "\\");
                lexeme = string_replace_all(lexeme, "\\t", "\t");
                lexeme = string_replace_all(lexeme, "\\n", "\n");
                lexeme = string_replace_all(lexeme, "\\v", "\v");
                lexeme = string_replace_all(lexeme, "\\f", "\f");
                lexeme = string_replace_all(lexeme, "\\r", "\r");
                pos.lexeme = lexeme;
            }
            if (peek(1) == ord("\"")) {
                // I don't care about raising an error in this situation,
                // since Catspeak should be a bit forgiving as a modding
                // language
                skipNextByte = true;
            }
        } else if (catspeak_ascii_desc_contains(desc,
                CatspeakASCIIDesc.OPERATOR)) {
            advanceWhile(CatspeakASCIIDesc.OPERATOR);
            registerLexeme();
            token = catspeak_string_to_token_keyword(pos.lexeme) ?? token;
            if (token == CatspeakToken.COMMENT) {
                // consume the coment
                advanceWhile(CatspeakASCIIDesc.NEWLINE, false);
                registerLexeme();
            }
        } else if (catspeak_ascii_desc_contains(desc,
                CatspeakASCIIDesc.ALPHABETIC)) {
            advanceWhile(CatspeakASCIIDesc.GRAPHIC);
            registerLexeme();
            token = catspeak_string_to_token_keyword(pos.lexeme) ?? token;
        } else if (catspeak_ascii_desc_contains(desc,
                CatspeakASCIIDesc.DIGIT)) {
            advanceWhile(CatspeakASCIIDesc.DIGIT);
            if (peek(1) == ord(".") && catspeak_ascii_desc_contains(
                catspeak_byte_to_ascii_desc(peek(2)),
                CatspeakASCIIDesc.DIGIT
            )) {
                advance();
                advanceWhile(CatspeakASCIIDesc.DIGIT);
            }
            registerLexeme();
            pos.lexeme = real(pos.lexeme);
        } else if (byte == ord("`")) {
            clearLexeme();
            advanceWhile(CatspeakASCIIDesc.IDENT);
            registerLexeme();
            if (peek(1) == ord("`")) {
                // similar to strings, I don't care about raising an error in
                // this situation, since Catspeak should be a bit forgiving as
                // a modding language
                skipNextByte = true;
            }
        }
        return token;
    };

    /// Advances the lexer and returns the next [CatspeakToken], ingoring
    /// any comments, whitespace, and line continuations.
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
            } else if (catspeak_token_skips_newline(token)) {
                skipNextSemicolon = true;
            }
            if (skipSemicolon && token == CatspeakToken.BREAK_LINE) {
                continue;
            }
            return token;
        }
    };
}

/// Returns whether a Catspeak token is a valid operator.
///
/// @param {Enum.CatspeakToken} token
///   The ID of the token to check.
///
/// @return {Bool}
function catspeak_token_is_operator(token) {
    gml_pragma("forceinline");
    return token > CatspeakToken.__OPERATORS_BEGIN__
            && token < CatspeakToken.__OPERATORS_END__;
}

/// Returns whether a Catspeak token can start a new expression.
///
/// @param {Enum.CatspeakToken} token
///   The ID of the token to check.
///
/// @return {Bool}
function catspeak_token_is_expression(token) {
    gml_pragma("forceinline");
    return global.__catspeakDatabaseTokenStartsExpression[
            catspeak_token_valueof(token)];
}

/// Returns whether a Catspeak token ignores any succeeding newline
/// characters.
///
/// @param {Enum.CatspeakToken} token
///   The ID of the token to check.
///
/// @return {Bool}
function catspeak_token_skips_newline(token) {
    gml_pragma("forceinline");
    return global.__catspeakDatabaseTokenSkipsLine[
            catspeak_token_valueof(token)];
}

/// Converts a string into a keyword token if once exists. If the keyword
/// doesn't exist, `undefined` is returned instead.
///
/// @param {String} str
///   The lexeme to look-up the keyword for.
///
/// @return {Enum.CatspeakToken}
function catspeak_string_to_token_keyword(str) {
    gml_pragma("forceinline");
    return global.__catspeakDatabaseLexemeToKeyword[$ str];
}

/// Converts an ASCII character into a Catspeak token. This is only an
/// informed prediction judging by the first character of a token.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakToken}
function catspeak_byte_to_token(char) {
    gml_pragma("forceinline");
    if (char < 0 || char > 255) {
        return CatspeakToken.OTHER;
    }
    return global.__catspeakDatabaseByteToToken[char];
}

/// Converts an ASCII character into a Catspeak character descriptor.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakASCIIDesc}
function catspeak_byte_to_ascii_desc(char) {
    gml_pragma("forceinline");
    if (char < 0 || char > 255) {
        return CatspeakASCIIDesc.NONE;
    }
    return global.__catspeakDatabaseByteToASCIIDesc[char];
}