//! Catspeak presets database.

//# feather use syntax-errors

/// Represents the set of environment presets understood by Catspeak.
/// When used with [setPreset], this enum determines what functions,
/// constants, and keywords get exposed.
enum CatspeakPreset {
    /// Changes keywords to resemble GML code.
    GML,
    /// Exposes safe type checking and type conversion functions.
    TYPE,
    /// Exposes safe array functions.
    ARRAY,
    /// Exposes safe string functions.
    STRING,
    /// Exposes safe mathematical and statistical functions.
    MATH,
    /// Exposes safe colour functions and constants.
    COLOUR,
    /// Exposes safe randomisation functions.
    RANDOM,
    /// Exposes unsafe reflection and debug functions.
    /// Use this preset with extreme caution, because all bets are off.
    UNSAFE,
    __SIZE__,
}

/// @ignore
///
/// @param {Enum.CatspeakPreset} preset
/// @return {Function}
function __catspeak_preset_get(preset) {
    var presetFunc = global.__catspeakPresets[preset];

    if (CATSPEAK_DEBUG_MODE && presetFunc == undefined) {
        __catspeak_error_bug();
    }

    return presetFunc;
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_gml(env) {
    env.renameKeyword(
        "//", "div",
        "--", "//",
        "let", "var",
        "fun", "function",
        "impl", "constructor",
    );
    env.addKeyword(
        "&&", CatspeakToken.AND,
        "||", CatspeakToken.OR,
        "mod", CatspeakToken.REMAINDER,
        "not", CatspeakToken.NOT
    );
}

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_type(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_array(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_string(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_math(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_colour(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_random(env) { }

/// @ignore
///
/// @param {Struct.CatspeakEnvironment} env
function __catspeak_preset_unsafe(env) { }

/// @ignore
function __catspeak_init_presets() {
    var presets = array_create(CatspeakPreset.__SIZE__, undefined);
    presets[@ CatspeakPreset.GML] = __catspeak_preset_gml;
    presets[@ CatspeakPreset.TYPE] = __catspeak_preset_type;
    presets[@ CatspeakPreset.ARRAY] = __catspeak_preset_array;
    presets[@ CatspeakPreset.STRING] = __catspeak_preset_string;
    presets[@ CatspeakPreset.MATH] = __catspeak_preset_math;
    presets[@ CatspeakPreset.COLOUR] = __catspeak_preset_colour;
    presets[@ CatspeakPreset.RANDOM] = __catspeak_preset_random;
    presets[@ CatspeakPreset.UNSAFE] = __catspeak_preset_unsafe;
    /// @ignore
    global.__catspeakPresets = presets;
}