event_inherited();

code = @'-- compute the factorial of n
factorial = fun n {
  if (n <= 1) {
    return 1;
  }
  return n * factorial(n - 1)
}

-- outputs 1, 2, 6, 24
log factorial 1
log factorial 2
log factorial 3
log factorial 4';

desc = "This example computes the factorial of four numbers and outputs " +
        "their result to the log window.";