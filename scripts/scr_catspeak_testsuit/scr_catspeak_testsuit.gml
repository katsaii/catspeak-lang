/* Catspeak Tests
 * --------------
 * Kat @katsaii
 */

var src = @'{.a "hi";.b 2}.a';
var chunk = catspeak_eagar_compile(src);
show_message(chunk);
var vm = new CatspeakVM()
		.setOption(CatspeakVMOption.RESULT_HANDLER, function(_result) {
			show_debug_message("result: " + string(_result));
		});
vm.addChunk(chunk);
while (vm.inProgress()) {
	vm.computeProgram();
}

/*
var src = @'
add list 1 2 3
print [
	list.[0]
	list.[1]
	list.[2]
]
';
var chunk = catspeak_eagar_compile(src);
var vm = new CatspeakVM()
		.addInterface(new CatspeakVMInterface()
				.addConstant("list", ds_list_create())
				.addFunction("add", ds_list_add))
		.setOption(CatspeakVMOption.GLOBAL_VISIBILITY, true)
		.setOption(CatspeakVMOption.RESULT_HANDLER, function(_result) {
			show_debug_message("result: " + string(_result));
		});
vm.addChunk(chunk);
while (vm.inProgress()) {
	vm.computeProgram();
}*/