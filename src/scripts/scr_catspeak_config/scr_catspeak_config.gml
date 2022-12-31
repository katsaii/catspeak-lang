//! The primary user-facing interface for configuring the Catspeak execution
//! engine.
//!
//! Many parts of the Catspeak engine expose configuration features. These
//! are:
//!
//!  - "frameAllocation" should be a number in the range [0, 1]. Determines
//!    what percentage of a game frame should be reserved for processing
//!    Catspeak programs. Catspeak will only spend this time when necessary,
//!    and will not sit idly wasting time. A value of 1 will cause Catspeak
//!    to spend the whole frame processing, and a value of 0 will cause
//!    Catspeak to only process a single instruction per frame. The default
//!    setting is 0.5 (50% of a frame). This leaves enough time for the other
//!    components of your game to complete, whilst also letting Catspeak be
//!    speedy.
//!
//!  - "processTimeLimit" should be a number greater than 0. Determines how
//!    long (in seconds) a process can run for before it is assumed
//!    unresponsive and terminated. The default value is 1 second. Setting
//!    this to `infinity` is technically possible, but will not be officially
//!    supported.
//!
//!  - "keywords" is a struct whose keys map to [CatspeakToken] values.
//!    This struct can be modified to customise the keywords expected by the
//!    Catspeak compiler. For example, if you would like to use "func" for
//!    functions (instead of the default "fun"), you can add a new definition:
//!    ```
//!    var keywords = catspeak_config().keywords;
//!    keywords[$ "func"] = CatspeakToken.FUN;
//!    variable_struct_remove(keywords, "fun"); // delete the old keyword
//!    ```
//!    Please take care when modifying this struct because any changes will
//!    be **permanent** until you close and re-open the game.

/// Configures various global settings of the Catspeak compiler and runtime.
/// See the list in [scr_catspeak_config] for configuration values and their
/// usages.
///
/// @return {Struct}
function catspeak_config() {
    catspeak_force_init();
    var config = global.__catspeakConfig;
    if (argument_count > 0 && is_struct(argument[0])) {
        // for compatibility
        var newConfig = argument[0];
        var keys = variable_struct_get_names(newConfig);
        for (var i = array_length(keys) - 1; i > 0; i -= 1) {
            var key = keys[i];
            if (variable_struct_exists(config, key)) {
                config[$ key] = newConfig[$ key];
            }
        }
    }
    return config;
}

/// Permanently adds a new Catspeak function to the default standard library.
///
/// @param {String} name
///   The name of the function to add.
///
/// @param {Function} f
///   The function to add, will be converted into a method if a script ID
///   is used.
///
/// @param {Any} ...
///   The remaining key-value pairs to add, in the same pattern as the two
///   previous arguments.
function catspeak_add_function() {
    catspeak_force_init();
    var db = global.__catspeakDatabasePrelude;
    for (var i = 0; i < argument_count; i += 2) {
        var f = argument[i + 1];
        if (!is_method(f)) {
            f = method(undefined, f);
        }
        db[$ argument[i + 0]] = f;
    }
}

/// Permanently adds a new Catspeak constant to the default standard library.
/// If you want to add a function, use the [catspeak_add_function] function
/// instead because it makes sure your value will be callable from within
/// Catspeak.
///
/// @param {String} name
///   The name of the constant to add.
///
/// @param {Any} value
///   The value to add.
///
/// @param {Any} ...
///   The remaining key-value pairs to add, in the same pattern as the two
///   previous arguments.
function catspeak_add_constant() {
    catspeak_force_init();
    var db = global.__catspeakDatabasePrelude;
    for (var i = 0; i < argument_count; i += 2) {
        db[$ argument[i + 0]] = argument[i + 1];
    }
}

/// @ignore
function __catspeak_init_config() {
    /// @ignore
    global.__catspeakConfig = { };
    /// @ignore
    global.__catspeakDatabasePrelude = { };
    global.__catspeakConfig.libs = {
        "std" : global.__catspeakDatabasePrelude,
    }
}