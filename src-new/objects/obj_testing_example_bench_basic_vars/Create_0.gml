
//# feather use syntax-errors

event_inherited();

resizeLog(10);

code = @'let `hi` = do {
  let b = 3;
  b
}
hi';

nativeFunc = function() {
    var b = 3;
    var hi = b;
    return hi;
};