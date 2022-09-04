//! Handles potentially very large stacks of boolean values, storing them
//! compactly using run-length encoding.

//# feather use syntax-errors

/// Inserts a new boolean value into this bit stack.
///
/// @param {Array<Real>} stack
///   An array containing the values to modify.
///
/// @param {Bool} value
///   The state to push.
function catspeak_bitstack_push(stack, value) {
    var n = array_length(stack);
    var currentlyTrue = n % 2 == 0; // the default state is `true`
    if (n == 0 && value) {
        return;
    }
    if (value ^^ currentlyTrue) {
        stack[@ n] = 1;
    } else {
        stack[@ n - 1] += 1;
    }
}

/// Pops a new boolean value from this bit stack and returns it.
///
/// @param {Array<Real>} stack
///   An array containing the values to modify.
///
/// @return {Bool}
function catspeak_bitstack_pop(stack) {
    var n = array_length(stack);
    var currentlyTrue = n % 2 == 0; // the default state is `true`
    if (n > 0) {
        var idx = n - 1;
        var acc = stack[idx];
        stack[@ idx] = acc - 1;
        if (acc <= 1) {
            array_pop(stack);
        }
    }
    return currentlyTrue;
}