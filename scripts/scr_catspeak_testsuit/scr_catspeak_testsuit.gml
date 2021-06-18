/* Catspeak Tests
 * --------------
 * Kat @katsaii
 */

var src = @'
set arr [
    1
    { .b 5 }
    3
]
set arr.[1].{"b"} "hello"
print arr
';
var sess = catspeak_session_create();
catspeak_session_add_source(sess, src);
catspeak_session_set_result_handler(sess, function(_result) {
    show_message(_result);
});
while (catspeak_session_in_progress(sess)) {
    catspeak_session_update(sess);
}