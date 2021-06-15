/* Catspeak GML Interface
 * ----------------------
 * Kat @katsaii
 */

/// @desc Returns arithmetic operators as a struct.
function catspeak_ext_arithmetic() {
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
		_[$ "self"] = self;
		_[$ "other"] = other;
		_[$ "all"] = all;
		_[$ "noone"] = noone;
		_[$ "global"] = global;
		_[$ "undefined"] = undefined;
		_[$ "pointer_invalid"] = pointer_invalid;
		_[$ "pointer_null"] = pointer_null;
		_[$ "path_action_stop"] = path_action_stop;
		_[$ "path_action_restart"] = path_action_restart;
		_[$ "path_action_continue"] = path_action_continue;
		_[$ "path_action_reverse"] = path_action_reverse;
		_[$ "true"] = true;
		_[$ "false"] = false;
		_[$ "pi"] = pi;
		_[$ "NaN"] = NaN;
		_[$ "infinity"] = infinity;
		_[$ "GM_build_date"] = GM_build_date;
		_[$ "GM_version"] = GM_version;
		_[$ "GM_runtime_version"] = GM_runtime_version;
		_[$ "timezone_local"] = timezone_local;
		_[$ "timezone_utc"] = timezone_utc;
		_[$ "gamespeed_fps"] = gamespeed_fps;
		_[$ "gamespeed_microseconds"] = gamespeed_microseconds;
		return _;
	})();
	return vars;
}

/// @desc Returns the functions of the gml standard library as a struct.
function catspeak_ext_gml_scripts() {
	static vars = (function() {
		var _ = { };
		var i = 0;
		var m = "";
		do {
			var name = script_get_name(i);
			if (script_exists(i) || name != "" && name != "<unknown>") {
				m += name + " -- " + string(i) + "\n";
				_[$ name] = i;
				i += 1;
			} else {
				break;
			}
		} until (false);
		clipboard_set_text(m);
		return _;
	})();
	return vars;
}