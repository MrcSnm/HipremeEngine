/**
*   This class will be only a wrapper for importing the correct backend
*/
module implementations.renderer.texture;
import bindbc.sdl;
import graphics.image;

enum TextureWrapMode
{
    CLAMP_TO_EDGE,
    CLAMP_TO_BORDER,
    REPEAT,
    MIRRORED_REPEAT,
    MIRRORED_CLAMP_TO_EDGE,
    UNKNOWN
}
interface ITexture
{
    void setWrapMode(TextureWrapMode mode);
    bool load(SDL_Surface* surface);
    void bind();
}

class Texture
{
    ITexture textureImpl;
    Image img;
    this(ITexture textureImpl)
    {
        this.textureImpl = textureImpl;
    }
    public void setWrapMode(TextureWrapMode mode)
    {
        textureImpl.setWrapMode(mode);
    }
    public bool load(string path)
    {
        this.img = new Image(path);
        if(img.load())
        {
            textureImpl.load(img.data);
        }
        else
            return false;
    }
    public void bind()
    {
        textureImpl.bind();
    }
}