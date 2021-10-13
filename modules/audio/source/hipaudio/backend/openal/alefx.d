/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hipaudio.backend.alefx;
import bindbc.openal;
import error.handler;

/**
* Is using EAX Reverb
*/
static bool usingEAXReverb = false;

/**
* Returns an ALEffect index back to be used on a slot
* Code took from KCat OpenAL Soft
*/
ALuint loadReverb(ref ReverbProperties r)
{
    ALuint effect;

    alGenEffects(1, &effect);
    if(alGetEnumValue("AL_EFFECT_EAXREVERB") != 0)
    {
        usingEAXReverb = true;
        /* EAX Reverb is available. Set the EAX effect type then load the
         * reverb properties. */
        alEffecti(effect, AL_EFFECT_TYPE, AL_EFFECT_EAXREVERB);

        ALfloat* reflecPan = &r.reflectionsPan[0];
        ALfloat* lateRevPan = &r.lateReverbPan[0];

        alEffectf(effect, AL_EAXREVERB_DENSITY, r.density);
        alEffectf(effect, AL_EAXREVERB_DIFFUSION, r.diffusion);
        alEffectf(effect, AL_EAXREVERB_GAIN, r.gain);
        alEffectf(effect, AL_EAXREVERB_GAINHF, r.gainHF);
        alEffectf(effect, AL_EAXREVERB_GAINLF, r.gainLF);
        alEffectf(effect, AL_EAXREVERB_DECAY_TIME, r.decayTime);
        alEffectf(effect, AL_EAXREVERB_DECAY_HFRATIO, r.decayHFRatio);
        alEffectf(effect, AL_EAXREVERB_DECAY_LFRATIO, r.decayLFRatio);
        alEffectf(effect, AL_EAXREVERB_REFLECTIONS_GAIN, r.reflectionsGain);
        alEffectf(effect, AL_EAXREVERB_REFLECTIONS_DELAY, r.reflectionsDelay);
        alEffectfv(effect,AL_EAXREVERB_REFLECTIONS_PAN, reflecPan);
        alEffectf(effect, AL_EAXREVERB_LATE_REVERB_GAIN, r.lateReverbGain);
        alEffectf(effect, AL_EAXREVERB_LATE_REVERB_DELAY, r.lateReverbDelay);
        alEffectfv(effect,AL_EAXREVERB_LATE_REVERB_PAN, lateRevPan);
        alEffectf(effect, AL_EAXREVERB_ECHO_TIME, r.echoTime);
        alEffectf(effect, AL_EAXREVERB_ECHO_DEPTH, r.echoDepth);
        alEffectf(effect, AL_EAXREVERB_MODULATION_TIME, r.modulationTime);
        alEffectf(effect, AL_EAXREVERB_MODULATION_DEPTH, r.modulationDepth);
        alEffectf(effect, AL_EAXREVERB_AIR_ABSORPTION_GAINHF, r.airAbsorptionGainHF);
        alEffectf(effect, AL_EAXREVERB_HFREFERENCE, r.HFReference);
        alEffectf(effect, AL_EAXREVERB_LFREFERENCE, r.LFReference);
        alEffectf(effect, AL_EAXREVERB_ROOM_ROLLOFF_FACTOR, r.roomRolloffFactor);
        alEffecti(effect, AL_EAXREVERB_DECAY_HFLIMIT, r.decayHFLimit);
    }
    else
    {
        usingEAXReverb = false;

        /* No EAX Reverb. Set the standard reverb effect type then load the
         * available reverb properties. */
        alEffecti(effect, AL_EFFECT_TYPE, AL_EFFECT_REVERB);

        alEffectf(effect, AL_REVERB_DENSITY, r.density);
        alEffectf(effect, AL_REVERB_DIFFUSION, r.diffusion);
        alEffectf(effect, AL_REVERB_GAIN, r.gain);
        alEffectf(effect, AL_REVERB_GAINHF, r.gainHF);
        alEffectf(effect, AL_REVERB_DECAY_TIME, r.decayTime);
        alEffectf(effect, AL_REVERB_DECAY_HFRATIO, r.decayHFRatio);
        alEffectf(effect, AL_REVERB_REFLECTIONS_GAIN, r.reflectionsGain);
        alEffectf(effect, AL_REVERB_REFLECTIONS_DELAY, r.reflectionsDelay);
        alEffectf(effect, AL_REVERB_LATE_REVERB_GAIN, r.lateReverbGain);
        alEffectf(effect, AL_REVERB_LATE_REVERB_DELAY, r.lateReverbDelay);
        alEffectf(effect, AL_REVERB_AIR_ABSORPTION_GAINHF, r.airAbsorptionGainHF);
        alEffectf(effect, AL_REVERB_ROOM_ROLLOFF_FACTOR, r.roomRolloffFactor);
        alEffecti(effect, AL_REVERB_DECAY_HFLIMIT, r.decayHFLimit);
    }

    /* Check if an error occured, and clean up if so. */
    int err = alGetError();
    if(err != AL_NO_ERROR)
    {
        import util.conv:to;
        
        string str = to!string(alGetString(err));
        ErrorHandler.showErrorMessage("OpenAL error: "~str~"\n", "Reverb Error");
        if(alIsEffect(effect))
            alDeleteEffects(1, &effect);
        return 0;
    }

    return effect;
}