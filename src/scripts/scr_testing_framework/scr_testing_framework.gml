//! Helper functions for managing unit tests.

function test_begin(name) {
    catspeak_force_init();
    global.currentTest = {
        name : name ?? "unnamed",
        fails : [],
    };
}

function test_fail(msg="no message") {
    array_push(global.currentTest.fails, msg);
}

function test_assert(condition, msg) {
    if (!condition) {
        test_fail(__cat("condition must be true: ", msg));
    }
}

function test_assert_false(condition, msg) {
    if (condition) {
        test_fail(__cat("condition must be false: ", msg));
    }
}

function test_assert_eq(a, b, msg) {
    if (a != b) {
        test_fail(__cat("values are not the same (", a, "!=", b, "): ", msg));
    }
}

function test_assert_typeof(value, expectedType, msg) {
    var type = typeof(value);
    if (type != expectedType) {
        test_fail(__cat(
            "value '", value, "' ",
            "must have the type \"", expectedType, "\", ",
            "but got \"", type, "\": ", msg
        ));
    }
}

function test_assert_instanceof(value, expectedType, msg) {
    var type = instanceof(value);
    if (type != expectedType) {
        test_fail(__cat(
            "value '", value, "' ",
            "must derive the type \"", expectedType, "\", ",
            "but got \"", type, "\": ", msg
        ));
    }
}

function test_assert_asset(name, expectedType, msg) {
    if (asset_get_index(name) == -1) {
        test_fail(__cat(
            "an asset with the name '", name, "' must exist: ", msg
        ));
    } else {
        var type = asset_get_type(name);
        if (type != expectedType) {
            test_fail(__cat(
                "an asset with the name '", name, "' exists, ",
                "but is the wrong asset type (", type, " != ",
                expectedType, "): ", msg
            ));
        }
    }
}

function test_end() {
    var test = global.currentTest;
    var name = __cat(test.name);
    var fails = test.fails;
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
}

function __cat() {
    var msg = "";
    for (var i = 0; i < argument_count; i += 1) {
        var arg = argument[i];
        msg += is_string(arg) ? arg : string(arg);
    }
    return msg;
}