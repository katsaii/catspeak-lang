/* Catspeak Tests
 * --------------
 * Kat @katsaii
 */
/*
function __catspeak_ext_tests_assert_eq(_expects, _got) {
    var callstack_pos = argument_count > 2 ? argument[2] : 1;
    var pass;
    if (is_array(_expects) && is_array(_got)) {
        pass = array_equals(_expects, _got);
    } else {
        pass = _expects == _got;
    }
    if not (pass) {
        var msg = "expected '" + string(_expects) + "' (" + typeof(_got) +
                ") got '" + string(_got) + "' (" + typeof(_got) + ")";
        var callstack = debug_get_callstack();
        show_error("failed unit test at " + callstack[callstack_pos] + " -- " + msg, false);
    }
}

function __catspeak_ext_tests_assert_true(_condition) {
    __catspeak_ext_tests_assert_eq(true, _condition, 2);
}

function __catspeak_ext_tests_assert_false(_condition) {
    __catspeak_ext_tests_assert_eq(false, _condition, 2);
}

try {
    // basic functionality
    var session = catspeak_session_create();
    var this = { result : undefined };
    catspeak_session_add_result_handler(session, method(this, function(_result) {
        result = _result;
    }));
    catspeak_session_add_source(session, "return 12");
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(12, this.result);

    // empty source code and comments
    var session = catspeak_session_create();
    var this = { error : false };
    catspeak_session_add_error_handler(session, method(this, function(_) {
        error = true;
    }));
    catspeak_session_add_source(session, "");
    catspeak_session_add_source(session, "\n\n\t");
    catspeak_session_add_source(session, @'-- hello
    --another comment');
    catspeak_session_add_source(session, "\r\n\n");
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_false(this.error);

    // expression statement handler
    var session = catspeak_session_create();
    var this = { value : undefined };
    catspeak_session_add_expression_statement_handler(session, method(this, function(_value) {
        value = _value;
    }));
    catspeak_session_add_source(session, "18");
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(18, this.value);

    // assignment statements
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_session_add_source(session, "set var 3; set var' var");
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(3, workspace[$ "var"]);
    __catspeak_ext_tests_assert_eq(workspace[$ "var"], workspace[$ "var'"]);

    // foreign functions and values
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_session_add_constant(session, "const", -12);
    catspeak_session_add_function(session, "funct", max);
    catspeak_session_add_source(session, "set const' const; set funct' funct");
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(-12, workspace[$ "const'"]);
    __catspeak_ext_tests_assert_eq(max, method_get_index(workspace[$ "funct'"]));

    // gml interface
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_ext_session_add_gml_operators(session);
    catspeak_ext_session_add_gml_maths(session);
    catspeak_session_add_source(session, @'
    set a : -3
    set b : 12
    set c : a * b + -a
    set d : max a b c
    ');
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(-3, workspace[$ "a"]);
    __catspeak_ext_tests_assert_eq(12, workspace[$ "b"]);
    __catspeak_ext_tests_assert_eq(workspace[$ "a"] * workspace[$ "b"] + -workspace[$ "a"], workspace[$ "c"]);
    __catspeak_ext_tests_assert_eq(max(
            workspace[$ "a"], workspace[$ "b"], workspace[$ "a"] * workspace[$ "b"] + -workspace[$ "a"]),
            workspace[$ "d"]);

    // data types
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_ext_session_add_gml_maths(session);
    catspeak_session_add_source(session, @'
    set int 1
    set float 1.5
    set nan NaN
    set array [
        "hello world"
        true
        false
    ]
    set object {
        .x undefined
        .y infinity
    }
    ');
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(1, workspace[$ "int"]);
    __catspeak_ext_tests_assert_eq(1.5, workspace[$ "float"]);
    __catspeak_ext_tests_assert_true(is_nan(workspace[$ "nan"]));
    __catspeak_ext_tests_assert_eq(["hello world", true, false], workspace[$ "array"]);
    __catspeak_ext_tests_assert_eq(undefined, workspace[$ "object"].x);
    __catspeak_ext_tests_assert_eq(infinity, workspace[$ "object"].y);

    // if statements
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_ext_session_add_gml_operators(session);
    catspeak_session_add_source(session, @'
    set a 3
    set b 5
    if (a > b) {
        set c "greater"
    } else if (a < b) {
        set c "less"
    } else {
        set c "equal"
    }
    ');
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(3, workspace[$ "a"]);
    __catspeak_ext_tests_assert_eq(5, workspace[$ "b"]);
    __catspeak_ext_tests_assert_eq("less", workspace[$ "c"]);

    // while loops
    var session = catspeak_session_create();
    var this = { count : 0 };
    var workspace = catspeak_session_get_workspace(session);
    catspeak_ext_session_add_gml_operators(session);
    catspeak_session_add_function(session, "register_count", method(this, function() {
        count += 1;
    }));
    catspeak_session_add_source(session, @'
    set count 0
    set limit 10
    while (count < limit) {
        run register_count
        set count : count + 1
    }
    ');
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);
    __catspeak_ext_tests_assert_eq(10, workspace[$ "limit"]);
    __catspeak_ext_tests_assert_eq(workspace[$ "limit"], workspace[$ "count"]);
    __catspeak_ext_tests_assert_eq(workspace[$ "count"], this.count);

    // break points
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_ext_session_add_gml_maths(session);
    catspeak_session_add_function(session, "failure", function(_number) {
        throw "failed to break out of loop " + string(_number);
    });
    catspeak_session_add_source(session, @'
    while true {
        break
        failure 1
    }
    while true {
        while true {
            break 2
            failure 2
        }
        failure 3
    }
    ');
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);

    // continue points
    var session = catspeak_session_create();
    var workspace = catspeak_session_get_workspace(session);
    catspeak_ext_session_add_gml_operators(session);
    catspeak_ext_session_add_gml_maths(session);
    catspeak_session_add_function(session, "failure", function(_number) {
        throw "failed to continue outside of loop " + string(_number);
    });
    catspeak_session_add_source(session, @'
    set count 10
    while (count > 0) {
        set count : count - 1
        while true {
            continue 2
            failure 1
        }
    }
    ');
    catspeak_session_update_eager(session);
    catspeak_session_destroy(session);

    // JSON-like syntax
    var obj_json = catspeak_ext_json_parse(@'
    {
        "glossary": {
            "title": "example glossary",
            "GlossDiv": {
                "title": "S",
                "GlossList": {
                    "GlossEntry": {
                        "ID": "SGML",
                        "SortAs": "SGML",
                        "GlossTerm": "Standard Generalized Markup Language",
                        "Acronym": "SGML",
                        "Abbrev": "ISO 8879:1986",
                        "GlossDef": {
                            "para": "A meta-markup language, used to create markup languages such as DocBook.",
                            "GlossSeeAlso": ["GML", "XML"]
                        },
                        "GlossSee": "markup"
                    }
                }
            }
        }
    }
    ');
    var obj_catspeak_object = catspeak_ext_json_parse(@'
    {
        .glossary {
            .title "example glossary"
            .GlossDiv {
                .title "S",
                .GlossList {
                    .GlossEntry {
                        .ID "SGML"
                        .SortAs "SGML"
                        .GlossTerm "Standard Generalized Markup Language"
                        .Acronym "SGML"
                        .Abbrev "ISO 8879:1986"
                        .GlossDef {
                            .para "A meta-markup language, used to create markup languages such as DocBook.",
                            .GlossSeeAlso ["GML", "XML"]
                        }
                        .GlossSee "markup"
                    }
                }
            }
        }
    }
    ');
    __catspeak_ext_tests_assert_true(is_struct(obj_json));
    __catspeak_ext_tests_assert_true(is_struct(obj_catspeak_object));

    // success
    show_debug_message("ALL CATSPEAK TESTS PASSED SUCCESSFULLY");
} catch (_e) {
    var msg = is_struct(_e) && variable_struct_exists(_e, "message") ? _e[$ "message"] : string(_e);
    show_debug_message("AN ERROR OCCURRED WHEN RUNNING CATSPEAK UNIT TESTS:\n" + msg);
}
*/