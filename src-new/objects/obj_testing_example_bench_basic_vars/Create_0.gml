
//# feather use syntax-errors

event_inherited();

resizeLog(10);

code = @'let `hi` = do {
  let b = 3;
  let c = 4;
  let d = 5;
  let e = 6;
  b
}
hi';

nativeFunc = function () {
    var b = 3;
    var c = 4;
    var d = 5;
    var e = 6;
    var hi = b;
    return hi;
};

runTime = 60 * 5;