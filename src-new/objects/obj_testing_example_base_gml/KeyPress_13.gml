
//# feather use syntax-errors

try {
    var asg = Catspeak.parseString(code);
    gmlFunc = Catspeak.compileGML(asg);
} catch (e) {
    addLog(e, "error");
}