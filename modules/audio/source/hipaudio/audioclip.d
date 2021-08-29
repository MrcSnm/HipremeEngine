/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hipaudio.audioclip;
import std.path : baseName;
import data.hipfs;
import error.handler;
import data.audio.audio;
import hipaudio.audio;
import hipaudio.backend.audiosource;

///Wraps an audio buffer by saving the specific API inside 
struct HipAudioBufferWrapper
{
    void* buffer;
    uint  bufferSize;
    bool  isAvailable;

    bool opEquals(R)(const R other) const
    {
        import core.stdc.string:memcmp;
        static if(is(R == void*))
            return memcmp(other, buffer, bufferSize) == 0;
        else static if(is(R == typeof(this)))
            return memcmp(other.buffer, this.buffer, bufferSize) == 0;
        else
            return &this == other;
    }
}

/** 
 * Wraps a decoder onto it. Basically an easier interface with some more controls
 *  that would be needed inside specific APIs.
 */
public abstract class HipAudioClip
{
    IHipAudioDecoder decoder;
    ///Unused for non streamed. It is the binary loaded from a file which will be decoded
    void[] dataToDecode;
    ///Unused for non streamed. Where the user will get its audio decoded.
    void* outBuffer;
    ///Unused for non streamed
    uint chunkSize;

    /**
    *   Buffers recycled from HipAudioSource.
    *
    *   When source notifies that the buffer is free, it is added to
    *   that array. When getBuffer is called, it could send one
    *   of those recycleds.
    */ 
    private HipAudioBufferWrapper[] buffersToRecycle;
    private HipAudioBufferWrapper[] buffersCreated;
    
    ulong totalDecoded = 0;

    HipAudioType type;
    HipAudioEncoding encoding;
    bool isStreamed = false;
    string fullPath;
    string fileName;

    this(IHipAudioDecoder decoder){this.decoder = decoder;}
    this(IHipAudioDecoder decoder, uint chunkSize)
    in(chunkSize > 0, "Chunk must be greater than 0")
    {
        import core.stdc.stdlib:malloc;
        this(decoder);
        this.chunkSize = chunkSize;
        outBuffer = malloc(chunkSize);
        ErrorHandler.assertExit(outBuffer != null, "Out of memory");
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
    /**
    *   Decodes a bit more of the current buffer
    */
    public final uint updateStream()
    {
        ErrorHandler.assertExit(chunkSize > 0, "Can't update stream with 0 sized buffer.");
        uint dec = decoder.updateDecoding(dataToDecode, outBuffer, chunkSize,encoding);
        totalDecoded+= dec;
        onUpdateStream(outBuffer, dec);
        return dec;
    }

    ///Event method called when the stream is updated
    protected abstract void  onUpdateStream(void* data, uint decodedSize);
    /**
    *   Always alocates a pointer to the buffer data. So, after getting its content. Free the pointer
    */
    protected abstract HipAudioBufferWrapper createBuffer(void* data, uint size);
    protected abstract void  destroyBuffer(void* buffer);
    package final HipAudioBufferWrapper* findBuffer(void* buf)
    {
        foreach(ref b; buffersCreated)
            if(b == buf)
                return &b;
        return null;
    }
    public    abstract void  setBufferData(void* buffer, uint size, void* data);
    public    final    void* getBuffer(void* data, uint size)
    {
        void* ret;
        if(buffersToRecycle.length > 0)
        {
            HipAudioBufferWrapper* w = &buffersToRecycle[--buffersToRecycle.length];
            w.isAvailable = false;
            setBufferData(w.buffer, size, data);
            ret = w.buffer;
            return ret;
        }
        HipAudioBufferWrapper w = createBuffer(data, size);
        ret = w.buffer;
        buffersCreated~=w;
        return ret;
    }
    package final void setBufferAvailable(void* buffer)
    {
        HipAudioBufferWrapper* w = findBuffer(buffer);
        ErrorHandler.assertExit(w != null, "AudioClip Error: No buffer was found when trying to set it available");
        w.isAvailable = true;
    }

    /**
    *   Saves which data should be decoded and do 1 decoding frame
    */
    public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        dataToDecode = cast(void[])data;
        this.encoding = encoding;
        return updateStream();
    }
    ///Returns the streambuffer if streamed, else, returns entire sound
    public void* getClipData()
    {
        if(isStreamed)
            return outBuffer;
        return decoder.getClipData();
    }
    ///Returns how much has been decoded
    public ulong getClipSize()
    {
        if(isStreamed)
            return totalDecoded;
        return decoder.getClipSize();
    }
    public float getDuration(){return decoder.getDuration();}
    public final float getDecodedDuration()
    {
        import data.audio.audioconfig;
        AudioConfig cfg = decoder.getAudioConfig();
        import console.log;
        rawlog(cfg.getBitDepth, cfg.channels, cfg.sampleRate);
        return getClipSize() / (cast(float) cfg.sampleRate);
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
        foreach (b; buffersCreated)
            destroyBuffer(b.buffer);
        buffersCreated.length = 0;
        if(outBuffer != null)
        {
            free(outBuffer);
            outBuffer = null;
        }
    }


}
