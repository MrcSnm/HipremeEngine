/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hipaudio.audiobuffer;
import std.path : baseName;
import data.hipfs;
import data.audio.audio;
import hipaudio.audio;
import hipaudio.backend.audiosource;

struct HipAudioStreamBuffer
{
    void* data;
    uint  size;
    bool  inUse;
}

/** 
 * Wraps a decoder onto it. Basically an easier interface with some more controls
 *  that would be needed inside specific APIs.
 */
public class HipAudioBuffer
{
    IHipAudioDecoder decoder;
    ///Unused for non streamed. It is the binary loaded from a file which will be decoded
    void[] dataToDecode;
    ///Unused for non streamed. Where the user will get its audio decoded.
    void* outBuffer;
    ///Unused for non streamed
    uint chunkSize;
    
    ulong totalDecoded = 0;

    HipAudioType type;
    HipAudioEncoding encoding;
    bool isStreamed = false;
    string fullPath;
    string fileName;

    this(IHipAudioDecoder decoder){this.decoder = decoder;}
    this(IHipAudioDecoder decoder, uint chunkSize)
    {
        import core.stdc.stdlib:malloc;
        this(decoder);
        this.chunkSize = chunkSize;
        outBuffer = malloc(chunkSize);
        assert(outBuffer != null, "Out of memory");
    }
    /**
    *   Should implement the specific loading here
    */
    public bool load(in void[] data, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        this.type = type;
        this.isStreamed = isStreamed;
        return decoder.startDecoding(data, encoding, type, isStreamed);
    }
    public uint updateStream()
    {
        uint dec = decoder.updateDecoding(dataToDecode, outBuffer, chunkSize,encoding);
        totalDecoded+= dec;
        return dec;
    }
    
    public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        dataToDecode = cast(void[])data;
        this.encoding = encoding;
        return updateStream();
    }
    public void* getBuffer()
    {
        if(isStreamed)
            return outBuffer;
        return decoder.getBuffer();
    }
    public ulong getBufferSize()
    {
        if(isStreamed)
            return totalDecoded;
        return decoder.getBufferSize();
    }
    public float getDuration(){return decoder.getDuration();}
    public final float getDecodedDuration()
    {
        import data.audio.audioconfig;
        AudioConfig cfg = decoder.getAudioConfig();
        import console.log;
        rawlog(cfg.getBitDepth, cfg.channels, cfg.sampleRate);
        return getBufferSize() / (cast(float) cfg.sampleRate);
    }
    ///Probably isStreamed does not makes any sense when reading entire file
    public final bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false)
    {
        void[] data;
        fullPath = audioPath;
        fileName = baseName(audioPath);
        HipFS.read(audioPath, data);
        return load(data, encoding, type, isStreamed);
    }
    public final uint loadStreamed(string audioPath, HipAudioEncoding encoding)
    {
        isStreamed = true;
        void[] data;
        fullPath = audioPath;
        fileName = baseName(audioPath);
        HipFS.read(audioPath, data);
        return loadStreamed(data, encoding);
    }
    public void unload()
    {
        import core.stdc.stdlib:free;
        decoder.dispose();
        if(outBuffer != null)
        {
            free(outBuffer);
            outBuffer = null;
        }
    }


}
