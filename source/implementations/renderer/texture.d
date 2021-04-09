/**
*   This class will be only a wrapper for importing the correct backend
*/
module implementations.renderer.texture;
import error.handler;
import implementations.renderer.renderer;
import implementations.renderer.backend.gl.texture;
import implementations.renderer.backend.d3d.texture;
import implementations.renderer.backend.sdl.texture;
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
    bool load(SDL_Surface* surface);
    void bind();
}

class Texture
{
    ITexture textureImpl;
    Image img;
    uint width,height;
    TextureFilter min, mag;
    this(string path = "")
    {
        if(HipRenderer.rendererType == RendererType.GL3)
            textureImpl = new Hip_GL3_Texture();
        else if(HipRenderer.rendererType == RendererType.D3D11)
            textureImpl = new Hip_D3D11_Texture();
        else if(HipRenderer.rendererType == RendererType.SDL)
            textureImpl = new Hip_SDL_Texture();
        else
        {
            ErrorHandler.showErrorMessage("No renderer implementation active",
            "Can't create a texture without a renderer implementation active");
        }
        if(path != "")
            load(path);
    }
    public void setWrapMode(TextureWrapMode mode)
    {
        textureImpl.setWrapMode(mode);
    }
    public void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        this.min = min;
        this.mag = mag;
        textureImpl.setTextureFilter(min, mag);
    }
    
    SDL_Rect getBounds()
    {
        return SDL_Rect(0,0,width,height);
    }
    void render(int x, int y)
    {
        HipRenderer.draw(this, x, y);
    }

    public bool load(string path)
    {
        this.img = new Image(path);
        if(img.load())
        {
            textureImpl.load(img.data);
            width = img.data.w;
            height = img.data.h;
            return true;
        }
        else
            return false;
    }
    public void bind()
    {
        textureImpl.bind();
    }
}