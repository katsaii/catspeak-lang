
//# feather use syntax-errors

#macro TESTING_COL_BLACK #333333
#macro TESTING_COL_WHITE #DDDDDD
#macro TESTING_COL_GREY #AAAAAA
#macro TESTING_COL_DARK_GREY #777777
#macro TESTING_COL_PASS #64B58E
#macro TESTING_COL_WORKING #BDBD4D
#macro TESTING_COL_FAIL #CC4E67
#macro TESTING_COL_FATAL #FF0000


var env = new CatspeakEnvironment();
env.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
var f = env.compile(env.parseString(@'
    show_debug_message("--- START TEST ---")
    var inst = instance_create_depth(0, 0, 0, obj_testing_scratchpad)
    instance_deactivate_object(inst)
    instance_destroy(obj_testing_scratchpad)
    show_debug_message("--- END TEST ---")
'));
f();

show_debug_overlay(true);

exampleCurrent = -1;
examples = [
    {
        title : "basic performance",
        obj : obj_testing_example_bench_basic,
    },
    {
        title : "basic variable performance",
        obj : obj_testing_example_bench_basic_vars,
    },
    {
        title : "while loop performance",
        obj : obj_testing_example_bench_while,
    },
    {
        title : "factorial",
        obj : obj_testing_example_bench_factorial,
    },
    {
        title : "draw pendulum",
        obj : obj_testing_example_draw_pendulum,
    }
];
exampleIsValid = function (idx) {
    return idx >= 0 && idx < array_length(examples);
};
exampleChange = function (idx) {
    if (exampleIsValid(exampleCurrent)) {
        instance_destroy(examples[exampleCurrent].obj);
    }
    if (exampleIsValid(idx)) {
        instance_create_depth(0, 0, 0, examples[idx].obj);
        exampleCurrent = idx;
    } else {
        exampleCurrent = -1;
    }
};

exampleChange(0);

// so that the output of fps_real in the GUI is somewhat readable
fpsRealCache = 0;
fpsRealTimer = 0;

// example region
exampleLeft = 0;
exampleTop = 0;
exampleRight = 0;
exampleBottom = 0;
lineHeight = 0;