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
#macro CATSPEAK_VERSION "3.3.0"

#region LOCATION

/// 0b00000000000011111111111111111111
///
/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_LOCATION_LINE_MASK 0x000FFFFF

/// 0b11111111111100000000000000000000
///
/// @ignore
///
/// @return {Real}
#macro __CATSPEAK_LOCATION_COLUMN_MASK 0xFFF00000

/// Indicates a lack of location in a source file.
///
/// @return {Real}
#macro CATSPEAK_NOLOCATION 0

/// When compiling programs, diagnostic information can be added into
/// the generated IR. This information (such as the line and column numbers
/// of an expression or statement) can be used by failing Catspeak programs
/// to offer clearer error messages.
///
/// Encodes the line and column numbers of a source location into a 32-bit
/// integer. The first 20 least-significant bits are reserved for the row
/// number, with the remaining 12 bits used for the (less important)
/// column number.
///
/// Because a lot of diagnostic information may be created for any given
/// Catspeak program, it is important that this information has zero memory
/// impact; hence, the line and column numbers are encoded into a 32-bit
/// integer--which can be created and discarded without allocating
/// memory--instead of as a struct.
///
/// **Mask layout**
/// ```txt
/// | 00000000000011111111111111111111 |
/// | <--column--><-------line-------> |
/// ```
///
/// @remark
///   Because of this, the maximum line number is 1,048,576 and the maximum
///   column number is 4,096. Any line/column counts beyond this will 
///   be truncated to `CATSPEAK_NOLOCATION`
///
/// @param {Real} line
///   The line number of the source location.
///
/// @param {Real} column
///   The column number of the source location. This is the number of
///   Unicode codepoints since the previous new-line character. As a result,
///   tabs are considered a single column, not 2, 4, 8, etc. columns.
///
/// @return {Real}
function catspeak_location_create(line, column) {
    gml_pragma("forceinline");
    __catspeak_assert(is_numeric(line), "invalid line number");
    __catspeak_assert(is_numeric(column), "invalid column number");
    if (line < 0 || line > __CATSPEAK_LOCATION_LINE_MASK) {
        return CATSPEAK_NOLOCATION;
    }
    if (column < 0 || column > (__CATSPEAK_LOCATION_COLUMN_MASK >> 20)) {
        return CATSPEAK_NOLOCATION;
    }
    return line | (column << 20);
}

/// Gets the line component of a Catspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the supplied
/// Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_line(location) {
    gml_pragma("forceinline");
    __catspeak_assert(is_numeric(location), "invalid location");
    return location & __CATSPEAK_LOCATION_LINE_MASK;
}

/// Gets the column component of a Catspeak source location. This is stored
/// as a 12-bit unsigned integer within the most significant bits of the
/// supplied Catspeak location handle.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_column(location) {
    gml_pragma("forceinline");
    __catspeak_assert(is_numeric(location), "invalid location");
    return (location & __CATSPEAK_LOCATION_COLUMN_MASK) >> 20;
}

/// Displays the line and column numbers this location represents. Optionally
/// takes a filepath to associate this location information with.
///
/// @example
///   With both `location` and `filepath` passed:
///   ```
///   in mods/example.meow at (line 3, column 6)
///   ```
///
///   With only `location` passed:
///   ```
///   in a file at (line 3, column 6)
///   ```
///
///   With only `filepath` passed:
///   ```
///   in mods/example.meow
///   ```
///
///   With neither argument passed:
///   ```
///   in a file
///   ```
///
/// @param {Real} [location]
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @param {String} [filepath]
///   A path to a file to associate this diagnostic information with. A file
///   at the given path does not need to exist.
///
/// @returns {String}
function catspeak_location_show(location = CATSPEAK_NOLOCATION, filepath = "") {
    var msg = "in ";
    if (filepath != "") {
        msg += string(filepath);
    } else {
        msg += "a file";
    }
    if (location != CATSPEAK_NOLOCATION) {
        msg += " at (line " + string(catspeak_location_get_row(location));
        msg += ", column " + string(catspeak_location_get_column(location)) + ")";
    }
    return msg;
}

#endregion

#region VALIDATION

/// @ignore
function __catspeak_assert(expect, message_="assertion failed") {
    gml_pragma("forceinline");
    if (!expect) {
        __catspeak_error(message_);
    }
}

/// @ignore
function __catspeak_assert_eq(expect, got, message_="assertion failed") {
    gml_pragma("forceinline");
    if (expect != got) {
        __catspeak_error(message_);
    }
}

#endregion