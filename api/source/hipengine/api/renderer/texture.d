module hipengine.api.renderer.texture;
public import hipengine.api.data.image;
public import hipengine.api.graphics.color;

enum TextureWrapMode
{
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    REPEAT,
    MIRRORED_REPEAT,
    MIRRORED_CLAMP_TO_EDGE,
    UNKNOWN
}

enum TextureFilter
{
    LINEAR,
    NEAREST,
    NEAREST_MIPMAP_NEAREST,
    LINEAR_MIPMAP_NEAREST,
    NEAREST_MIPMAP_LINEAR,
    LINEAR_MIPMAP_LINEAR
}
interface ITexture
{
    void setWrapMode(TextureWrapMode mode);
    void setTextureFilter(TextureFilter min, TextureFilter mag);
    bool load(IImage img);
    void bind();
    void bind(int slot);
    void unbind();
    void unbind(int slot);
}
