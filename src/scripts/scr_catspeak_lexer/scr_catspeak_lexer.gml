//! Handles the lexical analysis stage of the Catspeak compiler.

var s = "this ? is : a ; test -- string";
var buff = buffer_create(string_byte_length(s), buffer_fixed, 1);
buffer_write(buff, buffer_text, s);
buffer_seek(buff, buffer_seek_start, 0);
var lex = new CatspeakLexer(buff);
while (!lex.eof) {
    var a = catspeak_token_show(lex.next());
    show_message([a, lex.lexeme]);
}

/// Tokenises the contents of a GML buffer. The lexer does not take ownership
/// of this buffer, but it may mutate it so beware. Therefore you should make
/// sure to delete the buffer once parsing is complete.
///
/// @param {ID.Buffer} buff
///   The ID of the GML buffer to use.
function CatspeakLexer(buff) constructor {
    self.buff = buff;
    self.alignment = buffer_get_alignment(buff);
    self.limit = buffer_get_size(buff);
    self.eof = false;
    self.cr = false;
    self.skipNextByte = false;
    self.lexeme = undefined;
    self.lexemeLength = 0;
    self.posStart = new CatspeakLocation(1, 1);
    self.posEnd = self.posStart.clone();

    /// Updates the line and column numbers of the lexer, also updates the.
    /// current length of the lexeme, in bytes.
    ///
    /// @param {Real} byte
    ///   The byte to consider.
    static registerByte = function(byte) {
        lexemeLength += 1;
        if (byte == ord("\r")) {
            cr = true;
            posEnd.column = 1;
            posEnd.line += 1;
        } else if (byte == ord("\n")) {
            posEnd.column = 1;
            if (cr) {
                cr = false;
            } else {
                posEnd.line += 1;
            }
        } else {
            posEnd.column += 1;
            cr = false;
        }
    }

    /// Registers the current lexeme as a string.
    static registerLexeme = function() {
        if (lexemeLength < 1) {
            // always an empty slice
            lexeme = "";
            return;
        }
        var buff_ = buff;
        var offset = buffer_tell(buff_);
        var byte = buffer_peek(buff_, offset, buffer_u8);
        buffer_poke(buff_, offset, buffer_u8, 0x00);
        buffer_seek(buff_, buffer_seek_start, offset - lexemeLength);
        lexeme = buffer_read(buff_, buffer_string);
        buffer_seek(buff_, buffer_seek_relative, -1);
        buffer_poke(buff_, offset, buffer_u8, byte);
    }

    /// Resets the current lexeme.
    static clearLexeme = function() {
        lexemeLength = 0;
        lexeme = undefined;
        posStart.line = posEnd.line;
        posStart.column = posEnd.column;
    }

    /// @desc Advances the scanner and returns the current byte.
    static advance = function() {
        var seek = buffer_tell(buff);
        if (seek + 1 >= limit) {
            eof = true;
        }
        var byte = buffer_read(buff, buffer_u8);
        registerByte(byte);
        return byte;
    }

    /// @desc Peeks `n` bytes ahead of the current buffer offset.
    ///
    /// @param {Real} n
    ///   The number of bytes to look ahead.
    static peek = function(n) {
        var offset = buffer_tell(buff) + n - 1;
        if (offset >= limit) {
            return -1;
        }
        return buffer_peek(buff, offset, buffer_u8);
    }

    /// @desc Advances the lexer whilst a bytes contain some expected ASCII
    /// descriptor, or until the end of the file is reached.
    ///
    /// @param {Enum.CatspeakASCIIDesc} desc
    ///   The descriptor to check for.
    static advanceWhile = function(desc) {
        var byte = undefined;
        var seek = buffer_tell(buff);
        while (seek < limit) {
            byte = buffer_peek(buff, seek, buffer_u8);
            var expect = catspeak_byte_to_asciidesc(byte);
            if (!catspeak_asciidesc_contains(expect, desc)) {
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
    }

    /// Advances the lexer and returns the next `CatspeakToken`.
    ///
    /// @return {Enum.CatspeakToken}
    static next = function() {
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
        var desc = catspeak_byte_to_asciidesc(byte);
        if (catspeak_asciidesc_contains(desc,
                CatspeakASCIIDesc.OPERATOR)) {
            advanceWhile(CatspeakASCIIDesc.OPERATOR);
            registerLexeme();
            token = catspeak_string_to_token_keyword(lexeme) ?? token;
            if (token == CatspeakToken.COMMENT) {
                // TODO, comments
            }
        } else if (catspeak_asciidesc_contains(desc,
                CatspeakASCIIDesc.ALPHABETIC)) {
            advanceWhile(CatspeakASCIIDesc.GRAPHIC);
            registerLexeme();
            token = catspeak_string_to_token_keyword(lexeme) ?? token;
        } else if (catspeak_asciidesc_contains(desc,
                CatspeakASCIIDesc.DIGIT)) {
            // TODO, numeric literals
        } else if (byte == "\"") {
            // TODO, strings
        } else if (byte == "`") {
            // TODO, identifier literals
        }
        return token;
    }

    /// Advances the lexer and returns the next `CatspeakToken`, ingoring
    /// any comments and whitespace.
    ///
    /// @return {Enum.CatspeakToken}
    static nextWithoutSpace = function() {
        // TODO
    }
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
        }, CatspeakToken.INT);
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
function catspeak_byte_to_asciidesc(char) {
    static db = undefined;
    if (char < 0 || char > 255) {
        return CatspeakASCIIDesc.NONE;
    }
    if (db == undefined) {
        db = array_create(256, CatspeakASCIIDesc.NONE);
        __catspeak_mark_asciidesc(db, [
            0x09, // CHARACTER TABULATION ('\t')
            0x0A, // LINE FEED ('\n')
            0x0B, // LINE TABULATION ('\v')
            0x0C, // FORM FEED ('\f')
            0x0D, // CARRIAGE RETURN ('\r')
            0x20, // SPACE (' ')
            0x85, // NEXT LINE
        ], CatspeakASCIIDesc.WHITESPACE);
        __catspeak_mark_asciidesc(db, [
            0x0A, // LINE FEED ('\n')
            0x0D, // CARRIAGE RETURN ('\r')
        ], CatspeakASCIIDesc.NEWLINE);
        __catspeak_mark_asciidesc(db, function (char) {
            return char >= ord("a") && char <= ord("z")
                    || char >= ord("A") && char <= ord("Z");
        }, CatspeakASCIIDesc.ALPHABETIC | CatspeakASCIIDesc.GRAPHIC);
        __catspeak_mark_asciidesc(db, ["_", "'"], CatspeakASCIIDesc.GRAPHIC);
        __catspeak_mark_asciidesc(db, function (char) {
            return char >= ord("0") && char <= ord("9");
        }, CatspeakASCIIDesc.DIGIT
                | CatspeakASCIIDesc.DIGIT_HEX
                | CatspeakASCIIDesc.GRAPHIC);
        __catspeak_mark_asciidesc(db, ["0", "1"], CatspeakASCIIDesc.DIGIT_BIN);
        __catspeak_mark_asciidesc(db, function (char) {
            return char >= ord("a") && char <= ord("f")
                    || char >= ord("A") && char <= ord("F");
        }, CatspeakASCIIDesc.DIGIT_HEX);
        __catspeak_mark_asciidesc(db, [
            "!", "#", "$", "%", "&", "*", "+", "-", ".", "/", ":", ";", "<",
            "=", ">", "?", "@", "\\", "^", "|", "~",
        ], CatspeakASCIIDesc.OPERATOR);
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
function __catspeak_mark_asciidesc(db, query, value) {
    if (!is_array(query)) {
        query = [query];
    }
    var count = array_length(query);
    var countDb = array_length(db);
    for (var i = 0; i < count; i += 1) {
        var queryItem = query[i];
        if (is_method(query)) {
            for (var i = 0; i < countDb; i += 1) {
                if (query(i)) {
                    db[@ i] |= value;
                }
            }
            continue;
        }
        var byte = is_string(queryItem) ? ord(queryItem) : queryItem;
        db[@ byte] |= value;
    }
}

/*
/// Marks all characters which match a query with a descriptor.
///
/// @param {Enum.CatspeakASCIIDesc} descriptor
///   The descriptor to mark.
///
/// @param {Any} query
///   The query used to search for elements. Can be one of: Array of ASCII
///   characters, function which takes a character and returns true/false,
///   or a single ASCII character to update.
///
/// @param {Array<Enum.CatspeakASCIIDesc>} [db]
///   The descriptor database to update, defaults to the global database.
function catspeak_ascii_database_mark(descriptor, query, db) {
    db ??= catspeak_ascii_database_get();
    if (is_method(query) || is_real(query) && script_exists(query)) {
        for (var i = 0; i < 256; i += 1) {
            if (query(i)) {
                db[@ i] |= descriptor;
            }
        }
        return;
    }
    if (!is_array(query)) {
        query = [query];
    }
    var count = array_length(query);
    for (var i = 0; i < count; i += 1) {
        var char = query[i];
        if (is_string(char)) {
            char = ord(char);
        }
        db[@ char] |= descriptor;
    }
}

/// Returns the ASCII global descriptor database.
///
/// @return {Array<Enum.CatspeakASCIIDesc>}
function catspeak_ascii_database_get() {
    static db = undefined;
    if (db == undefined) {
        db = array_create(256, CatspeakASCIIDesc.NONE);
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.WHITESPACE,
            [
                0x09, // CHARACTER TABULATION ('\t')
                0x0A, // LINE FEED ('\n')
                0x0B, // LINE TABULATION ('\v')
                0x0C, // FORM FEED ('\f')
                0x0D, // CARRIAGE RETURN ('\r')
                0x20, // SPACE (' ')
                0x85, // NEXT LINE
            ],
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.NEWLINE,
            [
                0x0A, // LINE FEED ('\n')
                0x0D, // CARRIAGE RETURN ('\r')
            ],
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.ALPHABETIC
            | CatspeakASCIIDesc.GRAPHIC,
            function (char) {
                return char >= ord("a") && char <= ord("z")
                        || char >= ord("A") && char <= ord("Z");
            },
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.GRAPHIC,
            ["_", "'"],
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.DIGIT
            | CatspeakASCIIDesc.DIGIT_HEX
            | CatspeakASCIIDesc.GRAPHIC,
            function (char) {
                return char >= ord("0") && char <= ord("9");
            },
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.DIGIT_BIN,
            ["0", "1"],
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.DIGIT_HEX,
            function (char) {
                return char >= ord("a") && char <= ord("f")
                        || char >= ord("A") && char <= ord("F");
            },
            db
        );
        catspeak_ascii_database_mark(
            CatspeakASCIIDesc.OPERATOR,
            function (char) {
                return char == ord("!")
                        || char >= ord("#") && char <= ord("&")
                        || char == ord("*")
                        || char == ord("+")
                        || char == ord("-")
                        || char == ord("/")
                        || char >= ord("<") && char <= ord("@")
                        || char == ord("^")
                        || char == ord("|")
                        || char == ord("~");
            },
            db
        );
    }
    return db;
}
*/