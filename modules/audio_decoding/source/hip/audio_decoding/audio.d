module hip.audio_decoding.audio;
import hip.audio_decoding.config;
public import hip.api.audio;
public import hip.api.data.audio;



private char* getNameFromEncoding(HipAudioEncoding encoding)
{
    final switch(encoding)
    {
        case HipAudioEncoding.FLAC:return cast(char*)"flac\0".ptr;
        case HipAudioEncoding.MIDI:return cast(char*)"midi\0".ptr;
        case HipAudioEncoding.MP3:return cast(char*)"mp3\0".ptr;
        case HipAudioEncoding.OGG:return cast(char*)"ogg\0".ptr;
        case HipAudioEncoding.WAV:return cast(char*)"wav\0".ptr;
    }
}



T* monoToStereo(T)(T* data, ulong framesLength)
{
    import core.stdc.stdlib;
    T* ret = cast(T*)malloc(framesLength*2 * T.sizeof);

    for(ulong i = 0; i < framesLength; i++)
    {
        ret[i*2]    = data[i];
        ret[i*2+1]  = data[i];
    }
    return ret;
}

T[] monoToStereo(T)(T[] data)
{
    T[] ret = new T[data.length*2];
    for(ulong i = 0; i < data.length; i++)
    {
        ret[i*2]    = data[i];
        ret[i*2+1]  = data[i];
    }
    return ret;
}

private struct _AudioStreamImpl
{
    void* block;
    void initialize()
    {
        import core.stdc.stdlib:malloc;
        import audioformats;
        block = malloc(AudioStream.sizeof);
    }

    void openFromMemory(in ubyte[] inputData)
    {
        if(block == null)
            initialize();
        import audioformats;
        (cast(AudioStream*)block).openFromMemory(inputData);
    }
    long getLengthInFrames()
    {
        import audioformats;
        return (cast(AudioStream*)block).getLengthInFrames();
    }
    int getNumChannels()
    {
        import audioformats;
        return (cast(AudioStream*)block).getNumChannels();
    }
    float getSamplerate()
    {
        import audioformats;
        return (cast(AudioStream*)block).getSamplerate();
    }
    int readSamplesFloat(float[] outputBuffer)
    {
        import audioformats;
        return (cast(AudioStream*)block).readSamplesFloat(outputBuffer);
    }
    void cleanUp()
    {
        import audioformats;
        import core.stdc.stdlib;
        AudioStream as = *(cast(AudioStream*)block); //Make it execute the destructor here
        free(block);
        block = null;
    }
}

class HipAudioFormatsDecoder : IHipAudioDecoder
{
    _AudioStreamImpl input;
    float sampleRate;
    int channels;
    float duration;
    ulong clipSize;
    uint chunkSize;

    float[] buffer;
    float[] decodedBuffer;


    bool decode(in void[] data, HipAudioEncoding encoding, HipAudioType type)
    {
        import audioformats : audiostreamUnknownLength;
        input.openFromMemory(cast(ubyte[])data);

        long lengthFrames = input.getLengthInFrames();
        channels = input.getNumChannels();
        sampleRate = input.getSamplerate();

        bool decodeSuccesful;

        if(lengthFrames == audiostreamUnknownLength)
        {
            uint bytesRead = 0;
        
            decodedBuffer.length = audioConfigDefaultBufferSize;
            void[] output = decodedBuffer;
            startDecoding(data, output, audioConfigDefaultBufferSize, encoding);
            while((bytesRead = updateDecoding(cast(void[])output)) != 0)
            {
                bytesRead/= float.sizeof;
                decodedBuffer.length+= bytesRead;
                output = decodedBuffer[$-bytesRead..$];
            }
            duration = (clipSize / channels) / sampleRate;
        }
        else
        {
            duration = lengthFrames/cast(double)sampleRate;
            decodedBuffer = new float[lengthFrames*channels];
            int bytesRead = input.readSamplesFloat(decodedBuffer);
            clipSize = decodedBuffer.length*float.sizeof;
            decodeSuccesful = bytesRead == lengthFrames;
        }
        if(decodeSuccesful)
        {
            if(channels == 1)
            {
                decodedBuffer = monoToStereo(decodedBuffer);
                clipSize+=clipSize;
            }
            // if(sampleRate != 44_100)
            // {
            //     decodedBuffer = resampleBuffer(decodedBuffer, sampleRate, 44_100);
            // }
        }

        input.cleanUp();

        return decodeSuccesful;
    }
    uint startDecoding(in void[] data, void[] outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    {
        input.openFromMemory(cast(ubyte[])data);
        channels = input.getNumChannels();
        sampleRate = input.getSamplerate();

        chunkSize = (chunkSize / channels) / float.sizeof;
        buffer = new float[chunkSize];
        this.chunkSize = chunkSize;
        
        return updateDecoding(outputDecodedData);
    }
    uint updateDecoding(void[] outputDecodedData)
    {
        import core.stdc.string:memcpy;
        int framesRead = 0;
        uint currentRead = 0;
        do
        {
            framesRead = input.readSamplesFloat(buffer);
            assert(framesRead * channels * float.sizeof < outputDecodedData.length, "Out of boundaries decoding");
            if(framesRead != 0)
                memcpy(outputDecodedData.ptr + currentRead,
                buffer.ptr, framesRead * channels * float.sizeof);
            
            currentRead += framesRead  * channels * float.sizeof;
        } while(framesRead > 0 && currentRead <= chunkSize);
        

        clipSize+= currentRead;
        return currentRead;
    }
    
    AudioConfig getAudioConfig(){return AudioConfig.init;}
    void[] getClipData(){return cast(void[])decodedBuffer;}
    ulong getClipSize(){return clipSize;}
    ///Don't apply to streamed audio. Gets the duration in seconds
    float getDuration(){return duration;}

    void dispose(){input.cleanUp();}


    public void testSRC(uint outputSampleRate, uint outputChannels)
    {
        import hip.audio_decoding.resampler;

        // new class ResamplingContext
        // {
        //     override void loadMoreSamples() 
        //     {
        //         float*[2] tmp;
        //         tmp[0] = buffersIn[0].ptr;
        //         tmp[1] = buffersIn[1].ptr;

        //         // loop:
        //         auto actuallyGot = updateDecoding(v.chans, tmp.ptr, cast(int) buffersIn[0].length);
        //         // if(actuallyGot == 0 && loop) {
        //         //     v.seekStart();
        //         //     scf.currentPosition = 0;
        //         //     goto loop;
        //         // }

        //         resamplerDataLeft.dataIn = buffersIn[0][0 .. actuallyGot];
        //         if(v.chans > 1)
        //             resamplerDataRight.dataIn = buffersIn[1][0 .. actuallyGot];
        //     }
        // }(new SampleControlFlags(), sampleRate, outputSampleRate, channels, outputChannels);
    }
}