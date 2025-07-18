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
    const(ubyte[]) getPixels() const;
    ubyte getBytesPerPixel() const;
    final ushort getBitsPerPixel() const {return getBytesPerPixel()*8;}
    final size_t getSizeBytes() const{return getBytesPerPixel * getPixels.length;}
    const(ubyte[]) getPalette() const;
    final bool hasPalette() const {return getPalette.length != 0;}
}

public interface IHipImageDecoder : IImageBase
{
    ///Use that for decoding from memory, returns whether data was invalid.
    bool startDecoding(ubyte[] data, void delegate() onSuccess, void delegate() onFailure);
    
    static const(ubyte[4]) getPixel(){return cast(ubyte[4])[255,255,255,255];}
    ///Dispose the pixels
    void dispose();
}



public interface IImage : IImageBase
{
    string getName() const;
    ///loadRaw assumes that you already have the raw pixels to be put on CPU, so, there's no error checking.
    void loadRaw(in ubyte[] pixels, int width, int height, ubyte bytesPerPixel);
    /**
    *   loadMemory expects data to be decoded. This process is not
    *   instant on Web. A decision was made of putting successful and
    *   unsuccessful callbacks for that reason. Prefer using the onError callback
    *   rather than the bool return.
    */
    bool loadFromMemory(ubyte[] data, void delegate(IImage self) onSuccess, void delegate() onFailure);
    bool hasLoadedData() const;
    ubyte[] convertPalettizedToRGBA() const;
    ubyte[] monochromeToRGBA() const;
}
