
var buff = catspeak_create_buffer_from_string(@'
    let x = do { let y = 1 }
    let h = return 10;
    return h;
');
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);

comp.emitProgram(-1);
var disasm = comp.ir.disassembly();
show_message(disasm);
clipboard_set_text(disasm);