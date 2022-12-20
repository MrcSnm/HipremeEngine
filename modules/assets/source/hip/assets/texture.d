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
*   Asset representation of a texture
*/
module hip.assets.texture;
import hip.asset;
import hip.error.handler;
import hip.hiprenderer.renderer;
import hip.math.rect;
import hip.assets.image;
public import hip.util.data_structures:Array2D;
public import hip.api.renderer.texture;


import renderer = hip.hiprenderer.texture;
import hip.util.reflection;

class HipTexture : HipAsset, IHipTexture
{
    mixin(ForwardInterface!("textureImpl", IHipTexture));
    
    IImage img;
    int width,height;
    public IHipTexture textureImpl;
    private bool successfullyLoaded;
    public bool hasSuccessfullyLoaded(){return successfullyLoaded;}
    
    public static HipTexture getPixelTexture()
    {
        static HipTexture pixelTexture;
        if(pixelTexture is null)
        {
            pixelTexture = new HipTexture();
            pixelTexture.img = cast(IImage)Image.getPixelImage; //Cast the immutable away, promise it is immutable
            pixelTexture.textureImpl.load(pixelTexture.img);
        }
        return pixelTexture;
    }
    /**
    *   Initializes with the current renderer type
    */
    protected this()
    {
        super("Texture");
        _typeID = assetTypeID!HipTexture;
        textureImpl = HipRenderer.getTextureImplementation();
    }

    /**
    *   Only use this style of initializing HipTexture if you wish to avoid HipAssetManager usage. 
    *   This is not really recommended as instantiating as simply new HipTexture("path.png") won't add to the asset manager cache.
    */
    this(string path)
    {
        this();
        load(path);
    }

    this(in IImage image)
    {
        this();
        if(image !is null)
            load(image);
    }

    alias load = IHipTexture.load;

    /**
    *   Returns whether the load was successful
    */
    public bool load(string path)
    {
        import hip.filesystem.hipfs;
        ubyte[] buffer;
        if(!HipFS.read(path, buffer))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not load texture from path ",path);
            return false;
        }      

        Image loadedImage = new Image(path, buffer);
        return load(loadedImage);
    }

    protected bool loadImpl(in IImage img)
    {
        successfullyLoaded = textureImpl.load(img);
        width = textureImpl.getWidth;
        height = textureImpl.getHeight;
        return successfullyLoaded;
    }
    
    override void onFinishLoading(){}
    override void onDispose(){}
    
    bool isReady(){return textureImpl !is null;}
    int getWidth(){return width;}
    int getHeight(){return height;}
    
}



class HipTextureRegion : HipAsset, IHipTextureRegion
{
    public static const float[8] defaultVertices = [0,0, 1,0, 1,1, 0,1];
    IHipTexture texture;
    public float u1, v1, u2, v2;
    protected float[8] vertices;
    int regionWidth, regionHeight;

    bool hasSuccessfullyLoaded(){return texture && texture.hasSuccessfullyLoaded;}

    protected this()
    {
        super("TextureRegion");
        _typeID = assetTypeID!HipTextureRegion;
    }

    this(string texturePath, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1){this(new HipTexture(texturePath));}

    this(IHipTexture texture, float u1 = 0, float v1 = 0, float u2 = 1, float v2 = 1)
    {
        this();
        this.texture = texture;
        setRegion(u1,v1,u2,v2);
    }
    this(IHipTexture texture, uint u1, uint v1, uint u2, uint v2)
    {
        this();
        this.texture = texture;
        setRegion(texture.getWidth, texture.getHeight, u1,  v1, u2, v2);
    }

    void setTexture(IHipTexture texture){this.texture = texture;}
    const(IHipTexture) getTexture() const {return cast(const)texture;}
    IHipTexture getTexture() {return texture;}
    int getWidth() const {return regionWidth;}
    int getHeight() const {return regionHeight;}
    TextureCoordinatesQuad getRegion() const
    {
        return TextureCoordinatesQuad(u1, v1, u2, v2);
    }

    /**
    * By passing the width and height values, you'll be able to crop useless frames
    * Default spritesheet method that makes a spritesheet from the entire texture
    */
    public static Array2D!IHipTextureRegion cropSpritesheet(
        IHipTexture t,
        uint frameWidth, uint frameHeight,
        uint width = 0, uint height = 0,
        uint offsetX = 0, uint offsetY = 0,
        uint offsetXPerFrame = 0, uint offsetYPerFrame = 0)
    {
        if(width == 0) width = t.getWidth;
        if(height == 0) height = t.getHeight;

        uint lengthW = width/(frameWidth+offsetXPerFrame);
        uint lengthH = height/(frameHeight+offsetYPerFrame);

        Array2D!IHipTextureRegion ret = Array2D!IHipTextureRegion(lengthH, lengthW);

        for(int i = 0, fh = 0; fh < height; i++, fh+= frameHeight+offsetXPerFrame)
            for(int j = 0, fw = 0; fw < width; j++, fw+= frameWidth+offsetYPerFrame)
                ret[i,j] = new HipTextureRegion(t, offsetX+fw , offsetY+fh, offsetX+fw+frameWidth, offsetY+fh+frameHeight);

        return ret;
    }
    public static Array2D!IHipTextureRegion cropSpritesheetRowsAndColumns(IHipTexture t, uint rows, uint columns)
    {
        uint frameWidth = t.getWidth() / columns;
        uint frameHeight = t.getHeight() / rows;
        return cropSpritesheet(t,frameWidth,frameHeight, t.getWidth, t.getHeight, 0, 0, 0, 0);
    }
    

    alias setRegion = IHipTextureRegion.setRegion;
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
        //Check for round
        float regWidth =  (u2 - u1) * texture.getWidth;
        float regHeight = (v2 - v1) * texture.getHeight;
        regionWidth =  cast(uint)(regWidth + 0.5) > cast(uint)regWidth ? cast(uint)(regWidth+0.5) : cast(uint)regWidth;
        regionHeight = cast(uint)(regHeight + 0.5) > cast(uint)regHeight ? cast(uint)(regHeight+0.5) : cast(uint)regHeight;

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

    HipTextureRegion clone()
    {
        return new HipTextureRegion(texture, u1, v1, u2, v2);
    }

    ref float[8] getVertices(){return vertices;}
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return texture !is null;}
    
}