
buffer_seek(buff, buffer_seek_start, 0);

var t = get_timer();
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);
while (comp.inProgress()) {
    comp.emitProgram();
}
var vm = new CatspeakVM();
vm.pushCallFrame(self, comp.ir);
vm.popCallFrame();
repeat (1000) {
    vm.reuseCallFrame();
    while (vm.inProgress()) {
        vm.runProgram(1);
    }
}
var dt1 = (get_timer() - t) / 1000000;

/*t = get_timer();
repeat (1000) {
    catspeak_legacy_session_create_process_greedy(oldsess);
}
var dt2 = (get_timer() - t) / 1000000;

show_message({
    old : dt2,
    new_ : dt1,
});
*/


//show_message(json_stringify(vm.returnValue));
//clipboard_set_text(disasm);