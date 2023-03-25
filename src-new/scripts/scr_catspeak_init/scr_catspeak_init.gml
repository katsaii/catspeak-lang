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
    // call initialisers
    //__catspeak_init_config();
    //__catspeak_init_process();
    __catspeak_init_alloc();
    //__catspeak_init_builtins();
    //__catspeak_init_lexer_database_token_starts_expression();
    //__catspeak_init_lexer_database_token_skips_line();
    //__catspeak_init_lexer_database_token_keywords();
    //__catspeak_init_lexer_database_token();
    //__catspeak_init_lexer_database_ascii_desc();
    // display the initialisation message
    var motd = "you are now using Catspeak v" + CATSPEAK_VERSION +
            " by @katsaii";
    show_debug_message(motd);
    return true;
}

catspeak_force_init();