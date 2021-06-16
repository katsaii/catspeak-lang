require "set"
$gml_names_incompatible = [
    "local",
    "gml_release_mode",
    "gml_pragma",
    "skeleton_animation_get_event_frames",
    "phy_particle_data_flag_color",
    "font_replace"
].to_set
$gml_names = []
content = File.read "./gml_builtins.txt"
content.scan /^([A-Za-z0-9_]+)(.*)$/ do |x|
    ident = x[0]
    kind = if $gml_names_incompatible.include? ident
        :incompatible
    elsif x[1].include? "&"
        :obsolete
    elsif x[1].include? "#"
        :constant
    elsif x[1].include? "("
        :function
    else
        :other
    end
    $gml_names.append [ident, kind]
end
$gml_constant = $gml_names
        .filter{|_, kind| kind == :constant}
        .map{|ident, _| ident}
$gml_function = $gml_names
        .filter{|_, kind| kind == :function}
        .map{|ident, _| ident}
$gml_template = <<~HEAD
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
	function catspeak_ext_gml_constants() {
		static vars = (function() {
			var _ = { };
			#{$gml_constant.map{|x| "_[$ \"#{x}\"] = #{x};"}.join("\n\t\t")}
			return _;
		})();
		return vars;
	}

	/// @desc Returns the functions of the gml standard library as a struct.
	function catspeak_ext_gml_functions() {
		static vars = (function() {
			var _ = { };
			#{$gml_function.map{|x| "_[$ \"#{x}\"] = #{x};"}.join("\n\t\t")}
			return _;
		})();
		return vars;
	}
HEAD
File.write "./scripts/scr_catspeak_ext_gml/scr_catspeak_ext_gml.gml", $gml_template
