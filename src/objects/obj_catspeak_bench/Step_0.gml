
//buffer_seek(buff, buffer_seek_start, 0);
var t = get_timer();
runs = 0;
    
    vm.reuseCallFrame();
    while (vm.inProgress()) {
        vm.runProgram(10);
    }
repeat (1000) {
    runs += 1;
    /*buffer_seek(buff, buffer_seek_start, 0);
    var lex = new CatspeakLexer(buff);
    var comp_ = new CatspeakCompiler(lex);
    while (comp_.inProgress()) {
        comp_.emitProgram(10);
    }
    */
    
    var f = vm.returnValue;
    f("hewwo", "OwO");
    
    //show_message(vm.returnValue)
}
var dt1 = (get_timer() - t) / 1000000;
/*
t = get_timer();
repeat (10000) {
    catspeak_legacy_session_create_process_greedy(oldsess);
}
var dt2 = (get_timer() - t) / 1000000;
*/
//show_message({
    //old : dt2,
    //new_ : dt1,
//});



//show_message(json_stringify(vm.returnValue));
//clipboard_set_text(disasm);