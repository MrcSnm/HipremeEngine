module hip.data.assets.image;

//Reserved for future implementation.
import hip.data.asset;
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
    ushort getBytesPerPixel(){return bytesPerPixel;}
    void* getPixels(){return pixels;}


    bool loadFromMemory(ref ubyte[] data)
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

    bool loadFromFile()
    {
        import hip.filesystem.hipfs;
        ubyte[] data_;
        HipFS.read(imagePath, data_);
        return loadFromMemory(data_);
    }

    override bool load()
    {
        _ready = loadFromFile();
        return _ready;
    }

    override bool isReady(){return _ready;}
    bool load(void function() onLoad)
    {
        bool ret = loadFromFile();
        if(ret)
            onLoad();
        return ret;
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
