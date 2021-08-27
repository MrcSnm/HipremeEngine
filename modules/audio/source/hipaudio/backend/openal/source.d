module hipaudio.backend.openal.source;
import hipaudio.backend.openal.buffer;
import hipaudio.audio;
import hipaudio.backend.audiosource;
import debugging.gui;
import bindbc.openal;

@InterfaceImplementation(function(ref void* data)
{
    version(CIMGUI)
    {
        import bindbc.cimgui;
        import imgui.fonts.icons;

        HipOpenALAudioSource* src = cast(HipOpenALAudioSource*)data;
        igBeginGroup();
        igCheckbox("Playing", &src.isPlaying);
        if(src.isPlaying)
        {
            igIndent(0);
            igText("Sound Name: %s %s", src.buffer.fileName.ptr, Icons_FontAwesome.FILE_AUDIO);
            igUnindent(0);
        }
        igSliderFloat3("Position", cast(float*)&src.position, -1000, 1000, "%.2f", 0);
        igSliderFloat("Pitch", &src.pitch, 0, 4, "%0.4f", 0);
        igSliderFloat("Panning", &src.panning, -1, 1, "%0.3f", 0);
        igSliderFloat("Volume", &src.volume, 0, 1, "%0.3f", 0);
        igSliderFloat("Reference Distance", &src.referenceDistance, 0, 65_000, "%0.3f", 0);
        igSliderFloat("Rolloff Factor", &src.rolloffFactor, 0, 1, "%0.3f", 0);
        igSliderFloat("Max Distance", &src.maxDistance, 0, 65_000, "%0.3f", 0);
        igEndGroup();
        HipAudio.update(*src);
    }

})public class HipOpenALAudioSource : HipAudioSource
{   
    import console.log;
    //id is created from OpenAL player
    bool isStreamed;

    this(bool isStreamed)
    {
        this.isStreamed=isStreamed;
    }

    override void setBuffer(HipAudioBuffer buf)
    {
        super.setBuffer(buf);
        if(!buf.isStreamed)
            alSourcei(id, AL_BUFFER, (cast(HipOpenALBuffer)buf).bufferPool[0]);
        logln(id);
    }

    override void pullStreamData()
    {
        assert(buffer !is null, "Can't pull stream data without any buffer attached");
        assert(id != 0, "Can't pull stream data without source id");
        uint freeBuf = getFreeBuffer();
        if(freeBuf != 0)
            alSourceUnqueueBuffers(id, 1, &freeBuf);
        HipOpenALBuffer alBuf = cast(HipOpenALBuffer)buffer;
        freeBuf = alBuf.updateALSourceStream(freeBuf); 
        alSourceQueueBuffers(id, 1, &freeBuf);
        
    }

    uint getFreeBuffer()
    {
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        return cast(uint)b;
    }
    

    ~this()
    {
        logln("HipAudioSource Killed!");
        alDeleteSources(1, &id);
        id = 0;
    }
}