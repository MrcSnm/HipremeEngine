/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
/**
*   This class will be only a wrapper for importing the correct backend
*/
module hip.hiprenderer.texture;
import hip.error.handler;
import hip.hiprenderer.renderer;
import hip.math.rect;
import hip.data.assets.image;
public import hip.util.data_structures:Array2D;
public import hip.hipengine.api.renderer.texture;

class Texture : ITexture
{
    Image img;
    int width,height;
    TextureFilter min, mag;
    private static Texture pixelTexture;
    public static Texture getPixelTexture()
    {
        if(pixelTexture is null)
        {
            pixelTexture = new Texture();
            pixelTexture.img = new Image("pixel");
            ubyte[4] pixel = IHipImageDecoder.getPixel();
            ubyte[] temp = pixel;
            pixelTexture.img.pixels = cast(void*)temp.ptr;
            pixelTexture.img.width = 1;
            pixelTexture.img.height = 1;
            pixelTexture.img.bytesPerPixel = 4;
            pixelTexture.textureImpl.load(pixelTexture.img);
        }
        return pixelTexture;
    }

    /**
    *   Make it available for implementors
    */
    package ITexture textureImpl;
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
    public void bind()
    {
        textureImpl.bind();
        HipRenderer.exitOnError();
    }
    ///Binds texture to the specific slot
    public void bind(int slot)
    {
        textureImpl.bind(slot);
        HipRenderer.exitOnError();
    }
    public void unbind()
    {
        textureImpl.unbind();
        HipRenderer.exitOnError();
    }
    public void unbind(int slot)
    {
        textureImpl.unbind(slot);
        HipRenderer.exitOnError();
    }
    public void setWrapMode(TextureWrapMode mode){textureImpl.setWrapMode(mode);}
    public void setTextureFilter(TextureFilter min, TextureFilter mag)
    {
        this.min = min;
        this.mag = mag;
        textureImpl.setTextureFilter(min, mag);
    }
    
    Rect getBounds(){return Rect(0,0,width,height);}

    /**
    *   Returns whether the load was successful
    */
    public bool load(string path)
    {
        import hip.data.assetmanager;
        HipAssetLoadTask task = HipAssetManager.loadImage(path);
        task.await;
        Image loadedImage = cast(Image)task.asset;

        return load(loadedImage);
    }
    
    bool load(IImage img)
    {
        this.img = cast(Image)img;
        this.width = img.getWidth;
        this.height = img.getHeight;
        this.textureImpl.load(cast(Image)img);
        return width != 0;
    }
    
}



class TextureRegion
{
    Texture texture;
    public float u1, v1, u2, v2;
    protected float[8] vertices;
    int regionWidth, regionHeight;

    this(string texturePath, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
    {
        texture = new Texture(texturePath);
        setRegion(u1,v1,u2,v2);
    }

    this(Texture texture, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
    {
        this.texture = texture;
        setRegion(u1,v1,u2,v2);
    }
    this(Texture texture, uint u1, uint v1, uint u2, uint v2)
    {
        this.texture = texture;
        setRegion(texture.width, texture.height, u1,  v1, u2, v2);
    }

    ///By passing the width and height values, you'll be able to crop useless frames
    public static Array2D!TextureRegion spritesheet(
        Texture t,
        uint frameWidth, uint frameHeight,
        uint width, uint height,
        uint offsetX, uint offsetY,
        uint offsetXPerFrame, uint offsetYPerFrame)
    {
        uint lengthW = width/(frameWidth+offsetXPerFrame);
        uint lengthH = height/(frameHeight+offsetYPerFrame);

        Array2D!TextureRegion ret = Array2D!TextureRegion(lengthH, lengthW);

        for(int i = 0, fh = 0; fh < height; i++, fh+= frameHeight+offsetXPerFrame)
            for(int j = 0, fw = 0; fw < width; j++, fw+= frameWidth+offsetYPerFrame)
                ret[i,j] = new TextureRegion(t, offsetX+fw , offsetY+fh, offsetX+fw+frameWidth, offsetY+fh+frameHeight);

        return ret;
    }
    ///Default spritesheet method that makes a spritesheet from the entire texture
    static Array2D!TextureRegion spritesheet(Texture t, uint frameWidth, uint frameHeight)
    {
        return spritesheet(t,frameWidth,frameHeight, t.width, t.height, 0, 0, 0, 0);
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
        regionWidth =  cast(uint)((u2 - u1) * texture.width);
        regionHeight = cast(uint)((v2 - v1) * texture.height);

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

    /**
    *   The uint variant from the setRegion receives arguments in a non normalized way to setup
    *   the UV coordinates.
    *   It is better if you wish to just pass where it start and ends.
    *   The region is divided by the width and height
    *   
    */
    void setRegion(uint width, uint height, uint u1, uint v1, uint u2, uint v2)
    {
        float fu1 = u1/cast(float)width;
        float fu2 = u2/cast(float)width;
        float fv1 = v1/cast(float)height;
        float fv2 = v2/cast(float)height;
        setRegion(fu1, fv1, fu2, fv2);
    }

    /**
    *   The UV coordinates passed are divided by the current texture width and height
    */
    void setRegion(uint u1, uint v1, uint u2, uint v2)
    {
        if(texture)
            setRegion(texture.width, texture.height, u1, v1, u2, v2);
    }


    public ref float[8] getVertices(){return vertices;}
}
