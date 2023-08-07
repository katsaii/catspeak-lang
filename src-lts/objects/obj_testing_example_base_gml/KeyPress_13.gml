
//# feather use syntax-errors

try {
    var asg = environment.parseString(code);
    gmlFunc = environment.compileGML(asg);
    //show_message(json_stringify(asg, true));
} catch (e) {
    addLog(e, "error");
}