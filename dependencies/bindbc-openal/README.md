# bindbc-openal
This project provides both static and dynamic bindings to API version 1.1 of the [OpenAL library](https://www.openal.org/) and the alternative [OpenAL Soft implementation](https://kcat.strangesoft.net/openal.html). They are `@nogc` and `nothrow` compatible and can be compiled for compatibility with `-betterC`. This package is intended as a replacement of [DerelictAL](https://github.com/DerelictOrg/DerelictAL), which is not compatible with `@nogc`,  `nothrow`, or `-betterC`.

## Usage
By default, `bindbc-openal` is configured to compile as a dynamic binding that is not `-betterC` compatible. The dynamic binding has no link-time dependency on the OpenAL library, so the OpenAL shared library must be manually loaded at runtime. When configured as a static binding, there is a link-time dependency on the OpenAL library -- either the static library or the appropriate file for linking with shared libraries on your platform (see below).

When using DUB to manage your project, the static binding can be enabled via a DUB `subConfiguration` statement in your project's package file. `-betterC` compatibility is also enabled via subconfigurations.

To use OpenAL, add `bindbc-openal` as a dependency to your project's package config file. For example, the following is configured to OpenAL as a dynamic binding that is not `-betterC` compatible:

__dub.json__
```
dependencies {
    "bindbc-openal": "~>0.1.0",
}
```

__dub.sdl__
```
dependency "bindbc-openal" version="~>0.1.0"
```

### The dynamic binding
The dynamic binding requires no special configuration when using DUB to manage your project. There is no link-time dependency. At runtime, the OpenAL shared library is required to be on the shared library search path of the user's system. On Windows, this is typically handled by distributing the OpenAL Soft DLL with your program or running the OpenAL installer on the end-user's system. On other systems, it usually means the user must install the OpenAL shared library through a package manager.

To load the shared library, you need to call the `loadOpenAL` function. This returns a member of the `ALSupport` enumeration (see [the README for `bindbc.loader`](https://github.com/BindBC/bindbc-loader/blob/master/README.md) for the error handling API):

* `ALSupport.noLibrary` indicating that the library failed to load (it couldn't be found)
* `ALSupport.badLibrary` indicating that one or more symbols in the library failed to load
* `ALSupport.al11` indicates that the library loaded successfully

```d
import bindbc.openal;

/*
This version attempts to load the OpenAL shared library using well-known variations
of the library name for the host system.
*/
ALSupport ret = loadOpenAL();
if(ret != ALSupport.al11) {

    // Handle error. For most use cases, its reasonable to use the the error handling API in
    // bindbc-loader to retrieve error messages and then abort. If necessary, it's  possible
    // to determine the root cause via the return value:

    if(ret == ALSupport.noLibrary) {
        // GLFW shared library failed to load
    }
    else if(ALSupport.badLibrary) {
        // One or more symbols failed to load. 
    }
}
/*
This version attempts to load the OpenAL library using a user-supplied file name.
Usually, the name and/or path used will be platform specific, as in this example
which attempts to load `soft_oal.dll`, the default name of the OpenAL Soft shared
library, from the `libs` subdirectory, relative to the executable, only on Windows.
*/
// version(Windows) loadGLFW("libs/soft_oal.dll")
```

__dub.json__
```
"dependencies": {
    "bindbc-openal": "~>0.1.0"
}
```

__dub.sdl__
```
dependency "bindbc-openal" version="~>0.1.0"
```

## The static binding
The static binding has a link-time dependency on either the shared or static OpenAL libraries. On Windows, you can link with the static library or, to use the shared library, with the import library. On other systems, you can link with either the static library or directly with the shared library.

_Note that the OpenAL distribution does not contain a static library and the source is not available to build one. OpenAL Soft is open source and can be compiled as a static library._

When linking with the static library, there is no runtime dependency on OpenAL. When linking with the shared library (or the import library on Windows), the runtime dependency is the same as the dynamic binding, the difference being that the shared library is no longer loaded manually -- loading is handled automatically by the system when the program is launched.

Enabling the static binding can be done in two ways.

### Via the compiler's `-version` switch or DUB's `versions` directive
Pass the `BindOpenAL_Static` version to the compiler and link with the appropriate library. Note that `BindOpenAL_Static` will also enable the static binding for any satellite libraries used.

When using the compiler command line or a build system that doesn't support DUB, this is the only option. The `-version=BindOpenAL_Static` option should be passed to the compiler when building your program. All of the required C libraries, as well as the `bindbc-glfw` and `bindbc-loader` static libraries must also be passed to the compiler on the command line or via your build system's configuration.

When using DUB, its `versions` directive is an option. For example, when using the static binding:

__dub.json__
```
"dependencies": {
    "bindbc-openal": "~>0.1.0"
},
"versions": ["BindOpenAL_Static"],
"libs-windows": ["OpenAL32"],
"libs-posix": ["openal"]
```

__dub.sdl__
```
dependency "bindbc-openal" version="~>0.1.0"
versions "BindOpenAL_Static"
libs "OpenAL32" platform="windows"
libs "openal" platform="posix"
```

### Via DUB subconfigurations
Instead of using DUB's `versions` directive, a `subConfiguration` can be used. Enable the `static` subconfiguration for the `bindbc-openal` dependency:

__dub.json__
```
"dependencies": {
    "bindbc-openal": "~>0.1.0"
},
"subConfigurations": {
    "bindbc-openal": "static"
},
"libs-windows": ["OpenAL32"],
"libs-posix": ["openal"]
```

__dub.sdl__
```
dependency "bindbc-openal" version="~>0.1.0"
subConfiguration "bindbc-openal" "static"
libs "OpenAL32" platform="windows"
libs "openal" platform="posix"
```

This has the benefit that it completely excludes from the build any source modules related to the dynamic binding, i.e. they will never be passed to the compiler.

## `betterC` support

`betterC` support is enabled via the `dynamicBC` and `staticBC` subconfigurations, for dynamic and static bindings respectively. To enable the static binding with `-betterC` support:

__dub.json__
```
"dependencies": {
    "bindbc-glfw": "~>0.1.0"
},
"subConfigurations": {
    "bindbc-glfw": "staticBC"
},
"libs-windows": ["OpenAL32"],
"libs-posix": ["openal"]
```

__dub.sdl__
```
dependency "bindbc-glfw" version="~>0.1.0"
subConfiguration "bindbc-glfw" "staticBC"
libs "OpenAL32" platform="windows"
libs "openal" platform="posix"
```

When not using DUB to manage your project, first use DUB to compile the BindBC libraries with the `dynamicBC` or `staticBC` configuration, then pass `-betterC` to the compiler when building your project.