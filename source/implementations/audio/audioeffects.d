/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module implementations.audio.audioeffects;
import implementations.audio.backend.audiosource;
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