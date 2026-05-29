outputs = [];

var env = new CatspeakEnvironment();
env.interface.exposeEverythingIDontCareIfModdersCanEditUsersSaveFilesJustLetMeDoThis = true;
env.interface.exposeConstant("outputs", outputs);
global.__testing_moss_o_step = env.compile(env.parseString(@'
    with self {
        array_push(outputs, variable_struct_get(self, "label"))
        if self.label == "B" {
            instance_destroy(self) break
        }
    }
'))
a = instance_create_depth(0, 0, 0, obj_testing_moss_omod, { outputs : outputs })
a.label = "A"
b =instance_create_depth(0, 0, 10, obj_testing_moss_omod, { outputs : outputs })
b.label = "B"

alarm[0] = 6;