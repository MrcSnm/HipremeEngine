module hip.image_backend.webassembly;


version(WebAssembly)
{
    import hip.wasm;
    import hip.api.data.image;
    extern(C) struct BrowserImage
    {
        size_t handle;
        bool valid() const {return handle > 0;}
        alias handle this;
    }
    //Returns a BrowserImage, but can't use it in type directly.
    extern(C) size_t WasmDecodeImage(
        size_t imgPathLength, char* imgPathChars, ubyte* data, size_t dataSize,
        JSDelegateType!(void delegate(BrowserImage)) onImageLoad
    );

    extern(C) size_t WasmImageGetWidth(size_t);
    extern(C) size_t WasmImageGetHeight(size_t);
    extern(C) ubyte* WasmImageGetPixels(size_t);
    extern(C) void WasmImageDispose(size_t);

    final class HipWasmImageDecoder : IHipAnyImageDecoder
    {
        //Everything here needs to be cached for not calling the Wasm bridge.
        private uint width, height;
        private size_t timePixelsGet = 0;
        BrowserImage img;
        string path;
        ubyte[] pixels;
        this(string path)
        {
            assert(path, "HipWasmImageDecoder requires a path.");
            this.path = path;
        }
        bool startDecoding(void[] data, void delegate() onSuccess, void delegate() onFailure)
        {
            import hip.console.log;
            img = WasmDecodeImage(path.length, cast(char*)path.ptr, cast(ubyte*)data.ptr, data.length, sendJSDelegate!((BrowserImage _img)
            {
                assert(img == _img, "Different image returned!");
                if(img.valid)
                {
                    width = WasmImageGetWidth(img);
                    height = WasmImageGetHeight(img);
                    pixels = getWasmBinary(WasmImageGetPixels(img));
                    hiplog(width, " x ", height, " ", pixels.length, " bytes");

                    (width != 0 && height != 0) ? onSuccess() : onFailure();
                }
                else
                {
                    loglnError("Corrupted JS image object.");
                    onFailure();
                }
            }).tupleof);

            return img.valid && width != 0 && height != 0;
        }
        uint getWidth() const {return width;}
        uint getHeight() const {return height;}
        const(ubyte)[] getPixels() const 
        {
            return cast(const(ubyte)[])pixels;
        }
        ubyte getBytesPerPixel() const {return 4;}
        const(ubyte)[] getPalette() const {return null;}
        void dispose()
        {
            assert(img.valid, "Invalid dispose call.");
            WasmImageDispose(img);
            freeWasmBinary(pixels);
            img = 0;
            pixels = null;
        }
    }
}