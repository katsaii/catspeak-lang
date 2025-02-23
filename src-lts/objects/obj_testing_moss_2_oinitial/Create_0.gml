global.__testing_moss_2_test.env.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
var f = global.__testing_moss_2_test.env.compile(global.__testing_moss_2_test.env.parseString(@"
    with obj_testing_blank { instance_create_depth(0, 0,0, obj_testing_moss_2_omod) }
"))
f.setSelf(self)
f()