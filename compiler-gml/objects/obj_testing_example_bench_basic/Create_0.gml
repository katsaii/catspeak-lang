
//# feather use syntax-errors

event_inherited();

resizeLog(10);

code = @'do {
  "hello world"
  123
  "yippee!"
  do {
    3.14_15
  }
}';

nativeFunc = function () {
    return 3.1415;
};