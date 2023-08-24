//! Example functions for the test case `env-gml-function-by-substring`.

//# feather use syntax-errors

// everything that starts with "test_array" should be exposed in the
// `env-gml-function-by-substring` test

function test_array_sum(array) {
    var len = array_length(array);
    var sum = 0;
    for(var i = 0; i < len; i++) {
        sum += array[i];
    }
    return sum;
}

function test_array_min(array) {
    return script_execute_ext(min, array);
}

function test_array_max(array) {
    return script_execute_ext(max, array);
}

function test_array_mean(array) {
    return script_execute_ext(mean, array);
}

function test_array_median(array) {
    return script_execute_ext(median, array);
}

// should never be added since it doesn't contain "test_array" at the front

function test_struct_create() {
    return { };
}