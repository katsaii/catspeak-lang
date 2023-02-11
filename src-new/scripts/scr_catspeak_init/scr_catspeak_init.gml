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
function __catspeak_string(val) {
    gml_pragma("forceinline");
    return is_string(val) ? val : string(val);
}

/// @ignore
function __catspeak_assert(msg="no message") {
    gml_pragma("forceinline");
    show_error("Catspeak: " + __catspeak_string(msg), false);
}

/// @ignore
function __catspeak_assert_arg_typeof(arg, val, expect) {
    var actual = typeof(val);
    if (actual != expect) {
        __catspeak_assert(
            "expected arg " + __catspeak_string(arg) + " (" +
                    __catspeak_string(val) + ") to have the type" +
                    __catspeak_string(expect) + ", but got " +
                    __catspeak_string(actual)
        );
    }
}