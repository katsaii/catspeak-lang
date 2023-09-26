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
//!   var getMessage = Catspeak.compileGML(ir);
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
//!   // calling `badMod` will throw an error instead of calling the `game_end` function
//!   try {
//!     var badMod = Catspeak.compileGML(ir);
//!     badMod();
//!   } catch (e) {
//!     show_message("a mod did something bad!");
//!   }
//!   ```

//# feather use syntax-errors

/// The Catspeak runtime version, should be updated before each release.
///
/// @return {String}
#macro CATSPEAK_VERSION "3.0.0"

/// Determines whether sanity checks and unsafe developer features are enabled
/// at runtime. You can override this using a configuration macro:
/// ```gml
/// #macro Release:CATSPEAK_DEBUG_MODE false
/// ```
///
/// @warning
///   Disabling this may give a significant performance boost, but may also
///   result in undefined behaviour or cryptic error messages if an error
///   occurs. If you are getting errors in your game, and you suspect
///   Catspeak may be the cause, make sure to re-enable debug mode if you
///   have it disabled.
///
/// @return {Bool}
#macro CATSPEAK_DEBUG_MODE (GM_build_type == "run")

/// Makes sure that the core Catspeak environment is properly set up. Returns
/// `true` the first time this function is called, and `false` otherwise.
///
/// @remark
///   This only needs to be called if you are trying to use Catspeak from
///   within a script, or through `gml_pragma`. Otherwise you can just
///   forget this function exists.
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

catspeak_force_init();