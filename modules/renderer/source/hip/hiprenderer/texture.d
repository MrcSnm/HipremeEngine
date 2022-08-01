/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hiprenderer.texture;
import hip.error.handler;
import hip.hiprenderer.renderer;
import hip.math.rect;
import hip.image;
public import hip.util.data_structures:Array2D;
public import hip.hipengine.api.renderer.texture;

class HipTexture : ITexture
{
    IImage img;
    int width,height;
    TextureFilter min, mag;
    private static HipTexture pixelTexture;
    public static immutable(HipTexture) getPixelTexture()
    {
        if(pixelTexture is null)
        {
            pixelTexture = new HipTexture();
            pixelTexture.img = cast(IImage)HipImageImpl.getPixelImage();
            pixelTexture.textureImpl.load(pixelTexture.img);
        }
        return cast(immutable)pixelTexture;
    }

    /**
    *   Make it available for implementors
    */
    package ITexture textureImpl;
    /**
    *   Initializes with the current renderer type
    */
    protected this(){textureImpl = HipRenderer.getTextureImplementation();}

    this(IImage image)
    {
        this();
        if(image !is null)
            load(image);
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
    bool load(in IImage img)
    {
        this.img = cast(IImage)img; //Promise it won't modify
        this.width = img.getWidth;
        this.height = img.getHeight;
        this.textureImpl.load(img);
        return width != 0;
    }
    int getWidth(){return width;}
    int getHeight(){return height;}
}