#macro TESTING_COL_BLACK #333333
#macro TESTING_COL_WHITE #DDDDDD
#macro TESTING_COL_PASS #64b58e
#macro TESTING_COL_FAIL #cc4e67

show_debug_overlay(true);

currentExample = undefined;
currentExampleId = -1;
examples = [
    {
        title : "factorial",
        obj : obj_testing_example_factorial,
    }
];