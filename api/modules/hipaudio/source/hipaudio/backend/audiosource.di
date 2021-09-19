// D import file generated from 'source\hipaudio\backend\audiosource.d'
module hipaudio.backend.audiosource;
import math.vector;
import hipaudio.audioclip : HipAudioClip;
import hipaudio.audio;
import debugging.gui;
import imgui.fonts.icons;


@(InterfaceImplementation(function (ref void* data)
{
	version (CIMGUI)
	{
		import bindbc.cimgui;
		HipAudioSource* src = cast(HipAudioSource*)data;
		igBeginGroup();
		igCheckbox("Playing", &src.isPlaying);
		if (src.isPlaying)
		{
			igIndent(0);
			igText("Sound Name: %s %s", src.buffer.fileName.ptr, Icons_FontAwesome.FILE_AUDIO);
			igUnindent(0);
		}
		igSliderFloat("Pitch", &src.pitch, 0, 4, "%0.4f", 0);
		igSliderFloat("Panning", &src.panning, -1, 1, "%0.3f", 0);
		igSliderFloat("Volume", &src.volume, 0, 1, "%0.3f", 0);
		igSliderFloat("Reference Distance", &src.referenceDistance, 0, 65000, "%0.3f", 0);
		igSliderFloat("Rolloff Factor", &src.rolloffFactor, 0, 1, "%0.3f", 0);
		igSliderFloat("Max Distance", &src.maxDistance, 0, 65000, "%0.3f", 0);
		igEndGroup();
		HipAudio.update(*src);
	}

}
))public class HipAudioSource
{
	public 
	{
		void attachToPosition();
		void attachOnDestroy();
		float getProgress();
		void pullStreamData();
		void setClip(HipAudioClip clip);
		HipAudioBufferWrapper* getFreeBuffer();
		final void sendAvailableBuffer(void* buffer);
		HipAudioClip clip;
		bool isLooping;
		bool isPlaying;
		float time;
		float length;
		float pitch = 1;
		float panning = 0;
		float volume = 1;
		float maxDistance = 0;
		float rolloffFactor = 0;
		float referenceDistance = 0;
		HipAudioSource clean();
		Vector3 position = [0.0F, 0.0F, 0.0F];
		uint id;
	}
}
