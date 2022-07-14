/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.image;
public import hip.hipengine.api.data.image;


IHipBMPDecoder bmp;
IHipJPEGDecoder jpeg;
IHipPNGDecoder png;
IHipWebPDecoder webP;


version(HipARSDImageDecoder)
final class HipARSDImageDecoder : IHipAnyImageDecoder
{
    import arsd.image;
    MemoryImage img;
    TrueColorImage trueImg;
    bool startDecoding(void[] data)
    {
        img = loadImageFromMemory(data);
        if(img !is null)
            trueImg = img.getAsTrueColorImage;

        return (img !is null) && (trueImg !is null);
    }

    uint getWidth()
    {
        if(img !is null)
            return img.width;
        return 0;
    }

    uint getHeight()
    {
        if(img !is null)
            return img.height;
        return 0;
    }

    void* getPixels()
    {
        if(img !is null)
            return trueImg.imageData.bytes.ptr;
        return null;
    }

    ubyte getBytesPerPixel()
    {
        //Every true image color has 4 bytes per pixel
        return 4;
    }

    ubyte[] getPalette()
    {
        return null;
    }

    void dispose()
    {
        img.clearInternal;
        destroy(trueImg);
        destroy(img);
    }
}

final class HipNullImageDecoder : IHipAnyImageDecoder
{
    bool startDecoding(void[] data){return false;}
    uint getWidth(){return 0;}
    uint getHeight(){return 0;}
    void* getPixels(){return null;}
    ubyte getBytesPerPixel(){return 0;}
    ubyte[] getPalette(){return null;}
    void dispose(){}
}

///Use that alias for supporting more platforms
version(HipSDLImageDecoder)
    alias HipPlatformImageDecoder = HipSDLImageDecoder;
else version(HipARSDImageDecoder)
    alias HipPlatformImageDecoder = HipARSDImageDecoder;
else
{
    alias HipPlatformImageDecoder = HipNullImageDecoder;
    pragma(msg, "WARNING: Using NullImageDecoder.");
}
