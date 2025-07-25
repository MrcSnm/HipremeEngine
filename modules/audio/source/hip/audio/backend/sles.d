module hip.audio.backend.sles;
import hip.error.handler;
import hip.console.log;
import hip.util.conv:to;
import core.atomic;

version(Android):
import opensles.android;
import opensles.sles;
/**
*   OpenSL ES Debuggability
*/
package __gshared SLresult[] sliErrorQueue;
package __gshared string[]   sliErrorMessages;

///Packs engine interface, object and capabilities and give a cleaner interface for use
struct SLIEngine
{
    SLObjectItf engineObject = null;
    SLEngineItf engine;
    SLEngineCapabilitiesItf engineCapabilities;
    bool willUseFastMixer;

    void initialize()
    {
        SLEngineOption engineOptions = SLEngineOption(SL_ENGINEOPTION_THREADSAFE, SL_BOOLEAN_TRUE);
        sliCall(slCreateEngine(&engineObject,1,&engineOptions,0,null,null),
        "Could not create engine");

        //Initialize|Realize the engine
        sliCall((*engineObject).Realize(engineObject, SL_BOOLEAN_FALSE),
        "Could not realize|initialize engine");


        //Get the interface for being able to create child objects from the engine
        sliCall((*engineObject).GetInterface(engineObject, SL_IID_ENGINE, &engine),
        "Could not get an interface for creating objects");

        if(sliCall((*engineObject).GetInterface(engineObject, SL_IID_ENGINECAPABILITIES, &engineCapabilities),
        "Could not get engine capabilities"))
        {
            if(sliCall((*engineCapabilities).QueryAPIVersion(engineCapabilities, &engineMajor, &engineMinor, &enginePatch),
            "Could not query OpenSLES version"))
                rawlog("OpenSL Version: "~to!string(engineMajor)~"."~to!string(engineMinor)~"."~to!string(enginePatch));
            else if(sliErrorMessages.length == 1)
                sliClearErrors();
        }
        else if(sliErrorMessages.length == 1)
            sliClearErrors();
    }

    uint CreateOutputMix(const(const(SLObjectItf_)*)** outputMix, uint interfacesCount,
    const(const(SLInterfaceID_)*)* interfaces, const(uint)* requirements)
    {
        return (*engine).CreateOutputMix(engine, outputMix, interfacesCount, interfaces, requirements);
    }
    uint CreateAudioPlayer(SLObjectItf* audioPlayer, SLDataSource* source, SLDataSink* sink,
    uint interfacesCount, SLInterfaceID* interfaces, uint* requirements)
    {
        return (*engine).CreateAudioPlayer(engine, audioPlayer, source, sink, interfacesCount, interfaces, requirements);
    }

    void Destroy()
    {
        if(engineObject != null)
        {
            (*engineObject).Destroy(engineObject);
        }
    }
}

/**
*   Engine related objects
*/
package __gshared SLIEngine engine;
package __gshared short engineMajor = 1;
package __gshared short engineMinor = 0;
package __gshared short enginePatch = 1;

/**
*   Controls the output and the players
*/
package __gshared SLIOutputMix outputMix;
package __gshared SLIAudioPlayer*[] genPlayers;



string sliGetError(SLresult res)
{
    switch (res)
    {
        case SL_RESULT_SUCCESS: return "Success";
        case SL_RESULT_BUFFER_INSUFFICIENT: return "Buffer insufficient";
        case SL_RESULT_CONTENT_CORRUPTED: return "Content corrupted";
        case SL_RESULT_CONTENT_NOT_FOUND: return "Content not found";
        case SL_RESULT_CONTENT_UNSUPPORTED: return "Content unsupported";
        case SL_RESULT_CONTROL_LOST: return "Control lost";
        case SL_RESULT_FEATURE_UNSUPPORTED: return "Feature unsupported";
        case SL_RESULT_INTERNAL_ERROR: return "Internal error";
        case SL_RESULT_IO_ERROR: return "IO error";
        case SL_RESULT_MEMORY_FAILURE: return "Memory failure";
        case SL_RESULT_OPERATION_ABORTED: return "Operation aborted";
        case SL_RESULT_PARAMETER_INVALID: return "Parameter invalid";
        case SL_RESULT_PERMISSION_DENIED: return "Permission denied";
        case SL_RESULT_PRECONDITIONS_VIOLATED: return "Preconditions violated";
        case SL_RESULT_RESOURCE_ERROR: return "Resource error";
        case SL_RESULT_RESOURCE_LOST: return "Resource lost";
        case SL_RESULT_UNKNOWN_ERROR: return "Unknown error";
        default: return "Undefined error";
    }
}

package void sliClearErrors()
{
    sliErrorMessages.length = 0;
    sliErrorQueue.length = 0;
}


bool sliError(SLresult res, lazy string errMessage, string file = __FILE__, string func = __PRETTY_FUNCTION__,  uint line = __LINE__)
{
    if(res != SL_RESULT_SUCCESS)
    {
        sliErrorQueue~= res;
        rawerror("'OpenSL ES' Error: '"~sliGetError(res)~"' at file "~file~":"~to!string(line)~ " at "~func~"\n\t"~errMessage);
    }
    return res != SL_RESULT_SUCCESS;
}

/**
*   Calls OpenSL ES function, checks if there was error, and append the message on the messagesqueue
* when an error occurs
*
*   Returns wether the call was okay
*/
private bool sliCall(SLresult opRes, string errMessage,
string file = __FILE__, string func = __PRETTY_FUNCTION__,  uint line = __LINE__)
{
    if(sliError(opRes, errMessage, file, func, line))
    {
        sliErrorMessages~= errMessage;
        return false;
    }

    return true;
}


struct SLIOutputMix
{
    SLEnvironmentalReverbItf environmentReverb;
    SLPresetReverbItf presetReverb;
    SLBassBoostItf bassBoost;
    SLEqualizerItf equalizer;
    SLVirtualizerItf virtualizer;
    SLObjectItf outputMixObj;


    static bool initializeForAndroid(ref SLIOutputMix output, ref SLIEngine e, bool willUseFastMixer)
    {
        //All those interfaces are supported on Android, so, require them
        const(SLInterfaceID)* ids = null;
        const(SLboolean)* req = null;
        uint count = 0;

        if(!willUseFastMixer)
        {
            ids =
            [
                SL_IID_ENVIRONMENTALREVERB,
                SL_IID_PRESETREVERB,
                SL_IID_BASSBOOST,
                SL_IID_EQUALIZER,
                SL_IID_VIRTUALIZER
            ].ptr;

            req =
            [
                SL_BOOLEAN_TRUE,
                SL_BOOLEAN_TRUE,
                SL_BOOLEAN_TRUE,
                SL_BOOLEAN_TRUE,
                SL_BOOLEAN_TRUE //5
            ].ptr;
            count = 5;
        }

        with(output)
        {
            sliCall(e.CreateOutputMix(&outputMixObj, count, ids, req),
            "Could not create output mix");
            //Do it assyncly
            sliCall((*outputMixObj).Realize(outputMixObj, SL_BOOLEAN_FALSE),
            "Could not initialize output mix");


            if(!willUseFastMixer)
            {
                if(!sliCall((*outputMixObj).GetInterface(outputMixObj, SL_IID_ENVIRONMENTALREVERB, &environmentReverb),
                "Could not get the ENVIRONMENTALREVERB interface"))
                    environmentReverb = null;

                if(!sliCall((*outputMixObj).GetInterface(outputMixObj, SL_IID_PRESETREVERB, &presetReverb),
                "Could not get the PRESETREVERB interface"))
                    presetReverb = null;

                if(!sliCall((*outputMixObj).GetInterface(outputMixObj, SL_IID_BASSBOOST, &bassBoost),
                "Could not get the BASSBOOST interface"))
                    bassBoost = null;

                if(!sliCall((*outputMixObj).GetInterface(outputMixObj, SL_IID_EQUALIZER, &equalizer),
                "Could not get the EQUALIZER interface"))
                    equalizer = null;

                if(!sliCall((*outputMixObj).GetInterface(outputMixObj, SL_IID_VIRTUALIZER, &virtualizer),
                "Could not get the VIRTUALIZER interface"))
                    virtualizer = null;
            }
        }
        return sliErrorQueue.length == 0;
    }
}


float sliToAttenuation(float gain)
{
    import std.math:log10;
    return (gain < 0.01f) ? -96.0f : 20 * log10(gain);
}

const(SLInterfaceID)[] getAudioPlayerInterfaces(bool willUseFastMixer)
{
    const(SLInterfaceID)[] ret = [SL_IID_VOLUME, SL_IID_ANDROIDSIMPLEBUFFERQUEUE/*, SL_IID_MUTESOLO*/]; //can't require SL_IID_MUTESOLO with a mono buffer queue data source error
    if(!willUseFastMixer)
    {
        ret~= [
            SL_IID_BASSBOOST,
            SL_IID_EFFECTSEND,
            SL_IID_ENVIRONMENTALREVERB,
            SL_IID_EQUALIZER,
            SL_IID_PLAYBACKRATE,
            SL_IID_PRESETREVERB,
            SL_IID_VIRTUALIZER,
            SL_IID_ANDROIDEFFECT,
            SL_IID_ANDROIDEFFECTSEND,
            SL_IID_METADATAEXTRACTION
        ][];
    }
    return ret;
}
SLboolean[] getAudioPlayerRequirements(ref const(SLInterfaceID)[] itfs)
{
    SLboolean[] ret;
    foreach (const(SLInterfaceID) id; itfs)
        ret~= SL_BOOLEAN_TRUE;
    return ret;
}

string sliGetErrorMessages()
{
    string ret;
    for(int i = 0; i < sliErrorMessages.length;i++)
        ret~= sliGetError(sliErrorQueue[i])~": "~sliErrorMessages[i];

    sliErrorQueue.length = 0;
    sliErrorMessages.length = 0;
    return ret;
}

///Must be used as an opaque pointer
struct SLIBuffer
{
    size_t size;
    bool isLocked;
    bool hasBeenProcessed;
    ///Tightly packed structure
    void[0] data;
}

/**
*   Creates an unresizable buffer(tightly packed) for not getting a cache miss
*/
SLIBuffer* sliGenBuffer(void[] data, size_t size)
{
    import core.stdc.stdlib:malloc;
    import core.stdc.string:memcpy,memset;
    SLIBuffer* buf = cast(SLIBuffer*)malloc(SLIBuffer.sizeof+size);
    buf.size = size;
    buf.isLocked = false;
    buf.hasBeenProcessed = false;
    if(data == null)
        memset(buf.data.ptr, 0, size);
    else
        memcpy(buf.data.ptr, data.ptr, size);
    return buf;
}

///Copies data inside the buffer on its immutable size. Use that on unlocked buffers.
void sliBufferData(SLIBuffer* buffer, void[] data)
{
    import core.stdc.string:memcpy;
    ErrorHandler.assertExit(!buffer.isLocked, "Can't write to locked buffer");
    memcpy(buffer.data.ptr, data.ptr, buffer.size);
}

///Invalidates the buffer and makes it null
void sliDestroyBuffer(ref SLIBuffer* buff)
{
    import core.stdc.stdlib:free;
    if(buff != null)
        free(buff);
    buff = null;
}

__gshared struct SLIAudioPlayer
{
    ///The Audio player
    SLObjectItf playerObj;
    ///Play/stop/pause the audio
    SLPlayItf player;
    ///Controls the volume
    SLVolumeItf playerVol;
    ///Ability to get and set the audio duration
    SLSeekItf playerSeek;

    SLBassBoostItf bassBoost;
    SLEnvironmentalReverbItf envReverb;
    SLEqualizerItf equalizer;
    SLPlaybackRateItf playbackRate;
    SLPresetReverbItf presetReverb;
    SLVirtualizerItf virtualizer;
    SLAndroidEffectItf androidEffect;
    SLAndroidEffectSendItf androidEffectSend;

    ///TODO:
    SLEffectSendItf playerEffectSend;
    ///TODO:
    SLMetadataExtractionItf playerMetadata;

    struct EnqueuedBuffer
    {
        void* data;
        size_t size;
    }

    EnqueuedBuffer enqueued;

    /**
    *   This queue works as:

        In Use   Unqueued    Capacity
    |1, 2, 3, 4|  /5, 6\   (0, 0, 0, 0)
    */
    protected SLIBuffer** streamQueue;
    ///Data between | |
    protected ushort streamQueueLength;
    ///Data between / \
    protected ushort streamQueueFree;
    //Data between ( )
    protected ushort streamQueueCapacity;
    ///How many chunks have been streamed to that player
    protected ushort totalChunksEnqueued;
    ///How many chunks have been played
    protected ushort totalChunksPlayed;


    SLAndroidSimpleBufferQueueItf playerAndroidSimpleBufferQueue;
    SLIBuffer* nextBuffer;
    bool isPlaying, hasFinishedTrack, isLooping;

    float volume;

    void update()
    {
        if(nextBuffer != null)
        {
            //Need to clear queue, as having too many can cause a crash
            SLIAudioPlayer.Clear(this);
            //Set it playing
            SLIAudioPlayer.Enqueue(this, nextBuffer.data.ptr, nextBuffer.size);
            nextBuffer = null;
        }
        else if(hasFinishedTrack)
        {
            if(isLooping)
            {
                if(enqueued != EnqueuedBuffer.init)
                {
                    SLIAudioPlayer.stop(this);
                    SLIAudioPlayer.Enqueue(this, enqueued.data, enqueued.size);
                    SLIAudioPlayer.play(this);
                }
                else
                    loglnError("Tried to loop OpenSLES AudioPlayer, but there is no enqueued buffer");
            }
            else
            {
                // logln("STOPPED!");
                SLIAudioPlayer.stop(this);
            }
        }
    }

    static void setVolume(ref SLIAudioPlayer audioPlayer, float gain)
    {
        with(audioPlayer)
        {
            (*playerVol).SetVolumeLevel(playerVol, cast(SLmillibel)(sliToAttenuation(gain)*100));
            volume = gain;
        }
    }

    static void setRate(ref SLIAudioPlayer audioPlayer, float rate)
    {
        if(rate < 0.5 || rate > 2.0)
        {
            import hip.util.conv:to;
            ErrorHandler.showErrorMessage("Unsupported rate change on OpenSL ES.", "Max rate change is from 0.5 to 2.0, received "~rate.to!string);
        }
        short newRate = cast(short)(rate * 1000);
        with(audioPlayer)
        {
            sliCall((*playbackRate).SetRate(playbackRate, newRate), "Could not set playback rate");
        }
    }

    /**
    *   Also invalidates enqueued SLIBuffer, so, destroy with care
    */
    static void destroyAudioPlayer(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            (*playerObj).Destroy(playerObj);
            if(streamQueue != null)
            {
                for(int i = 0; i < streamQueueLength; i++)
                    sliDestroyBuffer(streamQueue[i]);
                streamQueue = null;
                streamQueueLength = 0;
            }
            playerObj = null;
            player = null;
            playerVol = null;
            playerSeek = null;
            playerEffectSend = null;
            playerAndroidSimpleBufferQueue = null;
        }
    }
    alias PlayerCallback = extern(C) void function(SLPlayItf player, void* context, SLuint32 event);

    void RegisterCallback(PlayerCallback callback, void* context)
    {
        (*player).RegisterCallback(player, callback, context);
    }
    void SetCallbackEventsMask(uint mask)
    {
        (*player).SetCallbackEventsMask(player, mask);
    }

    /**
    *   Checking some bug issues tracker:
    *   - https://groups.google.com/g/android-ndk/c/zANdS2n2cQI
    *
    *   - https://issuetracker.google.com/issues/37011991
    *
    *   It seems that you can't make any call to OpenSL API inside SL_PLAYEVENT_HEADATEND
    *
    *   I'm delegating it right now to the void update() method. As it seems, there is a little
    *   more music playing after SL_PLAYEVENT_HEADATEND(it is notified early).
    *
    *   It can cause some unsync in some other device, but that must be checked case-to-case.
    *
    *   Using ushort.max seems to be the way to go about how much it need to decode. ushort.max/4 caused some
    *   interruptions in music, while ushort.max/8 was inaudible (ushort.max is a great number, 65k)
    *
    *   It is also possible to bypass the need for a callback by calling GetState and checking if count == 0,
    *   that will mean that the head is at the end
    */
    extern(C) static void checkStreamCallback(SLPlayItf player, void* context, SLuint32 event)
    {
        if(event & SL_PLAYEVENT_HEADATEND)
        {
            import hip.console.log;
            SLIAudioPlayer* p = (cast(SLIAudioPlayer*)context);
            if(p.streamQueueLength > 0)
            {
                SLIBuffer* buf;
                if(p.totalChunksPlayed == 0)
                    buf = p.streamQueue[0];
                else
                {
                    p.unqueue(p.streamQueue[0]); //Unqueue the old buffer, thus, streamQueueLength--
                    if(p.streamQueueLength > 0)
                        buf = p.streamQueue[0];
                }
                if(buf != null)
                {
                    buf.isLocked = true;
                    p.totalChunksPlayed++;
                    p.nextBuffer = buf;
                }
            }
            else
            {
                import hip.console.log;
                logln("Finished track on AudioThread");
                p.hasFinishedTrack = true;
            }
        }
    }

    void pushBuffer(SLIBuffer* buffer)
    {
        import core.stdc.stdlib:malloc,realloc;

        totalChunksEnqueued++;
        streamQueueLength++;
        ushort totalSize = cast(ushort)(streamQueueLength + streamQueueFree);

        if(streamQueue == null)
            streamQueue = cast(SLIBuffer**)malloc((SLIBuffer*).sizeof * totalSize);
        else if(totalSize > streamQueueCapacity)
        {
            streamQueue = cast(SLIBuffer**)realloc(streamQueue, (SLIBuffer*).sizeof * totalSize);
            streamQueueCapacity = totalSize;
        }
        buffer.hasBeenProcessed = false;
        //Buffer is locked when playing
        streamQueue[streamQueueLength-1] = buffer;
    }

    /**
    * Gets a free buffer from the /\ list
    */
    SLIBuffer* getProcessedBuffer()
    {
        for(int i = streamQueueLength; i < streamQueueLength+streamQueueFree;i++)
        {
            if(!streamQueue[i].isLocked && streamQueue[i].hasBeenProcessed)
                return streamQueue[i];
        }
        return null;
    }
    /**
    *   Will remove the free buffer and set it as unused /b\ -> (0)
    *
    * - | | = Enqueued
    *
    * - / \ = Free
    *
    * - ( ) = Unused (capacity)
    */
    void removeFreeBuffer(SLIBuffer* freeBuffer)
    {
        ErrorHandler.assertExit(!freeBuffer.isLocked, "This buffer is being used right now");
        bool isReordering = false;
        for(int i = streamQueueLength; i < streamQueueLength+streamQueueFree;i++)
        {
            if(streamQueue[i] == freeBuffer)
                isReordering = true;
            if(isReordering && i+1 < streamQueueCapacity)
                streamQueue[i] = streamQueue[i+1];
        }
        streamQueueFree--;
        ErrorHandler.assertExit(isReordering, "OpenSL ES: Buffer sent to remove is not in queue");
    }
    int GetState()
    {
        SLAndroidSimpleBufferQueueState res;
        (*playerAndroidSimpleBufferQueue).GetState(playerAndroidSimpleBufferQueue, &res);

        return res.count; //If 0, nothing is playing
    }

    /**
    *   Same behavior from (*androidBufferQueue).Enqueue. If you wish to use queue
    *   for streaming sound, call pushBuffer
    */
    static void Enqueue(ref SLIAudioPlayer audioPlayer, void* samples, size_t sampleSize)
    {
        assert(sampleSize <= uint.max, "Probably something bad will happen with that size.");

        audioPlayer.enqueued = EnqueuedBuffer(samples, sampleSize);

        (*audioPlayer.playerAndroidSimpleBufferQueue)
            .Enqueue(audioPlayer.playerAndroidSimpleBufferQueue, samples, cast(uint)sampleSize);
    }
    static void Clear(ref SLIAudioPlayer audioPlayer)
    {
        (*audioPlayer.playerAndroidSimpleBufferQueue)
            .Clear(audioPlayer.playerAndroidSimpleBufferQueue);
    }

    /**
    *   Will put the processed buffer into the free list |b| -> /b\
    *
    * - | | = Enqueued
    *
    * - / \ = Free
    *
    * - ( ) = Unused (capacity)
    */
    void unqueue(SLIBuffer* processedBuffer)
    {
        bool isReordering = false;
        for(int i = 0; i < streamQueueLength;i++)
        {
            if(streamQueue[i] == processedBuffer)
                isReordering = true;
            if(isReordering && i+1 < streamQueueCapacity)
                streamQueue[i] = streamQueue[i+1];
        }
        processedBuffer.hasBeenProcessed = true;
        processedBuffer.isLocked = false;
        streamQueueLength--;
        streamQueue[streamQueueLength+streamQueueFree] = processedBuffer;
        streamQueueFree++;
        ErrorHandler.assertExit(isReordering, "SLES Error: buffer not found when trying to unqueue it");
    }

    static void resume(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            isPlaying = true;
            uint playState;
            (*player).GetPlayState(player, &playState);

            if(playState == SL_PLAYSTATE_PAUSED || playState == SL_PLAYSTATE_STOPPED)
                (*player).SetPlayState(player, SL_PLAYSTATE_PLAYING);
        }
    }

    static void play(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            SLIAudioPlayer.resume(audioPlayer);
            totalChunksEnqueued = 0;
            totalChunksPlayed = 0;
            hasFinishedTrack = false;
        }
    }
    static void stop(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            (*player).SetPlayState(player, SL_PLAYSTATE_STOPPED);
            SLIAudioPlayer.Clear(audioPlayer);
            isPlaying = false;
        }
    }

    static void pause(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            (*player).SetPlayState(player, SL_PLAYSTATE_PAUSED);
            isPlaying = false;
        }
    }

    static void seekClipPosition(ref SLIAudioPlayer audioPlayer, float posMillis, SLuint32 seekMode = SL_SEEKMODE_FAST)
    {
        with(audioPlayer)
        {
            (*playerSeek).SetPosition(playerSeek, cast(SLmillisecond)posMillis, seekMode);
        }
    }

    // static void setLoop(ref SLIAudioPlayer audioPlayer, bool shouldLoop, float loopStartMillis = 0, float loopEnd = -1)
    // {
    //     with(audioPlayer)
    //     {
    //         if(playerSeek is null)
    //             return;
    //         SLmillisecond end = cast(SLmillisecond)loopEnd;
    //         if(loopEnd <= 0)
    //             end = SL_TIME_UNKNOWN;
    //         (*playerSeek).SetLoop(playerSeek, shouldLoop, cast(SLmillisecond)loopStartMillis, end);
    //     }
    // }

    static void setLoop(ref SLIAudioPlayer audioPlayer, bool shouldLoop)
    {
        audioPlayer.isLooping = shouldLoop;
    }

}

/**
*   Returns null on failure.
*/
SLIAudioPlayer* sliGenAudioPlayer(SLDataSource src,SLDataSink dest, bool autoRegisterCallback = true)
{
    SLIAudioPlayer temp;
    bool willUseFastMixer = engine.willUseFastMixer;
    with(temp)
    {
        const(SLInterfaceID)[] ids = getAudioPlayerInterfaces(willUseFastMixer);
        SLboolean[] req = getAudioPlayerRequirements(ids);



        version(OpenSLES1) //Used for SDK < 21. But I won't support unless someone ask.
        {
            sliCall(engine.CreateAudioPlayer(&playerObj, &src, &dest,
            cast(uint)(ids.length), (cast(SLInterfaceID[])ids).ptr, req.ptr),
            "Could not create AudioPlayer with format: "~to!string(*(cast(SLDataFormat_PCM*)src.pFormat)));
        }
        else
        {
            sliCall(engine.CreateAudioPlayer(&playerObj, &src, &dest,
            cast(uint)(ids.length), (cast(SLInterfaceID[])ids).ptr, req.ptr),
            "Could not create AudioPlayer with format: "~to!string(*(cast(SLAndroidDataFormat_PCM_EX*)src.pFormat)));
        }

        sliCall((*playerObj).Realize(playerObj, SL_BOOLEAN_FALSE),
        "Could not initialize AudioPlayer");


        sliCall((*playerObj).GetInterface(playerObj, SL_IID_PLAY, &player),
        "Could not get play interface for AudioPlayer");
        sliCall((*playerObj).GetInterface(playerObj, SL_IID_VOLUME, &playerVol),
        "Could not get volume interface for AudioPlayer");


        if(!willUseFastMixer)
        {

            // sliCall((*playerObj).GetInterface(playerObj, SL_IID_SEEK, &playerSeek),
            // "Could not get Seek interface for AudioPlayer");

            //Metadata
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_METADATAEXTRACTION, &playerMetadata),
            "Could not get MetadataExtraction interface for AudioPlayer");

            //Misc
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_PLAYBACKRATE, &playbackRate),
            "Could not get PlaybackRate interface for AudioPlayer");
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_VIRTUALIZER, &virtualizer),
            "Could not get Virtualizer interface for AudioPlayer");

            //Wave amplitude modifiers
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_BASSBOOST, &bassBoost),
            "Could not get BassBoost interface for AudioPlayer");

            sliCall((*playerObj).GetInterface(playerObj, SL_IID_EQUALIZER, &equalizer),
            "Could not get Equalizer interface for AudioPlayer");

            //Reverb
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_ENVIRONMENTALREVERB, &envReverb),
            "Could not get EnvironmentalReverb interface for AudioPlayer");
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_PRESETREVERB, &presetReverb),
            "Could not get PresetReverb interface for AudioPlayer");

            //Effect
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_EFFECTSEND, &playerEffectSend),
            "Could not get EffectSend interface for AudioPlayer");
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_ANDROIDEFFECT, &androidEffect),
            "Could not get AndroidEffect interface for AudioPlayer");


            sliCall((*playerObj).GetInterface(playerObj, SL_IID_ANDROIDEFFECTSEND, &androidEffectSend),
            "Could not get AndroidEffectSend interface for AudioPlayer");
        }

        version(Android)
        {
            sliCall((*playerObj).GetInterface(playerObj,
            SL_IID_ANDROIDSIMPLEBUFFERQUEUE, &playerAndroidSimpleBufferQueue),
            "Could not get AndroidSimpleBufferQueue for AudioPlayer");
        }
    }
    if(sliErrorMessages.length == 0)
    {
        SLIAudioPlayer* playerOut = new SLIAudioPlayer();
        *playerOut = temp;
        if(autoRegisterCallback)
        {
            temp.RegisterCallback(&SLIAudioPlayer.checkStreamCallback, cast(void*)playerOut);
            temp.SetCallbackEventsMask(SL_PLAYEVENT_HEADATEND);
        }
        genPlayers~= playerOut;
        return playerOut;
    }
    return null;
}

void sliDestroyContext()
{
    import core.stdc.stdlib;
    engine.Destroy();
    with(outputMix) (*outputMixObj).Destroy(outputMixObj);

    foreach(ref gp; genPlayers)
    {
        SLIAudioPlayer.destroyAudioPlayer(*gp);
        destroy(gp);
        gp = null;
    }
}



bool sliCreateOutputContext(
    bool hasProAudio=false,
    bool hasLowLatencyAudio=false,
    int  optimalBufferSize=4096,
    int  optimalSampleRate=44_100,
    bool willUseFastMixer = false
)
{
    engine = SLIEngine(null,null,null, willUseFastMixer);
    engine.initialize();

    // loadSawtooth();

    SLIOutputMix.initializeForAndroid(outputMix, engine, willUseFastMixer);
    // SLIAudioPlayer.initializeForAndroid(gAudioPlayer, engine, src, destination);

    return sliErrorQueue.length == 0;
}