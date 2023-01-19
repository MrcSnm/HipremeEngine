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
import hip.filesystem.hipfs;
import hip.error.handler;
import hip.audio_decoding.audio;
import hip.hipaudio.audio;
import hip.hipaudio.audiosource;
public import hip.api.audio.audioclip;

///Wraps an audio buffer by saving the specific API inside 
struct HipAudioBufferWrapper
{
    void[] buffer;
    uint  bufferSize;
    bool  isAvailable;

    bool opEquals(R)(const R other) const
    {
        import core.stdc.string:memcmp;
        static if(is(R == void*))
            return memcmp(other, buffer.ptr, bufferSize) == 0;
        else static if(is(R == void[]))
            return memcmp(other.ptr, buffer.ptr, bufferSize) == 0;
        else static if(is(R == HipAudioBufferWrapper))
            return memcmp(other.buffer, this.buffer, bufferSize) == 0;
        else
            return &this == other;
    }
}


union HipAudioBuffer
{
    version(Have_bindbc_openal)
    {
        import bindbc.openal;
        ALuint al;
    }
    version(Have_sles)
    {
        import opensles.sles;
        import hip.hipaudio.backend.sles;
        SLIBuffer* sles;
    }
    version(Windows) version(Have_directx_d)
    {
        import directx.xaudio2;
        XAUDIO2_BUFFER* xaudio;
    }
    version(WebAssembly)
    {
        import hip.hipaudio.backend.webaudio.clip;
        size_t webaudio;
    }
}

struct HipAudioBufferWrapper2
{
    HipAudioBuffer buffer;
    bool isAvailable;
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
    ubyte[] dataToDecode;
    ///Unused for non streamed. Where the user will get its audio decoded.
    ubyte[] outBuffer;
    ///Unused for non streamed
    uint chunkSize;


    HipAudioClipHint hint;

    /**
    *   Buffers recycled from HipAudioSource.
    *
    *   When source notifies that the buffer is free, it is added to
    *   that array. When getBuffer is called, it could send one
    *   of those recycleds.
    */ 
    private HipAudioBufferWrapper2[] buffersToRecycle;
    private HipAudioBufferWrapper2[] buffersCreated;
    
    size_t totalDecoded = 0;

    HipAudioType type;
    HipAudioEncoding encoding;
    bool isStreamed = false;
    string fullPath;
    string fileName;

    
    ///Event method called when the stream is updated
    protected abstract void  onUpdateStream(ubyte[] data, uint decodedSize);
    /**
    *   Always alocates a pointer to the buffer data. So, after getting its content. Send it to the
    *   recyclable buffers
    */
    protected abstract HipAudioBufferWrapper2 createBuffer(ubyte[] data);
    protected abstract void  destroyBuffer(HipAudioBuffer* buffer);
    
    /** The buffer is actually any kind of external API buffer, it is the buffer contained in
    *   HipAudioBufferWrapper.
    *
    *   OpenAL: `int` containing the buffer ID
    *   OpenSL ES: `SLIBuffer`
    *   XAudio2: To be thought?
    */
    public    abstract void  setBufferData(HipAudioBuffer* buffer, ubyte[] data, uint size);

    final immutable(HipAudioClipHint)* getHint(){return cast(immutable)&hint;}

    this(IHipAudioDecoder decoder, HipAudioClipHint hint){this.decoder = decoder; this.hint = hint;}
    this(IHipAudioDecoder decoder, HipAudioClipHint hint, uint chunkSize)
    in(chunkSize > 0, "Chunk must be greater than 0")
    {
        this(decoder, hint);
        this.chunkSize = chunkSize;
        outBuffer = new ubyte[chunkSize];
        ErrorHandler.assertExit(outBuffer != null, "Out of memory");
    }

    ///Probably isStreamed does not makes any sense when reading entire file
    public final bool load(string audioPath, HipAudioEncoding encoding, HipAudioType type, bool isStreamed = false,
    void delegate(in ubyte[]) onSuccess = null, void delegate() onFailure = null)
    {
        ubyte[] data;
        fullPath = audioPath;
        fileName = baseName(audioPath);
        return cast(bool)HipFS.read(audioPath, data).addOnError((err)
        {
            ErrorHandler.showWarningMessage("Could not load clip from path", audioPath);            
        }).addOnSuccess((in ubyte[] rawData)
        {
            load(cast(ubyte[])rawData, encoding, type, onSuccess, onFailure);
        });
    }

    /**
    *   Should implement the specific loading here
    */
    public bool load(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
    void delegate(in ubyte[]) onSuccess, void delegate() onFailure)
    {
        this.type = type;
        this.isStreamed = false;
        return decoder.loadData(data, encoding, type, hint, onSuccess, onFailure);
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
    package final HipAudioBufferWrapper2* findBuffer(HipAudioBuffer buf)
    {
        foreach(ref b; buffersCreated)
            if(b.buffer == buf)
                return &b;
        return null;
    }

    /**
    *   Attempts to get a buffer from the buffer recycler. 
    *   Used for when loadStreamed must set a buffer available
    */
    public    final    HipAudioBuffer pollFreeBuffer()
    {
        if(buffersToRecycle.length > 0)
        {
            HipAudioBufferWrapper2* w = &(buffersToRecycle[$ - 1]);
            buffersToRecycle.length--;
            w.isAvailable = false;
            return w.buffer;
        }
        return HipAudioBuffer.init;
    }
    
    public final HipAudioBuffer getBuffer(ubyte[] data, uint size)
    {
        HipAudioBuffer ret;
        if((ret = pollFreeBuffer()) != HipAudioBuffer.init)
        {
            setBufferData(&ret, data, size);
            return ret;
        }
        HipAudioBufferWrapper2 w = createBuffer(data);
        setBufferData(&w.buffer, data, size);
        ret = w.buffer;
        buffersCreated~=w;
        return ret;
    }
    
    package final void setBufferAvailable(HipAudioBuffer buffer)
    {
        HipAudioBufferWrapper2* w = findBuffer(buffer);
        ErrorHandler.assertExit(w != null, "AudioClip Error: No buffer was found when trying to set it available");
        buffersToRecycle~= *w;
        w.isAvailable = true;
    }

    /**
    *   Saves which data should be decoded and do 1 decoding frame
    */
    public uint loadStreamed(in ubyte[] data, HipAudioEncoding encoding)
    {
        dataToDecode = cast(ubyte[])data;
        this.encoding = encoding;
        ErrorHandler.assertExit(chunkSize > 0, "Can't update stream with 0 sized buffer.");
        uint dec = decoder.startDecoding(dataToDecode, outBuffer, chunkSize, encoding);
        totalDecoded+= dec;
        onUpdateStream(outBuffer, dec);
        return dec;
    }

    ///Returns the streambuffer if streamed, else, returns entire sound
    public ubyte[] getClipData()
    {
        if(isStreamed)
            return outBuffer;
        return decoder.getClipData();
    }
    ///Returns how much has been decoded
    public size_t getClipSize()
    {
        if(isStreamed)
            return totalDecoded;
        return decoder.getClipSize();
    }
    public float getDuration(){return decoder.getDuration();}
    public final uint getSampleRate(){return decoder.getSamplerate();}
    public final float getDecodedDuration()
    {
        AudioConfig cfg = decoder.getAudioConfig();
        import hip.console.log;
        rawlog(cfg.getBitDepth, cfg.channels, cfg.sampleRate);
        return getClipSize() / (cast(float) cfg.sampleRate);
    }
    
    public final uint loadStreamed(string audioPath, HipAudioEncoding encoding)
    {
        isStreamed = true;
        ubyte[] data;
        fullPath = audioPath;
        fileName = baseName(audioPath);

        if(!HipFS.read(audioPath, data))
        {
            import hip.error.handler;
            ErrorHandler.showWarningMessage("Could not load clip streamed from path", audioPath);
            return 0;
        }
        return loadStreamed(data, encoding);
    }

    public void unload()
    {
        decoder.dispose();
        foreach (ref b; buffersCreated)
            destroyBuffer(&b.buffer);
        buffersCreated.length = 0;
        if(outBuffer != null)
        {
            destroy(outBuffer);
            outBuffer = null;
        }
    }
}
