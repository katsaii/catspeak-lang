code = "-- no code";
desc = "No further description...\n/(.Ö x Ö.)\\ !!";

addLog = function(msg, severity="ok") {
    log[@ logTail] = is_string(msg) ? msg : string(msg);
    logSeverity[@ logTail] = severity;
    logTail = (logTail + 1) % logLength;
    return undefined;
};

resizeLog = function(length) {
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