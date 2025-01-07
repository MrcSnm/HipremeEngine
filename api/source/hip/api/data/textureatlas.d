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

    /**
     *
     * Params:
     *   size = The entire atlas size.
     * Returns: A TextureQuad compatible format from this atlas rect. Used for getting its vertices
     */
    TextureCoordinatesQuad toQuad(AtlasSize size)
    {
        return TextureCoordinatesQuad(
            x / size.width,
            y / size.height,
            (x+width) / size.width,
            (x+height) / size.height
        );
    }

    version(Have_data)
    {
        import hip.data.jsonc;
        static AtlasRect fromJSON()(JSONValue v, bool useShortenedDimensionNames = true)
        {
            return AtlasRect(
                v["x"].get!float,
                v["y"].get!float,
                v[useShortenedDimensionNames ? "w" : "width"].get!float,
                v[useShortenedDimensionNames ? "h" : "height"].get!float
            );
        }
    }
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