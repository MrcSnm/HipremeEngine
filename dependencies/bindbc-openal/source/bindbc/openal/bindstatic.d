
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.openal.bindstatic;

version(BindOpenAL_Static):

import bindbc.openal.types;

extern(C) @nogc nothrow {
    void alEnable(ALenum);
    void alDisable(ALenum);
    ALboolean alIsEnabled(ALenum);
    const(ALchar)* alGetString(ALenum);
    void alGetBooleanv(ALenum, ALboolean*);
    void alGetIntegerv(ALenum, ALint*);
    void alGetFloatv(ALenum, ALfloat*);
    void alGetDoublev(ALenum, ALdouble*);
    ALboolean alGetBoolean(ALenum);
    ALint alGetInteger(ALenum);
    ALfloat alGetFloat(ALenum);
    ALdouble alGetDouble(ALenum);
    ALenum alGetError();
    ALboolean alIsExtensionPresent(const(char)*);
    ALvoid* alGetProcAddress(const(char)*);
    ALenum alGetEnumValue(const(char)*);
    void alListenerf(ALenum, ALfloat);
    void alListener3f(ALenum, ALfloat, ALfloat, ALfloat);
    void alListenerfv(ALenum, const(ALfloat)*);
    void alListeneri(ALenum, ALint);
    void alListener3i(ALenum, ALint, ALint, ALint);
    void alListeneriv(ALenum, const(ALint)*);
    void alGetListenerf(ALenum, ALfloat*);
    void alGetListener3f(ALenum, ALfloat*, ALfloat*, ALfloat*);
    void alGetListenerfv(ALenum, ALfloat*);
    void alGetListeneri(ALenum, ALint*);
    void alGetListener3i(ALenum, ALint*, ALint*, ALint*);
    void alGetListeneriv(ALenum, ALint*);
    void alGenSources(ALsizei, ALuint*);
    void alDeleteSources(ALsizei, const(ALuint)*);
    ALboolean alIsSource(ALuint);
    void alSourcef(ALuint, ALenum, ALfloat);
    void alSource3f(ALuint, ALenum, ALfloat, ALfloat, ALfloat);
    void alSourcefv(ALuint, ALenum, const(ALfloat)*);
    void alSourcei(ALuint, ALenum, ALint);
    void alSource3i(ALuint, ALenum, ALint, ALint, ALint);
    void alSourceiv(ALuint, ALenum, const(ALint)*);
    void alGetSourcef(ALuint, ALenum, ALfloat*);
    void alGetSource3f(ALuint, ALenum, ALfloat*, ALfloat*, ALfloat*);
    void alGetSourcefv(ALuint, ALenum, ALfloat*);
    void alGetSourcei(ALuint, ALenum, ALint*);
    void alGetSource3i(ALuint, ALenum, ALint*, ALint*, ALint*);
    void alGetSourceiv(ALuint, ALenum, ALint*);
    void alSourcePlayv(ALsizei, const(ALuint)*);
    void alSourceStopv(ALsizei, const(ALuint)*);
    void alSourceRewindv(ALsizei, const(ALuint)*);
    void alSourcePausev(ALsizei, const(ALuint)*);
    void alSourcePlay(ALuint);
    void alSourcePause(ALuint);
    void alSourceRewind(ALuint);
    void alSourceStop(ALuint);
    void alSourceQueueBuffers(ALuint, ALsizei, ALuint*);
    void alSourceUnqueueBuffers(ALuint, ALsizei, ALuint*);
    void alGenBuffers(ALsizei, ALuint*);
    void alDeleteBuffers(ALsizei, const(ALuint)*);
    ALboolean alIsBuffer(ALuint);
    void alBufferData(ALuint, ALenum, const(ALvoid)*, ALsizei, ALsizei);
    void alBufferf(ALuint, ALenum, ALfloat);
    void alBuffer3f(ALuint, ALenum, ALfloat, ALfloat, ALfloat);
    void alBufferfv(ALuint, ALenum, const(ALfloat)*);
    void alBufferi(ALuint, ALenum, ALint);
    void alBuffer3i(ALuint, ALenum, ALint, ALint, ALint);
    void alBufferiv(ALuint, ALenum, const(ALint)*);
    void alGetBufferf(ALuint, ALenum, ALfloat*);
    void alGetBuffer3f(ALuint, ALenum, ALfloat*, ALfloat*, ALfloat*);
    void alGetBufferfv(ALuint, ALenum, ALfloat*);
    void alGetBufferi(ALuint, ALenum, ALint*);
    void alGetBuffer3i(ALuint, ALenum, ALint*, ALint*, ALint*);
    void alGetBufferiv(ALuint, ALenum, ALint*);
    void alDopplerFactor(ALfloat);
    void alDopplerVelocity(ALfloat);
    void alSpeedOfSound(ALfloat);
    void alDistanceModel(ALenum);
    ALCcontext* alcCreateContext(ALCdevice*, const(ALCint)*);
    ALCboolean alcMakeContextCurrent(ALCcontext*);
    void alcProcessContext(ALCcontext*);
    void alcSuspendContext(ALCcontext*);
    void alcDestroyContext(ALCcontext*);
    ALCcontext* alcGetCurrentContext();
    ALCdevice* alcGetContextsDevice(ALCcontext*);
    ALCdevice* alcOpenDevice(const(char)*);
    ALCboolean alcCloseDevice(ALCdevice*);
    ALCenum alcGetError(ALCdevice*);
    ALCboolean alcIsExtensionPresent(ALCdevice*, const(char)*);
    void* alcGetProcAddress(ALCdevice*, const(char)*);
    ALCenum alcGetEnumValue(ALCdevice*, const(char)*);
    const(char)* alcGetString(ALCdevice*, ALCenum);
    void alcGetIntegerv(ALCdevice*, ALCenum, ALCsizei, ALCint*);
    ALCdevice* alcCaptureOpenDevice(const(char)*, ALCuint, ALCenum, ALCsizei);
    ALCboolean alcCaptureCloseDevice(ALCdevice*);
    void alcCaptureStart(ALCdevice*);
    void alcCaptureStop(ALCdevice*);
    void alcCaptureSamples(ALCdevice*, ALCvoid*, ALCsizei);


    //EFX Functions
    void alGenEffects(ALsizei n, ALuint *effects);
    void alDeleteEffects(ALsizei n, const ALuint *effects);
    ALboolean alIsEffect(ALuint effect);
    void alEffecti(ALuint effect, ALenum param, ALint iValue);
    void alEffectiv(ALuint effect, ALenum param, const ALint *piValues);
    void alEffectf(ALuint effect, ALenum param, ALfloat flValue);
    void alEffectfv(ALuint effect, ALenum param, const ALfloat *pflValues);
    void alGetEffecti(ALuint effect, ALenum param, ALint *piValue);
    void alGetEffectiv(ALuint effect, ALenum param, ALint *piValues);
    void alGetEffectf(ALuint effect, ALenum param, ALfloat *pflValue);
    void alGetEffectfv(ALuint effect, ALenum param, ALfloat *pflValues);

    void alGenFilters(ALsizei n, ALuint *filters);
    void alDeleteFilters(ALsizei n, const ALuint *filters);
    ALboolean alIsFilter(ALuint filter);
    void alFilteri(ALuint filter, ALenum param, ALint iValue);
    void alFilteriv(ALuint filter, ALenum param, const ALint *piValues);
    void alFilterf(ALuint filter, ALenum param, ALfloat flValue);
    void alFilterfv(ALuint filter, ALenum param, const ALfloat *pflValues);
    void alGetFilteri(ALuint filter, ALenum param, ALint *piValue);
    void alGetFilteriv(ALuint filter, ALenum param, ALint *piValues);
    void alGetFilterf(ALuint filter, ALenum param, ALfloat *pflValue);
    void alGetFilterfv(ALuint filter, ALenum param, ALfloat *pflValues);

    void alGenAuxiliaryEffectSlots(ALsizei n, ALuint *effectslots);
    void alDeleteAuxiliaryEffectSlots(ALsizei n, const ALuint *effectslots);
    ALboolean alIsAuxiliaryEffectSlot(ALuint effectslot);
    void alAuxiliaryEffectSloti(ALuint effectslot, ALenum param, ALint iValue);
    void alAuxiliaryEffectSlotiv(ALuint effectslot, ALenum param, const ALint *piValues);
    void alAuxiliaryEffectSlotf(ALuint effectslot, ALenum param, ALfloat flValue);
    void alAuxiliaryEffectSlotfv(ALuint effectslot, ALenum param, const ALfloat *pflValues);
    void alGetAuxiliaryEffectSloti(ALuint effectslot, ALenum param, ALint *piValue);
    void alGetAuxiliaryEffectSlotiv(ALuint effectslot, ALenum param, ALint *piValues);
    void alGetAuxiliaryEffectSlotf(ALuint effectslot, ALenum param, ALfloat *pflValue);
    void alGetAuxiliaryEffectSlotfv(ALuint effectslot, ALenum param, ALfloat *pflValues);

}
