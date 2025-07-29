
<p align="center">
<img src="assets/marketing/svg/engine_logo.svg" width="300"/>
</p>


<h1 align="center">
<a href="https://github.com/MrcSnm/HipremeEngine/wiki/Getting-Started">Getting Started</a>
</h1>

[![HBuild](https://github.com/MrcSnm/HipremeEngine/actions/workflows/hbuild.yml/badge.svg)](https://github.com/MrcSnm/HipremeEngine/actions/workflows/hbuild.yml)




The engine maintains  some global options which you can modify it on
- [modules/config/source/hip/config/opts.d](modules/config/source/hip/config/opts.d):
- [modules/config/source/hip/config/renderer.d](modules/config/source/hip/config/renderer.d):
- HE_DEBUG    -> Use that for creating a debug version for the engine only
- HE_NO_LOG   -> Disable the global logging functions
- HE_ERR_ONLY -> Maintain only error logging

## Platforms
> Almost all of those platforms can be built by using the [hbuild](tools/user/hbuild) project.
>
> If you have D installed already, the hbuild can be got by running `dub run hipreme_engine:hbuild`
>
> If not, you may go to the [BuildAssets](https://github.com/MrcSnm/HipremeEngine/releases/tag/BuildAssets.v1.0.0) page and select your system. Both the language and engine will be installed locally by using them.

## Build System Showcase
![Example on build selector running and showing the build system](hbuild_showcase.png)

- Xbox Series (UWP): [build/uwp](build/uwp/HipremeEngine/HipremeEngine)
- Android: [build/android/](build/android/project/)
- Browser (WebAssembly): [build/wasm](build/wasm)
- PS Vita: [build/vita](build/vita/hipreme_engine/)
- MacOS : [build/appleos](build/appleos/)
- iOS: [build/appleos](build/appleos/)
- Windows: [bin/desktop](bin/desktop/)
- Linux: [bin/desktop](bin/desktop/)
> Requires libgl1-mesa-dev for opening X11 window and OpenGL

## Engine Core

| Rendering | Audio | Decoding | FileSystem | Renderer2D | Network | Input |
|:---------:|:-----:|:--------:|:----------:|:----------:|:-------:|:-----:|
| Metal 2.4 | AVAudioEngine | Image: PNG, JPG, BMP & TIFF | C Std | Sprite | Server | Mouse
| DirectX 11| XAudio2 | Audio: MP3, OGG, WAV, FLAC | D Std| Sprite/Geometry Batch | WebSocket | Touch
| OpenGL 3 | OpenAL | [Tiled](https://www.mapeditor.org/): TSJ & TMJ | Android AAssetManager | Framebuffer | TCP | Xbox Gamepad
| OpenGL ES 3 | OpenSL ES | Font: FNT, OTF TTF | Web Filesystem Simulation| BitmapText | NetController | Input Listener
| OpenGL ES 2 |  | Pack: HapFile (coming) | Parallel Asset Manager | Shader | Lightweight TypeInfo |
| WebGL 1 (OpenGL ES2 Emulation) | WebAudio | General: INI, CSV, JSONC  | Dynamic Asset Factory | Material | Auto Data Layout
| HipRenderer* | HipAudio* |TextureAtlas: JSON, ATLAS, XML & TXT | | TiledMaps | HipNetwork*

*: Hipreme Engine abstraction

### Features

- HBuild build system. 1-Click deliver to expected platform
- WebAssembly reload server
- Centralized asset locator with caching and new types registering
- Lightweight TypeInfo: Guarantees that the sent type is the same that is received
- Auto Data Layout: Guarantees that the data is aligned to 1 byte reducing the overall toll of sending data over net
- Abstraction over renderer and audio player guaranteeing best performance and unified API
- Easy asset loading system


### Coding

- Scripting: Use D for scripting with runtime code loading
- Filewatcher: Currently disabled since I didn't like the experience
- WebAssembly server reloader: Every rebuild of wasm automatically reloads the game
-
## Next steps

- GLSL to HLSL transpiler
- Multi threaded audio decoding (currently only single threaded is supported)
- Create a proof of concept
