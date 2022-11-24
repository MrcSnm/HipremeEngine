# HipremeEngine

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

- UWP (Xbox and everything Windows runs on)
- Android
- Linux

### Features

1. Simple build system
2. Virtual File System
3. Centralized asset locator with caching
4. File reading with progress notification


## Rendering

- Direct X 11
- OpenGL 3
- OpenGL ES 3
- OpenGL ES 2
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
- HipAudio (abstraction)

### Features

1. Streaming
2. 3D audio
3. Low Latency on Android -> See flags at config/opts.d `HIP_OPENSLES_OPTIMAL` and `HIP_OPENSLES_FAST_MIXER`

## Decoding

- Images: PNG, JPG, BMP, TIFF and maybe others via arsd-official:image_files
- Audio: MP3, OGG, WAV, FLAC via audioformats
- Tiled: TSX and JSON parser
- TextureAtlas: JSON and ATLAS parser
- Font: FNT parser, TTF and OTF decoding
- Pack: HapFile(Hipreme Asset Packing File)
- Settings: INI/CONF parser

### Coding

- Scripting:

1. Lua
2. D ( check api module for reference )
- Filewatcher for recompiling the script
- Live reload ( no engine restart for coding )
  


## Next steps

- GLSL to HLSL transpiler
- Multi threaded audio decoding (currently only single threaded is supported)
- Dispatch file reading to the asset/resource packer.
- Create a proof of concept


## Issues list

- ~~D3DReflect needs to link to D3dcompiler_43 instead of _47~~ -> Fixed, directx-d D3DReflect had a wrong GUID
- You can't spawn an Object from within an interface without calling `hipSaveRef` or `GC.addRoot`. This is a bug
on DLL implementation which doesn't actually add the new object spawned from an interface as a leaf.