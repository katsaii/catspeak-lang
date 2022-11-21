code = "-- no code";
desc = "No further description...\n/(.Ö x Ö.)\\ !!";
log = [];
logSeverity = [];
logLength = 6;

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