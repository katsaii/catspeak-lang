
var buff = catspeak_create_buffer_from_string(@'
    -- let hi = 1.0
    ; ; ; ; ; ; ... 1 ; ; ... ; ; ;  -- cool!!!
');
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);

comp.emitProgram(-1);
clipboard_set_text(comp.ir.disassembly());