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
    /// @ignore
    banList = { };
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
    __exists__ = function () {
        /*
        if (variable_struct_exists(banList, name)) {
            // this function has been banned!
            return false;
        }
        if (
            variable_struct_exists(database, name) ||
            variable_struct_exists(databaseDynConst, name)
        ) {
            return true;
        }
        if (exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis) {
            try {
                var db = __catspeak_get_gml_interface();
                return variable_struct_exists(db, name) || asset_get_index(name) != -1;
            } catch (_) {
                __catspeak_error_silent("GML interface not included, defaulting to `false`");
            }
        }
        return false;
        */
    };
    /// @ignore
    __get__ = function () {
        /*
        if (variable_struct_exists(banList, name)) {
            // this function has been banned!
            return undefined;
        }
        if (variable_struct_exists(database, name)) {
            return database[$ name];
        }
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
        */
    };

    /// Returns whether the foreign symbol is a "dynamic constant".
    /// If the symbol hasn't been added then this function returns `false`.
    ///
    /// @experimental
    ///
    /// @deprecated {4.0.0}
    ///
    /// @param {String} name
    ///   The name of the symbol as it appears in Catspeak.
    ///
    /// @return {Bool}
    static isDynamicConstant = function (name) {
        return false;
    };

    /// Bans an array of symbols from being used by this interface. Any
    /// symbols in this list will be treated as though they do not exist. To
    /// unban a set of symbols, you should use the `addPardonList` method.
    ///
    /// If a symbol was previously banned, this function will have no effect.
    ///
    /// @deprecated {4.0.0}
    ///   If you need this, then you're probably cutting corners.
    ///
    /// @param {String} ban
    ///   The symbol to ban the usage of from within Catspeak.
    static addBanList = function () {
        var banList_ = banList;
        for (var i = 0; i < argument_count; i += 1) {
            var ban = argument[i];
            banList_[$ ban] = true;
        }
    };

    /// Pardons an array of symbols within this interface.
    ///
    /// If a symbol was not previously banned by `addBanList`, there will be
    /// no effect.
    ///
    /// @deprecated {4.0.0}
    ///   If you need this, then you're probably cutting corners.
    ///
    /// @param {String} pardon
    ///   The symbol to pardon the usage of from within Catspeak.
    static addPardonList = function () {
        var banList_ = banList;
        for (var i = 0; i < argument_count; i += 1) {
            var pardon = argument[i];
            if (variable_struct_exists(banList_, pardon)) {
                variable_struct_remove(banList_, pardon);
            }
        }
    };

    /// Exposes a constant value to this interface.
    ///
    /// @remark
    ///   You cannot expose GML functions using this method. Instead you
    ///   should use one of `exposeDynamicConstant`, `exposeFunction`, or
    ///   `exposeMethod`.
    ///
    /// @deprecated {4.0.0}
    ///   Assign constants directly to `.globals` now:
    ///   ```gml
    ///   var module = new CatspeakModule();
    ///   module.globals.one = 1;
    ///   ```
    ///
    /// @param {String} name
    ///   The name of the constant as it will appear in Catspeak.
    ///
    /// @param {Any} value
    ///   The constant value to add.
    static exposeConstant = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var value = argument[i + 1];
            globals[$ name] = value;
        }
    };

    /// Exposes a "dynamic constant" to this interface. The value provided for
    /// the constant should be a script or method. When the dynamic constant
    /// is evaluated at runtime, the method will be executed with zero
    /// arguments and the return value used as the value of the constant.
    ///
    /// @experimental
    ///
    /// @deprecated {4.0.0}
    ///   Assign "dynamic constants" directly to `.globals` now:
    ///   ```gml
    ///   var module = new CatspeakModule();
    ///   module.globals.random_n_get = function () { return choose(1, 2, 3) };
    ///   ```
    ///   Instead of `exposeDynamicConstant("random_n", function () { ... })`.
    ///
    /// @param {String} name
    ///   The name of the constant as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script ID or function to add.
    static exposeDynamicConstant = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var func = argument[i + 1];
            func = is_method(func) ? func : catspeak_method(undefined, func);
            globals[$ name + "_get"] = func;
        }
    };

    /// Exposes a new unbound function to this interface. When passed a bound
    /// method (i.e. a non-global function), it will be unbound before it is
    /// added to the interface.
    ///
    /// @remark
    ///   If you would prefer to keep the bound `self` of a method, you should
    ///   use the `exposeMethod` method instead.
    ///
    /// @deprecated {4.0.0}
    ///   Assign functions directly to `.globals` now:
    ///   ```gml
    ///   var module = new CatspeakModule();
    ///   module.globals.show_message = show_message;
    ///   ```
    ///
    /// @param {String} name
    ///   The name of the function as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script ID or function to add.
    static exposeFunction = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var func = argument[i + 1];
            func = is_method(func) ? catspeak_get_index(func) : func;
            globals[$ name] = catspeak_method(undefined, func);
        }
    };

    /// Behaves similarly to `exposeFunction`, except the name of definition
    /// is inferred. There are three ways this name will be inferred:
    ///
    ///  1) If the value is a script resource, `script_get_name` is used.
    ///  2) If the value is a method and a `name` field exists, then the value
    ///     of this `name` field will be used as the name.
    ///  3) If the value is a method and a `name` field does not exist, then
    ///     `script_get_name` will be called on the underlying bound script
    ///     resource.
    ///
    /// @remark
    ///   If you would prefer to keep the bound `self` of a method, you should
    ///   use the `exposeMethodByName` method instead.
    ///
    /// @deprecated {4.0.0}
    ///   Will not work on GMRT.
    ///
    /// @param {Function} func
    ///   The script ID or function to add.
    static exposeFunctionByName = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var func = argument[i];
            var name;
            if (is_string(func)) {
                name = func;
                func = undefined;
                if (
                    !string_starts_with(name, "<unknown>") &&
                    !string_starts_with(name, "@@") &&
                    !string_starts_with(name, "$") &&
                    !string_starts_with(name, "YoYo") &&
                    !string_starts_with(name, "yy") &&
                    !string_starts_with(name, "[[") &&
                    !string_starts_with(name, "__")
                ) {
                    for(var builtinID = 0; builtinID < 10000; builtinID += 1;) {
                        var scriptName = script_get_name(builtinID);
                        if (scriptName == name) {
                            func = builtinID;
                            break;
                        }
                    }
                }
                if (func == undefined) {
                    for (var scriptID = 100001; script_exists(scriptID); scriptID += 1) {
                        var scriptName = script_get_name(scriptID);
                        if (
                            string_starts_with(scriptName, "anon") ||
                            string_count("gml_GlobalScript", scriptName) > 0 ||
                            string_count("__struct__", scriptName) > 0
                        ) {
                            continue;
                        }
                        if (scriptName == name) {
                            func = scriptID;
                            break;
                        }
                    }
                }
                if (func == undefined) {
                    __catspeak_error(__catspeak_cat(
                        "function with the name '", name, "' cannot be found"
                    ));
                }
            } else {
                name = __catspeak_infer_function_name(func);
                func = is_method(func) ? catspeak_get_index(func) : func;
            }
            globals[$ name] = catspeak_method(undefined, func);
        }
    };

    /// Exposes many user-defined global GML functions to this interface which
    /// share a common prefix.
    ///
    /// @deprecated {4.0.0}
    ///   Will not work on GMRT.
    ///
    /// @param {String} namespace
    ///   The common prefix for the set of functions you want to expose to
    ///   Catspeak.
    static exposeFunctionByPrefix = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var namespace = argument[i];
            // asset scanning for functions can be a lil weird, in my experience
            // i've came across a few variations
            //
            // their positions aren't always 100% known, except for anon
            // (which is always at the front)
            //
            // NOTE: not GMRT compatible
            var database_ = globals;
            if (
                !string_starts_with(namespace, "<unknown>") &&
                !string_starts_with(namespace, "@@") &&
                !string_starts_with(namespace, "$") &&
                !string_starts_with(namespace, "YoYo") &&
                !string_starts_with(namespace, "yy") &&
                !string_starts_with(namespace, "[[") &&
                !string_starts_with(namespace, "__")
            ) {
                for(var builtinID = 0; builtinID < 10000; builtinID += 1;) {
                    var name = script_get_name(builtinID);
                    if (string_starts_with(name, namespace)) {
                        database_[$ name] = method(undefined, builtinID);
                    }
                }
            }
            for (var scriptID = 100001; script_exists(scriptID); scriptID += 1) {
                var name = script_get_name(scriptID);
                if (
                    string_starts_with(name, "anon") ||
                    string_count("gml_GlobalScript", name) > 0 ||
                    string_count("__struct__", name) > 0
                ) {
                    continue;
                }
                if (string_starts_with(name, namespace)) {
                    database_[$ name] = method(undefined, scriptID); 
                }
            }
        }
    };

    /// Exposes a new bound function to this interface.
    ///
    /// @remark
    ///   If you would prefer to ignore the bound `self` value of the function,
    ///   and treat it as a global script, you should use the `exposeFunction`
    ///   method instead.
    ///
    /// @deprecated {4.0.0}
    ///   Assign functions directly to `.globals` now:
    ///   ```gml
    ///   var module = new CatspeakModule();
    ///   module.globals.add_3 = function (a, b, c) { return a + b + c };
    ///   ```
    ///
    /// @param {String} name
    ///   The name of the method as it will appear in Catspeak.
    ///
    /// @param {Function} func
    ///   The script ID or method to add.
    static exposeMethod = function () {
        for (var i = 0; i < argument_count; i += 2) {
            var name = argument[i + 0];
            var func = argument[i + 1];
            func = is_method(func) ? func : method(undefined, func);
            globals[$ name] = func;
        }
    };

    /// Behaves similarly to `exposeMethod`, except the name of definition
    /// is inferred. There are three ways a name will be inferred:
    ///
    ///  1) If the value is a script resource, `script_get_name` is used.
    ///  2) If the value is a method and a `name` field exists, then the value
    ///     of this `name` field will be used as the name.
    ///  3) If the value is a method and a `name` field does not exist, then
    ///     `script_get_name` will be called on the underlying bound script
    ///     resource.
    ///
    /// @remark
    ///   If you would prefer to ignore the bound `self` value of the function,
    ///   and treat it as a global script, you should use the
    ///   `exposeFunctionByName` method instead.
    ///
    /// @deprecated {4.0.0}
    ///   Will not work on GMRT.
    ///
    /// @param {Function} func
    ///   The script ID or method to add.
    static exposeMethodByName = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var func = argument[i];
            var name;
            if (is_string(func)) {
                name = func;
                func = undefined;
                if (
                    !string_starts_with(name, "<unknown>") &&
                    !string_starts_with(name, "@@") &&
                    !string_starts_with(name, "$") &&
                    !string_starts_with(name, "YoYo") &&
                    !string_starts_with(name, "yy") &&
                    !string_starts_with(name, "[[") &&
                    !string_starts_with(name, "__")
                ) {
                    for(var builtinID = 0; builtinID < 10000; builtinID += 1;) {
                        var scriptName = script_get_name(builtinID);
                        if (scriptName == name) {
                            func = builtinID;
                            break;
                        }
                    }
                }
                if (func == undefined) {
                    for (var scriptID = 100001; script_exists(scriptID); scriptID += 1) {
                        var scriptName = script_get_name(scriptID);
                        if (
                            string_starts_with(scriptName, "anon") ||
                            string_count("gml_GlobalScript", scriptName) > 0 ||
                            string_count("__struct__", scriptName) > 0
                        ) {
                            continue;
                        }
                        if (scriptName == name) {
                            func = scriptID;
                            break;
                        }
                    }
                }
                if (func == undefined) {
                    __catspeak_error(__catspeak_cat(
                        "method with the name '", name, "' cannot be found"
                    ));
                }
            } else {
                name = __catspeak_infer_function_name(func);
            }
            func = is_method(func) ? func : method(undefined, func);
            globals[$ name] = func;
        }
    };

    /// Exposes a GameMaker asset from the resource tree to this interface.
    ///
    /// @deprecated {4.0.0}
    ///   Use `CatspeakModuleAssets` instead.
    ///
    /// @param {String} name
    ///   The name of the GM asset that you wish to expose to Catspeak.
    static exposeAsset = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var name = argument[i];
            __catspeak_assert_typeof(name, is_string);
            var value = asset_get_index(name);
            var type = asset_get_type(name);
            // validate that it's an actual GM Asset
            if (value == -1) {
                __catspeak_error(__catspeak_cat(
                    "invalid GMAsset: got '", value, "' from '", name, "'"
                ));
            }
            if (type == asset_script) {
                // scripts must be coerced into methods
                value = method(undefined, value);
            }
            globals[$ name] = value;
        }
    };

    /// Exposes a set of tagged GameMaker assets to this interface.
    ///
    /// @deprecated {4.0.0}
    ///   Use `CatspeakModuleAssets` instead.
    ///
    /// @param {Any} tag
    ///   The name of a tag, or array of tags, of assets to expose to Catspeak.
    static exposeAssetByTag = function () {
        for (var i = 0; i < argument_count; i += 1) {
            var assets = tag_get_assets(argument[i]);
            for (var j = array_length(assets) - 1; j >= 0; j -= 1) {
                exposeAsset(assets[j]);
            }
        }
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