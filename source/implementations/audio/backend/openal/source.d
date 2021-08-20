module implementations.audio.backend.openal.source;

@InterfaceImplementation(function(ref void* data)
{
    import bindbc.cimgui;
    HipAudioSource3D* src = cast(HipAudioSource3D*)data;
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
    Audio.update(*src);

})public class HipOpenALAudioSource : HipAudioSource
{   
    import def.debugging.log;

    override void setBuffer(AudioBuffer buf)
    {
        import implementations.audio.backend.audio3d : OpenALBuffer;
        super.setBuffer(buf);
        logln((cast(OpenALBuffer)buf).bufferId);
        logln(id);
        alSourcei(id, AL_BUFFER, (cast(OpenALBuffer)buf).bufferId);
    }
    ~this()
    {
        logln("HipAudioSource Killed!");
        alDeleteSources(1, &id);
        id = -1;
    }
}