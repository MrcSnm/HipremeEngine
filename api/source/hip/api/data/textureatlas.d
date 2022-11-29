module hip.api.data.textureatlas;
public import hip.api.renderer.texture;


struct Size
{
    uint width, height;
    alias w = width, h = height;
}
struct Rect
{
    float x, y, width, height;
    alias w = width, h = height;
}

struct AtlasFrame
{
    string filename;
    bool rotated;
    bool trimmed;

    Rect frame;
    Rect spriteSourceSize;
    Size sourceSize;
    IHipTextureRegion region;

    alias region this;
}

interface IHipTextureAtlas
{
    ref AtlasFrame[string] frames();

    alias frames this;
}