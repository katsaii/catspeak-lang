<picture>
  <source
    media="(prefers-color-scheme: dark)"
    align="right"
    width="30%"
    height="30%"
    srcset="./catspeak-logo-dark.svg">
  <source
    media="(prefers-color-scheme: light)"
    align="right"
    width="30%"
    height="30%"
    srcset="./catspeak-logo.svg">
  <img
    align="right"
    width="30%"
    height="30%"
    alt="Catspeak Logo"
    src="./catspeak-logo.svg">
</picture>

# The Catspeak Programming Language

A cross-platform, expression oriented programming language for implementing
modding support into your GameMaker Studio 2.3 games.

_Developed by
[katsaii](https://www.katsaii.com/), logo design by
[mashmerlow](https://mashmerlow.github.io/)._

## Overview

Check out the [online documentation](https://www.katsaii.com/catspeak-lang) for
a full overview of the language.

If you run into any issues using this project, please create a [GitHub issue](https://github.com/katsaii/catspeak-lang/issues/new)
or get in contact on Discord through the [GameMaker Kitchen](https://discord.com/channels/724320164371497020/1007968808926982184) server.

### Features

 - [x] **Minimal setup required**; ready to use after installation, no need to
       create a controller object.
 - [x] **Cross-platform**, allowing mods to work on any platform out of the box.
 - [x] **Sandboxed execution environment**, so modders cannot modify parts of
       your game you don't want them to.
 - [x] **Customisable standard library**, exposing only the functions you want
       modders to have access to.
 - [x] **Performant runtime**, capable of interpreting thousands (and even
       tens of thousands) Catspeak scripts per step[^complexity].
 - [x] **Asynchronous execution over multiple steps**, making it impossible for
       modders to freeze your game with an infinite loop.
 - [x] **Intelligent process manager**, so no time is wasted idly waiting for
       new Catspeak programs to appear.
 - [x] **Failsafes to catch unresponsive Catspeak processes**.
 - [x] **Call GML code from Catspeak**.
 - [x] **Call Catspeak code from GML**.
 - [x] **Simple, relaxed syntax**, but still similar enough to GML to be
       familiar.
 - [ ] **Pre-compilation of scripts**, to both reduce load times when
       initialising mods or obfuscate production code. (Coming Soon!)
 - [x] **Compiler internals exposed and well-documented**, in order to give
       power users as much control over their programs as possible.
 - [x] **Cute name and mascot**.

[^complexity]: Dependent on the complexity of your scripts.

### Syntax

```hs
factorial = fun(n) {
  if (n <= 1) {
    return 1
  }
  return n * factorial(n - 1)
}

let a = [1, 2, 3, 4]
let size = len(a)
let i = 0
while (i < size) {
  let num = a.[i]
  i = i + 1
  print factorial(num)
}

-- output:
-- 1
-- 2
-- 6
-- 24
```

You can find a full description of the syntax in the
[online documentation](https://www.katsaii.com/catspeak-lang/#syntax).

## Acknowledgements

Thanks to [JujuAdams](https://www.jujuadams.com/) for giving feedback on
aspects of the implementation.
