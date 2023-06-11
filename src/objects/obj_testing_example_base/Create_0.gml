
//# feather use syntax-errors

code = "-- no code";
desc = "No further description...\n/(.Ö x Ö.)\\ !!";

addLog = function (msg, severity="ok") {
    var msg_ = msg;
    if (is_struct(msg_) && variable_struct_exists(msg_, "message")) {
        msg_ = msg_.message;
    } else if (!is_string(msg_)) {
        msg_ = string(msg_);
    }
    log[@ logTail] = msg_;
    logSeverity[@ logTail] = severity;
    logTail = (logTail + 1) % logLength;
    return undefined;
};

resizeLog = function (length) {
    logLength = length;
    log = array_create(logLength, "");
    logSeverity = array_create(logLength, "ok");
    logTail = 0;
};

resizeLog(6);

severities = {
    "ok" : TESTING_COL_WHITE,
    "boring" : TESTING_COL_GREY,
    "error" : TESTING_COL_FAIL,
    "good" : TESTING_COL_PASS,
}