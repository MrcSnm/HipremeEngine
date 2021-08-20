module implementations.audio.backend.sles;
import std.algorithm:count;
import opensles.sles;
version(Android)
{
    import opensles.android;
}

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
private SLresult[] sliErrorQueue;
private string[]   sliErrorMessages;
bool sliError(SLresult res)
{
    if(res != SL_RESULT_SUCCESS)
        sliErrorQueue~= res;
    return res != SL_RESULT_SUCCESS;
}

/**
*   Calls OpenSL ES function, checks if there was error, and append the message on the messagesqueue
* when an error occurs
*
*   Returns wether the call was okay
*/
private bool sliCall(SLresult opRes, string errMessage)
{
    if(sliError(opRes))
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


    static bool initializeForAndroid(ref SLIOutputMix output, ref SLEngineItf e)
    {
        //All those interfaces are supported on Android, so, require them
        const(SLInterfaceID)* ids = 
        [
            SL_IID_ENVIRONMENTALREVERB,
            SL_IID_PRESETREVERB,
            SL_IID_BASSBOOST,
            SL_IID_EQUALIZER,
            SL_IID_VIRTUALIZER
        ].ptr;
        const(SLboolean)* req = 
        [
            SL_BOOLEAN_TRUE,
            SL_BOOLEAN_TRUE,
            SL_BOOLEAN_TRUE,
            SL_BOOLEAN_TRUE,
            SL_BOOLEAN_TRUE //5
        ].ptr;

        with(output)
        {
            sliCall((*e).CreateOutputMix(e, &outputMixObj, 5, ids, req),
            "Could not create output mix");
            //Do it assyncly
            sliCall((*outputMixObj).Realize(outputMixObj, SL_BOOLEAN_FALSE),
            "Could not initialize output mix");

            
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
        return sliErrorQueue.length == 0;
    }
}


float sliToAttenuation(float gain)
{
    import std.math:log10;
    return (gain < 0.01f) ? -96.0f : 20 * log10(gain);
}

string getAudioPlayerInterfaces()
{
    string itfs = "SL_IID_VOLUME, SL_IID_EFFECTSEND, SL_IID_METADATAEXTRACTION";
    version(Android)
    {
        itfs~=", SL_IID_ANDROIDSIMPLEBUFFERQUEUE";
    }
    return itfs;
}
string getAudioPlayerRequirements()
{
    string req;
    bool isFirst = true;
    foreach (i; 0..getAudioPlayerInterfaces().count(",")+1)
    {
        if(isFirst)isFirst=!isFirst;
        else req~=",";
        req~= "SL_BOOLEAN_TRUE";
    }
    return req;
}

struct SLIAudioPlayer
{
    ///The Audio player
    SLObjectItf playerObj;
    ///Play/stop/pause the audio
    SLPlayItf player;
    ///Controls the volume
    SLVolumeItf playerVol;
    ///Ability to get and set the audio duration
    SLSeekItf playerSeek;
    ///@TODO
    SLEffectSendItf playerEffectSend;
    ///@TODO
    SLMetadataExtractionItf playerMetadata;

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

    static void destroyAudioPlayer(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            (*playerObj).Destroy(playerObj);
            playerObj = null;
            player = null;
            playerVol = null;
            playerSeek = null;
            playerEffectSend = null;
            version(Android){playerAndroidSimpleBufferQueue = null;}

        }
    }

    extern(C) static void checkClipEnd_Callback(SLPlayItf player, void* context, SLuint32 event)
    {
        if(event & SL_PLAYEVENT_HEADATEND)
        {
            SLIAudioPlayer p = *(cast(SLIAudioPlayer*)context);
            p.hasFinishedTrack = true;
        }
    }
    static void play(ref SLIAudioPlayer audioPlayer, void* samples, uint sampleSize)
    {
        with(audioPlayer)
        {
            version(Android){(*playerAndroidSimpleBufferQueue).Enqueue(playerAndroidSimpleBufferQueue, samples, sampleSize);}
            isPlaying = true;
            hasFinishedTrack = false;

            (*player).SetPlayState(player, SL_PLAYSTATE_PLAYING);
        }
    }
    static void stop(ref SLIAudioPlayer audioPlayer)
    {
        with(audioPlayer)
        {
            (*player).SetPlayState(player, SL_PLAYSTATE_STOPPED);
            version(Android){(*playerAndroidSimpleBufferQueue).Clear(playerAndroidSimpleBufferQueue);}
            isPlaying = false;
        }
    }

    static void checkFinishedPlaying(ref SLIAudioPlayer audioPlayer)
    {
        if(audioPlayer.isPlaying && audioPlayer.hasFinishedTrack)
        {
            SLIAudioPlayer.stop(audioPlayer);
        }
    }



    static bool initializeForAndroid(ref SLIAudioPlayer output, ref SLEngineItf engine, ref SLDataSource src, ref SLDataSink dest, bool autoRegisterCallback = true)
    {
        string[] errs;
        with(output)
        {
            mixin("const(SLInterfaceID)* ids = ["~getAudioPlayerInterfaces()~"].ptr;");
            mixin("const(SLboolean)* req = ["~getAudioPlayerRequirements()~"].ptr;");

            sliCall((*engine).CreateAudioPlayer(engine, &playerObj, &src, &dest,
            cast(uint)(getAudioPlayerInterfaces().count(",")+1), ids, req),
            "Could not create AudioPlayer");

            sliCall((*playerObj).Realize(playerObj, SL_BOOLEAN_FALSE),
            "Could not initialize AudioPlayer");


            sliCall((*playerObj).GetInterface(playerObj, SL_IID_PLAY, &player),
            "Could not get play interface for AudioPlayer");
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_VOLUME, &playerVol),
            "Could not get volume interface for AudioPlayer");
            
            // sliCall((*playerObj).GetInterface(playerObj, SL_IID_SEEK, &playerSeek),
            //("Could not get Seek interface for AudioPlayer");
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_EFFECTSEND, &playerEffectSend),
            "Could not get EffectSend interface for AudioPlayer");
            sliCall((*playerObj).GetInterface(playerObj, SL_IID_METADATAEXTRACTION, &playerMetadata),
            "Could not get MetadataExtraction interface for AudioPlayer");
            
            version(Android)
            {
                sliCall((*playerObj).GetInterface(playerObj, 
                SL_IID_ANDROIDSIMPLEBUFFERQUEUE, &playerAndroidSimpleBufferQueue),
                "Could not get AndroidSimpleBufferQueue for AudioPlayer");
            }
            if(autoRegisterCallback)
            {
                (*player).RegisterCallback(player, &SLIAudioPlayer.checkClipEnd_Callback, cast(void*)&output);
                (*player).SetCallbackEventsMask(player, SL_PLAYEVENT_HEADATEND);
            }
            return errs.length == 0;
        }
    }
}

/**
* Engine interface
*/
static SLObjectItf engineObject = null;
static SLEngineItf engine;

static SLIOutputMix outputMix;
static SLIAudioPlayer gAudioPlayer;
static short[8000] sawtoothBuffer;

static void loadSawtooth()
{
    for(uint i =0; i < 8000; ++i)
        sawtoothBuffer[i] = cast(short)(40_000 - ((i%100) * 220));
        
}

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

bool sliCreateOutputContext()
{
    sliCall(slCreateEngine(&engineObject,0,null,0,null,null),
    "Could not create engine");

    //Initialize|Realize the engine
    sliCall((*engineObject).Realize(engineObject, SL_BOOLEAN_FALSE),
    "Could not realize|initialize engine");
    

    //Get the interface for being able to create child objects from the engine
    sliCall((*engineObject).GetInterface(engineObject, SL_IID_ENGINE, &engine),
    "Could not get an interface for creating objects");

    loadSawtooth();

    version(Android)
    {
        SLIOutputMix.initializeForAndroid(outputMix, engine);
        SLDataLocator_AndroidSimpleBufferQueue locator;
        locator.locatorType = SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE;
        locator.numBuffers = 1;
    }
    else
    {
        SLDataLocator_Address locator;
        locator.locatorType = SL_DATALOCATOR_ADDRESS;
        locator.pAddress = sawtoothBuffer.ptr;
        locator.length = 8000*2;
    }
    //Okay
    SLDataFormat_PCM format;
    format.formatType = SL_DATAFORMAT_PCM;
    format.numChannels = 1;
    format.samplesPerSec =  SL_SAMPLINGRATE_8;
    format.bitsPerSample = SL_PCMSAMPLEFORMAT_FIXED_16;
    format.containerSize = SL_PCMSAMPLEFORMAT_FIXED_16;
    format.channelMask = SL_SPEAKER_FRONT_CENTER;
    format.endianness = SL_BYTEORDER_LITTLEENDIAN;

    

    //Okay
    SLDataSource src;
    src.pLocator = &locator;
    src.pFormat = &format;

    //Okay
    SLDataLocator_OutputMix locatorMix;
    locatorMix.locatorType = SL_DATALOCATOR_OUTPUTMIX;
    locatorMix.outputMix = outputMix.outputMixObj;

    //Okay
    SLDataSink destination;
    destination.pLocator = &locatorMix;
    destination.pFormat = null;

    SLIAudioPlayer.initializeForAndroid(gAudioPlayer, engine, src, destination);
    SLIAudioPlayer.play(gAudioPlayer, sawtoothBuffer.ptr, 8000);

    
    return sliErrorQueue.length == 0;
}


// pointer and size of the next player buffer to enqueue, and number of remaining buffers
static short *nextBuffer;
static uint nextSize;
static int nextCount;
// this callback handler is called every time a buffer finishes playing
extern(C)void bqPlayerCallback(SLAndroidSimpleBufferQueueItf bq, void *context)
{
    // for streaming playback, replace this test by logic to find and fill the next buffer
    if (--nextCount > 0 && null != nextBuffer && 0 != nextSize) {
        SLresult result;
        // enqueue another buffer
        result = (*bq).Enqueue(bq, nextBuffer, nextSize);
        // the most likely other result is SL_RESULT_BUFFER_INSUFFICIENT,
        // which for this code example would indicate a programming error
        // if (SL_RESULT_SUCCESS != result) {
        //     pthread_mutex_unlock(&audioEngineLock);
        // }
    } 
    // else {
    //     releaseResampleBuf();
    //     pthread_mutex_unlock(&audioEngineLock);
    // }
}