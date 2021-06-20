require "set"
require "erb"

def generate_identifiers filepath, incompatible_names
    names = []
    content = File.read filepath
    content.scan /^([A-Za-z0-9_]+)(.*)$/ do |x|
        name = x[0]
        modifier = x[1]
        kind = if incompatible_names.include? name
            :incompatible
        elsif modifier.include? "&"
            :obsolete
        elsif modifier.include? "#"
            :constant
        elsif modifier.include? "("
            :function
        else
            :other
        end
        names.append [name, kind]
    end
    constants = names
            .filter{|_, kind| kind == :constant}
            .map{|name, _| name}
    functions = names
            .filter{|_, kind| kind == :function}
            .map{|name, _| name}
    [constants, functions]
end

$gml_constants, $gml_functions = generate_identifiers "./gml_builtins.txt", [
    "local", "gml_release_mode", "gml_pragma", "skeleton_animation_get_event_frames",
    "phy_particle_data_flag_color", "font_replace", "room", "room_persistent", "score",
    "lives", "health", "cursor_sprite"
].to_set

def filter_map patterns, names
    contains = (patterns.fetch :contains, []).to_set
    prefixes = patterns.fetch :prefixes, []
    names.filter{|name| contains.include? name or prefixes.any?{|prefix| name.start_with? prefix + "_"}}
end

def show_map_constants patterns, indent=8
    (filter_map patterns, $gml_constants)
            .map{|name| "c(_session, \"#{name}\", #{name});"}
            .join("\n" + " " * indent)
end

def show_map_functions patterns, indent=8
    (filter_map patterns, $gml_functions)
            .map{|name| "f(_session, \"#{name}\", #{name});"}
            .join("\n" + " " * indent)
end

gml_script_groups = {
    :instances => {
        :contains => ["all", "noone", "global"],
        :prefixes => [
            "object", "instance", "motion", "place", "move", "distance",
            "position", "collision", "point", "rectangle", "bbox", "physics",
            "phy"
        ]
    },
    :pointers => {
        :contains => ["ptr"],
        :prefixes => ["pointer", "weak_ref"]
    },
    :unsafe => {
        :prefixes => [
            "exception", "variable", "game", "gamespeed", "room", "event",
            "ev", "get", "external", "ty", "dll", "of_challenge", "achievement",
            "leaderboard", "highscore", "shop", "ads", "iap", "analytics",
            "win8", "uwp", "winphone", "network", "steam", "ov", "lb", "ugc",
            "push", "gc"
        ]
    },
    :introspection => {
        :contains => ["typeof", "instanceof"],
        :prefixes => ["is", "in", "asset", "tag", "extension"]
    },
    :maths => {
        :contains => [
            "undefined", "true", "false", "NaN", "infinity", "pi", "abs",
            "round", "floor", "ceil", "sign", "frac", "sqrt", "sqr", "exp",
            "ln", "log2", "log10", "sin", "cos", "tan", "arcsin", "arccos",
            "arctan", "arctan2", "dsin", "dcos", "dtan", "darcsin",
            "darccos", "darctan", "darctan2", "degtorad", "power", "logn",
            "min", "max", "mean", "median", "clamp", "lerp", "real", "bool",
            "int64"
        ],
        :prefixes => ["dot", "math", "point", "lengthdir", "matrix"]
    },
    :animation => {
        :prefixes => [
            "path", "mp", "timeline", "skeleton", "sequence", "animcurve", "seqtracktype",
            "seqplay", "seqdir", "seqinterpolation", "seqaudiokey",
            "animcurvetype"
        ]
    },
    :collections => {
        :prefixes => [
            "path", "mp", "array", "struct", "ds", "highscore", "buffer"
        ]
    },
    :random => {
        :contains => ["random", "irandom", "randomize", "randomise", "choose"],
        :prefixes => ["random", "irandom"]
    },
    :strings => {
        :contains => ["string", "chr", "ansi_char", "ord"],
        :prefixes => ["string"]
    },
    :scripts => {
        :contains => ["method"],
        :prefixes => ["method", "script"]
    },
    :input => {
        :prefixes => [
            "clipboard", "date", "timezone", "keyboard", "vk", "io", "mouse",
            "mb", "cursor", "clickable", "virtual_key", "gamepad", "gp",
            "gesture", "kbv"
        ]
    },
    :audio => {
        :prefixes => ["audio"]
    },
    :graphics => {
        :contains => [
            "merge_color", "merge_colour", "fa_left", "fa_center", "fa_right",
            "fa_top", "fa_middle", "fa_bottom"
        ],
        :prefixes => [
            "application", "font", "sprite", "image", "bboxmode", "bboxkind",
            "background", "draw", "c",  "make_color", "make_colour",
            "color", "colour", "pr", "texture", "bm", "tf", "mip", "surface",
            "texturegroup", "spritespeed", "cmpfunc", "cull", "lighttype",
            "gpu", "shader", "vertex"
        ]
    },
    :layers => {
        :prefixes => ["layer", "layerelementtype", "tilemap", "tile"]
    },
    :display => {
        :prefixes => ["display", "window", "cr", "view", "camera", "tm"]
    },
    :debug => {
        :prefixes => ["show", "debug", "stacktrace"]
    },
    :files => {
        :contains => [
            "fa_readonly", "fa_hidden", "fa_sysfile", "fa_volumeid",
            "fa_directory", "fa_archive", "load_csv"
        ],
        :prefixes => [
            "file", "parameter", "ini", "text", "screen", "gif", "cloud",
            "http", "json", "zip", "base64", "md5", "sha1"
        ]
    },
    :particles => {
        :prefixes => ["effect", "ef", "part", "pt", "ps"]
    },
    :device => {
        :contains => ["code_is_compiled"],
        :prefixes => ["GM", "os", "browser", "device"]
    }
}

gml_interface = (ERB.new <<~HEAD, trim_mode: "->").result binding
    /* Catspeak GML Interface
     * ----------------------
     * Kat @katsaii
     */

    /// @desc Applies a GML interface to this Catspeak session.
    /// @param {struct} session The Catspeak session to update.
    function catspeak_ext_session_add_gml_operators(_session) {
        var f = catspeak_session_add_function;
        var c = catspeak_session_add_constant;
        f(_session, "+", function(_l, _r) { return _l + _r; });
        f(_session, "++", function(_l, _r) { return (is_string(_l) ? _l : string(_l)) + (is_string(_r) ? _r : string(_r)); });
        f(_session, "-", function(_l, _r) { return _r == undefined ? -_l : _l - _r; });
        f(_session, "*", function(_l, _r) { return _l * _r; });
        f(_session, "/", function(_l, _r) { return _l / _r; });
        f(_session, "%", function(_l, _r) { return _l % _r; });
        f(_session, "div", function(_l, _r) { return _l div _r; });
        f(_session, "|", function(_l, _r) { return _l | _r; });
        f(_session, "&", function(_l, _r) { return _l & _r; });
        f(_session, "^", function(_l, _r) { return _l ^ _r; });
        f(_session, "~", function(_x) { return ~_x; });
        f(_session, "<<", function(_l, _r) { return _l << _r; });
        f(_session, ">>", function(_l, _r) { return _l >> _r; });
        f(_session, "||", function(_l, _r) { return _l || _r; });
        f(_session, "&&", function(_l, _r) { return _l && _r; });
        f(_session, "^^", function(_l, _r) { return _l ^^ _r; });
        f(_session, "!", function(_x) { return !_x; });
        f(_session, "==", function(_l, _r) { return _l == _r; });
        f(_session, "!=", function(_l, _r) { return _l != _r; });
        f(_session, ">=", function(_l, _r) { return _l >= _r; });
        f(_session, "<=", function(_l, _r) { return _l <= _r; });
        f(_session, ">", function(_l, _r) { return _l > _r; });
        f(_session, "<", function(_l, _r) { return _l < _r; });
        f(_session, "!!", function(_x) { return is_numeric(_x) && _x; });
    }

    #macro CATSPEAK_EXT_GML_FUNCTIONS (1 << 0)
    #macro CATSPEAK_EXT_GML_CONSTANTS (1 << 1)
    #macro CATSPEAK_EXT_GML_ALL (CATSPEAK_EXT_GML_FUNCTIONS | CATSPEAK_EXT_GML_CONSTANTS)

    <% gml_script_groups.each do |group, keywords| -%>
    /// @desc Applies a GML interface to this Catspeak session.
    /// @param {struct} session The Catspeak session to update.
    /// @param {real} [mode] Whether to include functions, constants, or both.
    function catspeak_ext_session_add_gml_<%= group %>(_session, _mode) {
        if (_mode == undefined) {
            _mode = CATSPEAK_EXT_GML_ALL;
        }
        if (_mode & CATSPEAK_EXT_GML_FUNCTIONS) {
            var f = catspeak_session_add_function;
            <%= show_map_functions keywords %>
        }
        if (_mode & CATSPEAK_EXT_GML_CONSTANTS) {
            var c = catspeak_session_add_constant;
            <%= show_map_constants keywords %>
        }
    }

    <% end -%>
HEAD
File.write "./scripts/scr_catspeak_ext_gml/scr_catspeak_ext_gml.gml", gml_interface
