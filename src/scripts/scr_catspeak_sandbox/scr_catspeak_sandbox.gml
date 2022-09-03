


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
    let a = {
        "glossary": {
            "title": "example glossary",
            "GlossDiv": {
                "title": "S",
                "GlossList": {
                    "GlossEntry": {
                        "ID": "SGML",
                        "SortAs": "SGML",
                        "GlossTerm": "Standard Generalized Markup Language",
                        "Acronym": "SGML",
                        "Abbrev": "ISO 8879:1986",
                        "GlossDef": {
                            "para": "A meta-markup language, used to create markup languages such as DocBook.",
                            "GlossSeeAlso": ["GML", "XML"]
                        },
                        "GlossSee": "markup"
                    }
                }
            }
        }
    };
');
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);

comp.emitProgram(-1);
var disasm = comp.ir.disassembly();
show_message(disasm);
clipboard_set_text(disasm);