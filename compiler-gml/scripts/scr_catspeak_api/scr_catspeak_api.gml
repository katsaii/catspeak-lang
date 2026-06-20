//! TODO

/// TODO
function CatspeakModule(path_) constructor {
    /// TODO
    path = path_;
    /// TODO
    globals = { };
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
            return __catspeak_get(globals, name);
        }
        if (__get__ != undefined) {
            return __get__(name);
        }
        return undefined;
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
    /// **Requires the official `api-gml` plugin! (`scr_catspeak_api_gml`)**
    ///
    /// @experimental
    /// @advanced
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
            return __catspeak_get_gml_api().exists(name);
        }
        return false;
    };
    /// @ignore
    __get__ = function (name) {
        if (exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis) {
            return __catspeak_get_gml_api().get(name);
        }
        return undefined;
    };
}

function __catspeak_get_gml_api() {
    static module_ = undefined;
    static loaded = false;
    if (!loaded) {
        loaded = true;
        try {
            module_ = new CatspeakModuleGML();
        } catch (ex) {
            __catspeak_error(__catspeak_cat(
                "error encountered when trying to load the GML interface ",
                "(are you missing the GML API plugin? 'scr_catspeak_api_gml'): ",
                ex.message
            ));
        }
    }
    return module_;
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