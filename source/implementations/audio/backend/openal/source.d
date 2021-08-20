module implementations.audio.backend.openal.source;
import implementations.audio.backend.openal.buffer;
import implementations.audio.audiobase;
import implementations.imgui.imgui_debug;
import global.fonts.icons;
import implementations.audio.audio;
import implementations.audio.backend.audiosource;
import bindbc.openal;

@InterfaceImplementation(function(ref void* data)
{
    import bindbc.cimgui;
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

})public class HipOpenALAudioSource : HipAudioSource
{   
    import def.debugging.log;

    override void setBuffer(HipAudioBuffer buf)
    {
        super.setBuffer(buf);
        logln((cast(HipOpenALBuffer)buf).bufferId);
        logln(id);
        alSourcei(id, AL_BUFFER, (cast(HipOpenALBuffer)buf).bufferId);
    }
    ~this()
    {
        logln("HipAudioSource Killed!");
        alDeleteSources(1, &id);
        id = 0;
    }
}