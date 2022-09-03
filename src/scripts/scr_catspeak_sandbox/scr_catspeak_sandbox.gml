


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

var buff = catspeak_create_buffer_from_string(@'
    let a
');
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);

comp.emitProgram(-1);
var disasm = comp.ir.disassembly();
show_message(disasm);
clipboard_set_text(disasm);