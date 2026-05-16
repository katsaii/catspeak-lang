//! ```txt
//!      _             _                                                       
//!     |  `.       .'  |                   _                             _    
//!     |    \_..._/    |                  | |                           | |   
//!    /    _       _    \     |\_/|  __ _ | |_  ___  _ __    ___   __ _ | | __
//! `-|    / \     / \    |-'  / __| / _` || __|/ __|| '_ \  / _ \ / _` || |/ /
//! --|    | |     | |    |-- | (__ | (_| || |_ \__ \| |_) ||  __/| (_| ||   < 
//!  .'\   \_/ _._ \_/   /`.   \___| \__,_| \__||___/| .__/  \___| \__,_||_|\_\
//!     `~..______    .~'                       _____| |   by: katsaii         
//!               `.  |                        / ._____/ logo: mashmerlow      
//!                 `.|                        \_)                             
//! ```
//!
//! Catspeak is the spiritual successor to the long dead `execute_string`
//! function from GameMaker 8.1, but on overdrive.
//!
//! Use the built-in Catspeak scripting language to expose **safe** and
//! **sandboxed** modding APIs within GameMaker projects, or bootstrap your own
//! domain-specific languages and development tools using the back-end code
//! generation tools offered by Catspeak.
//!
//! This top-level module contains common metadata and utility functions used
//! throughout the Catspeak codebase.
//!
//! @example
//!   Compile performant scripts from plain-text...
//!   ```gml
//!   // run Catspeak code
//!   var globals = Catspeak.run(@'
//!     get_message = fun () {
//!       let catspeak = "Catspeak"
//!
//!       return "hello! from within " + catspeak
//!     }
//!   ');
//!
//!   // call Catspeak code directly from GML!
//!   show_message(globals.get_message());
//!   ```
//!   ...**without** giving modders unrestricted access to your sensitive game
//!   code:
//!   ```gml
//!   var cartridge = Catspeak.build(@'
//!     game_end(); -- heheheh, my mod will make your game close >:3
//!   ');
//!
//!   // calling `badMod` will throw an error instead
//!   // of calling the `game_end` function
//!   try {
//!     Catspeak.run(cartridge);
//!   } catch (e) {
//!     show_message("a mod did something bad!");
//!   }
//!   ```

//# feather use syntax-errors

/// The Catspeak runtime version, as a string, in the
/// [MAJOR.MINOR.PATCH](https://semver.org/) format.
///
/// Updated before every new release.
///
/// @return {String}
#macro CATSPEAK_VERSION "4.0.0"

/// The number of microseconds before a Catspeak program times out. The
/// default is 1 second.
///
/// @return {Real}
#macro CATSPEAK_TIMEOUT 1000

/// Checks whether a value is a valid Catspeak function.
///
/// @warning
///   Internally, this actually just checks whether the methods name starts
///   with `__catspeak_`. Because of this, you should avoid giving your
///   functions that prefix to prevent false positives.
///
/// @param {Any} value
///   The value to check is a Catspeak function.
///
/// @return {Bool}
function is_catspeak(value) {
    if (!is_method(value)) {
        return false;
    }
    var scr = method_get_index(value);
    if (scr == __catspeak_function__) {
        return true;
    }
    var scrName = script_get_name(scr);
    if (string_starts_with(scrName, "__catspeak_")) {
        var self_ = method_get_self(value);
        if (variable_struct_exists(self_, "ctx")) {
            // all Catspeak functions should have this on their self binding
            return true;
        }
    }
    return false;
}

/// Simple wrapper over `catspeak_execute_ext` which infers the `self` and
/// `other` context from the current callsite.
///
/// @remark
///   Gets around a limitation in GML where the `self` and `other` of the
///   callsite cannot be accessed from within bound methods. Use this
///   function if you want the `self` of a called Catspeak function to be
///   the same as the `self` of the callsite in GML land.
///
/// @param {Any} callee_
///   The function to call. Can be a GML function, Catspeak function, or a
///   function bound using `catspeak_method`.
///
/// @param {Any} ...
///   The arguments to pass to this function.
///
/// @return {Any}
///   The result of evaluating the `callee` function.
function catspeak_execute(callee_) {
    static args = [];
    for (var i = argument_count; i >= 1; i -= 1) {
        args[@ i - 1] = argument[i];
    }
    return catspeak_execute_ext(callee_, self, args, 0, argument_count - 1);
}

/// Executes a Catspeak-compatible function in the supplied `self` scope.
///
/// @remark
///   Gets around a limitation in GML where the `self` and `other` of the
///   callsite cannot be accessed from within bound methods. Use this
///   function if you want the `self` of a called Catspeak function to be
///   the same as the `self` of the callsite in GML land.
///
/// @param {Any} callee_
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
    callee_,
    self_,
    args = undefined,
    offset = 0,
    argc = undefined
) {
    var scopes = __catspeak_scope_get();
    var oldSelf = scopes.self_;
    var oldOther = scopes.other_;
    var result = undefined;
    try {
        scopes.other_ = scopes.self_;
        scopes.self_ = catspeak_special_to_struct(self_);
        var boundScopes = __catspeak_scope_get_bound(method_get_self(callee_));
        with (boundScopes.other_) with (boundScopes.self_) {
            var calleeUnbound = method_get_index(callee_);
            if (args == undefined) {
                result = script_execute(calleeUnbound);
            } else {
                argc ??= array_length(args) - offset;
                result = script_execute_ext(calleeUnbound, args, offset, argc);
            }
        }
    } finally {
        scopes.self_ = oldSelf;
        scopes.other_ = oldOther;
    }
    return result;
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
    if (gmlSpecial == undefined || is_struct(gmlSpecial)) {
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
    __catspeak_error_silent(__catspeak_cat(
        "could not convert special GML value '", gmlSpecial, "' ",
        "into a valid Catspeak representation"
    ));
    return undefined;
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
    if (is_method(callee)) {
        var closure = method_get_self(callee);
        if (is_struct(closure)) {
            var ctx = closure[$ "ctx"];
            if (is_struct(ctx)) {
                return ctx[$ "globals"];
            }
        }
    }
    return undefined;
}

/// Returns a struct containing the metadata of a Catspeak function, or
/// `undefined` if no metadata exists.
///
/// @param {Any} callee
///   The function to get the global context of. Can be a GML function,
///   Catspeak function, or a function bound using `catspeak_method`.
///
/// @return {Struct}
function catspeak_meta(callee) {
    if (is_method(callee)) {
        var closure = method_get_self(callee);
        if (is_struct(closure)) {
            var ctx = closure[$ "ctx"];
            if (is_struct(ctx)) {
                return ctx[$ "meta"];
            }
        }
    }
    return undefined;
}

/// @ignore
#macro __catspeak_gml_method method

/// @ignore
#macro __catspeak_gml_method_get_self method_get_self

/// @ignore
#macro __catspeak_gml_method_get_index method_get_index

/// @ignore
function __catspeak_method__() {
    static args = [];
    for (var i = argument_count; i >= 0; i -= 1) {
        args[@ i] = argument[i];
    }
    return catspeak_execute_ext(callee, self_, args, 0, argument_count);
}

/// Binds a function to a `self`. Similar to the built-in `method` function,
/// except this supports Catspeak functions as well as GML functions.
///
/// @remark
///   Prefered over using `method` otherwise you risk breaking your
///   Catspeak functions.
///
/// @remark
///   For your convenience, you can do the following to override the built-in
///   `method` implementation with the Catspeak implementation:
///   ```gml
///   #macro method catspeak_method
///   ```
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
        if (__catspeak_gml_method_get_index(callee) == __catspeak_method__) {
            var methodData = __catspeak_gml_method_get_self(callee);
            if (self_ == undefined) {
                return methodData.callee;
            }
            return __catspeak_gml_method({
                ctx : methodData.ctx,
                callee : methodData.callee,
                self_ : self_,
            }, __catspeak_method__);
        } else {
            if (self_ == undefined) {
                return callee;
            }
            var calleeSelf = __catspeak_gml_method_get_self(callee);
            return __catspeak_gml_method({
                ctx : calleeSelf[$ "ctx"],
                callee : callee,
                self_ : self_,
            }, __catspeak_method__);
        }
    }
    return __catspeak_gml_method(self_, callee);
}

/// Returns the 'self' of the current method. Similar to the built-in 
/// `method_get_self` function, except this supports Catspeak functions as well
/// as GML functions.
///
/// @remark
///   Preferred over 'method_get_self', otherwise you risk breaking your
///   Catspeak functions.
///
/// @remark
///   For your convenience, you can do the following to override the built-in
///   `method_get_self` implementation with the Catspeak implementation:
///   ```gml
///   #macro method_get_self catspeak_get_self
///   ```
///
/// @param {Any} callee
///  The function to get the current global context of. Can be a GML function,
///  Catspeak function, or a function bound using `catspeak_method`.
///
/// @return {Any}
function catspeak_get_self(callee) {
    if (is_catspeak(callee)) {
        if (__catspeak_gml_method_get_index(callee) == __catspeak_method__) {
            var methodData = __catspeak_gml_method_get_self(callee);
            return methodData.self_;
        }
        return undefined;
    }
    return __catspeak_gml_method_get_self(callee);
}

/// Returns the... ✌_"index"_✌ ...of the current method, either by returning 
/// the compiled Catspeak function or the exposed GML function as a method
/// bound to `undefined`.
///
/// @remark
///   Preferred over 'method_get_index', otherwise you risk breaking your compiled
///   Catspeak functions. However, if you need the numeric ID of the given
///   GML/Catspeak function then avoid using this function! (NOTE: Why are you
///   doing that? It won't work on GMRT. Stop it.)
///
/// @remark
///   For your convenience, you can do the following to override the built-in
///   `method_get_index` implementation with the Catspeak implementation:
///   ```gml
///   #macro method_get_index catspeak_get_index
///   ```
///
/// @param {Any} callee
///  The function to get the current global context of. Can be a GML function,
///  Catspeak function, or a function bound using `catspeak_method`.
///
/// @return {Any}
function catspeak_get_index(callee) {
    if (is_catspeak(callee)) {
        if (__catspeak_gml_method_get_index(callee) == __catspeak_method__) {
            var methodData = __catspeak_gml_method_get_self(callee);
            return methodData.callee;
        }
        return callee;
    }
    return __catspeak_gml_method(undefined, callee);
}

/// TODO
///
/// @experimental
function catspeak_debug_tree(value, indent = "  ") {
    if (is_method(value)) {
        var msg = script_get_name(__catspeak_gml_method_get_index(value));
        if (is_catspeak(value)) {
            var methodData = __catspeak_gml_method_get_self(value);
            var names = variable_struct_get_names(methodData);
            var n = array_length(names) - 2;
            for (var i = array_length(names) - 1; i >= 0; i -= 1) {
                var name = names[i];
                if (name == "ctx" || name == "toString") {
                    continue;
                }
                var newIndent = n > 0 ? (indent + "| ") : (indent + "  ");
                msg += "\n" + indent + name + ": " +
                        catspeak_debug_tree(methodData[$ name], newIndent);
                n -= 1;
            }
        }
        return msg;
    } else {
        return string(value);
    }
}

/// TODO
function CatspeakCtx() constructor {

    //fileHandler = undefined;

    // assign this to make scripts share a global variable scope
    globals = undefined;
    /// TODO
    interface = new CatspeakModulePrelude();
    /// @ignore
    modules = { };
    addModule(interface);

    /// @deprecated {3.0.0}
    ///   Use `Catspeak.interface` instead.
    ///
    /// @return {Struct.CatspeakForeignInterface}
    static getInterface = function () { return interface };

    /// TODO
    static addModule = function (module) {
        modules[$ module.path] = module;
    };

    /// TODO
    static parse = function (args) {
        // load args
        var path = undefined;
        var src = args;
        var srcOffset = undefined;
        var srcLength = undefined;
        var cart = undefined;
        if (is_struct(args)) {
            path = args[$ "path"];
            src = args[$ "src"];
            srcOffset = args[$ "offset"];
            srcLength = args[$ "length"];
            cart = args[$ "cart"];
        }
        var srcIsBuff = __catspeak_is_buffer(src);
        var srcBuff = srcIsBuff ? src : catspeak_buffer_create_from_string(src);
        // do parsing
        var writer = new CatspeakCartWriter();
        writer.path = path;
        writer.addInclude(interface.path, "*"); // prelude included implicitly
        try {
            // TODO :: multi-language support
            // TODO :: caching support
            // TODO :: filesystem support
            var lexer = new CatspeakLexer(srcBuff, srcOffset, srcLength);
            var parser = new CatspeakParser(writer, lexer);
            do {
                var keepParsing = parser.parseOnce() == undefined;
            } until (!keepParsing);
            cart = writer.finalise(cart);
        } finally {
            writer.destroy();
            if (srcIsBuff) {
                buffer_delete(srcBuff);
            }
        }
        return cart;
    };

    /// TODO
    static compile = function (cart) {
        // TODO :: multi-backend support
        // TODO :: module system
        var codegen;
        var program = undefined;
        try {
            codegen = new CatspeakGenGML(modules, globals);
            var reader = new CatspeakCartReader(cart, codegen);
            do {
                var keepReading = reader.readInstr();
            } until (!keepReading);
            program = codegen.finalise();
        } finally {
            codegen.destroy();
        }
        return program;
    };

    /// TODO
    static run = function (args) {
        var cartIsOwned = !(is_struct(args) && __catspeak_is_buffer(args[$ "cart"]));
        var cart = parse(args);
        var program;
        try {
            program = compile(cart);
        } finally {
            if (cartIsOwned) {
                buffer_delete(cart);
            }
        }
        return {
            result : program(),
            globals : catspeak_globals(program),
        };
    };
}