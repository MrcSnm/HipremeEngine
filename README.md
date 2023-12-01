
<p align="center">
<img src="engine_logo.svg" width="300"/>
</p>


<h1 align="center">
<a href="https://github.com/MrcSnm/HipremeEngine/wiki/Getting-Started">Getting Started</a>
</h1>



The engine mantains some global options which you can modify it on source/global/opts.d:
- HE_DEBUG    -> Use that for creating a debug version for the engine only
- HE_NO_LOG   -> Disable the global logging functions
- HE_ERR_ONLY -> Mantain only error logging




## Current features

- Input handler and text input with selected keyboard layout;
- Xbox One/Series Gamepad implementation;
- Minimal Matrix/Vector implementation;
- Asset packing, appending, updating and reading for faster performance(less IO);
- Multi threaded asset loading and decoding (image).

## Platforms

- Xbox Series (UWP): [build/uwp](build/uwp/HipremeEngine/HipremeEngine)
- Android: **build/android**
- Browser (WebAssembly): [build/wasm](build/wasm)
- PS Vita: [build/vita](build/vita/hipreme_engine/)
- MacOS : [build/appleos](build/appleos/)
- Windows
- Linux: Requires libgl1-mesa-dev for opening X11 window and OpenGL

### Features

1. Simple build system
2. Virtual File System
3. Centralized asset locator with caching
4. File reading with progress notification


## Rendering

- Metal 2.4
- Direct X 11
- OpenGL 3
- OpenGL ES 3
- OpenGL ES 2
- WebGL 1.0 (OpenGL ES 2 emulated)
- HipRenderer (abstraction)
  
### Features

1. Sprite
2. SpriteBatch
3. GeometryBatch
4. FrameBuffer
5. BitmapText
7. Shader
8. Material
9. Tiled maps

## Audio

- OpenSL ES
- OpenAL
- XAudio2
- WebAudio
- HipAudio (abstraction)

### Features

1. Streaming
2. 3D audio
3. Low Latency on Android -> See flags at config/opts.d `HIP_OPENSLES_OPTIMAL` and `HIP_OPENSLES_FAST_MIXER`

## Decoding

- Images: PNG, JPG, BMP, TIFF and maybe others via arsd-official:image_files
- Audio: MP3, OGG, WAV, FLAC via audioformats
- Tiled: TSX and TSJ parser
- TextureAtlas: JSON, ATLAS, XML and TXT(Spritesheet) parser
- Font: FNT, TTF, OTF
- Pack: HapFile(Hipreme Asset Packing File)
- Settings: INI/CONF, JSON (HipremeEngine own's implementation that simulates std.json but faster) and CSV

### Coding

- Scripting:

1. D ( check api module for reference )
- Filewatcher for recompiling the script
- Live reload ( no engine restart for coding )

2. Lua (outdated)
  


## Next steps

- GLSL to HLSL transpiler
- Multi threaded audio decoding (currently only single threaded is supported)
- Create a proof of concept


## Issues list

- ~~D3DReflect needs to link to D3dcompiler_43 instead of _47~~ -> Fixed, directx-d D3DReflect had a wrong GUID
- You can't spawn an Object from within an interface without calling `hipSaveRef` or `GC.addRoot`. This is a bug
on DLL implementation which doesn't actually add the new object spawned from an interface as a leaf.
