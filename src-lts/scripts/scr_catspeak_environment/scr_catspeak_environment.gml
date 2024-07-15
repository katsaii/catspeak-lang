//! The primary user-facing API for compiling Catspeak programs and
//! configuring the Catspeak runtime environment.
//!
//! @example
//!   A high-level overview of Catspeak usage. The example walks through how
//!   to compile, execute, and introspect the global variables of a Catspeak
//!   script:
//!   ```gml
//!   // parse Catspeak code
//!   var ir = Catspeak.parseString(@'
//!     count = 0
//!     counter = fun {
//!       count += 1
//!       return count
//!     }
//!   ');
//!
//!   // compile Catspeak code into a callable GML function
//!   var main = Catspeak.compileGML(ir);
//!
//!   // initialise the Catspeak script by calling its main entry point
//!   catspeak_execute(main);
//!
//!   // grab the counter function from the script
//!   var counter = catspeak_globals(main).counter;
//!
//!   // call the Catspeak `counter` function from GML!
//!   show_message(counter()); // prints 1
//!   show_message(counter()); // prints 2
//!   show_message(counter()); // prints 3
//!   show_message(counter()); // prints 4
//!   ```

//# feather use syntax-errors

/// Encapsulates all common Catspeak features into a single, configurable box.
function CatspeakEnvironment() constructor {
    /// @ignore
    self.keywords = undefined;
    /// The foreign interface used by this Catspeak environment. This is where
    /// all external GML functions and constants are exposed to the Catspeak
    /// runtime environment.
    ///
    /// @return {Struct.CatspeakForeignInterface}
    self.interface = new CatspeakForeignInterface();
    /// @ignore
    self.sharedGlobal = undefined;
    /// The tokeniser to use for this Catspeak environment. Defaults to
    /// `CatspeakLexer`.
    ///
    /// @experimental
    ///
    /// @return {Function}
    self.lexerType = CatspeakLexer;
    /// The parser to use for this Catspeak environment. Defaults to
    /// `CatspeakParser`.
    ///
    /// @experimental
    ///
    /// @return {Function}
    self.parserType = CatspeakParser;
    /// The code generator to use for this Catspeak environment. Defaults to
    /// `CatspeakGMLCompiler`.
    ///
    /// @experimental
    ///
    /// @return {Function}
    self.codegenType = CatspeakGMLCompiler;

    /// Enables the shared global feature on this Catspeak environment,
    /// forcing all Catspeak programs compiled after this point to share the
    /// same global variable scope.
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
    /// You can add additional presets using the `catspeak_preset_add` function.
    ///
    /// @experimental
    ///
    /// @example
    ///   Enabling the math and draw presets on the default Catspeak
    ///   environment:
    ///   ```gml
    ///   Catspeak.applyPreset(
    ///     CatspeakPreset.MATH,
    ///     CatspeakPreset.DRAW
    ///   );
    ///   ```
    ///
    /// @param {Enum.CatspeakPreset} preset
    ///   The preset type to apply.
    ///
    /// @param {Enum.CatspeakPreset} ...
    ///   Additional presets.
    static applyPreset = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var presetFunc = __catspeak_preset_get(argument[i]);
            presetFunc(getInterface());
        }
    };

    /// @deprecated {3.0.0}
    ///   Use `Catspeak.interface` instead.
    ///
    /// @return {Struct.CatspeakForeignInterface}
    static getInterface = function () {
        interface ??= new CatspeakForeignInterface();
        return interface;
    };

    /// Creates a new lazy tokeniser from the supplied buffer, overriding
    /// the keyword database if one exists for the current Catspeak
    /// environment.
    ///
    /// @warning
    ///   The lexer does not take ownership of this buffer, so you must make
    ///   sure to delete it after calling this function. Failure to do this
    ///   will result in leaking memory.
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
    /// @return {Struct}
    static tokenise = function (buff, offset=undefined, size=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("buff", buff, buffer_exists);
            __catspeak_check_arg_optional("offset", offset, is_numeric);
            __catspeak_check_arg_optional("size", size, is_numeric);
        }
        return new lexerType(buff, offset, size, keywords);
    };

    /// Parses a buffer containing a Catspeak program into a bespoke format
    /// understood by Catspeak. Overrides the keyword database if one exists
    /// for this `CatspeakEngine`.
    ///
    /// @warning
    ///   The parser does not take ownership of this buffer, so you must make
    ///   sure to delete it after calling this function. Failure to do this
    ///   will result in leaking memory.
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
    /// @return {Struct}
    static parse = function (buff, offset=undefined, size=undefined) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("buff", buff, buffer_exists);
            __catspeak_check_arg_optional("offset", offset, is_numeric);
            __catspeak_check_arg_optional("size", size, is_numeric);
        }
        var lexer = tokenise(buff, offset, size);
        var builder = new CatspeakIRBuilder();
        var parser = new parserType(lexer, builder);
        var moreToParse;
        do {
            moreToParse = parser.update();
        } until (!moreToParse);
        return builder.get();
    };

    /// Similar to `Catspeak.parse`, except a string is used instead of a buffer.
    ///
    /// @param {String} src
    ///   The string containing Catspeak source code to parse.
    ///
    /// @return {Struct}
    static parseString = function (src) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("src", src, is_string);
        }
        var buff = __catspeak_create_buffer_from_string(src);
        var result = parse(buff);
        buffer_delete(buff);
        return result;
    };

    /// Similar to `parse`, except it will pass the responsibility of
    /// parsing to this environments async handler.
    ///
    /// @experimental
    ///
    /// @remark
    ///   The async handler can be customised, and therefore any
    ///   third-party handlers are not guaranteed to finish within a
    ///   reasonable time.
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
    static parseAsync = function (buff, offset=undefined, size=undefined) {
        __catspeak_error_unimplemented("async-parsing");
    };

    /// Compiles Catspeak IR into its final representation.
    ///
    /// @remark
    ///   By default, the result is a function callable from GML. However,
    ///   this may vary if you have customised the `codegen` field on this
    ///   environment.
    ///
    /// @param {Struct} ir
    ///   The Catspeak IR to compile. You can get this from `Catspeak.parse`.
    ///
    /// @return {Function}
    static compile = function (ir) {
        if (CATSPEAK_DEBUG_MODE) {
            __catspeak_check_arg("ir", ir, is_struct);
        }
        var compiler = new codegenType(ir, interface);
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

    /// Compiles Catspeak IR into a callable GML function.
    ///
    /// @deprecated {3.0.2}
    ///   Use `Catspeak.compile` instead.
    ///
    /// @param {Struct} ir
    ///   The Catspeak IR to compile. You can get this from `Catspeak.parse`.
    ///
    /// @return {Function}
    static compileGML = compile;

    /// Used to change the string representation of a Catspeak keyword.
    ///
    /// @experimental
    ///
    /// @param {String} currentName
    ///   The current string representation of the keyword to change.
    ///   E.g. `"fun"`
    ///
    /// @param {String} newName
    ///   The new string representation of the keyword.
    ///   E.g. `"function"`
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
    /// @experimental
    ///
    /// @param {String} name
    ///   The name of the keyword to add.
    ///   E.g. `"otherwise"`
    ///
    /// @param {Enum.CatspeakToken} token
    ///   The token this keyword should represent.
    ///   E.g. `CatspeakToken.ELSE`
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
    /// @experimental
    ///
    /// @param {String} name
    ///   The name of the keyword to remove.
    ///   E.g. `"do"`
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

    /// Used to add a new constant to this environment.
    ///
    /// @deprecated {3.0.1}
    ///   Use `Catspeak.interface.exposeConstant` instead.
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
        var interface_ = getInterface();
        for (var i = 0; i < argument_count; i += 2) {
            interface_.exposeConstant(argument[i + 0], argument[i + 1]);
        }
    };

    /// Used to add a new method to this environment.
    ///
    /// @deprecated {3.0.1}
    ///   Use `Catspeak.interface.exposeMethod` instead.
    ///
    /// @param {String} name
    ///   The name of the function as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script or function to add.
    ///
    /// @param {Any} ...
    ///   Additional arguments in the same name-value format.
    static addMethod = function () {
        var interface_ = getInterface();
        for (var i = 0; i < argument_count; i += 2) {
            interface_.exposeMethod(argument[i + 0], argument[i + 1]);
        }
    };

    /// Used to add a new unbound function to this environment.
    ///
    /// @deprecated {3.0.1}
    ///   Use `Catspeak.interface.exposeFunction` instead.
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
        var interface_ = getInterface();
        for (var i = 0; i < argument_count; i += 2) {
            interface_.exposeFunction(argument[i + 0], argument[i + 1]);
        }
    };

    /// @ignore
    static __removeInterface = function () {
        var interface_ = getInterface();
        for (var i = 0; i < argument_count; i += 1) {
            interface_.addBanList([argument[i]]);
        }
    };

    /// Used to remove an existing constant from this environment.
    ///
    /// @deprecated {3.0.1}
    ///   Use `Catspeak.interface.addBanList` instead.
    ///
    /// @remark
    ///   Although you can use this to remove functions, it's recommended to
    ///   use `Catspeak.removeFunction` for that purpose instead.
    ///
    /// @param {String} name
    ///   The name of the constant to remove.
    ///
    /// @param {String} ...
    ///   Additional constants to remove.
    static removeConstant = __removeInterface;

    /// Used to remove an existing function from this environment.
    ///
    /// @deprecated {3.0.1}
    ///   Use `Catspeak.interface.addBanList` instead.
    ///
    /// @param {String} name
    ///   The name of the function to remove.
    ///
    /// @param {String} ...
    ///   Additional functions to remove.
    static removeFunction = __removeInterface;
}

/// Because Catspeak is sandboxed, care must be taken to not expose any
/// unintentional exploits to modders with GML-specific knowledge. One
/// exampe of an exploit is using the number `-5` to access all the
/// internal global variables of a game:
/// ```gml
/// var globalBypass = -5;
/// show_message(globalBypass.secret);
/// ```
///
/// Catspeak avoids these exploits by requiring that all special values
/// be converted to their struct counterpart; that is, Catspeak does not
/// coerce numbers to these special types implicitly.
///
/// Use this function to convert special GML constants, such as `self`,
/// `global`, or instances into their struct counterparts. Will return
/// `undefined` if there does not exist a valid conversion.
///
/// @param {Any} gmlSpecial
///   Any special GML value to convert into a Catspeak-compatible struct.
///   E.g. `global` or an instance ID.
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

/// The default global Catspeak environment. Mostly exists for UX reasons.
///
/// Unless you need to have multiple instances of Catspeak with different
/// configurations, you should use this. Otherwise, you should create a new
/// sandboxed Catspeak environment using `new CatspeakEnvironment()`.
///
/// @return {Struct.CatspeakEnvironment}
#macro Catspeak global.__catspeak__

/// Simple wrapper over `catspeak_execute_ext` which infers the `self` and
/// `other` context from the current callsite.
///
/// @remark
///   Gets around a limitation in GML where the `self` and `other` of the
///   callsite cannot be accessed from within bound methods. Use this
///   function if you want the `self` of a called Catspeak function to be
///   the same as the `self` of the callsite in GML land.
///
/// @param {Any} callee
///   The function to call. Can be a GML function, Catspeak function, or a
///   function bound using `catspeak_method`.
///
/// @param {Any} ...
///   The arguments to pass to this function.
///
/// @return {Any}
///   The result of evaluating the `callee` function.
function catspeak_execute(callee) {
    static args = [];
    for (var i = argument_count; i >= 1; i -= 1) {
        args[@ i - 1] = argument[i];
    }
    return catspeak_execute_ext(callee, self, args, 0, argument_count - 1);
}

#macro __CATSPEAK_BEGIN_SELF \
        var __selfPrev = global.__catspeakGmlSelf; \
        var __otherPrev = global.__catspeakGmlOther; \
        try { \
            global.__catspeakGmlOther = __selfPrev; \
            global.__catspeakGmlSelf
            
#macro __CATSPEAK_END_SELF \
        } finally { \
            global.__catspeakGmlSelf = __selfPrev; \
            global.__catspeakGmlOther = __otherPrev; \
        }

/// Executes a Catspeak-compatible function in the supplied `self` scope.
///
/// @remark
///   Gets around a limitation in GML where the `self` and `other` of the
///   callsite cannot be accessed from within bound methods. Use this
///   function if you want the `self` of a called Catspeak function to be
///   the same as the `self` of the callsite in GML land.
///
/// @param {Any} callee
///   The function to call. Can be a GML function, Catspeak function, or a
///   function bound using `catspeak_method`.
///
/// @param {Struct} self_
///   The `self` context to use when calling this Catspeak function.
///
/// @param {Array<Any>} [args]
///   The argument list to call this function with. Defaults to no arguments.
///
/// @param {Real} [offset]
///   The offset in the `args` array to begin reading arguments from. Defaults
///   to 0.
///
/// @param {Real} [argc]
///   The number of arguments to pass to the function call. Defaults to
///   `array_length(args) - offset`.
///
/// @return {Any}
///   The result of evaluating the `callee` function.
function catspeak_execute_ext(
    callee,
    self_,
    args = undefined,
    offset = 0,
    argc = undefined
) {
    var result = undefined;
    __CATSPEAK_BEGIN_SELF = self_;
    with (__selfPrev ?? other) {
        with (method_get_self(callee) ?? self_) {
            if (args == undefined) {
                result = script_execute(method_get_index(callee));
            } else {
                argc ??= array_length(args) - offset;
                result =  script_execute_ext(
                    method_get_index(callee),
                    args, offset, argc
                );
            }
        }
    }
    __CATSPEAK_END_SELF;
    return result;
}

/// Returns a struct containing the global variable context of a Catspeak
/// function, or `undefined` if no globals exist.
///
/// @param {Any} callee
///   The function to get the global context of. Can be a GML function,
///   Catspeak function, or a function bound using `catspeak_method`.
///
/// @return {Struct}
function catspeak_globals(callee) {
    if (is_catspeak(callee)) {
        if (method_get_index(callee) == __catspeak_function_method__) {
            // TODO
        } else {
            return callee.getGlobals();
        }
    }
    return undefined;
}

/// Binds a function to a `self`. Similar to the built-in `method` function,
/// except this supports Catspeak functions as well as GML functions.
///
/// @remark
///   Prefered over using `method` otherwise you risk breaking your compiled
///   Catspeak functions.
///
/// @param {Any} self_
///   The scope to bind this function to. Can be a struct or `undefined`.
///
/// @param {Any} callee
///   The function to get the global context of. Can be a GML function,
///   Catspeak function, or a function bound using `catspeak_method`.
///
/// @return {Any}
function catspeak_method(self_, callee) {
    if (is_catspeak(callee)) {
        if (method_get_index(callee) == __catspeak_function_method__) {
            var methodData = method_get_self(callee);
            return method({
                callee : methodData.callee,
                self_ : self_,
            }, __catspeak_function_method__);
        } else {
            return method({
                callee : callee,
                self_ : self_,
            }, __catspeak_function_method__);
        }
    }
    return method(self_, callee);
}

/// @ignore
function __catspeak_function_method__() {
    static args = [];
    for (var i = argument_count; i >= 0; i -= 1) {
        args[@ i] = argument[i];
    }
    return catspeak_execute_ext(callee, self_, args, 0, argument_count);
}

/// @ignore
function __catspeak_init_engine() {
    // initialise the default Catspeak env
    Catspeak = new CatspeakEnvironment();
}