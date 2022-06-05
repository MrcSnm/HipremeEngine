/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hipaudio.audioclip;
import hip.util.path : baseName;
import hip.data.hipfs;
import hip.error.handler;
import hip.data.audio.audio;
import hip.hipaudio.audio;
import hip.hipaudio.audiosource;
public import hip.hipengine.api.audio.audioclip;

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
        else static if(is(R == HipAudioBufferWrapper))
            return memcmp(other.buffer, this.buffer, bufferSize) == 0;
        else
            return &this == other;
    }
}

/** 
* Wraps a decoder onto it. Basically an easier interface with some more controls
*  that would be needed inside specific APIs.
*
*   AudioClip flow basically consists in: 
*   1. Initialize the audio clip with the current decoder.
*   2. Call `.load`, which calls `.decode`
*   3. HipAudioSource calls `.setClip`, which should call `clip.getBuffer`, which gets the buffer
*   wrapped by the current implementation `createBuffer`, and then the buffer is enqueued.
*/
public abstract class HipAudioClip : IHipAudioClip
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
        return decoder.decode(data, encoding, type);
    }
    /**
    *   Decodes a bit more of the current buffer
    */
    public final uint updateStream()
    {
        ErrorHandler.assertExit(chunkSize > 0, "Can't update stream with 0 sized buffer.");
        uint dec = decoder.updateDecoding(outBuffer);
        totalDecoded+= dec;
        onUpdateStream(outBuffer, dec);
        return dec;
    }

    ///Event method called when the stream is updated
    protected abstract void  onUpdateStream(void* data, uint decodedSize);
    /**
    *   Always alocates a pointer to the buffer data. So, after getting its content. Send it to the
    *   recyclable buffers
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

    /** The buffer is actually any kind of external API buffer, it is the buffer contained in
    *   HipAudioBufferWrapper.
    *
    *   OpenAL: `int` containing the buffer ID
    *   OpenSL ES: `SLIBuffer`
    *   XAudio2: To be thought?
    */
    public    abstract void  setBufferData(void* buffer, uint size, void* data);
    /**
    *   Attempts to get a buffer from the buffer recycler. 
    *   Used for when loadStreamed must set a buffer available
    */
    public    final    void* pollFreeBuffer()
    {
        if(buffersToRecycle.length > 0)
        {
            import hip.console.log;
            logln(buffersToRecycle.length);
            HipAudioBufferWrapper* w = &(buffersToRecycle[buffersToRecycle.length - 1]);
            buffersToRecycle.length--;
            w.isAvailable = false;
            return w.buffer;
        }
        return null;
    }
    public final void* getBuffer(void* data, uint size)
    {
        void* ret;
        if(buffersToRecycle.length > 0)
        {
            HipAudioBufferWrapper* w = &(buffersToRecycle[buffersToRecycle.length-1]);
            buffersToRecycle.length--;
            w.isAvailable = false;
            setBufferData(w.buffer, size, data);
            ret = w.buffer;
            return ret;
        }
        HipAudioBufferWrapper w = createBuffer(data, size);
        setBufferData(w.buffer, size, data);
        ret = w.buffer;
        buffersCreated~=w;
        return ret;
    }
    package final void setBufferAvailable(void* buffer)
    {
        HipAudioBufferWrapper* w = findBuffer(buffer);
        ErrorHandler.assertExit(w != null, "AudioClip Error: No buffer was found when trying to set it available");
        buffersToRecycle~= *w;
        w.isAvailable = true;
    }

    /**
    *   Saves which data should be decoded and do 1 decoding frame
    */
    public uint loadStreamed(in void[] data, HipAudioEncoding encoding)
    {
        dataToDecode = cast(void[])data;
        this.encoding = encoding;
        ErrorHandler.assertExit(chunkSize > 0, "Can't update stream with 0 sized buffer.");
        uint dec = decoder.startDecoding(dataToDecode, outBuffer, chunkSize, encoding);
        totalDecoded+= dec;
        onUpdateStream(outBuffer, dec);
        return dec;
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
        import hip.data.audio.audioconfig;
        AudioConfig cfg = decoder.getAudioConfig();
        import hip.console.log;
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
