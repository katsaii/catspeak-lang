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
//!   // parse Catspeak code
//!   var ir = Catspeak.parseString(@'
//!     let catspeak = "Catspeak"
//!
//!     return "hello! from within " + catspeak
//!   ');
//!
//!   // compile Catspeak code into a callable GML function
//!   var getMessage = Catspeak.compile(ir);
//!
//!   // call the Catspeak code just like you would any other GML function!
//!   show_message(getMessage());
//!   ```
//!   ...**without** giving modders unrestricted access to your sensitive game
//!   code:
//!   ```gml
//!   var ir = Catspeak.parseString(@'
//!     game_end(); -- heheheh, my mod will make your game close >:3
//!   ');
//!
//!   // calling `badMod` will throw an error instead
//!   // of calling the `game_end` function
//!   try {
//!     var badMod = Catspeak.compile(ir);
//!     badMod();
//!   } catch (e) {
//!     show_message("a mod did something bad!");
//!   }
//!   ```

//# feather use syntax-errors

#region SANITY

/// @ignore
///
/// @param {Any} val
/// @return {Bool}
function __catspeak_is_withable(val) {
    if (is_struct(val) || val == self || val == other) {
        return true;
    }
    // for non-LTS versions
    //if (is_handle(val) && (object_exists(val) || instance_exists(val)) {
    //    return true;
    //}
    if (is_numeric(val)) {
        // LTS-specific checks for numeric ids
        if (val < 0) {
            return false; // prevent accessing special instances like -5 or -3
        }
        var isInst = false;
        try {
            //isInst = !object_exists(val) && instance_exists(val);
            isInst = object_exists(val) || instance_exists(val);
        } catch (_) { }
        return isInst;
    }
    var type_ = typeof(val);
    return type_ == "struct" || type_ == "ref" && (object_exists(val) || instance_exists(val));
}

/// @ignore
///
/// @param {Any} val
/// @return {Bool}
function __catspeak_is_callable(val) {
    gml_pragma("forceinline");
    return is_method(val) || is_numeric(val) && script_exists(val);
}

/// @ignore
///
/// @param {Any} val
/// @return {Bool}
function __catspeak_is_nullish(val) {
    gml_pragma("forceinline");
    return val == undefined || val == pointer_null;
}

/// @ignore
///
/// @param {Any} val
/// @return {String}
function __catspeak_string(val) {
    gml_pragma("forceinline");
    return is_string(val) ? val : string(val);
}

/// @ignore
///
/// @param {Any} ...
function __catspeak_error() {
    var msg = "Catspeak v" + CATSPEAK_VERSION;
    if (argument_count > 0) {
        msg += ": ";
        for (var i = 0; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    show_error(msg, false);
}

/// @ignore
///
/// @param {Any} ...
function __catspeak_error_silent() {
    var msg = "Catspeak v" + CATSPEAK_VERSION;
    if (argument_count > 0) {
        msg += ": ";
        for (var i = 0; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    show_debug_message(msg);
}

/// @ignore
///
/// @param {Any} msg
/// @param {Any} got
function __catspeak_error_got(msg, got) {
    var gotStr;
    if (is_numeric(got)) {
        gotStr = string(got);
    } else if (is_string(got) && string_length(got) < 16) {
        gotStr = got;
    } else {
        gotStr = typeof(got);
    }
    __catspeak_error(msg, ", got '", gotStr, "'");
}

/// @ignore
function __catspeak_error_bug() {
    gml_pragma("forceinline");
    __catspeak_error(
        "you have likely encountered a compiler bug! ",
        "please get in contact and report this as an issue on the official ",
        "GitHub page: https://github.com/katsaii/catspeak-lang/issues"
    );
}

/// @ignore
///
/// @param {Any} feature
function __catspeak_error_unimplemented(feature) {
    gml_pragma("forceinline");
    __catspeak_error(
        "the feature '", feature, "' has not been implemented yet"
    );
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} [alternative]
function __catspeak_error_deprecated(name, alternative=undefined) {
    if (__catspeak_is_nullish(alternative)) {
        __catspeak_error_silent("'", name, "' isn't supported anymore");
    } else {
        __catspeak_error_silent(
            "'", name, "' isn't supported anymore",
            ", use '", alternative, "' instead"
        );
    }
}

/// @ignore
function __catspeak_check_init() {
    gml_pragma("forceinline");
    if (catspeak_force_init()) {
        __catspeak_error(
            "Catspeak was not initialised at this point, make sure to call ",
            "'catspeak_force_init' at the start of your code if you are ",
            "using Catspeak inside of a script resource"
        );
    }
}

/// @ignore
///
/// @param {Function} func
/// @return {String}
function __catspeak_infer_type_from_predicate(p) {
    switch (p) {
        case is_string: return "string"; break;
        case is_real: return "real"; break;
        case is_numeric: return "numeric"; break;
        case is_bool: return "bool"; break;
        case is_array: return "array"; break;
        case is_struct: return "struct"; break;
        case is_method: return "method"; break;
        case __catspeak_is_callable: return "callable"; break;
        case is_ptr: return "pointer"; break;
        case is_int32: return "int32"; break;
        case is_int64: return "int64"; break;
        case is_undefined: return "undefined"; break;
        case is_nan: return "NaN"; break;
        case is_infinity: return "infinity"; break;
        case buffer_exists: return "buffer"; break;
    }
    return undefined;
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Function} func
/// @param {Any} [typeName]
function __catspeak_check_arg(name, val, func, typeName=undefined) {
    if (func(val)) {
        return;
    }
    typeName ??= __catspeak_infer_type_from_predicate(func);
    __catspeak_error(
        "expected argument '", name, "' to be of type '", typeName, "'",
        ", but got '", typeof(val), "' instead"
    );
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Function} func
/// @param {Any} [typeName]
function __catspeak_check_arg_optional(name, val, func, typeName=undefined) {
    if (val == undefined) {
        return;
    }
    return __catspeak_check_arg(name, val, func, typeName);
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Function} func
/// @param {Any} [typeName]
function __catspeak_check_arg_not(name, val, func, typeName=undefined) {
    if (!func(val)) {
        return;
    }
    typeName ??= __catspeak_infer_type_from_predicate(func);
    __catspeak_error(
        "expected argument '", name,
        "' to be any type EXCEPT of type '", typeName, "'"
    );
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Any} ...
function __catspeak_check_arg_struct(name, val) {
    __catspeak_check_arg(name, val, is_struct);
    for (var i = 2; i < argument_count; i += 2) {
        var varName = argument[i];
        var varFunc = argument[i + 1];
        if (!variable_struct_exists(val, varName)) {
            __catspeak_error(
                "expected struct argument '", name,
                "' to contain a variable '", varName, "'"
            );
        }
        if (varFunc != undefined) {
            __catspeak_check_arg(
                    name + "." + varName, val[$ varName], varFunc);
        }
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Any} expect
function __catspeak_check_arg_struct_instanceof(name, val, expect) {
    __catspeak_check_arg(name, val, is_struct);
    var actual = instanceof(val);
    if (actual != expect) {
        __catspeak_error(
            "expected struct argument '", name, "' to be an instance of '",
            expect, "', but got '", actual, "'"
        );
    }
}

/// @ignore
///
/// @param {Any} name
/// @param {Any} val
/// @param {Real} size
function __catspeak_check_arg_size_bits(name, val, size) {
    gml_pragma("forceinline");
    __catspeak_check_arg(name, val, is_numeric);
    if (val < 0) {
        __catspeak_error("argument '", name, "' must not be negative, got", val);
    }
    if (val >= power(2, size)) {
        __catspeak_error(
            "argument '", name, "' is too large (", val,
            ") it must fit within ", size, " bits"
        );
    }
}

/// @ignore
///
/// @param {Any} name
function __catspeak_check_global_exists(name) {
    gml_pragma("forceinline");
    if (!variable_global_exists(name)) {
        __catspeak_error(
            "global variable '", name, "' does not exist"
        );
    }
}

#endregion

/// Usually the Catspeak environment tries to self-initialise at the start of
/// the game, but at what time this happens relative to other scripts is not
/// guaranteed by GameMaker.
///
/// Call this function to force the core Catspeak environment to be
/// initialised immediately. If Catspeak was already initialised before
/// calling this function, then nothing will happen.
///
/// @remark
///   You shouldn't need to call this function unless you are trying to use
///   Catspeak from within a global script asset, or through
///   `gml_pragma("global", ...)`.
///
///   If neither of these situations apply to you, feel free to forget this
///   function even exists.
///
/// @return {Bool}
///   Returns `true` the first time this function is called, and `false`
///   every other time.
function catspeak_force_init() {
    static initialised = false;
    if (initialised) {
        return false;
    }
    initialised = true;
    /// @ignore
    global.__catspeakConfig = { };
    // call initialisers
    __catspeak_init_alloc();
    __catspeak_init_operators();
    __catspeak_init_presets();
    __catspeak_init_lexer();
    __catspeak_init_codegen();
    __catspeak_init_engine();
    // display the initialisation message
    var motd = "you are now using Catspeak v" + CATSPEAK_VERSION +
            " by @katsaii";
    show_debug_message(motd);
    return true;
}

catspeak_force_init();