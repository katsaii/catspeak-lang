// Example functions for the test case "engine-gml-function-by-substring"

// Everything that starts with "array" should be exposed in "engine-gml-function-by-substring".
function array_sum(array) {
    var len = array_length(array);
    var sum = 0;
    for(var i = 0; i < len; i++) {
        sum += array[i];
    }
    return sum;
}

function array_min(array) {
    return script_execute_ext(min, array);   
}

function array_max(array) {
    return script_execute_ext(max, array);   
}

function array_mean(array) {
    return script_execute_ext(mean, array);   
}

function array_median(array) {
    return script_execute_ext(median, array);   
}

// This should never be added, since it doesn't contain "array" at the front.
function struct_create() {
    return {};   
}