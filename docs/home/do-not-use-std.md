---
description: >-
  Describes the general code style any Hipreme Engine project must follow. doing
  that will guarantee to make your project stable between various platforms.
---

# Do not use std

Hipreme Engine supports various platforms. Given that, it brings a new problem: There are parts of the standard library (Phobos) that should not be used with H.E. projects, currently the only allowed modules are one which doesn't rely in any part of the clib. Beyond that, H.E. wasn't designed to support `try/catch` at all, they are being only used for development time debug information, they really can't be used for releases. This makes it a lot easier to support more platforms and also you get a speed boost by not using them.

### Allowed Standard Modules

Modules which uses algorithms or compile time information are allowed. Currently, the tested modules are:

* std.traits
* std.algorithm
* core.stdc.math
* core.math

### Use instead

* std.stdio -> hip.api.console
* std.json -> hip.api.data.jsonc
* std.conv -> hip.util.conv
* std.path -> hip.util.path
* std.array -> hip.util.array
* std.random -> hip.math.random

### Additional Useful Modules

Beyond those which are fairly common in game development, there are a bunch of useful modules which provides extra useful functionality:

* hip.util.string: Provides a bunch of string related functions and a `@nogc String` struct which you can append anything to it, this string is refcounted, so, it won't allocate GC memory.
* hip.util.time: Used for when needing to calculate some time pass or even profiling
* hip.util.to\_string\_range: Provides same thing as hip.util.conv, but you can use a sink for not allocating memory.
