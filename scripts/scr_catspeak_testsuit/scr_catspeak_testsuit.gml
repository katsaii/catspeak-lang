/* Catspeak Tests
 * --------------
 * Kat @katsaii
 */

var src = @'
set count 10
while (count > 0) {
    set count : count - 1
    if (count == 5) {
        print "hey, its five"
    } else {
        continue
        print "boring..."
    }
    print count
}
return "blast off!"
';
var sess = catspeak_session_create();
catspeak_ext_session_add_gml_operators(sess);
catspeak_session_set_error_handler(sess, function(_error) {
    show_message(_error);
});
catspeak_session_set_result_handler(sess, function(_result) {
    show_message(_result);
});
catspeak_session_set_expression_statement_handler(sess, function(_value) {
    if (is_array(_value) && array_length(_value) == 1) {
        show_debug_message(_value[0]);
    }
});
catspeak_session_add_source(sess, src);
while (catspeak_session_in_progress(sess)) {
    catspeak_session_update(sess);
}