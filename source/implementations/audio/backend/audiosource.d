/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.backend.audiosource;
import math.vector;
import implementations.audio.audiobase : AudioBuffer;
import implementations.audio.audio;
import bindbc.openal;
import implementations.imgui.imgui_debug;
import global.fonts.icons;

@InterfaceImplementation(function(ref void* data)
{
    import bindbc.cimgui;
    AudioSource* src = cast(AudioSource*)data;
    igBeginGroup();
    igCheckbox("Playing", &src.isPlaying);
    if(src.isPlaying)
    {
        igIndent(0);
        igText("Sound Name: %s %s", src.buffer.fileName.ptr, Icons_FontAwesome.FILE_AUDIO);
        igUnindent(0);
    }
    igSliderFloat("Pitch", &src.pitch, 0, 4, "%0.4f", 0);
    igSliderFloat("Panning", &src.panning, -1, 1, "%0.3f", 0);
    igSliderFloat("Volume", &src.volume, 0, 1, "%0.3f", 0);
    igSliderFloat("Reference Distance", &src.referenceDistance, 0, 65_000, "%0.3f", 0);
    igSliderFloat("Rolloff Factor", &src.rolloffFactor, 0, 1, "%0.3f", 0);
    igSliderFloat("Max Distance", &src.maxDistance, 0, 65_000, "%0.3f", 0);
    igEndGroup();
    Audio.update(*src);

}) public class AudioSource
{
    public:
    //Functions
        void attachToPosition(){}
        void attachOnDestroy(){}
        float getProgress(){return time/length;}
        void setBuffer(AudioBuffer buf)
        {
            buffer = buf;
        }

    //Properties
        AudioBuffer buffer;

        bool isLooping;
        bool isPlaying;

        float time;
        float length;
        float pitch = 1;
        float panning = 0;
        float volume = 1;

        //3D Audio Only
        float maxDistance = 0;
        float rolloffFactor = 0;
        float referenceDistance = 0;

        public AudioSource clean()
        {
            isLooping = false;
            isPlaying = false;
            Audio.stop(this);
            length = 0;
            Audio.setPitch(this, 1f);
            Audio.setPanning(this, 0f);
            Audio.setVolume(this, 1f);
            Audio.setMaxDistance(this, 0f);
            Audio.setRolloffFactor(this, 1f);
            Audio.setReferenceDistance(this, 0f);
            position = Vector3.Zero();
            // id = -1;
            buffer = null;
            return this;
        }

        
        //Making 3D concept available for every audio, it can be useful
        // Vector!float position = [0f,0f,0f];
        Vector3 position = [0f,0f,0f];
        uint id;
}

@InterfaceImplementation(function(ref void* data)
{
    import bindbc.cimgui;
    AudioSource3D* src = cast(AudioSource3D*)data;
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

})public class AudioSource3D : AudioSource
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
        logln("AudioSource Killed!");
        alDeleteSources(1, &id);
        id = -1;
    }
}