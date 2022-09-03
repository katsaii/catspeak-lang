//! Handles the lexical analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// A helper function for creating a buffer from a string.
///
/// @param {String} src
///   The source code to convert into a buffer.
///
/// @return {Id.Buffer}
function catspeak_create_buffer_from_string(src) {
    var capacity = string_byte_length(src);
    var buff = buffer_create(capacity, buffer_fixed, 1);
    buffer_write(buff, buffer_text, src);
    buffer_seek(buff, buffer_seek_start, 0);
    return buff;
}

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

    /// Advances the lexer and returns the next `CatspeakToken`. This includes
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
        var token = catspeak_byte_to_token(byte);
        var desc = catspeak_byte_to_ascii_desc(byte);
        if (catspeak_ascii_desc_contains(desc,
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
            // TODO hex/binary digits
            advanceWhile(CatspeakASCIIDesc.DIGIT);
            if (peek(1) == ord(".") && catspeak_ascii_desc_contains(
                catspeak_byte_to_ascii_desc(peek(2)),
                CatspeakASCIIDesc.DIGIT
            )) {
                advance();
                advanceWhile(CatspeakASCIIDesc.DIGIT);
            }
            registerLexeme();
        } else if (byte == ord("\"")) {
            clearLexeme();
            while (true) {
                var peeked = peek(1);
                if (peeked == -1 || peeked == ord("\"")) {
                    break;
                }
                advance();
            }
            registerLexeme();
            if (peek(1) == "\"") {
                // I don't care about raising an error in this situation,
                // since Catspeak should be a bit forgiving as a modding
                // language
                skipNextByte = true;
            }
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

    /// Advances the lexer and returns the next `CatspeakToken`, ingoring
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
    static tokens = undefined;
    if (tokens == undefined) {
        tokens = array_create(catspeak_token_sizeof(), true);
        var exceptions = [
            CatspeakToken.PAREN_RIGHT,
            CatspeakToken.BOX_RIGHT,
            CatspeakToken.BRACE_RIGHT,
            CatspeakToken.DOT,
            CatspeakToken.COLON,
            CatspeakToken.COMMA,
            CatspeakToken.ASSIGN,
            CatspeakToken.BREAK_LINE,
            CatspeakToken.CONTINUE_LINE,
            CatspeakToken.ELSE,
            CatspeakToken.LET,
            CatspeakToken.WHITESPACE,
            CatspeakToken.COMMENT,
            CatspeakToken.EOL,
            CatspeakToken.BOF,
            CatspeakToken.EOF,
            CatspeakToken.OTHER,
            CatspeakToken.OP_LOW,
            CatspeakToken.OP_OR,
            CatspeakToken.OP_AND,
            CatspeakToken.OP_COMP,
            CatspeakToken.OP_ADD,
            CatspeakToken.OP_MUL,
            CatspeakToken.OP_DIV,
            CatspeakToken.OP_HIGH,
        ];
        var count = array_length(exceptions);
        for (var i = 0; i < count; i += 1) {
            tokens[@ catspeak_token_valueof(exceptions[i])] = false;
        }
    }
    return tokens[catspeak_token_valueof(token)];
}

/// Returns whether a Catspeak token ignores any succeeding newline
/// characters.
///
/// @param {Enum.CatspeakToken} token
///   The ID of the token to check.
///
/// @return {Bool}
function catspeak_token_skips_newline(token) {
    static tokens = undefined;
    if (tokens == undefined) {
        tokens = array_create(catspeak_token_sizeof(), false);
        var tokens_ = [
            // !! DO NOT ADD `BREAK_LINE` HERE, IT WILL RUIN EVERYTHING !!
            //              you have been warned... (*^_^*) b
            CatspeakToken.PAREN_LEFT,
            CatspeakToken.BOX_LEFT,
            CatspeakToken.BRACE_LEFT,
            CatspeakToken.DOT,
            CatspeakToken.COLON,
            CatspeakToken.COMMA,
            CatspeakToken.ASSIGN,
            // this token technically does, but it's handled in a different
            // way to the others, so it's only here honorarily
            //CatspeakToken.CONTINUE_LINE,
            CatspeakToken.DO,
            CatspeakToken.IF,
            CatspeakToken.ELSE,
            CatspeakToken.WHILE,
            CatspeakToken.FOR,
            CatspeakToken.LET,
            CatspeakToken.FUN,
            CatspeakToken.OP_LOW,
            CatspeakToken.OP_OR,
            CatspeakToken.OP_AND,
            CatspeakToken.OP_COMP,
            CatspeakToken.OP_ADD,
            CatspeakToken.OP_MUL,
            CatspeakToken.OP_DIV,
            CatspeakToken.OP_HIGH,
        ];
        var count = array_length(tokens_);
        for (var i = 0; i < count; i += 1) {
            tokens[@ catspeak_token_valueof(tokens_[i])] = true;
        }
    }
    return tokens[catspeak_token_valueof(token)];
}

/// Converts a string into a keyword token if once exists. If the keyword
/// doesn't exist, `undefined` is returned instead.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakToken}
function catspeak_string_to_token_keyword(str) {
    static keywords = undefined;
    if (keywords == undefined) {
        keywords = { };
        keywords[$ "--"] = CatspeakToken.COMMENT;
        keywords[$ "="] = CatspeakToken.ASSIGN;
        keywords[$ ":"] = CatspeakToken.COLON;
        keywords[$ ";"] = CatspeakToken.BREAK_LINE;
        keywords[$ "."] = CatspeakToken.DOT;
        keywords[$ "..."] = CatspeakToken.CONTINUE_LINE;
        keywords[$ "do"] = CatspeakToken.DO;
        keywords[$ "it"] = CatspeakToken.IT;
        keywords[$ "if"] = CatspeakToken.IF;
        keywords[$ "else"] = CatspeakToken.ELSE;
        keywords[$ "while"] = CatspeakToken.WHILE;
        keywords[$ "for"] = CatspeakToken.FOR;
        keywords[$ "let"] = CatspeakToken.LET;
        keywords[$ "fun"] = CatspeakToken.FUN;
        keywords[$ "break"] = CatspeakToken.BREAK;
        keywords[$ "continue"] = CatspeakToken.CONTINUE;
        keywords[$ "return"] = CatspeakToken.RETURN;
    }
    return keywords[$ str];
}

/// Converts an ASCII character into a Catspeak token. This is only an
/// informed prediction judging by the first character of a token.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakToken}
function catspeak_byte_to_token(char) {
    static db = undefined;
    if (char < 0 || char > 255) {
        return CatspeakToken.OTHER;
    }
    if (db == undefined) {
        db = array_create(256, CatspeakToken.OTHER);
        __catspeak_mark_token(db, [
            0x09, // CHARACTER TABULATION ('\t')
            0x0B, // LINE TABULATION ('\v')
            0x0C, // FORM FEED ('\f')
            0x20, // SPACE (' ')
            0x85, // NEXT LINE
        ], CatspeakToken.WHITESPACE);
        __catspeak_mark_token(db, [
            0x0A, // LINE FEED ('\n')
            0x0D, // CARRIAGE RETURN ('\r')
        ], CatspeakToken.BREAK_LINE);
        __catspeak_mark_token(db, function (char) {
            return char >= ord("a") && char <= ord("z")
                    || char >= ord("A") && char <= ord("Z")
                    || char == ord("_")
                    || char == ord("'")
                    || char == ord("`");
        }, CatspeakToken.IDENT);
        __catspeak_mark_token(db, function (char) {
            return char >= ord("0") && char <= ord("9");
        }, CatspeakToken.NUMBER);
        __catspeak_mark_token(db, ["$", ":", ";"], CatspeakToken.OP_LOW);
        __catspeak_mark_token(db, ["^", "|"], CatspeakToken.OP_OR);
        __catspeak_mark_token(db, ["&"], CatspeakToken.OP_AND);
        __catspeak_mark_token(db, [
            "!", "<", "=", ">", "?", "~"
        ], CatspeakToken.OP_COMP);
        __catspeak_mark_token(db, ["+", "-"], CatspeakToken.OP_ADD);
        __catspeak_mark_token(db, ["*", "/"], CatspeakToken.OP_MUL);
        __catspeak_mark_token(db, ["%", "\\"], CatspeakToken.OP_DIV);
        __catspeak_mark_token(db, ["#", ".", "@"], CatspeakToken.OP_HIGH);
        __catspeak_mark_token(db, "\"", CatspeakToken.STRING);
        __catspeak_mark_token(db, "(", CatspeakToken.PAREN_LEFT);
        __catspeak_mark_token(db, ")", CatspeakToken.PAREN_RIGHT);
        __catspeak_mark_token(db, "[", CatspeakToken.BOX_LEFT);
        __catspeak_mark_token(db, "]", CatspeakToken.BOX_RIGHT);
        __catspeak_mark_token(db, "{", CatspeakToken.BRACE_LEFT);
        __catspeak_mark_token(db, "}", CatspeakToken.BRACE_RIGHT);
        __catspeak_mark_token(db, ",", CatspeakToken.COMMA);
    }
    return db[char];
}

/// Converts an ASCII character into a Catspeak character descriptor.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakASCIIDesc}
function catspeak_byte_to_ascii_desc(char) {
    static db = undefined;
    if (char < 0 || char > 255) {
        return CatspeakASCIIDesc.NONE;
    }
    if (db == undefined) {
        db = array_create(256, CatspeakASCIIDesc.NONE);
        __catspeak_mark_ascii_desc(db, [
            0x09, // CHARACTER TABULATION ('\t')
            0x0A, // LINE FEED ('\n')
            0x0B, // LINE TABULATION ('\v')
            0x0C, // FORM FEED ('\f')
            0x0D, // CARRIAGE RETURN ('\r')
            0x20, // SPACE (' ')
            0x85, // NEXT LINE
        ], CatspeakASCIIDesc.WHITESPACE);
        __catspeak_mark_ascii_desc(db, [
            0x0A, // LINE FEED ('\n')
            0x0D, // CARRIAGE RETURN ('\r')
        ], CatspeakASCIIDesc.NEWLINE);
        __catspeak_mark_ascii_desc(db, function (char) {
            return char >= ord("a") && char <= ord("z")
                    || char >= ord("A") && char <= ord("Z");
        }, CatspeakASCIIDesc.ALPHABETIC
                | CatspeakASCIIDesc.GRAPHIC
                | CatspeakASCIIDesc.IDENT);
        __catspeak_mark_ascii_desc(db, ["_", "'"],
                CatspeakASCIIDesc.GRAPHIC | CatspeakASCIIDesc.IDENT);
        __catspeak_mark_ascii_desc(db, function (char) {
            return char >= ord("0") && char <= ord("9");
        }, CatspeakASCIIDesc.DIGIT
                | CatspeakASCIIDesc.DIGIT_HEX
                | CatspeakASCIIDesc.GRAPHIC
                | CatspeakASCIIDesc.IDENT);
        __catspeak_mark_ascii_desc(db, ["0", "1"], CatspeakASCIIDesc.DIGIT_BIN);
        __catspeak_mark_ascii_desc(db, function (char) {
            return char >= ord("a") && char <= ord("f")
                    || char >= ord("A") && char <= ord("F");
        }, CatspeakASCIIDesc.DIGIT_HEX);
        __catspeak_mark_ascii_desc(db, [
            "!", "#", "$", "%", "&", "*", "+", "-", ".", "/", ":", ";", "<",
            "=", ">", "?", "@", "\\", "^", "|", "~",
        ], CatspeakASCIIDesc.OPERATOR | CatspeakASCIIDesc.IDENT);
    }
    return db[char];
}

/// @ignore
function __catspeak_mark_token(db, query, value) {
    if (!is_array(query)) {
        query = [query];
    }
    var count = array_length(query);
    var countDb = array_length(db);
    for (var i = 0; i < count; i += 1) {
        var queryItem = query[i];
        if (is_method(queryItem)) {
            for (var i = 0; i < countDb; i += 1) {
                if (queryItem(i)) {
                    db[@ i] = value;
                }
            }
            continue;
        }
        var byte = is_string(queryItem) ? ord(queryItem) : queryItem;
        db[@ byte] = value;
    }
}

/// @ignore
function __catspeak_mark_ascii_desc(db, query, value) {
    if (!is_array(query)) {
        query = [query];
    }
    var count = array_length(query);
    var countDb = array_length(db);
    for (var i = 0; i < count; i += 1) {
        var queryItem = query[i];
        if (is_method(queryItem)) {
            for (var i = 0; i < countDb; i += 1) {
                if (queryItem(i)) {
                    db[@ i] |= value;
                }
            }
            continue;
        }
        var byte = is_string(queryItem) ? ord(queryItem) : queryItem;
        db[@ byte] |= value;
    }
}