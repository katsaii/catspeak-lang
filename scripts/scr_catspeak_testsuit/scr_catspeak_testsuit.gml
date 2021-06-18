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
        print "boring..."
    }
    print count
}
return "blast off!"
';
var sess = catspeak_session_create();
catspeak_session_add_source(sess, src);
catspeak_session_set_result_handler(sess, function(_result) {
    show_message(_result);
});
catspeak_session_set_error_handler(sess, function(_error) {
    show_message(_error);
});
catspeak_session_add_function(sess, ">", function(_l, _r) { return _l > _r; });
catspeak_session_add_function(sess, "==", function(_l, _r) { return _l == _r; });
catspeak_session_add_function(sess, "-", function(_l, _r) { return _l - _r; });
while (catspeak_session_in_progress(sess)) {
    catspeak_session_update(sess);
}