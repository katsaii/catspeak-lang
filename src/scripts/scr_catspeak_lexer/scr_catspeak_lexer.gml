//! Handles the lexical analysis stage of the Catspeak compiler.

//# feather use syntax-errors

/// Tokenises the contents of a GML buffer. The lexer does not take ownership
/// of this buffer, but it may mutate it so beware. Therefore you should make
/// sure to delete the buffer once parsing is complete.
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
        if (offset >= capacity) {
            // beyond the actual capacity of the buffer
            var offsetStart = min(offset - lexemeLength, capacity);
            pos.lexeme = buffer_peek(buff_, offsetStart, buffer_text);
        } else {
            // quickly write a null terminator and then read the string content
            var offsetStart = max(offset - lexemeLength, 0);
            var byte = buffer_peek(buff_, offset, buffer_u8);
            buffer_poke(buff_, offset, buffer_u8, 0x00);
            pos.lexeme = buffer_peek(buff_, offsetStart, buffer_string);
            buffer_poke(buff_, offset, buffer_u8, byte);
        }
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
        if (offset + 1 >= limit) {
            eof = true;
        }
        var byte = buffer_peek(buff, offset, buffer_u8);
        offset += 1;
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
        var peekOffset = offset + n - 1;
        if (peekOffset >= limit) {
            return -1;
        }
        return buffer_peek(buff, peekOffset, buffer_u8);
    };

    /// @desc Advances the lexer whilst a bytes contain some expected ASCII
    /// descriptor, or until the end of the file is reached.
    ///
    /// @param {Function} predicate
    ///   The predicate to satisfy.
    ///
    /// @param {Bool} [condition]
    ///   The condition to expect. Defaults to `true`, set the `false` to
    ///   invert the condition.
    ///
    /// @return {Real}
    static advanceWhile = function(predicate, condition=true) {
        var byte = undefined;
        var seek = offset;
        while (seek < limit) {
            byte = buffer_peek(buff, seek, buffer_u8);
            if (condition != predicate(byte)) {
                break;
            }
            registerByte(byte);
            seek += alignment;
        }
        if (seek >= limit) {
            eof = true;
        }
        offset = seek;
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
        var desc = __catspeak_byte_to_ascii_desc(byte);
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
        } else if (__catspeak_ascii_desc_contains(desc,
                __CatspeakASCIIDesc.OPERATOR)) {
            advanceWhile(__isOp);
            registerLexeme();
            token = catspeak_string_to_token_keyword(pos.lexeme) ?? token;
            if (token == CatspeakToken.COMMENT) {
                // consume the coment
                advanceWhile(__isNewline, false);
                registerLexeme();
            }
        } else if (__catspeak_ascii_desc_contains(desc,
                __CatspeakASCIIDesc.ALPHABETIC)) {
            advanceWhile(__isGraphic);
            registerLexeme();
            token = catspeak_string_to_token_keyword(pos.lexeme) ?? token;
        } else if (__catspeak_ascii_desc_contains(desc,
                __CatspeakASCIIDesc.DIGIT)) {
            advanceWhile(__isDigit);
            if (peek(1) == ord(".") && __isDigit(peek(2))) {
                advance();
                advanceWhile(__isDigit);
            }
            registerLexeme();
            pos.lexeme = real(pos.lexeme);
        } else if (byte == ord("`")) {
            clearLexeme();
            advanceWhile(__isNotWhitespaceOrBacktick);
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

    /// @ignore
    static __isOp = function(byte) {
        return __catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.OPERATOR
        );
    };

    /// @ignore
    static __isNewline = function(byte) {
        return __catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.NEWLINE
        );
    };

    /// @ignore
    static __isAlphabetic = function(byte) {
        return __catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.ALPHABETIC
        );
    };

    /// @ignore
    static __isGraphic = function(byte) {
        return __catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.GRAPHIC
        );
    };

    /// @ignore
    static __isDigit = function(byte) {
        return __catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.DIGIT
        );
    };

    /// @ignore
    static __isIdent = function(byte) {
        return __catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.IDENT
        );
    };

    /// @ignore
    static __isNotWhitespaceOrBacktick = function(byte) {
        if (byte == ord("`")) {
            return false;
        }
        return !__catspeak_ascii_desc_contains(
            __catspeak_byte_to_ascii_desc(byte),
            __CatspeakASCIIDesc.WHITESPACE
        );
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

/// @ignore
function __catspeak_byte_to_ascii_desc(char) {
    gml_pragma("forceinline");
    if (char < 0 || char > 255) {
        return __CatspeakASCIIDesc.NONE;
    }
    return global.__catspeakDatabaseByteToASCIIDesc[char];
}

/// @ignore
function __catspeak_init_lexer_database_token_starts_expression() {
    var db = array_create(catspeak_token_sizeof(), true);
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
        CatspeakToken.AND,
        CatspeakToken.OR,
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
        db[@ catspeak_token_valueof(exceptions[i])] = false;
    }
    /// @ignore
    global.__catspeakDatabaseTokenStartsExpression = db;
}

/// @ignore
function __catspeak_init_lexer_database_token_skips_line() {
    var db = array_create(catspeak_token_sizeof(), false);
    var tokens = [
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
    var count = array_length(tokens);
    for (var i = 0; i < count; i += 1) {
        db[@ catspeak_token_valueof(tokens[i])] = true;
    }
    /// @ignore
    global.__catspeakDatabaseTokenSkipsLine = db;
}

/// @ignore
function __catspeak_init_lexer_database_token_keywords() {
    var db = { };
    db[$ "--"] = CatspeakToken.COMMENT;
    db[$ "="] = CatspeakToken.ASSIGN;
    db[$ ":"] = CatspeakToken.COLON;
    db[$ ";"] = CatspeakToken.BREAK_LINE;
    db[$ "."] = CatspeakToken.DOT;
    db[$ "..."] = CatspeakToken.CONTINUE_LINE;
    db[$ "do"] = CatspeakToken.DO;
    db[$ "it"] = CatspeakToken.IT;
    db[$ "if"] = CatspeakToken.IF;
    db[$ "else"] = CatspeakToken.ELSE;
    db[$ "while"] = CatspeakToken.WHILE;
    db[$ "for"] = CatspeakToken.FOR;
    db[$ "loop"] = CatspeakToken.LOOP;
    db[$ "let"] = CatspeakToken.LET;
    db[$ "fun"] = CatspeakToken.FUN;
    db[$ "break"] = CatspeakToken.BREAK;
    db[$ "continue"] = CatspeakToken.CONTINUE;
    db[$ "return"] = CatspeakToken.RETURN;
    db[$ "and"] = CatspeakToken.AND;
    db[$ "or"] = CatspeakToken.OR;
    db[$ "new"] = CatspeakToken.NEW;
    db[$ "impl"] = CatspeakToken.IMPL;
    db[$ "self"] = CatspeakToken.SELF;
    global.__catspeakConfig.keywords = db;
    /// @ignore
    global.__catspeakDatabaseLexemeToKeyword = db;
}

/// @ignore
function __catspeak_init_lexer_database_ascii_desc() {
    var db = array_create(256, __CatspeakASCIIDesc.NONE);
    var mark = __catspeak_init_lexer_database_ascii_desc_mark;
    mark(db, [
        0x09, // CHARACTER TABULATION ('\t')
        0x0A, // LINE FEED ('\n')
        0x0B, // LINE TABULATION ('\v')
        0x0C, // FORM FEED ('\f')
        0x0D, // CARRIAGE RETURN ('\r')
        0x20, // SPACE (' ')
        0x85, // NEXT LINE
    ], __CatspeakASCIIDesc.WHITESPACE);
    mark(db, [
        0x0A, // LINE FEED ('\n')
        0x0D, // CARRIAGE RETURN ('\r')
    ], __CatspeakASCIIDesc.NEWLINE);
    mark(db, function (char) {
        return char >= ord("a") && char <= ord("z")
                || char >= ord("A") && char <= ord("Z");
    }, __CatspeakASCIIDesc.ALPHABETIC
            | __CatspeakASCIIDesc.GRAPHIC
            | __CatspeakASCIIDesc.IDENT);
    mark(db, ["_", "'"],
            __CatspeakASCIIDesc.ALPHABETIC
            | __CatspeakASCIIDesc.GRAPHIC
            | __CatspeakASCIIDesc.IDENT);
    mark(db, function (char) {
        return char >= ord("0") && char <= ord("9");
    }, __CatspeakASCIIDesc.DIGIT
            | __CatspeakASCIIDesc.GRAPHIC
            | __CatspeakASCIIDesc.IDENT);
    mark(db, [
        "!", "#", "$", "%", "&", "*", "+", "-", ".", "/", ":", ";", "<",
        "=", ">", "?", "@", "\\", "^", "|", "~",
    ], __CatspeakASCIIDesc.OPERATOR | __CatspeakASCIIDesc.IDENT);
    /// @ignore
    global.__catspeakDatabaseByteToASCIIDesc = db;
}

/// @ignore
function __catspeak_init_lexer_database_ascii_desc_mark(db, query, value) {
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

/// @ignore
function __catspeak_init_lexer_database_token() {
    var db = array_create(256, CatspeakToken.OTHER);
    var mark = __catspeak_init_lexer_database_token_mark;
    mark(db, [
        0x09, // CHARACTER TABULATION ('\t')
        0x0B, // LINE TABULATION ('\v')
        0x0C, // FORM FEED ('\f')
        0x20, // SPACE (' ')
        0x85, // NEXT LINE
    ], CatspeakToken.WHITESPACE);
    mark(db, [
        0x0A, // LINE FEED ('\n')
        0x0D, // CARRIAGE RETURN ('\r')
    ], CatspeakToken.BREAK_LINE);
    mark(db, function (char) {
        return char >= ord("a") && char <= ord("z")
                || char >= ord("A") && char <= ord("Z")
                || char == ord("_")
                || char == ord("'")
                || char == ord("`");
    }, CatspeakToken.IDENT);
    mark(db, function (char) {
        return char >= ord("0") && char <= ord("9");
    }, CatspeakToken.NUMBER);
    mark(db, ["$", ":", ";"], CatspeakToken.OP_LOW);
    mark(db, ["^", "|"], CatspeakToken.OP_OR);
    mark(db, ["&"], CatspeakToken.OP_AND);
    mark(db, [
        "!", "<", "=", ">", "?", "~"
    ], CatspeakToken.OP_COMP);
    mark(db, ["+", "-"], CatspeakToken.OP_ADD);
    mark(db, ["*", "/"], CatspeakToken.OP_MUL);
    mark(db, ["%", "\\"], CatspeakToken.OP_DIV);
    mark(db, ["#", ".", "@"], CatspeakToken.OP_HIGH);
    mark(db, "\"", CatspeakToken.STRING);
    mark(db, "(", CatspeakToken.PAREN_LEFT);
    mark(db, ")", CatspeakToken.PAREN_RIGHT);
    mark(db, "[", CatspeakToken.BOX_LEFT);
    mark(db, "]", CatspeakToken.BOX_RIGHT);
    mark(db, "{", CatspeakToken.BRACE_LEFT);
    mark(db, "}", CatspeakToken.BRACE_RIGHT);
    mark(db, ",", CatspeakToken.COMMA);
    /// @ignore
    global.__catspeakDatabaseByteToToken = db;
}

/// @ignore
function __catspeak_init_lexer_database_token_mark(db, query, value) {
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
