module hip.assets.image;

//Reserved for future implementation.
import hip.asset;
import hip.image;


/**
*   This class represents pixel data on RAM (CPU Powered)
*   this is useful for loading images on another thread and then
*   sending it to the GPU
*/
public class Image : HipAsset, IImage
{
    protected shared bool _ready;
    IHipImageDecoder decoder;
    string imagePath;
    int width, height;
    ubyte bytesPerPixel;
    ushort bitsPerPixel;
    void* pixels;

    protected void* convertedPixels;


    this(in string path)
    {
        super("Image_"~path);
        typeID = assetTypeID!Image;
        initialize(path);
    }
    private void initialize(in string path)
    {
        import hip.util.system : sanitizePath;
        decoder = new HipPlatformImageDecoder();
        imagePath = sanitizePath(path);
    }
    static immutable(Image) getPixelImage()
    {
        static Image img; 
        static ubyte[4] pixel = IHipImageDecoder.getPixel();
        if(img is null)
        {
            img = new Image("pixel");
            img.pixels = cast(void*)pixel.ptr;
            img.width = 1;
            img.height = 1;
            img.bytesPerPixel = 4;
        }
        return cast(immutable)img;
    }
    string getName(){return name;}
    uint getWidth(){return width;}
    uint getHeight(){return height;}
    ubyte getBytesPerPixel(){return bytesPerPixel;}
    ubyte[] getPalette(){return decoder.getPalette;}
    void* getPixels(){return pixels;}

    void loadRaw(in ubyte[] pixels, int width, int height, ubyte bytesPerPixel)
    {
        this.width = width;
        this.height = height;
        this.pixels = cast(void*)pixels.ptr;
        this.bytesPerPixel = bytesPerPixel;
        this.bitsPerPixel = cast(ubyte)(bytesPerPixel*8);
    }


    bool loadFromMemory(ubyte[] data)
    {
        import hip.error.handler;
        if(ErrorHandler.assertErrorMessage(data.length != 0, "No data was passed to load Image.", "Could not load image"))
            return false;
        if(ErrorHandler.assertErrorMessage(decoder.startDecoding(data),
        "Decoding Image: ", "Could not load image " ~ imagePath))
            return false;
        width         = decoder.getWidth();
        height        = decoder.getHeight();
        bitsPerPixel  = decoder.getBitsPerPixel();
        bytesPerPixel = decoder.getBytesPerPixel();
        pixels        = decoder.getPixels();
        return true;
    }

    void* monochromeToRGBA()
    {
        import core.stdc.stdlib;
        import hip.error.handler;
        ubyte* pix = cast(ubyte*)malloc(4*width*height); //RGBA for each pixel
        ErrorHandler.assertExit(pix != null, "Out of memory when converting monochrome to RGBA");
        convertedPixels = pix;
        uint pixelsLength = width*height;
        ubyte color;
        uint z;
        for(uint i = 0; i < pixelsLength; i++)
        {
            //Palette r color = palette[pixels[i]*4]
            color = (cast(ubyte*)pixels)[i];
            pix[z++] = color; //R
            pix[z++] = color; //G
            pix[z++] = color; //B
            pix[z++] = color; //A
        }

        return cast(void*)pix;
    }

    void* convertPalettizedToRGBA()
    {
        import core.stdc.stdlib:malloc;
        import hip.error.handler;
        if(convertedPixels != null)
            return convertedPixels;
        ubyte* pix = cast(ubyte*)malloc(4*width*height); //RGBA for each pixel
        ErrorHandler.assertExit(pix != null, "Out of memory when converting palette pixels to RGBA");
        convertedPixels = pix;

        uint pixelsLength = width*height;
        ubyte[] palette = decoder.getPalette();

        uint colorIndex;
        uint z;
        for(uint i = 0; i < pixelsLength; i++)
        {
            //Palette r color = palette[pixels[i]*4]
            colorIndex = (cast(ubyte*)pixels)[i]*4;
            pix[z++]   = palette[colorIndex]; //R
            pix[z++] = palette[colorIndex+1]; //G
            pix[z++] = palette[colorIndex+2]; //B
            pix[z++] = palette[colorIndex+3]; //A
        }

        destroy(palette);

        return cast(void*)pix;
    }

    override bool load()
    {
        pragma(msg, __FILE__, " Should change img.loadFromFile");
        // _ready = loadFromFile();
        return _ready;
    }

    override bool isReady(){return _ready;}
    bool load(void function() onLoad)
    {
        pragma(msg, __FILE__, " Should change img.loadFromFile");
        // bool ret = loadFromFile();
        if(false)
            onLoad();
        return false;
    }
    override void onDispose()
    {
        import core.stdc.stdlib:free;
        decoder.dispose();
        if(convertedPixels != null)
        {
            free(convertedPixels);
            convertedPixels = null;
        }
    }
    override void onFinishLoading(){}
    alias w = width;
    alias h = height;
}
