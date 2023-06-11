
//# feather use syntax-errors

event_inherited();

resizeLog(10);

code = @'let n = 1000
while n {
    n = n - 1
}';

nativeFunc = function () {
    var n = 1000;
    while (n) {
        n = n - 1;
    }
};

runTime = 60;