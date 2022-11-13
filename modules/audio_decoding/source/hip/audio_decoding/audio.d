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

T[][2] stereoToDualChannel(T)(T[] data)
{
    assert(data.length % 2 == 0, "Stereo to mono data must be divisible by 2");

    size_t len2 = cast(size_t)(data.length / 2);
    T[][2] ret = [new T[len2], new T[len2]];

    for(size_t i = 0; i < data.length; i++)
    {
        ret[i%2][cast(size_t)(i/2)] = data[i];
    }

    return ret;
}

T[] stereoToMono(T)(T[] data)
{
    assert(data.length % 2 == 0, "Stereo to mono data must be divisible by 2");
    T[] ret = new T[cast(size_t)(data.length / 2)];

    size_t retIdx = 0;
    for(size_t i = 0; i < data.length; i+= 2)
    {
        ret[retIdx++] = cast(T)(cast(float)((data[i] + data[i+1]) / 2));
    }

    return ret;
}

private struct _AudioStreamImpl
{
    void[] block;
    void initialize()
    {
        import audioformats;
        block = new void[AudioStream.sizeof];
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
        if(block != null)
        {
            AudioStream as = *(cast(AudioStream*)block); //Make it execute the destructor here
            destroy(block);
            block = null;
        }
    }
}

class HipAudioFormatsDecoder : IHipAudioDecoder
{
    ///This is where the compressed data will actually be stored and from where we get the decoded data
    private _AudioStreamImpl input;
    float sampleRate;
    int channels;
    protected float duration;
    protected ulong clipSize;

    ///Intermediary buffer where the decoded buffer will be put.
    protected float[] chunkBuffer;
    
    ///Probably this will be deprecated
    protected uint chunkSize;

    ///This can hold the entire audio buffer or only enough for playing
    float[] decodedBuffer;


    uint getSamplerate(){return cast(uint)sampleRate;}

    
    public bool loadData(in void[] data, HipAudioEncoding encoding, HipAudioType type, HipAudioClipHint hint)
    {
        if(hint.needsResample)
            return decodeAndResample(data, encoding, type, hint.outputSamplerate, hint.outputChannels);
        else
        {
            bool ret = decode(data, encoding, type);
            if(hint.outputChannels == 2 && channels == 1)
            {
                decodedBuffer = monoToStereo(decodedBuffer);
                clipSize*= 2;
            }
            else if(hint.outputChannels == 1 && channels == 2)
            {
                decodedBuffer = stereoToMono(decodedBuffer);
                clipSize/= 2;
            }
            return ret;
        }
    }
    

    /**
    *   Will completely decode all the data.
    *   Returns if the decode was successful.
    *   The decoded data can be retrieved by calling `getClipData()`
    */
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

        input.cleanUp();

        return decodeSuccesful;
    }
    uint startDecoding(in void[] data, void[] outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
    {
        input.openFromMemory(cast(ubyte[])data);
        channels = input.getNumChannels();
        sampleRate = input.getSamplerate();

        chunkSize = (chunkSize / channels) / float.sizeof;
        chunkBuffer = new float[chunkSize];
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
            framesRead = input.readSamplesFloat(chunkBuffer);
            assert(framesRead * channels * float.sizeof < outputDecodedData.length, "Out of boundaries decoding");
            if(framesRead != 0)
                memcpy(outputDecodedData.ptr + currentRead,
                chunkBuffer.ptr, framesRead * channels * float.sizeof);
            
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



    public bool decodeAndResample(in void[] data, HipAudioEncoding encoding, HipAudioType type, uint outputSampleRate, uint outputChannels)
    {
        bool ret = decode(data, encoding, type);
        if(ret && sampleRate != outputSampleRate)
        {
            auto resampler = new HipAllResample(
                getClipData(),
                cast(int)sampleRate, 
                cast(int)outputSampleRate, 
                channels, 
                1
            );


            float resampleRate = cast(float)outputSampleRate / cast(float)sampleRate;
            float[] resampledBuffer = new float[cast(ulong)(decodedBuffer.length * resampleRate)];
            resampledBuffer[] = 0;

            do{

                import std.stdio;
                writeln("Resampled!");
            }
            while(resampler.fillBuffer(resampledBuffer));

            decodedBuffer = resampledBuffer;
            clipSize = decodedBuffer.length * float.sizeof;
                import std.stdio;
            writeln("Converted from ",cast(int)sampleRate, "Hz to ", outputSampleRate, "Hz");

        }
        return ret;
    }
}


import hip.audio_decoding.resampler;
package class HipAllResample : ResamplingContext
{
    enum BYTES_PER_LOAD = 4096;

    int resampledSamples = 0;
    float[] decodedData;
    
    this(void[] decodedData, int inputSampleRate, int outputSampleRate, int inputChannels, int outputChannels)
    {
        super(new SampleControlFlags(), inputSampleRate, outputSampleRate, inputChannels, outputChannels);
        this.decodedData = cast(float[])decodedData;
    }
    override void loadMoreSamples()  @trusted
    {

        int toResample;
        ///Do it BYTES_PER_LOAD as step
        if(resampledSamples + BYTES_PER_LOAD <= decodedData.length )
            toResample = BYTES_PER_LOAD;
        else //If it overflows, clamp it to the minimum
            toResample = cast(int)(decodedData.length) - resampledSamples;


        resamplerDataLeft.dataIn = cast(float[])(decodedData[resampledSamples .. resampledSamples+toResample]);
        resamplerDataRight.dataIn = cast(float[])(decodedData[resampledSamples .. resampledSamples+toResample]);
        resampledSamples+= toResample;

    }
}