module hip.image_backend.impl;
public import hip.api.data.image;


final class HipNullImageDecoder : IHipImageDecoder
{
    this(string path){}
    bool startDecoding(void[] data, void delegate() onSuccess, void delegate() onFailure)
    {
        onFailure();
        return false;
    }
    uint getWidth() const {return 0;}
    uint getHeight() const {return 0;}
    const(ubyte)[] getPixels() const {return null;}
    ubyte getBytesPerPixel() const {return 0;}
    const(ubyte)[] getPalette() const {return null;}
    void dispose(){}
}

export extern(System) IHipImageDecoder getDecoder(string path)
{
    ///Use that alias for supporting more platforms
   version(HipGamutImageDecoder)
    {
        import hip.image_backend.gamut;
        return new HipGamutImageDecoder(path);
    } 
    else version(WebAssembly) 
    {
        import hip.image_backend.webassembly;
        return new HipWasmImageDecoder(path);
    }
    else
    {
        pragma(msg, "WARNING: Using NullImageDecoder.");
        return new HipNullImageDecoder();
    }
}


