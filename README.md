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

A **cross-platform** scripting language and compiler back-end for GameMaker
projects. Use Catspeak to implement, **fast** and **sandboxed modding support**
by compiling and executing **arbitrary user code** from files or text prompt.

_Developed and maintained by [Katsaii](https://www.katsaii.com/)._  
_Logo design by [Mashmerlow](https://mashmerlow.github.io/)._  

## Overview

The spiritual successor to the long dead `execute_string` function...

```js
// parse Catspeak code
var ir = Catspeak.parseString(@'
  let catspeak = "Catspeak"

  return "hello! from within " + catspeak
');

// compile Catspeak code into a callable GML function
var getMessage = Catspeak.compileGML(ir);

// call the Catspeak code just like you would any other GML function!
show_message(getMessage());
```

...without any of the vulnerabilities from unrestricted access to your game
code:

```js
var ir = Catspeak.parseString(@'
  game_end(); -- heheheh, my mod will make your game close >:3
');

// calling `badMod` will throw an error instead of calling the `game_end` function
try {
  var badMod = Catspeak.compileGML(ir);
  badMod();
} catch (e) {
  show_message("a mod did something bad!");
}
```

## Features

If you run into any issues using this project, please create a [GitHub issue](https://github.com/katsaii/catspeak-lang/issues/new/choose)
or get in contact on Discord through the [GameMaker Kitchen](https://discord.com/channels/724320164371497020/1007968808926982184) server.

### 📝 Minimal Setup Required

 - Self-contained and ready to use after installation.
 - No need to place a persistent God Object in the first room of your game!

### ☯ Seamless GML-Catspeak Interoperability

 - Call GML code from Catspeak.
 - Call Catspeak code from GML.
 - Familiar syntax inspired by GML and JavaScript.

### 🏃‍♀️ Performant Runtime

 - Optimising compiler generates performant code capable of competing with pure GML implementations.
 - At best, Catspeak code will be just as fast as GML.
 - On average, Catspeak code will be 5x slower than GML.

### 👽 Cross-platform

 - Implemented in pure GML.
 - No external dependencies or platform-specific DLLs.
 - Mods should work on any target platform. _(Tested on VM, YYC, HTML5, and others)_

### 🔨 Customisable, Sandboxed Runtime Environment

 - Modders cannot gain access to parts of your game you don't want them to.
 - Expose only the functions and resources you feel comfortable with.
 - Impossible for modders to execute malicious code by default.
 - Detects infinite loops and recursion so the sly `while true { }` doesn't freeze your game, whether intentionally or unintentionally.

### 💪 Built for Power Users

 - Full compiler back-end documented and available for experimentation.
 - Pre-compile your scripts to JSON, and cache them for later. Skip straight to code generation.
 - Parse your own domain-specific language into Catspeak IR, then let the code generator turn that into a GML compatibile representation:
   - A custom UI language which supports running user-defined functions as button events.
   - A custom data-specification language where certain keywords act as calls to GML functions.
   - A simple shell-script language for a developer console.
   - A custom scripting language for a programming game.

### 🙀 Cute Name and Mascot

## Acknowledgements

Thanks to [JujuAdams](https://www.jujuadams.com/) for giving important feedback
on aspects of the implementation, an important step towards making sure
Catspeak is battle hardened.

Thanks to [TabularElf](https://github.com/tabularelf) for donating lots and lots
of prototype code for new Catspeak features.

Thanks to anyone spreading the good name of Catspeak.