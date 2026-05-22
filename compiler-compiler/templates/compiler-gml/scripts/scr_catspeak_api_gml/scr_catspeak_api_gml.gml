//! TODO

//# feather use syntax-errors

/// TODO
///
/// @remark
///   Some permissions courtesy of: https://github.com/tinkerer-red/GML-Function-DB
enum CatspeakPerm {
    /// No special permissions needed.
    NONE = 0,
    /// Allow deprecated API functions.
    DEPRECATED = 1 << 0,
    /// Allow unsafe behaviour.
    UNSAFE = 1 << 1,
    /// Allow functions which could be used to exploit the Catspeak sandbox
    /// or break internal Catspeak behaviour.
    EXPLOITABLE = 1 << 2,
    /// Allow functions which mutate their inputs.
    EFFECTS = 1 << 3,
    /// Allow functions which have global effects.
    EFFECTS_GLOBAL = 1 << 4,
    /// Allow access to the users filesystem.
    IO_FILE = 1 << 5,
    /// Allow access to networking behaviour.
    IO_NETWORK = 1 << 6,
    /// Allow access to user input.
    IO_INPUT = 1 << 7,
    /// Allow access to rendering/draw functions.
    IO_RENDER = 1 << 8,
    /// ALlow access to platform-specific functions.
    PLATFORM_SPECIFIC = 1 << 9,
    /// Allow access to functions which leak personal information.
    FINGERPRINTING = 1 << 10,
    /// Allow asset reflection.
    REFLECTION = 1 << 11,
    /// Allow window dialogs, e.g. `show_message` and debug overlays.
    OS_DIALOG = 1 << 12,
    /// Allow mods to modify window state.
    OS_DIRECTIVE = 1 << 13,
    /// Typical safe API which doesn't give mods too much power, whilst still
    /// being flexible enough to take user input and render to the screen.
    DEFAULT_ = CatspeakPerm.EFFECTS | CatspeakPerm.IO_INPUT | CatspeakPerm.IO_RENDER,
    /// @ignore
    __UNSPECIFIED = 0xFFFFFFFF,
}

/// TODO
function CatspeakModuleGML(perms_) : CatspeakModule("gm::gml") constructor {
    /// @ignore
    perms = perms_;
    /// @ignore
    __exists__ = function (name) {
        return false;
    };
    /// @ignore
    __get__ = function (name) {
        return undefined;
    };
    /// @ignore
    static defs = undefined;
    if (defs == undefined) {
        defs = { };
        with ({ }) { // protects from incorrectly reading a missing function from an instance variable
            var defPerms;
{% for (fnameses, symbols) in fnames.items() %}
{%  if len(symbols) > 0 %}
            try {
{%   for (symbol, flags) in symbols %}
{%    set symbol_alias = GML_SYMBOL_MAP.get(symbol, symbol) %}
{%    set symbol_perms = GML_PERMS.get(symbol, (None, []))[1] %}
{%    if len(symbol_perms) < 1 %}
{%     set symbol_perms = ["NONE"] %}
{%    endif %}
{%    set symbol_perms_str = " | ".join(map(add_prefix("CatspeakPerm."), symbol_perms)) %}
{%     if band(flags, TAG_FUNCTION) %}
                defs[$ "{{ symbol }}"] = { v : method(undefined, {{ symbol_alias }}), perms : {{ symbol_perms_str }} };
{%     endif %}
{%     if band(flags, TAG_CONST) %}
{%      if symbol == "global" %}
                defs[$ "{{ symbol }}"] = { v : catspeak_special_to_struct({{ symbol_alias }}), perms : {{ symbol_perms_str }} };
{%      else %}
                defs[$ "{{ symbol }}"] = { v : {{ symbol_alias }}, perms : {{ symbol_perms_str }} };
{%      endif %}
{%     endif %}
{%     if band(flags, TAG_PROP_GET) %}
                defs[$ "{{ symbol }}_get"] = { v : method(undefined, function () { return {{ symbol_alias }} }), perms : {{ symbol_perms_str }} };
{%     endif %}
{%     if band(flags, TAG_PROP_SET) %}
                defs[$ "{{ symbol }}_set"] = { v : method(undefined, function (val) { return {{ symbol_alias }} = val }), perms : {{ symbol_perms_str }} };
{%     endif %}
{%     if band(flags, TAG_PROP_GET_I) %}
                defs[$ "{{ symbol }}_get"] = { v : method(undefined, function (idx) { return {{ symbol_alias }}[idx] }), perms : {{ symbol_perms_str }} };
{%     endif %}
{%     if band(flags, TAG_PROP_SET_I) %}
                defs[$ "{{ symbol }}_set"] = { v : method(undefined, function (idx, val) { return {{ symbol_alias }}[idx] = val }), perms : {{ symbol_perms_str }} };
{%     endif %}
{%   endfor %}
            } catch (err_) {
                __catspeak_error_silent(__catspeak_cat(
                    "skipping GML API versions: {{ ', '.join(fnameses) }} ",
                    "(your GameMaker version may be out of date) reason: ",
                    err_.message
                ));
            }
{%  endif %}
{% endfor %}
        }
    }
}