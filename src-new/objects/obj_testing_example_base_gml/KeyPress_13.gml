
//# feather use syntax-errors

try {
    var asg = Catspeak.parseString(code);
    gmlFunc = Catspeak.compileGML(asg);
    //show_message(json_stringify(asg, true));
} catch (e) {
    addLog(e, "error");
}