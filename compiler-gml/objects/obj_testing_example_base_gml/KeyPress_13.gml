
//# feather use syntax-errors

try {
    var ir = environment.parseString(code);
    gmlFunc = environment.compile(ir);
    //show_message(json_stringify(ir, true));
} catch (e) {
    addLog(e, "error");
}