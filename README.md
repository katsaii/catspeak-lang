# Catspeak

Catspeak is a small, dynamically typed domain-specific scripting language for [GameMaker Studio 2](https://www.yoyogames.com/gamemaker) that resembles the Lisp-family of languages. It is possible for Catspeak to be used as a modding language or as a replacement for configuration files, such as JSON and INI.

## Features

The language is entirely customisable, with only a few primitive constructs. These include:

 - Support for strings (`"hello world"`) and numerical values (`12.5`)
 - Support for array (`[1, 2, 3]`) and object (`{ a : "this is a", b : "this is b" }`) literals
 - Groupings of expressions using parenthesis, or the use of the unary grouping operator `:`
 - Variable assignment using the `=` operator
 - Control-flow statements such as `if`, `while`, `break`, and `continue`
 - Return values using the `return` keyword
 - Call GameMaker functions using the `run` keyword or by passing parameters in a Lisp-style `f arg1 arg2 arg3 ...`
 - Access elements of collections using ordered (`a.[i]`) and unordered (`a.{"key"}` or `a.key`) index operators

Custom operators and functions are exposed to the Catspeak virtual machine under the discretion of developers, in order to limit how much access a modder has to the game environment. This is done using the `catspeak_session_add_function` script; a full list of script names and their uses is included in the [wiki](https://github.com/NuxiiGit/catspeak-lang/wiki).

Furthermore, Catspeak is implemented in GameMaker Language in order to be stable across many different platforms. The language is designed be evaluated over multiple frames in order to avoid intentionally (or unintionally) freezing the game. In order to achieve this, both the compiler and virtual machine use a flat execution model; that is, no recursive descent parsing or tree-walk interpreters. This enables Catspeak programs to be passively compiled, executed, and paused at any time. Despite this, it is still possible for Catspeak scripts to be compiled and evaluated eagerly within a single step using the `catspeak_session_create_process_eager`, if desired.

## Installation

See the [wiki page](https://github.com/NuxiiGit/catspeak-lang/wiki/Getting-Started#installing).