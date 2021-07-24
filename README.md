# HipremeEngine

The engine mantains some global options which you can modify it on source/global/opts.d:
- HE_DEBUG    -> Use that for creating a debug version for the engine only
- HE_NO_LOG   -> Disable the global logging functions
- HE_ERR_ONLY -> Mantain only error logging




## Current features

- Abstract renderer for writing code once for DirectX and OpenGL;
- Abstract audio player, with OpenAL and SDL_Sound;
- Tiled .tsx and .json parser;
- Input handler and text input with selected keyboard layout;
- Minimal Matrix/Vector implementation;
- TextureAtlas .atlas and .json parser;
- BitmapFont parser and renderer, currently only text align is supported;
- ImGUI compatibility;
- Sprite, SpriteBatch, GeometryBatch, FrameBuffer renderer;
- Initial JNI and Android build system for future Android support
  