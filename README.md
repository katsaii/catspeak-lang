<img src="./catspeak.svg" alt="Catspeak Logo" width="157.74" height="120" />

![Catspeak Logo](./catspeak.svg)

# Catspeak

Catspeak is a small, dynamically typed domain-specific scripting language for [GameMaker Studio 2](https://www.yoyogames.com/gamemaker) that resembles the Lisp-family of languages. It is possible for Catspeak to be used as a modding language or as a replacement for configuration files, such as JSON and INI.

## Features

The language is entirely customisable, with only a few primitive constructs. These include:

 - Support for strings (`"hello world"`) and numerical values (`12.5`)
 - Support for array (`[1, 2, 3]`) and object (`{ .a : "this is a", .b : "this is b" }`) literals
 - Groupings of expressions using parenthesis, or the use of the unary grouping operator `:`
 - Variable assignment using the `=` operator
 - Control-flow statements such as `if`, `while`, `for`, `break`, and `continue`
 - Return values using the `return` keyword
 - Call GameMaker functions using the `run` keyword or by passing parameters in a Lisp-style `f arg1 arg2 arg3 ...`
 - Access elements of collections using ordered (`a.[i]`) and unordered (`a.{"key"}` or `a.key`) index operators
 - Create new functions using the `fun` keyword and export them to GML using `extern`
 - Entirely sandboxed runtime environment, only expose functions to modders that you want to expose
 - Execute large and complex programs asynchronously over multiple steps

Custom operators and functions are exposed to the Catspeak virtual machine under the discretion of developers, in order to limit how much access a modder has to the game environment. This is done using the `catspeak_session_add_function` script; a full list of script names and their uses is included in the [wiki](https://github.com/NuxiiGit/catspeak-lang/wiki).

## Examples

### Functions!

```
factorial = fun n {
  if (n <= 1) {
    return 1
  }
  return : n * factorial (n - 1)
}
print : factorial 10 -- 3628800
```

### For-loops!

```
for [1, 2].[_] = outer {
  for [3, 4].[_] = inner {
    if (outer == 1) {
      continue 2
    }
    result = inner * outer
    break 2
  }
}
print result -- 6
```

## Installation

See the [wiki page](https://github.com/NuxiiGit/catspeak-lang/wiki/Getting-Started#installing).

# Acknowledgements

Thanks to [@JujuAdams](https://www.jujuadams.com/) for giving feedback on aspects of the implementation.
