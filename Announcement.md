# Hipreme Engine v1.0.0 Announcement

Today, I'm glad to announce that Hipreme Engine is finally releasing its version 1.0. The 1000th commit marks the first release of this engine. There is a lot of work already done and a lot of work to be done. Some systems may find unstable support, such as Linux, which of course I'm willing to help, since it is not my development platform, it may not even work on the first run. But, even though this may happen, there is still a lot of work already done to be shown. It is the first D library with that quantity of abstraction done for making your work fully cross platform. But, with a lot of missing functionality, why announce right now? 

# Battle Testing
It is high time to start battle testing Hipreme Engine. The engine is not gonna suffer any more power refactor for some time now, since all the platforms are supported, the abstraction is good enough for doing much. 

### Make It Better
By releasing this to public, it is possible to identify common pitfalls that could be easily solved with a little time. Build selector born from the need of making it easier to users setup the engine.

### Be Patient
Expecting the engine to work with the same behavior on every OS and API is quite a hard task. It may take some time until the engine is stable for everyone, although I guarantee I've done the best I could to provide a high quality experience.

### Your Issue Is My Priority
If you find any kind of issue, don't be afraid to submit the issue, don't try to circumvent it unless you're really planning to release anything soon. By submitting the issue you make me aware of it and I'm certain that if it is doable, it is definitely priority.




## Platforms Supported:
- Windows
- Linux
- MacOS
- iOS
- Android
- PS Vita
- WebAssembly
- Xbox Series

## Current Compiler:
- DMD 2.106
- LDC 1.36
### Warning:
You won't be able to use your PC's D version. This was made because the existence of the custom runtime I'm supporting right now and to guarantee the best experience of any user. The language understands which version you're using on hbuild, and queries your permission for downloading it. Since this is a one person project, this is the best way I found for guaranteeing more stability.

## Supporting APIs:
### Rendering
- OpenGL 3
- OpenGL ES 1/2
- WebGL
- Direct3D 11
- Metal 2.4

### Audio
- OpenAL
- OpenSL ES
- XAudio 2
- AVAudioEngine


## Features

- Basic Windowing Support (Meant to open your window and execute your game)
- Basic Filesystem (Read/Write) on supported platforms with async API
- Game assets recognition + preloading
- Primitives Rendering
- Sprites+Animations rendering
- Tween
- Scripting API (Hot reload without reopening game window) + null dereference check on Windows + Linux
- Easy build system that should not require knowledge in specific domains
- Tilemap rendering


## What you can do with the current state
- Easily create a single screen game
- Generate builds to every platform mentioned
- 2D games

## Common functionalities it is lacking
- GUI
- 2D Physics Engine
- Particle System (needs more testing and serialization)
- Post Processing shaders
- User threading (means that the API user should not use core.thread as it is not guaranteed to work)


# Planned Features
The features here planned are in order of importance:

1. Tutorials
    1. Particle System
    2. Basic GUI
2. Documentations
3. Small refactors on audio engine
4. Shader Transpiler - Write in D, output shaders for every API
   1. Frame buffer abstraction
   2. Post processing shaders
5. Make the renderer message based
  
## Warnings
### Starting Point
- Means that the API finally reached a lot more of stability, it is entirely possible to create games.

### You may find dumb bugs
- As of now, I'm releasing this to make it easily available to `dub` users. So, this project is still lacking some battle testing.

### Lack of tutorials and documentation
- The lack of tutorials and documentation are a real problem right now. This is the next step after the creation of some games

### Build Selector CI
- The build selector CI is still requiring some updates to not let it get changes from separate branches, it may break on the release section.


# Getting Started
Run `dub run hipreme_engine:hbuild`. The actual recommended
