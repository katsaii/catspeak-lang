if (keyboard_check_pressed(vk_enter)) {
    addLog("...compiling", "boring");
    catspeak_compile_string(code).andThen(function(ir) {
        ir.setGlobal("log", addLog);
        addLog("...running", "boring");
        return catspeak_execute(ir);
    }).andThen(function(result) {
        if (result != undefined) {
            addLog("result = " + string(result));
        }
    }).andCatch(function(e) {
        addLog("ERROR! SOMETHING WENT WRONG:", "error");
        if (is_struct(e) && variable_struct_exists(e, "message")) {
            addLog(e[$ "message"], "error");
        } else {
            addLog("no message", "error");
        }
    });
}