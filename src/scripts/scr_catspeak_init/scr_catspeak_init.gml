//! Initialises core components of the Catspeak compiler.

//# feather use syntax-errors

/// The compiler version, should be updated before each release.
#macro CATSPEAK_VERSION "2.0.0"

// display the initialisation message
var motd = "you are now using Catspeak v" + CATSPEAK_VERSION + " by @katsaii";
show_debug_message(motd);