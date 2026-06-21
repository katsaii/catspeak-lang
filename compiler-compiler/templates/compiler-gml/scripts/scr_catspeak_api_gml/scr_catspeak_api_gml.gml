//! A full-fat module containing the GML standard library functions, constants,
//! and properties. Permissions can be granted by passing `CatspeakPerm` mask
//! into the `CatspeakModuleGML` constructor.

//# feather use syntax-errors

/// A module for exposing the GML API to Catspeak programs.
///
/// @param {String} [name]
///   The name of the module. Defaults to `"gm::gml"`.
function CatspeakModuleGML(name = "gm::gml") : CatspeakModule(name) constructor {
    /// @ignore
    __exists__ = function (name) {
        return asset_get_index(name) != -1 || defs[$ name] != undefined;
    };
    /// @ignore
    __get__ = function (name) {
        var asset = asset_get_index(name);
        var fallback = undefined;
        if (asset != -1) {
            if (asset_get_type(name) == asset_script) {
                fallback = method(undefined, fallback);
            } else {
                return asset;
            }
        }
        return defs[$ name] ?? fallback;
    };
    /// @ignore
    static defs = undefined;
    if (defs == undefined) {
        defs = { };
        with ({ }) { // protects from incorrectly reading a missing function from an instance variable
{% for (fnameses, symbols) in fnames.items() %}
{%  if len(symbols) > 0 %}
            try {
{%   for (symbol, flags) in symbols %}
{%    set symbol_alias = GML_SYMBOL_MAP.get(symbol, symbol) %}
{%     if band(flags, TAG_FUNCTION) %}
                defs[$ "{{ symbol }}"] = method(undefined, {{ symbol_alias }});
{%     endif %}
{%     if band(flags, TAG_CONST) %}
{%      if symbol == "global" %}
                defs[$ "{{ symbol }}"] = catspeak_special_to_struct({{ symbol_alias }});
{%      else %}
                defs[$ "{{ symbol }}"] = {{ symbol_alias }};
{%      endif %}
{%     endif %}
{%     if band(flags, TAG_PROP_GET) %}
                defs[$ "{{ symbol }}_get"] = method(undefined, function () { return {{ symbol_alias }} });
{%     endif %}
{%     if band(flags, TAG_PROP_SET) %}
                defs[$ "{{ symbol }}_set"] = method(undefined, function (val) { return {{ symbol_alias }} = val });
{%     endif %}
{%     if band(flags, TAG_PROP_GET_I) %}
                defs[$ "{{ symbol }}_get"] = method(undefined, function (idx) { return {{ symbol_alias }}[idx] });
{%     endif %}
{%     if band(flags, TAG_PROP_SET_I) %}
                defs[$ "{{ symbol }}_set"] = method(undefined, function (idx, val) { return {{ symbol_alias }}[idx] = val });
{%     endif %}
{%   endfor %}
            } catch (err_) {
                __catspeak_error_silent(__catspeak_cat(
                    "skipping GML API version: {{ ' + '.join(fnameses) }} ",
                    "(your GameMaker version may be out of date) reason: ",
                    err_.message
                ));
            }
{%  endif %}
{% endfor %}
        }
    }
}