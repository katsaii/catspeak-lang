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
        testQueue : ds_queue_create(),
    };
    return stats;
}

function Test(name) constructor {
    show_debug_message("RUNNING TEST " + string(name));

    var stats = test_stats();
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

    assertEq = function(a, b, exact=true) {
        var testCase = __makeTestCaseStruct();
        if (!__structuralEq(a, b, exact)) {
            testCase.fail(__cat(
                "values are not the same (", a, "!=", b, ")"
            ));
        }
        return testCase;
    };

    assertNeq = function(a, b, exact=true) {
        var testCase = __makeTestCaseStruct();
        if (__structuralEq(a, b, exact)) {
            testCase.fail(__cat(
                "values are the same (", a, "==", b, ")"
            ));
        }
        return testCase;
    };

    assertStrictEq = function(a, b) {
        var testCase = __makeTestCaseStruct();
        if (!__strictEq(a, b)) {
            testCase.fail(__cat(
                "values are not the same [strict!] (", a, "!=", b, ")"
            ));
        }
        return testCase;
    };

    assertStrictNeq = function(a, b) {
        var testCase = __makeTestCaseStruct();
        if (__strictEq(a, b)) {
            testCase.fail(__cat(
                "values are the same [strict!] (", a, "==", b, ")"
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

function test_add(f, forceRun=false) {
    if (!forceRun && !TEST_RUN_ENABLED) {
        return;
    }
    var stats = test_stats();
    stats.total += 1;
    stats.totalActive += 1;
    ds_queue_enqueue(stats.testQueue, f);
}

function test_run() {
    var stats = test_stats();
    if (ds_queue_empty(stats.testQueue)) {
        return;
    }
    var testFunc = ds_queue_dequeue(stats.testQueue);
    try {
        test = new testFunc();
        if (test.automatic) {
            // otherwise `complete()` needs to be called manually
            test.complete();
        }
    } catch (e) {
        stats.totalFatal += 1;
        show_debug_message(
            "encountered a fatal error when running one of the test cases:\n"
            + __catspeak_string(e)
        );
    }
}

/// @ignore
function __cat() {
    var msg = "";
    for (var i = 0; i < argument_count; i += 1) {
        var arg = argument[i];
        msg += is_string(arg) ? arg : string(arg);
    }
    return msg;
}

/// @ignore
function __strictEq(a, b) {
    if (typeof(a) != typeof(b)) {
        return false;
    }
    return a == b || is_real(a) && is_real(b) && is_nan(a) && is_nan(b);
};

/// @ignore
function __structuralEq(a, b, exact) {
    // value type comparison
    if (a == b || is_real(a) && is_real(b) && is_nan(a) && is_nan(b)) {
        return true;
    }
    // method comparison
    if (is_method(a) && is_method(b)) {
        if (method_get_index(a) != method_get_index(b)) {
            return false;
        }
        return __structuralEq(method_get_self(a), method_get_self(b), exact);
    }
    // array comparison
    if (is_array(a) && is_array(b)) {
        if (array_equals(a, b)) {
            return true;
        }
        var n = array_length(a);
        var m = array_length(b);
        if (n != m) {
            return false;
        }
        for (var i = 0; i < n; i += 1) {
            if (!__structuralEq(a[i], b[i], exact)) {
                return false;
            }
        }
        return true;
    }
    // struct comparison
    if (is_struct(a) && is_struct(b)) {
        if (instanceof(a) != instanceof(b)) {
            return false;
        }
        var aNames = variable_struct_get_names(a);
        var bNames = variable_struct_get_names(b);
        var n = array_length(aNames);
        var m = array_length(bNames);
        if (exact) {
            if (n != m) {
                return false;
            }
            for (var i = 0; i < n; i += 1) {
                var name = aNames[i];
                if (!variable_struct_exists(b, name)) {
                    return false;
                }
                if (!__structuralEq(a[$ name], b[$ name], exact)) {
                    return false;
                }
            }
            for (var i = 0; i < m; i += 1) {
                var name = bNames[i];
                if (!variable_struct_exists(a, name)) {
                    return false;
                }
                if (!__structuralEq(a[$ name], b[$ name], exact)) {
                    return false;
                }
            }
        } else {
            for (var i = 0; i < m; i += 1) {
                var name = bNames[i];
                if (!variable_struct_exists(a, name)) {
                    return false;
                }
                if (!__structuralEq(a[$ name], b[$ name], exact)) {
                    return false;
                }
            }
        }
        return true;
    }
    // not equal
    return false;
};