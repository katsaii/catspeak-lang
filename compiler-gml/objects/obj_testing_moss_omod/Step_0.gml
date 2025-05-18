if (global.__testing_moss_o_step) {
    array_push(self.outputs, self.label)
	global.__testing_moss_o_step.setSelf(self)
	global.__testing_moss_o_step()
}