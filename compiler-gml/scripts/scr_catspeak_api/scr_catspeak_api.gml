//! TODO

/// TODO
///
/// @remark
///   Courtesy of: https://github.com/tinkerer-red/GML-Function-DB
enum CatspeakTag {
    NONE = 0,
    UNSPECIFIED = 1 << 0,
    DEPRECATED = 1 << 1,
    SAFE = 1 << 2,
    SANDBOXED = 1 << 3,
    FILE_IO = 1 << 4,
    NETWORK_IO = 1 << 5,
    PERSONAL_DATA = 1 << 6,
    PLATFORM_SPECIFIC = 1 << 7,
    //GETTER = 1 << 8,
    //SETTER = 1 << 9,
    GLOBAL_EFFECT = 1 << 10,
    ASSET_REFLECTION = 1 << 11,
    OS_DIALOG = 1 << 12,
    OS_DIRECTIVE = 1 << 13,
}

/// TODO
function CatspeakModule(path_) constructor {
    /// TODO
    path = path_;
    /// TODO
    globals = { };
    /// TODO
    tags = { };
    /// TODO
    result = undefined;
    /// TODO
    __exists__ = undefined;
    /// TODO
    __get__ = undefined;
    /// TODO
    publicByDefault = false;

    /// TODO
    static exists = function (name) {
        if (variable_struct_exists(globals, name)) {
            return true;
        }
        if (__exists__ != undefined) {
            var exists_ = __exists__(name);
            return is_numeric(exists_) && exists_;
        }
        return false;
    };

    /// TODO
    static get = function (name) {
        if (variable_struct_exists(globals, name)) {
            return globals[$ name];
        }
        if (__get__ != undefined) {
            return __get__(name);
        }
        return undefined;
    };

    /// TODO
    static getTag = function (name) {
        return tags[$ name] ?? CatspeakTag.UNSPECIFIED;
    };
}

/// TODO
function CatspeakModuleAssets(path, tag_) : CatspeakModule(path) constructor {
    tag = tag_;
}

/// TODO
function CatspeakModulePrelude() : CatspeakModule("core::prelude") constructor {
    /// Whether to expose every symbol available to Catspeak programs. This will
    /// attempt to expose all functions, assets, constants, and global properties
    /// available in GML (with a few exceptions).
    ///
    /// @experimental
    ///
    /// @remark
    ///   **Does not** support the physics capabilities of GameMaker because of some
    ///   weird quirks with how functions need to be bound.
    ///
    /// @warning
    ///   This turns off sandboxing in Catspeak, and as a result modders will be
    ///   able to access everything about your game state, its global variables,
    ///   user save files (and potentially corrupt them), unlock achievements,
    ///   cheat, access sensitive information such as API keys (if they are stored
    ///   in variables), and much more that I can't think of right now.
    ///
    ///   If this sounds okay with you, set this property to `true`, and all bets
    ///   are off. You will meet God.
    exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = false;
    /// @ignore
    __exists__ = function (name) {
        if (exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis) {
            try {
                var db = __catspeak_get_gml_interface();
                return variable_struct_exists(db, name) || asset_get_index(name) != -1;
            } catch (_) {
                __catspeak_error_silent("GML interface not included, defaulting to `false`");
            }
        }
        return false;
    };
    /// @ignore
    __get__ = function (name) {
        if (exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis) {
            try {
                var db = __catspeak_get_gml_interface();
                if (variable_struct_exists(db, name)) {
                    return db[$ name];
                }
                var asset = asset_get_index(name);
                if (asset != -1) {
                    if (asset_get_type(name) == asset_script) {
                        return method(undefined, asset);
                    }
                    return asset;
                }
            } catch (_) {
                __catspeak_error_silent("GML interface not included, defaulting to `undefined`");
            }
        }
        return undefined;
    };
}

/// @ignore
/// @deprecated {4.0.0}
function __catspeak_infer_function_name(func) {
    if (is_method(func)) {
        var name = func[$ "name"];
        if (is_string(name)) {
            return name;
        }
        func = __catspeak_gml_method_get_index(func);
    }
    return script_get_name(func);
}