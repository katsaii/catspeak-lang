/* Catspeak Tests
 * --------------
 * Kat @katsaii
 */

var src = @'
set arr [
    1
    { .b 5 }
    3
]
set arr.[1].{"b"} "hello"
print arr
';
var chunk = catspeak_eagar_compile(src);
show_message(chunk);
var vm = new __CatspeakVM();
vm.addInterface(catspeak_ext_gml_interface(CatspeakExtGMLClass.OPERATORS))
vm.setOption(CatspeakVMOption.RESULT_HANDLER, function(_result) {
            show_debug_message("result: " + string(_result));
        });
vm.addChunk(chunk);
while (vm.inProgress()) {
    vm.computeProgram();
}