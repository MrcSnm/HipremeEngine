/**
*   This class will be only a wrapper for importing the correct backend
*/
module implementations.renderer.texture;
import data.assetmanager;
import error.handler;
import implementations.renderer.renderer;
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
    /**
    *   Initializes with the current renderer type
    */
    protected this()
    {
        textureImpl = HipRenderer.getTextureImplementation();
    }


    this(string path = "")
    {
        this();
        if(path != "")
            load(path);
    }
    /** Binds as the texture target on the renderer. */
    public void bind(){textureImpl.bind();}
    public void setWrapMode(TextureWrapMode mode){textureImpl.setWrapMode(mode);}
    public void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        this.min = min;
        this.mag = mag;
        textureImpl.setTextureFilter(min, mag);
    }
    
    SDL_Rect getBounds(){return SDL_Rect(0,0,width,height);}
    void render(int x, int y){HipRenderer.draw(this, x, y);}

    /**
    *   Returns whether the load was successful
    */
    public bool load(string path)
    {
        HipAssetManager.loadImage(path, (Image img)
        {
            this.img = img;
            this.width = img.data.w;
            this.height = img.data.h;
            this.textureImpl.load(img.data);
        }, false);
        return this.width != 0;
    }



}



class TextureRegion : Texture
{
    public float u1, v1, u2, v2;
    protected float[8] vertices;

    this(string texturePath, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
    {
        super(texturePath);
        this.setRegion(u1,v1,u2,v2);
    }

    /**
    *   Defines a region for the texture in the following order:
    *   Top-left
    *   Top-Right
    *   Bot-Right
    *   Bot-Left
    */
    public void setRegion(float u1, float v1, float u2, float v2)
    {
        this.u1 = u1;
        this.u2 = u2;
        this.v1 = v1;
        this.v2 = v2;

        //Top left
        vertices[0] = u1;
        vertices[1] = v1;

        //Top right
        vertices[2] = u2;
        vertices[3] = v1;
        
        //Bot right
        vertices[4] = u2;
        vertices[5] = v2;

        //Bot left
        vertices[6] = u1;
        vertices[7] = v2;
    }

    public ref float[8] getVertices()
    {
        return vertices;
    }
}