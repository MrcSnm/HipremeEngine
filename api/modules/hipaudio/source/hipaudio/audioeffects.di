// D import file generated from 'source\hipaudio\audioeffects.d'
module hipaudio.audioeffects;
import hipaudio.backend.audiosource;
public class AudioEffect
{
	void addVolumeModifier(float delegate(HipAudioSource src) modifier);
	void addPitchModifier(float delegate(HipAudioSource src) modifier);
	void addPanningModifier(float delegate(HipAudioSource src) modifier);
	void addModifier(bool delegate(HipAudioSource src) modifier);
	float[] modVolume;
	float[] modPitch;
	float[] modPanning;
	private 
	{
		float delegate(HipAudioSource src)[] volumeDel;
		float delegate(HipAudioSource src)[] pitchDel;
		float delegate(HipAudioSource src)[] panningDel;
		void delegate(HipAudioSource src)[] events;
	}
}
