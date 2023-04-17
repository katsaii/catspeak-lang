//! Contains the primary user-facing API for consuming Catspeak.

//# feather use syntax-errors

/// Packages all common Catspeak features into a neat, configurable box.
function CatspeakEnvironment() constructor {
    self.keywords = undefined;

    /// Returns the keyword store for this Catspeak engine, allowing you to
    /// modify how the Catspeak lexer interprets keywords.
    ///
    /// @return {Struct}
    static getKeywords = function () {
        keywords ??= catspeak_keywords_create();
        return keywords;
    };

    /// Creates a new [CatspeakLexer] from the supplied buffer, overriding
    /// the keyword database if one exists for this [CatspeakEngine].
    ///
    /// NOTE: The lexer does not take ownership of this buffer, but it may mutate
    ///       it so beware. Therefore you should make sure to delete the buffer
    ///       once parsing is complete.
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
    /// @return {Struct.CatspeakLexer}
    static tokenise = function (buff, offset=undefined, size=undefined) {
        var lexer = new CatspeakLexer(buff, offset, size);
        if (keywords != undefined) {
            lexer.withKeywords(keywords);
        }
        return lexer;
    };
}

/// The default Catspeak environment. Mainly exists for UX reasons.
globalvar Catspeak;

/// @ignore
function __catspeak_init_engine() {
    // initialise the default Catspeak engine
    Catspeak = new CatspeakEnvironment();
}