event_inherited();

resizeLog(10);

code = @'-- count down from 10000
let n = 10000
while (n > 0) {
    log n
    n = it - 1
}
return "blast off!"';

desc = "This example counts down from ten thousand and outputs the result " +
        "to the log window.";