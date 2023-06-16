//! Initialises core components of the Catspeak compiler. This includes
//! any uninitialised global variables.

//      _             _                                                       
//     |  `.       .'  |                   _                             _    
//     |    \_..._/    |                  | |                           | |   
//    /    _       _    \     |\_/|  __ _ | |_  ___  _ __    ___   __ _ | | __
// `-|    / \     / \    |-'  / __| / _` || __|/ __|| '_ \  / _ \ / _` || |/ /
// --|    | |     | |    |-- | (__ | (_| || |_ \__ \| |_) ||  __/| (_| ||   < 
//  .'\   \_/ _._ \_/   /`.   \___| \__,_| \__||___/| .__/  \___| \__,_||_|\_\
//     `~..______    .~'                       _____| |   by: katsaii         
//               `.  |                        / ._____/ logo: mashmerlow      
//                 `.|                        \_)                             

//# feather use syntax-errors

/// The compiler version, should be updated before each release.
#macro CATSPEAK_VERSION "3.0.0"

/// Whether sanity checks and unsafe developer features are enabled at runtime.
/// You can override this using a configuration macro:
///
/// ```gml
/// #macro Release:CATSPEAK_DEBUG_MODE false
/// ```
///
/// NOTE: Disabling this will give a significant performance boost, but may
///       result in undefined behaviour or cryptic error messages if an error
///       occurs. If you are getting errors in your game, and you suspect
///       Catspeak may be the cause, make sure to re-enable debug mode if you
///       have it disabled.
#macro CATSPEAK_DEBUG_MODE (GM_build_type == "run")

/// Makes sure that all Catspeak global variables are initialised.
/// Returns `true` if this is the first time this function was called, and
/// `false` otherwise.
///
/// NOTE: This only needs to be called if you are trying to use Catspeak from
///       within a script, or through `gml_pragma`. Otherwise you can just
///       forget this function exists.
///
/// @return {Bool}
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

/// Returns the global configuration struct you can use to modify the
/// behaviour of select Catspeak components.
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

catspeak_force_init();