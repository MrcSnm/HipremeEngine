module implementations.audio.audioeffects;
import implementations.audio.backend.audiosource;
public class AudioEffect
{


    void addVolumeModifier(float delegate(AudioSource src) modifier)
    {

    }
    void addPitchModifier(float delegate(AudioSource src) modifier)
    {

    }
    void addPanningModifier(float delegate(AudioSource src) modifier)
    {

    }
    void addModifier(bool delegate(AudioSource src) modifier)
    {

    }


    float[] modVolume;
    float[] modPitch;
    float[] modPanning;

    private:
        float delegate(AudioSource src)[] volumeDel;
        float delegate(AudioSource src)[] pitchDel;
        float delegate(AudioSource src)[] panningDel;
        void delegate(AudioSource src)[] events;

}