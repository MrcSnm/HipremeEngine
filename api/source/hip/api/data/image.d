/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.data.image;

public interface IImageBase
{
    uint getWidth() const;
    uint getHeight() const;
    const(void[]) getPixels() const;
    ubyte getBytesPerPixel() const;
    final ushort getBitsPerPixel() const {return getBytesPerPixel()*8;}
    const(ubyte[]) getPalette() const;
    final bool hasPalette() const {return getPalette.length != 0;}
}

public interface IHipImageDecoder : IImageBase
{
    ///Use that for decoding from memory, returns wether decode was successful
    bool startDecoding(void[] data);
    
    static const(ubyte[4]) getPixel(){return cast(ubyte[4])[255,255,255,255];}
    ///Dispose the pixels
    void dispose();
}

//In progress?
public interface IHipPNGDecoder  : IHipImageDecoder{}
public interface IHipJPEGDecoder : IHipImageDecoder{}
public interface IHipWebPDecoder : IHipImageDecoder{}
public interface IHipBMPDecoder  : IHipImageDecoder{}
public interface IHipAnyImageDecoder : IHipPNGDecoder, IHipJPEGDecoder, IHipWebPDecoder, IHipBMPDecoder{}


public interface IImage : IImageBase
{
    string getName() const;
    void loadRaw(in ubyte[] pixels, int width, int height, ubyte bytesPerPixel);
    bool loadFromMemory(ubyte[] data);
    bool hasLoadedData() const;
    void[] convertPalettizedToRGBA() const;
    void[] monochromeToRGBA() const;
}
