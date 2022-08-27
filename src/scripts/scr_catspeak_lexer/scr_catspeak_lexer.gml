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

/// Returns the descriptor for this ASCII character. Uses the default
/// descriptor database returned by `catspeak_ascii_descriptor_database_get`.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakASCIIDesc}
function catspeak_byte_get_desc(char) {
    gml_pragma("forceinline");
    return catspeak_byte_get_desc_ext(char,
            catspeak_ascii_database_get());
}

/// Returns the descriptor for this ASCII character. Allows for a custom
/// descriptor database to be passed as a parameter.
///
/// @param {Real} char
///   The character to check.
///
/// @param {Array<Enum.CatspeakASCIIDesc>} db
///   The descriptor database to use. Must be an array whose length is exactly
///   256 elements long.
///
/// @return {Enum.CatspeakASCIIDesc}
function catspeak_byte_get_desc_ext(char, db) {
    gml_pragma("forceinline");
    return char < 0 || char > 255 ? CatspeakASCIIDesc.NONE : db[char];
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