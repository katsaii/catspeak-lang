//! Boilerplate for the `CatspeakASCIIDescriptor` enum.
//! NOTE: AVOID EDITING THIS FILE, IT HAS BEEN AUTOMATICALLY GENERATED!

//# feather use syntax-errors

/// Simple tags that identify ASCII characters read from a GML buffer.
enum CatspeakASCIIDescriptor {
    NONE = 0,
    NEWLINE = (1 << 0),
    WHITESPACE = (1 << 1),
    ALPHABETIC = (1 << 2),
    GRAPHIC = (1 << 3),
    DIGIT = (1 << 4),
    DIGIT_HEX = (1 << 5),
    DIGIT_BIN = (1 << 6),
    OPERATOR = (1 << 7),
    ALL = (
        CatspeakASCIIDescriptor.NONE
        | CatspeakASCIIDescriptor.NEWLINE
        | CatspeakASCIIDescriptor.WHITESPACE
        | CatspeakASCIIDescriptor.ALPHABETIC
        | CatspeakASCIIDescriptor.GRAPHIC
        | CatspeakASCIIDescriptor.DIGIT
        | CatspeakASCIIDescriptor.DIGIT_HEX
        | CatspeakASCIIDescriptor.DIGIT_BIN
        | CatspeakASCIIDescriptor.OPERATOR
    ),
}

/// Marks all characters which match a query with a descriptor.
///
/// @param {Enum.CatspeakASCIIDescriptor} descriptor
///   The descriptor to mark.
///
/// @param {Any} query
///   The query used to search for elements. Can be one of: Array of ASCII
///   characters, function which takes a character and returns true/false,
///   or a single ASCII character to update.
///
/// @param {Array<Enum.CatspeakASCIIDescriptor>} db
///   The descriptor database to update.
function catspeak_ascii_descriptor_database_mark(descriptor, query, db) {
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

/// Returns the ASCII descriptor database.
///
/// @return {Array<Enum.CatspeakASCIIDescriptor>}
function catspeak_ascii_descriptor_database_get() {
    static db = undefined;
    if (db == undefined) {
        db = array_create(256, CatspeakASCIIDescriptor.NONE);
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.WHITESPACE,
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
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.NEWLINE,
            [
                0x0A, // LINE FEED ('\n')
                0x0D, // CARRIAGE RETURN ('\r')
            ],
            db
        );
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.ALPHABETIC
            | CatspeakASCIIDescriptor.GRAPHIC,
            function(char) {
                return char >= ord("a") && char <= ord("z")
                        || char >= ord("A") && char <= ord("Z");
            },
            db
        );
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.GRAPHIC,
            ["_", "'"],
            db
        );
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.DIGIT
            | CatspeakASCIIDescriptor.DIGIT_HEX
            | CatspeakASCIIDescriptor.GRAPHIC,
            function(char) {
                return char >= ord("0") && char <= ord("9");
            },
            db
        );
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.DIGIT_BIN,
            ["0", "1"],
            db
        );
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.DIGIT_HEX,
            function(char) {
                return char >= ord("a") && char <= ord("f")
                        || char >= ord("A") && char <= ord("F");
            },
            db
        );
        catspeak_ascii_descriptor_database_mark(
            CatspeakASCIIDescriptor.OPERATOR,
            function(char) {
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

/// Returns the descriptor for this ASCII character. Uses the default
/// descriptor database returned by `catspeak_ascii_descriptor_database_get`.
///
/// @param {Real} char
///   The character to check.
///
/// @return {Enum.CatspeakASCIIDescriptor}
function catspeak_byte_get_descriptor(char) {
    return catspeak_byte_get_descriptor_ext(char,
            catspeak_ascii_descriptor_database_get());
}

/// Returns the descriptor for this ASCII character. Allows for a custom
/// descriptor database to be passed as a parameter.
///
/// @param {Real} char
///   The character to check.
///
/// @param {Array<Enum.CatspeakASCIIDescriptor>} db
///   The descriptor database to use. Must be an array whose length is exactly
///   256 elements long.
///
/// @return {Enum.CatspeakASCIIDescriptor}
function catspeak_byte_get_descriptor_ext(char, db) {
    if (char < 0 || char > 255) {
        return CatspeakASCIIDescriptor.NONE;
    }
    return db[char];
}
