module hip.api.data.textureatlas;
public import hip.api.renderer.texture;


struct AtlasSize
{
    uint width, height;
    alias w = width, h = height;
}
struct AtlasRect
{
    float x, y, width, height;
    alias w = width, h = height;
}

struct AtlasFrame
{
    string filename;
    bool rotated;
    bool trimmed;

    AtlasRect frame;
    AtlasRect spriteSourceSize;
    AtlasSize sourceSize;
    IHipTextureRegion region;

    alias region this;
}

interface IHipTextureAtlas
{
    ref AtlasFrame[string] frames();

    alias frames this;
}