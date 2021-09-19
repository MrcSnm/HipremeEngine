// D import file generated from 'source\hipaudio\backend\openal\source.d'
module hipaudio.backend.openal.source;
import hipaudio.backend.openal.clip;
import hipaudio.audio;
import hipaudio.backend.audiosource;
import debugging.gui;
@(InterfaceImplementation(function (ref void* data)
{
	version (CIMGUI)
	{
		import bindbc.cimgui;
		import imgui.fonts.icons;
		HipOpenALAudioSource* src = cast(HipOpenALAudioSource*)data;
		igBeginGroup();
		igCheckbox("Playing", &src.isPlaying);
		if (src.isPlaying)
		{
			igIndent(0);
			igText("Sound Name: %s %s", src.buffer.fileName.ptr, Icons_FontAwesome.FILE_AUDIO);
			igUnindent(0);
		}
		igSliderFloat3("Position", cast(float*)&src.position, -1000, 1000, "%.2f", 0);
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
))public class HipOpenALAudioSource : HipAudioSource
{
	import console.log;
	bool isStreamed;
	this(bool isStreamed)
	{
		this.isStreamed = isStreamed;
	}
	override void setClip(HipAudioClip clip);
	override void pullStreamData();
	uint getALFreeBuffer();
	override HipAudioBufferWrapper* getFreeBuffer();
	~this();
}
