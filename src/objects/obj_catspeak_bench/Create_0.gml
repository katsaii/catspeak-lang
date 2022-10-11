show_debug_overlay(true);

var comp = catspeak_compile_string(@'
    let n = 0
    while (n <= 10) {
        print n
        n = it + 1
    }
    return "blast off!"
');

comp.andThen(function(ir) {
    self.ir = ir;
    clipboard_set_text(ir.disassembly())
});

delayProc = new CatspeakFuture();

catspeak_futures_join([comp, delayProc]).andThen(function(results) {
    show_message(results);
});

/*show_debug_overlay(true);


buff = catspeak_create_buffer_from_string(@'
    fun a, b { a ++ " " ++ b }
');

var lex = new CatspeakLexer(buff);
comp = new CatspeakCompiler(lex);
while (comp.inProgress()) {
    comp.emitProgram(10);
}
if (os_browser == browser_not_a_browser) {
    clipboard_set_text(comp.ir.disassembly());
} else {
    show_debug_message(comp.ir.disassembly());
}
show_message("emitted");

vm = new CatspeakVM();
vm.pushCallFrame(self, comp.ir);
vm.popCallFrame();

oldsess = catspeak_legacy_session_create();
catspeak_legacy_session_set_source(oldsess, @'
    a = 1
    b = 2
    return : a + b
');
*/