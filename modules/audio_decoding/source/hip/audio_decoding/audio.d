module hip.audio_decoding.audio;
public import hip.api.audio : HipAudioType;
public import hip.api.data.audio;



private const(char)* getNameFromEncoding(HipAudioEncoding encoding)
{
    final switch(encoding) with(HipAudioEncoding)
    {
        case MOD: return "mod";
        case XM: return "xm";
        case FLAC:return "flac";
        case MIDI:return "midi";
        case MP3:return "mp3";
        case OGG:return "ogg";
        case WAV:return "wav";
    }
}



T[] monoToStereo(T)(T[] data)
{
    T[] ret = new T[data.length*2];
    for(size_t i = 0; i < data.length; i++)
    {
        ret[i*2]    = data[i];
        ret[i*2+1]  = data[i];
    }
    return ret;
}

T[][2] stereoToMonoSplit(T)(T[] data)
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

private abstract class AHipAudioDecoder : IHipAudioDecoder
{
    float sampleRate;
    int channels;
    protected float duration;
    protected size_t clipSize;
    ubyte getClipChannels(){return cast(ubyte)channels;}
    size_t getClipSize(){return clipSize;}
    float getDuration(){return duration;}
    uint getSamplerate(){return cast(uint)sampleRate;}
    AudioConfig getAudioConfig(){return AudioConfig(getSamplerate, AudioFormat.init, getClipChannels, cast(int)getClipSize);}
    bool resample(in ubyte[] data, HipAudioType type, uint outputSampleRate, uint outputChannels){return false;}
    bool channelConversion(in ubyte[] data, ubyte from, ubyte to){return false;}
}


version(AudioFormatsDecoder)
{
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
            if(block != null)
            {
                AudioStream as = *(cast(AudioStream*)block); //Make it execute the destructor here
                destroy(block);
                block = null;
            }
        }
    }

    class HipAudioFormatsDecoder : AHipAudioDecoder
    {
        ///This is where the compressed data will actually be stored and from where we get the decoded data
        private _AudioStreamImpl input;
        

        ///Intermediary buffer where the decoded buffer will be put.
        protected float[] chunkBuffer;
        
        ///Probably this will be deprecated
        protected uint chunkSize;

        ///This can hold the entire audio buffer or only enough for playing
        float[] decodedBuffer;


        /**
        *   Will completely decode all the data.
        *   Returns if the decode was successful.
        *   The decoded data can be retrieved by calling `getClipData()`
        */
        bool decode(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
        void delegate(in ubyte[]) onSuccess, void delegate() onFailure)
        {
            import audioformats : audiostreamUnknownLength;
            input.openFromMemory(cast(ubyte[])data);

            long lengthFrames = input.getLengthInFrames();
            channels = input.getNumChannels();
            sampleRate = input.getSamplerate();

            bool decodeSuccesful;

            if(lengthFrames == audiostreamUnknownLength) ///? Streamed audio
            {
                uint bytesRead = 0;
            
                decodedBuffer.length = audioConfigDefaultBufferSize;
                ubyte[] output = cast(ubyte[])decodedBuffer;
                startDecoding(data, output, audioConfigDefaultBufferSize, encoding);
                while((bytesRead = updateDecoding(output)) != 0)
                {
                    bytesRead/= float.sizeof;
                    decodedBuffer.length+= bytesRead;
                    output = cast(ubyte[])decodedBuffer[$-bytesRead..$];
                }
                duration = (clipSize / channels) / sampleRate;
            }
            else
            {
                duration = lengthFrames/cast(double)sampleRate;
                size_t bufferSize = cast(size_t)(lengthFrames*channels);
                decodedBuffer = new float[bufferSize];
                int bytesRead = input.readSamplesFloat(decodedBuffer);

                clipSize = decodedBuffer.length*float.sizeof;
                decodeSuccesful = bytesRead == lengthFrames;
            }
            input.cleanUp();
            decodeSuccesful ? onSuccess(getClipData) : onFailure();

            return decodeSuccesful;
        }
        uint startDecoding(in ubyte[] data, ubyte[] outputDecodedData, uint chunkSize, HipAudioEncoding encoding)
        {
            input.openFromMemory(cast(ubyte[])data);
            channels = input.getNumChannels();
            sampleRate = input.getSamplerate();

            chunkSize = (chunkSize / channels) / float.sizeof;
            chunkBuffer = new float[chunkSize];
            this.chunkSize = chunkSize;
            
            return updateDecoding(outputDecodedData);
        }
        uint updateDecoding(ubyte[] outputDecodedData)
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

        override AudioConfig getAudioConfig(){return AudioConfig(getSamplerate, AudioFormat.float32Little, getClipChannels, cast(int)getClipSize);}
        

        void dispose(){input.cleanUp();}

        override bool resample(in ubyte[] data, HipAudioType type, uint outputSampleRate, uint outputChannels,
        void delegate(in ubyte[]) onSuccess, void delegate())
        {
            version(none)
            {
                static assert(false, "Incomplete implementation.");
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
            onSuccess(getClipData);

            return true;
        }
        override bool channelConversion(in ubyte[] data, ubyte from, ubyte to)
        {
            if(to == 2 && from == 1)
            {
                decodedBuffer = monoToStereo!(float)(cast(float[])data);
                channels = to;
                clipSize*= 2;
                return true;
            }
            else if(to == 1 && from == 2)
            {
                decodedBuffer = stereoToMono!(float)(cast(float[])data);
                channels = to;
                clipSize/= 2;
                return true;
            }
            return false;
        }

        ubyte[] getClipData(){return cast(ubyte[])decodedBuffer;}
    }
}

version(WebAssembly)
{
    import hip.wasm;

    private alias WasmAudioBuffer = size_t;
    extern(C) WasmAudioBuffer WasmDecodeAudio(size_t length, void* ptr, JSDelegateType!(void) dg);
    extern(C) size_t WasmGetClipChannels(WasmAudioBuffer);
    extern(C) size_t WasmGetClipSize(WasmAudioBuffer);
    extern(C) double WasmGetClipDuration(WasmAudioBuffer);
    extern(C) float WasmGetClipSamplerate(WasmAudioBuffer);

    class HipWebAudioDecoder : AHipAudioDecoder
    {

        WasmAudioBuffer buffer;

        bool decode(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
        void delegate(in ubyte[] data) onSuccess, void delegate() onFailure)
        {
            buffer = WasmDecodeAudio(data.length, cast(void*)data.ptr, sendJSDelegate!((WasmAudioBuffer buff)
            {
                assert(buff == buffer, "Different object returned from audio decoded.");

                channels = WasmGetClipChannels(buffer);
                clipSize = WasmGetClipSize(buffer);
                duration = WasmGetClipDuration(buffer);
                sampleRate = WasmGetClipSamplerate(buffer);
                onSuccess(getClipData);
            }).tupleof);
            return false;
        }
    
        ///Unsupported at the moment 
            uint startDecoding(in ubyte[] data, ubyte[] outputDecodedData, uint chunkSize, HipAudioEncoding encoding){return 0;}
            uint updateDecoding(ubyte[] outputDecodedData){return 0;}
        ///

        ///Returns the buffer handle.
        ubyte[] getClipData()
        {
            ubyte* ptr = cast(ubyte*)&buffer;
            return ptr[0..WasmAudioBuffer.sizeof];
        }
    
        void dispose(){}
    }
}


class HipNullAudioDecoder: IHipAudioDecoder
{
    bool decode(in ubyte[] data, HipAudioEncoding encoding, HipAudioType type,
    void delegate(in ubyte[]), void delegate()){return false;}

    bool resample(in ubyte[] data, HipAudioType type, uint outputSampleRate, uint outputChannels,
    void delegate(in ubyte[]), void delegate()){return false;}

    bool channelConversion(in ubyte[] data, ubyte from, ubyte to){return false;}
    uint startDecoding(in ubyte[] data, ubyte[] outputDecodedData, uint chunkSize, HipAudioEncoding encoding){return 0;}
    uint updateDecoding(ubyte[] outputDecodedData){return 0;}
    AudioConfig getAudioConfig(){return AudioConfig.init;}
    ubyte[] getClipData(){return null;}
    size_t getClipSize(){return 0;}
    float getDuration(){return 0;}
    void dispose(){}
    uint getSamplerate(){return 0;}
    ubyte getClipChannels(){return 0;}
}


version(none) //Buggy and not currently working
{
    import hip.audio_decoding.resampler;
    package class HipAllResample : ResamplingContext
    {
        enum BYTES_PER_LOAD = 4096;

        int resampledSamples = 0;
        float[] decodedData;
        
        this(ubyte[] decodedData, int inputSampleRate, int outputSampleRate, int inputChannels, int outputChannels)
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
}

version(WebAssembly)
    alias HipAudioDecoder = HipWebAudioDecoder;
else version(AudioFormatsDecoder)
    alias HipAudioDecoder = HipAudioFormatsDecoder;
else
{
    alias HipAudioDecoder = HipNullAudioDecoder;
    pragma(msg, "WARNING: Using NullAudioDecoder");
}
