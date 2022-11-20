//! Helper functions for managing unit tests.

function TestCase(name="unnamed") constructor {
    self.name = __cat(name);
    self.fails = [];

    catspeak_force_init();

    static complete = function() {
        var passed = array_length(fails) < 1;
        var msg = " ---===--- test ";
        if (passed) {
            msg += "PASSED";
        } else {
            msg += "FAILED";
        }
        msg += " '" + name + "'";
        if (!passed) {
            msg += " [";
            for (var i = 0; i < array_length(fails); i += 1) {
                msg += __cat("\n  ", fails[i]);
            }
            msg += "\n]";
        }
        show_debug_message(msg);
    };

    static fail = function(msg="no message") {
        array_push(global.currentTest.fails, msg);
    };

    static assert = function(condition, msg) {
        if (!condition) {
            fail(__cat("condition must be true: ", msg));
        }
    };

    static assertFalse = function(condition, msg) {
        if (condition) {
            fail(__cat("condition must be false: ", msg));
        }
    };

    static assertEq = function(a, b, msg) {
        if (a != b) {
            fail(__cat(
                "values are not the same (", a, "!=", b, "): ", msg
            ));
        }
    };

    static assertTypeof = function(value, expectedType, msg) {
        var type = typeof(value);
        if (type != expectedType) {
            fail(__cat(
                "value '", value, "' ",
                "must have the type \"", expectedType, "\", ",
                "but got \"", type, "\": ", msg
            ));
        }
    };

    static assertInstanceof = function(value, expectedType, msg) {
        var type = instanceof(value);
        if (type != expectedType) {
            fail(__cat(
                "value '", value, "' ",
                "must derive the type \"", expectedType, "\", ",
                "but got \"", type, "\": ", msg
            ));
        }
    }

    static assertAsset = function(name, expectedType, msg) {
        if (asset_get_index(name) == -1) {
            fail(__cat(
                "an asset with the name '", name, "' must exist: ", msg
            ));
        } else {
            var type = asset_get_type(name);
            if (type != expectedType) {
                fail(__cat(
                    "an asset with the name '", name, "' exists, ",
                    "but is the wrong asset type (", type, " != ",
                    expectedType, "): ", msg
                ));
            }
        }
    };
}

function __cat() {
    var msg = "";
    for (var i = 0; i < argument_count; i += 1) {
        var arg = argument[i];
        msg += is_string(arg) ? arg : string(arg);
    }
    return msg;
}