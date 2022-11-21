code = "-- no code";
desc = "No further description...\n/(.Ö x Ö.)\\ !!";
logLength = 6;
log = array_create(logLength, "");
logSeverity = array_create(logLength, "ok");

addLog = function(msg, severity="ok") {
    array_push(log, is_string(msg) ? msg : string(msg));
    array_push(logSeverity, severity);
    return undefined;
};

severities = {
    "ok" : TESTING_COL_WHITE,
    "boring" : TESTING_COL_GREY,
    "error" : TESTING_COL_FAIL,
    "good" : TESTING_COL_PASS,
}