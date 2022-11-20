//! Helper functions for managing unit tests.

function Test(name) constructor {
    self.name = __cat(name);
    self.fails = [];
    self.automatic = true;

    catspeak_force_init();

    completeAutomatically = function(enable) {
        automatic = enable;
    };

    complete = function() {
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

    fail = function() {
        var testCase = __makeTestCaseStruct();
        testCase.fail("failed test");
        return testCase;
    };

    assert = function(condition) {
        var testCase = __makeTestCaseStruct();
        if (!condition) {
            testCase.fail(__cat("condition must be true"));
        }
        return testCase;
    };

    assertFalse = function(condition) {
        var testCase = __makeTestCaseStruct();
        if (condition) {
            testCase.fail(__cat("condition must be false"));
        }
        return testCase;
    };

    assertEq = function(a, b) {
        var testCase = __makeTestCaseStruct();
        if (a != b) {
            testCase.fail(__cat(
                "values are not the same (", a, "!=", b, ")"
            ));
        }
        return testCase;
    };

    assertNeq = function(a, b) {
        var testCase = __makeTestCaseStruct();
        if (a == b) {
            testCase.fail(__cat(
                "values are the same (", a, "!=", b, ")"
            ));
        }
        return testCase;
    };

    assertTypeof = function(value, expectedType) {
        var testCase = __makeTestCaseStruct();
        var type = typeof(value);
        if (type != expectedType) {
            testCase.fail(__cat(
                "value '", value, "' ",
                "must have the type \"", expectedType, "\", ",
                "but got \"", type, "\""
            ));
        }
        return testCase;
    };

    assertInstanceof = function(value, expectedType) {
        var testCase = __makeTestCaseStruct();
        var type = instanceof(value);
        if (type != expectedType) {
            testCase.fail(__cat(
                "value '", value, "' ",
                "must derive the type \"", expectedType, "\", ",
                "but got \"", type, "\""
            ));
        }
        return testCase;
    };

    assertAsset = function(name, expectedType) {
        var testCase = __makeTestCaseStruct();
        if (asset_get_index(name) == -1) {
            testCase.fail(__cat(
                "an asset with the name '", name, "' must exist"
            ));
        } else {
            var type = asset_get_type(name);
            if (type != expectedType) {
                testCase.fail(__cat(
                    "an asset with the name '", name, "' exists, ",
                    "but is the wrong asset type (", type, " != ",
                    expectedType, ")"
                ));
            }
        }
        return testCase;
    };

    __makeTestCaseStruct = function() {
        return {
            idx : -1,
            fails : fails,
            fail : function(msg="no message") {
                if (idx < 0) {
                    idx = array_length(fails);
                    fails[idx] = __cat(msg);
                } else {
                    fails[idx] = __cat(fails[idx], " + ", msg);
                }
            },
            withMessage : function(msg) {
                if (idx < 0) {
                    return;
                }
                fails[idx] += __cat(": ", msg);
            }
        };
    }
}

function run_test(f) {
    var test = new f();
    if (test.automatic) {
        // otherwise `complete()` needs to be called manually
        test.complete();
    }
}

function __cat() {
    var msg = "";
    for (var i = 0; i < argument_count; i += 1) {
        var arg = argument[i];
        msg += is_string(arg) ? arg : string(arg);
    }
    return msg;
}