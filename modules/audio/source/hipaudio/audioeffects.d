/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipaudio.audioeffects;
import hipaudio.audiosource;
public class AudioEffect
{


    void addVolumeModifier(float delegate(HipAudioSource src) modifier)
    {

    }
    void addPitchModifier(float delegate(HipAudioSource src) modifier)
    {

    }
    void addPanningModifier(float delegate(HipAudioSource src) modifier)
    {

    }
    void addModifier(bool delegate(HipAudioSource src) modifier)
    {

    }


    float[] modVolume;
    float[] modPitch;
    float[] modPanning;

    private:
        float delegate(HipAudioSource src)[] volumeDel;
        float delegate(HipAudioSource src)[] pitchDel;
        float delegate(HipAudioSource src)[] panningDel;
        void delegate(HipAudioSource src)[] events;

}