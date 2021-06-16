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

def show_map pattern, names, indent=2
    names.filter{|x| x.include? pattern}
            .map{|x| "_[$ \"#{x}\"] = #{x};"}.join("\n" + "\t" * indent)
end

gml_constants, gml_functions = generate_identifiers "./gml_builtins.txt", [
    "local",
    "gml_release_mode",
    "gml_pragma",
    "skeleton_animation_get_event_frames",
    "phy_particle_data_flag_color",
    "font_replace"
].to_set
gml_script_groups = [
    "keyboard"
]

gml_interface = (ERB.new <<~HEAD, trim_mode: "->").result binding
	/* Catspeak GML Interface
	 * ----------------------
	 * Kat @katsaii
	 */

	/// @desc Returns arithmetic operators as a struct.
	function catspeak_ext_gml_operators() {
		static vars = (function() {
			var _ = { };
			_[$ "+"] = function(_l, _r) { return _l + _r };
			_[$ "-"] = function(_l, _r) { return _r == undefined ? -_l : _l - _r };
			_[$ "*"] = function(_l, _r) { return _l * _r };
			_[$ "/"] = function(_l, _r) { return _l / _r };
			_[$ "%"] = function(_l, _r) { return _l % _r };
			_[$ "mod"] = _[$ "%"];
			_[$ "div"] = function(_l, _r) { return _l div _r };
			_[$ "|"] = function(_l, _r) { return _l | _r };
			_[$ "&"] = function(_l, _r) { return _l & _r };
			_[$ "^"] = function(_l, _r) { return _l ^ _r };
			_[$ "~"] = function(_x) { return ~_x };
			_[$ "<<"] = function(_l, _r) { return _l << _r };
			_[$ ">>"] = function(_l, _r) { return _l >> _r };
			_[$ "||"] = function(_l, _r) { return _l || _r };
			_[$ "or"] = _[$ "||"];
			_[$ "&&"] = function(_l, _r) { return _l && _r };
			_[$ "and"] = _[$ "&&"];
			_[$ "^^"] = function(_l, _r) { return _l ^^ _r };
			_[$ "xor"] = _[$ "^^"];
			_[$ "!"] = function(_x) { return !_x };
			_[$ "not"] = _[$ "!"];
			_[$ "=="] = function(_l, _r) { return _l == _r };
			_[$ "="] = _[$ "=="];
			_[$ "!="] = function(_l, _r) { return _l != _r };
			_[$ "<>"] = _[$ "!="];
			_[$ ">="] = function(_l, _r) { return _l >= _r };
			_[$ "<="] = function(_l, _r) { return _l <= _r };
			_[$ ">"] = function(_l, _r) { return _l > _r };
			_[$ "<"] = function(_l, _r) { return _l < _r };
			_[$ "!!"] = function(_x) { return is_numeric(_x) && _x };
			return _;
		})();
		return vars;
	}

	/// @desc Returns the constants of the gml standard library as a struct.
	/// @param {string} class The class of constants to include.
	function catspeak_ext_gml_constants(_class) {
	<% gml_script_groups.each do |group| -%>
		static vars_<%= group %> = (function() {
			var _ = { };
			<%= show_map group, gml_constants %>
			return _;
		})();
	<% end -%>
		switch (_class) {
	<% gml_script_groups.each do |group| -%>
		case "<%= group %>": return vars_<%= group %>;
	<% end -%>
		default: return undefined;
		}
	}

	/// @desc Returns the functions of the gml standard library as a struct.
	/// @param {string} class The class of constants to include.
	function catspeak_ext_gml_functions(_class) {
	<% gml_script_groups.each do |group| -%>
		static vars_<%= group %> = (function() {
			var _ = { };
			<%= show_map group, gml_functions %>
			return _;
		})();
	<% end -%>
		switch (_class) {
	<% gml_script_groups.each do |group| -%>
		case "<%= group %>": return vars_<%= group %>;
	<% end -%>
		default: return undefined;
		}
	}
HEAD
File.write "./scripts/scr_catspeak_ext_gml/scr_catspeak_ext_gml.gml", gml_interface
