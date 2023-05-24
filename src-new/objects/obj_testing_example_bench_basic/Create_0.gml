
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

desc = "This example attempts to find how many times a simple Catspeak " +
        "script can run per game frame";

nativeFunc = function() {
    return 3.1415;
};