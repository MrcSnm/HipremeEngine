module hipaudio.backend.sles;
import error.handler;
import console.log;
import std.conv:to;
import std.format:format;
import core.sync.mutex;
import core.atomic;
import std.algorithm:count;
import opensles.sles;
version(Android)
{
    import opensles.android;
}
version(Android):
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
        sliCall(slCreateEngine(&engineObject,0,null,0,null,null),
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
                rawlog(format!"OpenSL Version: %s.%s.%s"(engineMajor, engineMinor, enginePatch));
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
package __gshared Mutex mtx;



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
        rawerror(format!("'OpenSL ES' Error: '%s' at file %s:%s at %s\n\t%s")(sliGetError(res), file, line, func, errMessage));
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

SLInterfaceID[] getAudioPlayerInterfaces(bool willUseFastMixer)
{
    SLInterfaceID[] ret = [SL_IID_VOLUME/*, SL_IID_MUTESOLO*/]; //can't require SL_IID_MUTESOLO with a mono buffer queue data source error
    if(!willUseFastMixer)
    {
        ret~= [SL_IID_BASSBOOST, SL_IID_EFFECTSEND, SL_IID_ENVIRONMENTALREVERB, SL_IID_EQUALIZER,
        SL_IID_PLAYBACKRATE, SL_IID_PRESETREVERB, SL_IID_VIRTUALIZER, SL_IID_ANDROIDEFFECT,
        SL_IID_ANDROIDEFFECTSEND, SL_IID_METADATAEXTRACTION][];
    }
    version(Android)
        ret~= SL_IID_ANDROIDSIMPLEBUFFERQUEUE;
    return ret;
}
SLboolean[] getAudioPlayerRequirements(ref SLInterfaceID[] itfs)
{
    SLboolean[] ret;
    foreach (SLInterfaceID id; itfs)
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
    uint size;
    bool isLocked;
    bool hasBeenProcessed;
    ///Tightly packed structure
    void[0] data;
}

/**
*   Creates an unresizable buffer(tightly packed) for not getting a cache miss
*/
SLIBuffer* sliGenBuffer(void* data, uint size)
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
        memcpy(buf.data.ptr, data, size);
    return buf;
}

///Copies data inside the buffer on its immutable size. Use that on unlocked buffers.
void sliBufferData(SLIBuffer* buffer, void* data)
{
    import core.stdc.string:memcpy;
    ErrorHandler.assertExit(!buffer.isLocked, "Can't write to locked buffer");
    memcpy(buffer.data.ptr, data, buffer.size);
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

    ///@TODO
    SLEffectSendItf playerEffectSend;
    ///@TODO
    SLMetadataExtractionItf playerMetadata;

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


    version(Android){SLAndroidSimpleBufferQueueItf playerAndroidSimpleBufferQueue;}
    else  //Those lines will appear just as a documentation, right now, we don't have any implementation using it
    {
        ///@NO_SUPPORT
        SL3DSourceItf source3D;
        SL3DDopplerItf doppler3D;
        SL3DLocationItf location3D;
    }
    bool isPlaying, hasFinishedTrack;

    float volume;

    static void setVolume(ref SLIAudioPlayer audioPlayer, float gain)
    {
        with(audioPlayer)
        {
            (*playerVol).SetVolumeLevel(playerVol, cast(SLmillibel)(sliToAttenuation(gain)*100));
            volume = gain;
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
            version(Android){playerAndroidSimpleBufferQueue = null;}
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

    extern(C) static void checkStreamCallback(SLPlayItf player, void* context, SLuint32 event)
    {
        if(event & SL_PLAYEVENT_HEADATEND)
        {
            import console.log;
            SLIAudioPlayer* p = (cast(SLIAudioPlayer*)context);
            if(p.streamQueueLength > 0)
            {
                SLIBuffer* buf;
                if(p.totalChunksPlayed == 0)
                {
                    buf = p.streamQueue[0];
                    logln("Using the first in queue");
                }
                else
                {
                    logln("Removing the last in the queue");
                    p.unqueue(p.streamQueue[0]); //Unqueue the old buffer, thus, streamQueueLength--
                    if(p.streamQueueLength > 0)
                    {
                        buf = p.streamQueue[0];
                        logln("Using the next in the queue");
                    }
                }
                if(buf != null)
                {
                    buf.isLocked = true;
                    logln("Next:", *buf);
                    p.totalChunksPlayed++;
                    SLIAudioPlayer.Enqueue(*p, buf.data.ptr, buf.size);
                    SLIAudioPlayer.stop(*p);
                    SLIAudioPlayer.play(*p);
                }
            }
            else
                p.hasFinishedTrack = true;
        }
    }

    void pushBuffer(SLIBuffer* buffer)
    {
        import core.stdc.stdlib:malloc,realloc;
        // mtx.lock();

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
        // mtx.unlock();
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

    /**
    *   Same behavior from (*androidBufferQueue).Enqueue. If you wish to use queue
    *   for streaming sound, call pushBuffer
    */
    static void Enqueue(ref SLIAudioPlayer audioPlayer, void* samples, uint sampleSize)
    {
        version(Android)
        {
            (*audioPlayer.playerAndroidSimpleBufferQueue)
                .Enqueue(audioPlayer.playerAndroidSimpleBufferQueue, samples, sampleSize);
        }
    }
    static void Clear(ref SLIAudioPlayer audioPlayer)
    {
        version(Android)
        {
            (*audioPlayer.playerAndroidSimpleBufferQueue)
                .Clear(audioPlayer.playerAndroidSimpleBufferQueue);
        }
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
    
}

/**
*   Returns null on failure.
*/
SLIAudioPlayer* sliGenAudioPlayer(SLDataSource src,SLDataSink dest, bool autoRegisterCallback = true)
{
    import core.stdc.stdlib:malloc;
    SLIAudioPlayer temp;
    bool willUseFastMixer = engine.willUseFastMixer;
    with(temp)
    {
        SLInterfaceID[] ids = getAudioPlayerInterfaces(willUseFastMixer);
        SLboolean[] req = getAudioPlayerRequirements(ids);

        sliCall(engine.CreateAudioPlayer(&playerObj, &src, &dest,
        cast(uint)(ids.length), ids.ptr, req.ptr),
        "Could not create AudioPlayer with format: "~to!string(*(cast(SLDataFormat_PCM*)src.pFormat)));

        sliCall((*playerObj).Realize(playerObj, SL_BOOLEAN_FALSE),
        "Could not initialize AudioPlayer");


        sliCall((*playerObj).GetInterface(playerObj, SL_IID_PLAY, &player),
        "Could not get play interface for AudioPlayer");
        sliCall((*playerObj).GetInterface(playerObj, SL_IID_VOLUME, &playerVol),
        "Could not get volume interface for AudioPlayer");
        

        if(!willUseFastMixer)
        {
            // sliCall((*playerObj).GetInterface(playerObj, SL_IID_SEEK, &playerSeek),
            //("Could not get Seek interface for AudioPlayer");

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
        SLIAudioPlayer* playerOut = cast(SLIAudioPlayer*)malloc(SLIAudioPlayer.sizeof);
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
        free(gp);
        gp = null;
    }
}


// __gshared short[8000] sawtoothBuffer;

// static void loadSawtooth()
// {
//     for(uint i =0; i < 8000; ++i)
//         sawtoothBuffer[i] = cast(short)(40_000 - ((i%100) * 220));
        
// }

version(Android){alias SLIDataLocator_Address = SLDataLocator_AndroidSimpleBufferQueue;}
else{alias SLIDataLocator_Address = SLDataLocator_Address;}


// SLIDataLocator_Address sliGetAddressDataLocator()
// {
//     SLIDataLocator_Address ret;
//     version(Android)
//     {
//         ret.locatorType = SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE;
//         ret.numBuffers = 1;
//     }
//     else
//     {
//         ret.locatorType = SL_DATALOCATOR_ADDRESS;
//         ret.pAddress = 
//     }
// }

// static BufferQueuePlayer bq;

bool sliCreateOutputContext(
    bool hasProAudio=false,
    bool hasLowLatencyAudio=false,
    int  optimalBufferSize=44_100,
    int  optimalSampleRate=4096,
    bool willUseFastMixer = false
)
{
    engine = SLIEngine(null,null,null, willUseFastMixer);
    engine.initialize();
    mtx = new Mutex();

    // loadSawtooth();

    version(Android)
        SLIOutputMix.initializeForAndroid(outputMix, engine, willUseFastMixer);
    // SLIAudioPlayer.initializeForAndroid(gAudioPlayer, engine, src, destination);
    
    return sliErrorQueue.length == 0;
}


// pointer and size of the next player buffer to enqueue, and number of remaining buffers
static short *nextBuffer;
static uint nextSize;
static int nextCount;
// this callback handler is called every time a buffer finishes playing
// extern(C)void bqPlayerCallback(SLAndroidSimpleBufferQueueItf bq, void *context)
// {
//     // for streaming playback, replace this test by logic to find and fill the next buffer
//     if (--nextCount > 0 && null != nextBuffer && 0 != nextSize) {
//         SLresult result;
//         // enqueue another buffer
//         result = (*bq).Enqueue(bq, nextBuffer, nextSize);
//         // the most likely other result is SL_RESULT_BUFFER_INSUFFICIENT,
//         // which for this code example would indicate a programming error
//         // if (SL_RESULT_SUCCESS != result) {
//         //     pthread_mutex_unlock(&audioEngineLock);
//         // }
//     } 
//     // else {
//     //     releaseResampleBuf();
//     //     pthread_mutex_unlock(&audioEngineLock);
//     // }
// }