//! Contains the primary user-facing API for consuming Catspeak.

//# feather use syntax-errors

/// Represents optional features which can be passed to various parts of
/// the Catspeak environment to modify their behaviours.
enum CatspeakFeature {
    /// No features.
    NONE,
    /// Perform totality checking when parsing programs to ensure programs
    /// never enter infinite loops.
    TOTAL = 0x1,
}

/// Packages all common Catspeak features into a neat, configurable box.
function CatspeakEnvironment() constructor {
    self.keywords = undefined;
    self.features = undefined;

    /// Returns the keyword store for this Catspeak engine, allowing you to
    /// modify how the Catspeak lexer interprets keywords.
    ///
    /// @return {Struct}
    static getKeywords = function () {
        keywords ??= catspeak_keywords_create();
        return keywords;
    };

    /// Sets the list of features to enable for any Catspeak programs compiled
    /// with this Catspeak engine. Pass `undefined` to reset the feature flags
    /// back to the defaults.
    ///
    /// @param {Enum.CatspeakFeature} featureFlags
    ///   The Catspeak features to enable.
    static withFeatures = function (featureFlags) {
        self.features = featureFlags;
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
        var lexer = new CatspeakLexer(buff, offset, size);
        if (keywords != undefined) {
            lexer.withKeywords(keywords);
        }
        return lexer;
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
        if (features != undefined) {
            // withFeatures() will do argument validation
            parser.withFeatures(features);
        }
        while (parser.inProgress()) {
            parser.update();
        }
        return builder.get();
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
        // tokenise() will do argument validation
        var compiler = new CatspeakGMLCompiler(asg);
        while (compiler.inProgress()) {
            compiler.update();
        }
        return compiler.get();
    };
}

/// The default Catspeak environment. Mainly exists for UX reasons.
globalvar Catspeak;

/// @ignore
function __catspeak_init_engine() {
    // initialise the default Catspeak engine
    Catspeak = new CatspeakEnvironment();
}