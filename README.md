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

**We have [moved to codeberg](https://codeberg.org/katsaii/catspeak-lang)**,
this repo remains for legacy purposes, and to host documentation.

_Developed and maintained by [Katsaii](https://www.katsaii.com/)._  
_Logo design by [Mashmerlow](https://mashmerlow.github.io/)._  

Homepage: https://www.katsaii.com/catspeak-lang/

```js
// parse -> compile -> and run
var module = Catspeak.run(@'
  let catspeak = "Catspeak"

  return "hello! from within " + catspeak
');

// print result
show_message(module.result); // hello! from within Catspeak
```

## Projects Using Catspeak

In no particular order:

 - [Decks of Dexterity](https://decksofdexterity.com/)
 - [Picayune Dreams](https://store.steampowered.com/app/2088840/Picayune_Dreams/)
 - [ZERO Sievert](https://store.steampowered.com/app/1782120/ZERO_Sievert/)
 - [Rusted Moss](https://store.steampowered.com/app/1772830/Rusted_Moss/)

_(If you have a project you would want to appear here, please [get in contact](https://github.com/katsaii/catspeak-lang/issues/new?template=iuseit.yml)!)_