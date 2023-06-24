//! Contains the primary user-facing API for consuming Catspeak.

//# feather use syntax-errors

/// Packages all common Catspeak features into a neat, configurable box.
function CatspeakEnvironment() constructor {
    self.keywords = undefined;
    self.interface = undefined;
    self.sharedGlobal = undefined;

    /// Enables the shared global feature on this Catspeak environment. This
    /// forces all compiled programs to share the same global variable scope.
    ///
    /// Typically this should not be enabled, but it can be useful for REPL
    /// (Read-Eval-Print-Loop) style command consoles, where variables persist
    /// between commands.
    ///
    /// Returns the shared global struct if this feature is enabled, or
    /// `undefined` if the feature is disabled.
    ///
    /// @param {Bool} [enabled]
    ///   Whether to enable this feature. Defaults to `true`.
    ///
    /// @return {Struct}
    static enableSharedGlobal = function (enabled=true) {
         if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("enabled", enabled, is_numeric);
        }
        sharedGlobal = enabled ? { } : undefined;
        return sharedGlobal;
    };

    /// Applies list of presets to this Catspeak environment. These changes
    /// cannot be undone, so only choose presets you really need.
    ///
    /// @param {Enum.CatspeakPreset} preset
    ///   The preset type to apply.
    ///
    /// @param {Enum.CatspeakPreset} ...
    ///   Additional preset arguments.
    static applyPreset = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var presetFunc = __catspeak_preset_get(argument[i]);
            presetFunc(self);
        }
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
        var compiler = new CatspeakGMLCompiler(asg, interface);
        var result;
        do {
            result = compiler.update();
        } until (result != undefined);
        if (sharedGlobal != undefined) {
            // patch global
            result.setGlobals(sharedGlobal);
        }
        return result;
    };

    /// Used to change the string representation of a Catspeak keyword.
    ///
    /// @param {String} currentName
    ///   The current string representation of the keyword to change.
    ///
    /// @param {String} newName
    ///   The new string representation of the keyword.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static renameKeyword = function () {
        keywords ??= __catspeak_keywords_create();
        var keywords_ = keywords;
        for (var i = 0; i < argument_count; i += 2) {
            var currentName = argument[i];
            var newName = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("currentName", currentName, is_string);
                __catspeak_check_arg("newName", newName, is_string);
            }
            __catspeak_keywords_rename(keywords, currentName, newName);
        }
    };

    /// Used to add a new Catspeak keyword alias.
    ///
    /// @param {String} name
    ///   The name of the keyword to add.
    ///
    /// @param {Enum.CatspeakToken} token
    ///   The token this keyword should represent.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static addKeyword = function () {
        keywords ??= __catspeak_keywords_create();
        var keywords_ = keywords;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            var token = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            keywords_[$ name] = token;
        }
    };

    /// Used to remove an existing Catspeak keyword from this environment.
    ///
    /// @param {String} name
    ///   The name of the keyword to remove.
    ///
    /// @param {String} ...
    ///   Additional keywords to remove.
    static removeKeyword = function () {
        keywords ??= __catspeak_keywords_create();
        var keywords_ = keywords;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            if (variable_struct_exists(keywords_, name)) {
                variable_struct_remove(keywords_, name);
            }
        }
    };

    /// Used to add a new function to this environment.
    ///
    /// @param {String} name
    ///   The name of the function as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script or function to add.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static addFunction = function () {
        interface ??= { };
        var interface_ = interface;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            var func = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            func = is_method(func) ? func : method(undefined, func);
            interface_[$ name] = func;
        }
    };

    /// Used to remove an existing function from this environment.
    ///
    /// NOTE: Unlike [removeConstant], this function will only remove the
    ///       definition if it is a method (checked using `is_method`).
    ///
    /// @param {String} name
    ///   The name of the function to remove.
    ///
    /// @param {String} ...
    ///   Additional functions to remove.
    static removeFunction = function () {
        interface ??= { };
        var interface_ = interface;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            if (
                variable_struct_exists(interface_, name) &&
                is_method(interface_[$ name])
            ) {
                variable_struct_remove(interface_, name);
            }
        }
    };

    /// Used to add a new constant to this environment.
    ///
    /// NOTE: ALthough you can use this to add functions, it's recommended
    ///       to use [addFunction] for that purpose instead.
    ///
    /// @param {String} name
    ///   The name of the constant as it will appear in Catspeak.
    ///
    /// @param {Any} value
    ///   The constant value to add.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static addConstant = function () {
        interface ??= { };
        var interface_ = interface;

        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            var value = argument[i + 1];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            interface_[$ name] = value;
        }
    };

    /// Used to remove an existing constant from this environment.
    ///
    /// NOTE: ALthough you can use this to remove functions, it's
    ///       recommended to use [removeFunction] for that purpose instead.
    ///
    /// @param {String} name
    ///   The name of the constant to remove.
    ///
    /// @param {String} ...
    ///   Additional constants to remove.
    static removeConstant = function () {
        interface ??= { };
        var interface_ = interface;
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i];
            if (CATSPEAK_DEBUG_MODE) {
                __catspeak_check_arg("name", name, is_string);
            }
            if (variable_struct_exists(interface_, name)) {
                variable_struct_remove(interface_, name);
            }
        }
    };
}

/// A usability function for converting special GML constants, such as
/// `self` or `global` into structs.
///
/// Will return `undefined` if there does not exist a valid conversion.
///
/// @param {Any} gmlSpecial
///   Any special value to convert into a struct.
///
/// @return {Struct}
function catspeak_special_to_struct(gmlSpecial) {
    if (is_struct(gmlSpecial)) {
        return gmlSpecial;
    }
    if (gmlSpecial == global) {
        var getGlobal = method(global, function () { return self });
        return getGlobal();
    }
    if (__catspeak_is_withable(gmlSpecial)) {
        with (gmlSpecial) {
            // magic to convert an id into its struct version
            return self;
        }
    }
    __catspeak_error_silent(
        "could not convert special GML value '", gmlSpecial, "' ",
        "into a valid Catspeak representation"
    );
    return undefined;
}

/// The default Catspeak environment. Mainly exists for UX reasons.
globalvar Catspeak;

/// @ignore
function __catspeak_init_engine() {
    // initialise the default Catspeak engine
    Catspeak = new CatspeakEnvironment();
}