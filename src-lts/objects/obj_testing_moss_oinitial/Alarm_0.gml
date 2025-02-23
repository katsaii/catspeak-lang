test.assertEq(array_length(outputs) % 2, 0);
test.assert(array_length(outputs) >= 6);
if (!test.hasFailed()) {
    test.assertEq(outputs[0], "A");
    test.assertEq(outputs[1], "A");
    test.assertEq(outputs[2], "B");
    test.assertEq(outputs[3], "B");
    test.assertEq(outputs[4], "A");
    test.assertEq(outputs[5], "A");
    for (var i = 6; i < array_length(outputs); i += 1) {
        test.assertEq(outputs[i], "A");
    }
}
test.complete();