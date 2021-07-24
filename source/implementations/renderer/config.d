module implementations.renderer.config;

struct HipRendererConfig
{
    ///Use level 0 for pixel art games
    ubyte multisamplingLevel = 0;
    ///Single/Double/Triple buffering
    ubyte bufferingCount = 2;
    bool vsync = true;
}