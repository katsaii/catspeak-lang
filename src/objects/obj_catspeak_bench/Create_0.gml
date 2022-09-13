show_debug_overlay(true);

catspeak_compile_string(@'
    let n = 10
    while (n > 0) {
        n = it - 1
    }
    fun a, b { a ++ " "  ++ b }
').andThen(function(ir) {
    self.ir = ir;
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