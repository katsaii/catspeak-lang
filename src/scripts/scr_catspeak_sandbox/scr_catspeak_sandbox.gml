
catspeak_force_init();

var stack = [];

catspeak_bitstack_push(stack, true);
catspeak_bitstack_push(stack, true);
catspeak_bitstack_push(stack, false);
catspeak_bitstack_push(stack, false);
catspeak_bitstack_push(stack, false);
catspeak_bitstack_push(stack, true);
catspeak_bitstack_push(stack, false);
catspeak_bitstack_push(stack, false);
catspeak_bitstack_push(stack, true);
catspeak_bitstack_push(stack, false);

repeat (10) {
    //show_message(catspeak_bitstack_pop(stack));
}

buff = catspeak_create_buffer_from_string(@'
    let a = 1
');

var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);
while (comp.inProgress()) {
    comp.emitProgram(1);
}
//show_message(comp.ir.disassembly());

var vm = new CatspeakVM({
    "show_message" : method(undefined, show_message),
});
vm.pushCallFrame(self, comp.ir);
//while (vm.inProgress()) {
//    vm.runProgram(10);
//}