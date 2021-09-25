module hipengine.api.data.image;

public interface IHipImageDecoder
{
    ///Use that for decoding from memory, returns wether decode was successful
    bool startDecoding(void[] data);
    uint getWidth();
    uint getHeight();
    void* getPixels();
    ubyte getBytesPerPixel();
    ubyte[] getPalette();
    final ushort getBitsPerPixel(){return getBytesPerPixel()*8;}
    static ubyte[4] getPixel(){return cast(ubyte[4])[255,255,255,255];}
    ///Dispose the pixels
    void dispose();
}
//In progress?
public interface IHipPNGDecoder  : IHipImageDecoder{}
public interface IHipJPEGDecoder : IHipImageDecoder{}
public interface IHipWebPDecoder : IHipImageDecoder{}
public interface IHipBMPDecoder  : IHipImageDecoder{}
public interface IHipAnyImageDecoder : IHipPNGDecoder, IHipJPEGDecoder, IHipWebPDecoder, IHipBMPDecoder{}


public interface IImage
{
    string getName();
    bool loadFromMemory(ref ubyte[] data);
    void* convertPalettizedToRGBA();
    bool loadFromFile();
    bool load();
    bool load(void function() onLoad);
    bool isReady();
    uint getWidth();
    uint getHeight();
    ushort getBytesPerPixel();
    void* getPixels();
    void onDispose();
}
