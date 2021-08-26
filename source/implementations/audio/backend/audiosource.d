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
import implementations.audio.audiobuffer : HipAudioBuffer;
import implementations.audio.audio;
import bindbc.openal;
import def.debugging.gui;
import global.fonts.icons;
/** 
*   Wraps properties for the AudioPlayer. The closest graphical represetantion
*   to that would be the Material class, but for Audios.
*
*/

@InterfaceImplementation(function(ref void* data)
{
    version(CIMGUI)
    {
        import bindbc.cimgui;
        HipAudioSource* src = cast(HipAudioSource*)data;
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
        HipAudio.update(*src);
    }

}) public class HipAudioSource
{
    public:
    //Functions
        void attachToPosition(){}
        void attachOnDestroy(){}
        float getProgress(){return time/length;}
        void pullStreamData(){}
        void setBuffer(HipAudioBuffer buf){buffer = buf;}

    //Properties
        HipAudioBuffer buffer;

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

        HipAudioSource clean()
        {
            isLooping = false;
            isPlaying = false;
            HipAudio.stop(this);
            length = 0;
            HipAudio.setPitch(this, 1f);
            HipAudio.setPanning(this, 0f);
            HipAudio.setVolume(this, 1f);
            HipAudio.setMaxDistance(this, 0f);
            HipAudio.setRolloffFactor(this, 1f);
            HipAudio.setReferenceDistance(this, 0f);
            position = Vector3.Zero();
            id = 0;
            buffer = null;
            return this;
        }

        
        //Making 3D concept available for every audio, it can be useful
        // Vector!float position = [0f,0f,0f];
        Vector3 position = [0f,0f,0f];
        uint id;
}
