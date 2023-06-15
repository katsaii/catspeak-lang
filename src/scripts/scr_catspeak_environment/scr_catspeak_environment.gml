//! Contains the primary user-facing API for consuming Catspeak.

//# feather use syntax-errors

/// Packages all common Catspeak features into a neat, configurable box.
function CatspeakEnvironment() constructor {
    self.keywords = undefined;
    self.interface = undefined;

    /// Returns the keyword store for this Catspeak engine, allowing you to
    /// modify how the Catspeak lexer interprets keywords.
    ///
    /// @return {Struct}
    static getKeywords = function () {
        keywords ??= __catspeak_keywords_create();
        return keywords;
    };

    /// Used to change the string representation of a Catspeak keyword.
    ///
    /// @param {String} currentName
    ///   The current string representation of the keyword to change.
    ///
    /// @param {String} newName
    ///   The new string representation of the keyword.
    static renameKeyword = function (currentName, newName) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("currentName", currentName, is_string);
            __catspeak_check_arg("newName", newName, is_string);
        }

        __catspeak_keywords_rename(getKeywords(), currentName, newName);
    };

    /// Erases the identity of Catspeak programs by replacing all keywords with
    /// GML-adjacent alternatives.
    static presetGMLStyle = function () {
        var keywords_ = getKeywords();
        __catspeak_keywords_rename(keywords_, "//", "div");
        __catspeak_keywords_rename(keywords_, "--", "//");
        __catspeak_keywords_rename(keywords_, "let", "var");
        __catspeak_keywords_rename(keywords_, "fun", "function");
        __catspeak_keywords_rename(keywords_, "impl", "constructor");
        keywords_[$ "&&"] = CatspeakToken.AND;
        keywords_[$ "||"] = CatspeakToken.OR;
        keywords_[$ "mod"] = CatspeakToken.REMAINDER;
        keywords_[$ "not"] = CatspeakToken.NOT;
    };

    /// Returns the external function/constant store for this Catspeak engine,
    /// allowing you to modify what functions are exposed to the Catspeak
    /// runtime.
    ///
    /// @return {Struct}
    static getInterface = function () {
        interface ??= __catspeak_interface_create();
        return interface;
    };

    /// Creates a new [CatspeakLexer] from the supplied buffer, overriding
    /// the keyword database if one exists for this [CatspeakEngine].
    ///
    /// NOTE: The lexer does not take ownership of this buffer, but it may
    ///       mutate it so beware. Therefore you should make sure to delete
    ///       the buffer once parsing is complete.
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
        // CatspeakLexer() will do argument validation
        return new CatspeakLexer(buff, offset, size, keywords);
    };

    /// Parses a buffer containing a Catspeak program into a bespoke format
    /// understood by Catpskeak. Overrides the keyword database if one exists
    /// for this [CatspeakEngine].
    ///
    /// NOTE: The parser does not take ownership of this buffer, but it may
    ///       mutate it so beware. Therefore you should make sure to delete
    ///       the buffer once parsing is complete.
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
    static parse = function (buff, offset=undefined, size=undefined) {
        // tokenise() will do argument validation
        var lexer = tokenise(buff, offset, size);
        var builder = new CatspeakASGBuilder();
        var parser = new CatspeakParser(lexer, builder);
        var moreToParse;
        do {
            moreToParse = parser.update();
        } until (!moreToParse);
        return builder.get();
    };

    /// Similar to [parse], except a string is used instead of a buffer.
    ///
    /// @param {String} src
    ///   The string containing Catspeak source code to parse.
    ///
    /// @return {Struct.CatspeakLexer}
    static parseString = function (src) {
        var buff = __catspeak_create_buffer_from_string(src);
        return Catspeak.parse(buff);
    };

    /// Similar to [parse], except it will pass the responsibility of
    /// parsing to this sessions async handler.
    ///
    /// NOTE: The async handler can be customised, and therefore any
    ///       third-party handlers are not guaranteed to finish within a
    ///       reasonable time.
    ///
    /// NOTE: The parser does not take ownership of this buffer, but it may
    ///       mutate it so beware. Therefore you should make sure to delete
    ///       the buffer once parsing is complete.
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
    /// @return {Struct.Future}
    static parseAsync = function (buff, offset=undefined, size=undefined) {
        __catspeak_error_unimplemented("async-parsing");
    };

    /// Compiles a syntax graph into a GML function. See the [parse] function
    /// for how to generate a syntax graph from a Catspeak script.
    ///
    /// @param {Struct} asg
    ///   The syntax graph to convert into a GML function.
    ///
    /// @return {Function}
    static compileGML = function (asg) {
        // CatspeakGMLCompiler() will do argument validation
        var compiler = new CatspeakGMLCompiler(asg);
        var result;
        do {
            result = compiler.update();
        } until (result != undefined);
        return result;
    };
}

/// The default Catspeak environment. Mainly exists for UX reasons.
globalvar Catspeak;

/// @ignore
function __catspeak_init_engine() {
    // initialise the default Catspeak engine
    Catspeak = new CatspeakEnvironment();
}