rdmd tools/build/gendir.d assets/defaults build/wasm/generated

set DFLAGS=-I=%HIPREME_ENGINE%/modules/d_std/source ^
-I=%HIPREME_ENGINE%/build/wasm/runtime/webassembly/arsd-webassembly ^
-preview=shortenedMethods ^
-L-allow-undefined ^
-fvisibility=hidden ^
-d-version=CarelessAlocation


@REM d_std is the HipremeEngine's implementation for phobos std. Required for platforms which the std wasn't ported.
@REM arsd-webassembly is where the WebAssembly DRuntime is defined. 
@REM -L-allow-undefined is required for building for WebAssembly, it will allow linking to symbols defined in JS
@REM -fvisibility=hidden makes it only export symbols marked with `export`
@REM CarelessAlocation is necessary for allowing allocations that depends on GC implementation on Runtime.

dub build --build=debug -c wasm  --arch=wasm32-unknown-unknown-wasm