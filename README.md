# HipremeEngine

The engine mantains some global options which you can modify it on source/global/opts.d:
- HE_DEBUG    -> Use that for creating a debug version for the engine only
- HE_NO_LOG   -> Disable the global logging functions
- HE_ERR_ONLY -> Mantain only error logging




## Current features

- Input handler and text input with selected keyboard layout;
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
- HipRenderer (abstraction)
  
### Features

1. Sprite
2. SpriteBatch
3. GeometryBatch
4. FrameBuffer
5. BitmapText
6. ImGUI
7. Shader
8. Material
9. Tiled maps

## Audio

- OpenSL ES
- OpenAL
- SDL
- HipAudio (abstraction)

### Features

1. Streaming
2. 3D audio
3. Low Latency on Android -> See flags at config/opts.d `HIP_OPENSLES_OPTIMAL` and `HIP_OPENSLES_FAST_MIXER`

## Decoding

- Images: WebP, PNG, JPG, BMP via SDL_Image
- Audio: MP3, OGG, WAV, FLAC via SDL_Sound
- Tiled: TSX and JSON parser
- TextureAtlas: JSON and ATLAS parser
- Font: FNT parser
- Pack: HapFile(Hipreme Asset Packing File)
- Settings: INI/CONF parser

## Next steps

- GLSL to HLSL transpiler
- Multi threaded audio decoding (currently only single threaded is supported)
- Dispatch file reading to the asset/resource packer.
- Create a proof of concept
- Automatize dependencies dll's generation
- Event handler for UWP and Android


## Issues list

- D3DReflect needs to link to D3dcompiler_43 instead of _47