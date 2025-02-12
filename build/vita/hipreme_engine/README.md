# Hipreme Engine Vita SDK Port
Hipreme Engine port for the Vita SDK.

## THIS BUILD REQUIRES HIPREME ENGINE CUSTOM D RUNTIME

### Quick Start
To get it, call `git submodule update --recursive`. This will clone the custom D runtime.

## Checking Debug

- Install on your PS Vita NetLoggingMgrSettings
- Start listening with netcat on Linux, or, enter at [NetDbgLogPc](tools/NetDbgLogPc.exe) here on Windows.
- Open NetLoggingMgrSettings on PS Vita and set the IP and Ports used.
- Hit Update Config. Then Save Config

### Notices

1. The D custom runtime was started by Adam D. Ruppe, in arsd-webassembly. HipremeEngine has implemented all of the other
necessary features for it being able to run the entire engine. That means, including implementing a little bit of C standard library,
phobos and the runtime itself.
2. Some errors that didn't happen on Windows/Linux may happen when using this version. Please do put an issue to be fixed.
3. This runtime may become version locked as the D runtime hooks keeps changing.
4. In the future, this may be replaced by the real D runtime, so, try to not lose too much time trying to optimize D runtime related bugs (GC).


### What code you can't use:

1. `catch`: You can throw errors, they will be converted to `assert(false, "message")`. They won't be able to be caught though.
2. Fibers: The way they are implemented is by stack winding/unwinding which requires some assembly, so they were completed dropped out.
3. Threads: Threading was not implemented for the custom runtime. This may be at least simulated in future.
4. `static this`
5. `~static this`: Those 2 aren't actually hard to support, but I decided to not implement them as I don't use it on the engine. Keep in mind that the game engine provides a way to simulate them. It automatically creates `scriptmodules.txt` for you to be able to iterate all your `source` folder directory.

### Garbage Collection

This custom runtime allocates memory which will never be freed. For small games, that is okay. HipremeEngine only allocates memory that requires GC on startup. The entire update loop is partially `@nogc`(doesn't allocate but I'm not locking anyone by not using this attribute). That means it won't allocate nor leak memory during gameplay, that means you can create a complete game using the D runtime without getting OutOfMemory. This have been tested a lot and the engine is pretty concerned in how, where and when the memory allocation will happen. It was decided to make the engine do not contribute to a collection occur.

## Get the Vita SDK

Details into setting up vita sdk on: https://vitasdk.org/

You'll need the VitaSDK in your path. This process could be automatized in future.

## Generating a build for Vita


Extract `hipreme_engine_vita_dev_files.7z`.

It has the following content:
    -PVR_PSP2 headers and library
    -Tools for easing development on Vita such as net logging.


You'll need to create a folder "assets" in the same folder this README is located. It will be packaged to vita.
After that, you can run `./build.sh`. Which you will probably need to modify to get your PS Vita IP Address (The data is sent via CURL).


Install the .vpk file, after that, you'll be using from Hipreme Engine root folder `vitarun.sh`. Which will only transfer the binary data required to run your game. That way there won't be any need to install it again.
