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
    void setTextureFilter(TextureFilter min, TextureFilter mag);
    bool load(SDL_Surface* surface);
    void bind();
}

class Texture
{
    Image img;
    uint width,height;
    TextureFilter min, mag;

    protected ITexture textureImpl;


    this(string path = "")
    {
        if(HipRenderer.rendererType == HipRendererType.GL3)
            textureImpl = new Hip_GL3_Texture();
        else if(HipRenderer.rendererType == HipRendererType.D3D11)
            textureImpl = new Hip_D3D11_Texture();
        else if(HipRenderer.rendererType == HipRendererType.SDL)
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



class TextureRegion : Texture
{
    public float x1, y1, x2, y2;
    protected float[8] vertices;

    this(string texturePath, float x1 = 0, float y1 = 0, float x2 = 1, float y2 = 1)
    {
        super(texturePath);
        this.setRegion(x1,y1,x2,y2);
    }

    /**
    *   Defines a region for the texture in the following order:
    *   Top-left
    *   Top-Right
    *   Bot-Right
    *   Bot-Left
    */
    public void setRegion(float x1, float y1, float x2, float y2)
    {
        this.x1 = x1;
        this.x2 = x2;
        this.y1 = y1;
        this.y2 = y2;

        //Top left
        vertices[0] = x1;
        vertices[1] = y1;

        //Top right
        vertices[2] = x2;
        vertices[3] = y1;
        
        //Bot right
        vertices[4] = x2;
        vertices[5] = y2;

        //Bot left
        vertices[6] = x1;
        vertices[7] = y2;
    }

    public ref float[8] getVertices()
    {
        return vertices;
    }
}