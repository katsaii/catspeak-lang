//! Helper functions for managing unit tests.

//# feather use syntax-errors

#macro TEST_RUN_ENABLED true
#macro NoTest:TEST_RUN_ENABLED false

function test_stats() {
    static stats = {
        total : 0,
        totalFailed : 0,
        totalActive : 0,
        totalFatal : 0,
    };
    return stats;
}

function Test(name) constructor {
    var stats = test_stats();
    stats.total += 1;
    stats.totalActive += 1;
    self.number = stats.total;
    self.name = __cat(name);
    self.fails = [];
    self.automatic = true;

    catspeak_force_init();

    complete = function() {
        var stats = test_stats();
        stats.totalActive -= 1;
        var passed = array_length(fails) < 1;
        var msg = " ---===--- test ";
        msg += "#" + string(number) + " ";
        if (passed) {
            msg += "PASSED";
        } else {
            stats.totalFailed += 1;
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

    fail = function(msg="failed test") {
        var testCase = __makeTestCaseStruct();
        testCase.fail(msg);
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
            failed : false,
            fail : function(msg="no message") {
                failed = true;
                if (idx < 0) {
                    idx = array_length(fails);
                    fails[@ idx] = __cat(msg);
                } else {
                    fails[@ idx] = __cat(fails[idx], " + ", msg);
                }
            },
            withMessage : function(msg) {
                if (idx < 0) {
                    return;
                }
                fails[@ idx] += __cat(": ", msg);
            }
        };
    }
}

function AsyncTest(name) : Test(name) constructor {
    automatic = false;
}

function run_test(f, forceRun=false) {
    if (!forceRun && !TEST_RUN_ENABLED) {
        return;
    }
    try {
        var test = new f();
        if (test.automatic) {
            // otherwise `complete()` needs to be called manually
            test.complete();
        }
    } catch (e) {
        test_stats().totalFatal += 1;
        show_debug_message(
            "encountered a fatal error when running one of the test cases:\n"
            + __catspeak_string(e)
        );
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