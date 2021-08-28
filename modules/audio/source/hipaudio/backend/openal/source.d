module hipaudio.backend.openal.source;
import hipaudio.backend.openal.clip;
import hipaudio.audio;
import hipaudio.backend.audiosource;
import debugging.gui;
import util.memory;
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

    override void setClip(HipAudioClip clip)
    {
        super.setClip(clip);
        if(!clip.isStreamed)
        {
            ALuint buf = *cast(ALuint*)clip.getBuffer(cast(uint)clip.getClipSize(), clip.getClipData());
            alSourcei(id, AL_BUFFER, buf);
        }
        else
        {
            HipOpenALClip c = cast(HipOpenALClip)clip;
            ALuint buf = c.getALBuffer(c.chunkSize, c.getClipData());
            alSourceQueueBuffers(id, 1, &buf);
        }
        logln(id);
    }

    override void pullStreamData()
    {
        assert(clip !is null, "Can't pull stream data without any buffer attached");
        assert(id != 0, "Can't pull stream data without source id");
        uint freeBuf = getALFreeBuffer();
        if(freeBuf != 0)
        {
            uint fb = freeBuf;
            alSourceUnqueueBuffers(id, 1, &freeBuf);
            sendAvailableBuffer(&fb);
        }
        clip.updateStream();
        HipOpenALClip c = cast(HipOpenALClip)clip;
        freeBuf = c.getALBuffer(c.chunkSize, c.getClipData());
        alSourceQueueBuffers(id, 1, &freeBuf);
        
    }

    uint getALFreeBuffer()
    {
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        return cast(uint)b;
    }

    override HipAudioBufferWrapper* getFreeBuffer()
    {
        int b;
        alGetSourcei(id, AL_BUFFERS_PROCESSED, &b);
        if(b == 0)
            return null;
        return clip.findBuffer(&b);
    }
    

    ~this()
    {
        logln("HipAudioSource Killed!");
        alDeleteSources(1, &id);
        id = 0;
    }
}