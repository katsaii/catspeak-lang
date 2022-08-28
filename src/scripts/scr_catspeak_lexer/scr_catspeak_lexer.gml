//! Handles the lexical analysis stage of the Catspeak compiler.

/// Tokenises the contents of a GML buffer. The lexer does not take ownership
/// of this buffer, but it may mutate it so beware. Therefore you should make
/// sure to delete the buffer once parsing is complete.
///
/// @param {ID.Buffer} buff
///   The ID of the GML buffer to use.
///
/// @param {Array<Enum.CatspeakASCIIDesc>} [db]
///   The ASCII database to use, defaults to the global database. This
///   modifies how the lexer interprets the character codes read from the
///   buffer. 
function CatspeakLexer(buff, db) constructor {
    self.db = db ?? catspeak_ascii_database_get();
    self.buff = buff;
    self.alignment = buffer_get_alignment(buff);
    self.limit = buffer_get_size(buff);
    self.eof = false;
    self.cr = false;
    self.skipNextByte = false;
    self.lexeme = undefined;
    self.lexemeLength = 0;
    self.posStart = new CatspeakLocation(1, 1);
    self.posEnd = self.lexemePos.clone();

    /// Updates the line and column numbers of the lexer, also updates the.
    /// current length of the lexeme, in bytes.
    ///
    /// @param {Real} byte
    ///   The byte to consider.
    static registerByte = function(byte) {
        lexemeLength += 1;
        if (byte == ord("\r")) {
            cr = true;
            col = 1;
            row += 1;
        } else if (byte == ord("\n")) {
            col = 1;
            if (cr) {
                cr = false;
            } else {
                row += 1;
            }
        } else {
            col += 1;
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
            eofReached = true;
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
            if (!catspeak_byte_contains_desc(byte, db, desc)) {
                break;
            }
            registerByte(byte);
            seek += alignment;
        }
        if (seek >= limit) {
            eofReached = true;
        }
        buffer_seek(buff, buffer_seek_start, seek);
        return byte;
    }

    /// Advances the lexer and returns the next `CatspeakToken`.
    ///
    /// @return {Enum.CatspeakToken}
    static next = function() {
        // TODO
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

/// Returns whether a byte matches an expected ASCII descriptor of.
///
/// @param {Real} char
///   The character to check.
///
/// @param {Array<Enum.CatspeakASCIIDesc>} db
///   The descriptor database to use. Must be an array whose length is exactly
///   256 elements long.
///
/// @param {Any} descriptor
///   The descriptor to check.
///
/// @return {Bool}
function catspeak_byte_contains_desc(char, db, descriptor) {
    gml_pragma("forceinline");
    if (char < 0 || char > 255) {
        return false;
    }
    return (db[char] & descriptor) == descriptor;
}

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