


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
    let a = {"menu": {
        "header": "SVG Viewer",
        "items": [
            {"id": "Open"},
            {"id": "OpenNew", "label": "Open New"},
            null,
            {"id": "ZoomIn", "label": "Zoom In"},
            {"id": "ZoomOut", "label": "Zoom Out"},
            {"id": "OriginalView", "label": "Original View"},
            null,
            {"id": "Quality"},
            {"id": "Pause"},
            {"id": "Mute"},
            null,
            {"id": "Find", "label": "Find..."},
            {"id": "FindAgain", "label": "Find Again"},
            {"id": "Copy"},
            {"id": "CopyAgain", "label": "Copy Again"},
            {"id": "CopySVG", "label": "Copy SVG"},
            {"id": "ViewSVG", "label": "View SVG"},
            {"id": "ViewSource", "label": "View Source"},
            {"id": "SaveAs", "label": "Save As"},
            null,
            {"id": "Help"},
            {"id": "About", "label": "About Adobe CVG Viewer..."}
        ]
    }};
');
var lex = new CatspeakLexer(buff);
var comp = new CatspeakCompiler(lex);

comp.emitProgram(-1);
var disasm = comp.ir.disassembly();
show_message(disasm);
clipboard_set_text(disasm);