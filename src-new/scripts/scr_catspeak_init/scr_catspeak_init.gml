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

/// Whether sanity checks are enabled on Catspeak functions. You can override
/// this using a configuration macro:
/// ```
/// #macro Release:CATSPEAK_DEBUG_MODE false
/// ```
#macro CATSPEAK_DEBUG_MODE true

/// @ignore
///
/// @param {Any} ...
function __catspeak_error() {
    gml_pragma("forceinline");
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
/// @param {Any} val
/// @return {String}
function __catspeak_string(val) {
    gml_pragma("forceinline");
    return is_string(val) ? val : string(val);
}

/// Makes sure that all Catspeak global variables are initialised. Only needs
/// to be called if you are trying to use Catspeak from a script, or through
/// `gml_pragma`. Otherwise you can just ignore this.
function catspeak_force_init() {
    static initialised = false;
    if (initialised) {
        return;
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
}

catspeak_force_init();