array_push(global.__testing_moss_2_test.outputs, object_get_name(self.object_index));
var f = global.__testing_moss_2_test.env.compile(global.__testing_moss_2_test.env.parseString(@"
    array_push(global.__testing_moss_2_test.outputs, object_get_name(self.object_index))
"))
f.setSelf(self)
f()