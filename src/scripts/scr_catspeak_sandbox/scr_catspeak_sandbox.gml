
var buff = catspeak_create_buffer_from_string(@'
    let x = 1
    let x = x
');
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);

comp.emitProgram(-1);
var disasm = comp.ir.disassembly();
show_message(disasm);
clipboard_set_text(disasm);