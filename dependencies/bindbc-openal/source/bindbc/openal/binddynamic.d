
//          Copyright Michael D. Parker 2018.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.openal.binddynamic;

version(BindOpenAL_Static) {}
else version = BindOpenAL_Dynamic;

version(BindOpenAL_Dynamic):

import bindbc.loader;
import bindbc.openal.types;

extern(C) @nogc nothrow {
    alias palEnable = void function(ALenum);
    alias palDisable = void function(ALenum);
    alias palIsEnabled = ALboolean function(ALenum);
    alias palGetString = const(ALchar)* function(ALenum);
    alias palGetBooleanv = void function(ALenum, ALboolean*);
    alias palGetIntegerv = void function(ALenum, ALint*);
    alias palGetFloatv = void function(ALenum, ALfloat*);
    alias palGetDoublev = void function(ALenum, ALdouble*);
    alias palGetBoolean = ALboolean function(ALenum);
    alias palGetInteger = ALint function(ALenum);
    alias palGetFloat = ALfloat function(ALenum);
    alias palGetDouble = ALdouble function(ALenum);
    alias palGetError = ALenum function();
    alias palIsExtensionPresent = ALboolean function(const(char)*);
    alias palGetProcAddress = ALvoid* function(const(char)*);
    alias palGetEnumValue = ALenum function(const(char)*);
    alias palListenerf = void function(ALenum, ALfloat);
    alias palListener3f = void function(ALenum, ALfloat, ALfloat, ALfloat);
    alias palListenerfv = void function(ALenum, const(ALfloat)*);
    alias palListeneri = void function(ALenum, ALint);
    alias palListener3i = void function(ALenum, ALint, ALint, ALint);
    alias palListeneriv = void function(ALenum, const(ALint)*);
    alias palGetListenerf = void function(ALenum, ALfloat*);
    alias palGetListener3f = void function(ALenum, ALfloat*, ALfloat*, ALfloat*);
    alias palGetListenerfv = void function(ALenum, ALfloat*);
    alias palGetListeneri = void function(ALenum, ALint*);
    alias palGetListener3i = void function(ALenum, ALint*, ALint*, ALint*);
    alias palGetListeneriv = void function(ALenum, ALint*);
    alias palGenSources = void function(ALsizei, ALuint*);
    alias palDeleteSources = void function(ALsizei, const(ALuint)*);
    alias palIsSource = ALboolean function(ALuint);
    alias palSourcef = void function(ALuint, ALenum, ALfloat);
    alias palSource3f = void function(ALuint, ALenum, ALfloat, ALfloat, ALfloat);
    alias palSourcefv = void function(ALuint, ALenum, const(ALfloat)*);
    alias palSourcei = void function(ALuint, ALenum, ALint);
    alias palSource3i = void function(ALuint, ALenum, ALint, ALint, ALint);
    alias palSourceiv = void function(ALuint, ALenum, const(ALint)*);
    alias palGetSourcef = void function(ALuint, ALenum, ALfloat*);
    alias palGetSource3f = void function(ALuint, ALenum, ALfloat*, ALfloat*, ALfloat*);
    alias palGetSourcefv = void function(ALuint, ALenum, ALfloat*);
    alias palGetSourcei = void function(ALuint, ALenum, ALint*);
    alias palGetSource3i = void function(ALuint, ALenum, ALint*, ALint*, ALint*);
    alias palGetSourceiv = void function(ALuint, ALenum, ALint*);
    alias palSourcePlayv = void function(ALsizei, const(ALuint)*);
    alias palSourceStopv = void function(ALsizei, const(ALuint)*);
    alias palSourceRewindv = void function(ALsizei, const(ALuint)*);
    alias palSourcePausev = void function(ALsizei, const(ALuint)*);
    alias palSourcePlay = void function(ALuint);
    alias palSourcePause = void function(ALuint);
    alias palSourceRewind = void function(ALuint);
    alias palSourceStop = void function(ALuint);
    alias palSourceQueueBuffers = void function(ALuint, ALsizei, ALuint*);
    alias palSourceUnqueueBuffers = void function(ALuint, ALsizei, ALuint*);
    alias palGenBuffers = void function(ALsizei, ALuint*);
    alias palDeleteBuffers = void function(ALsizei, const(ALuint)*);
    alias palIsBuffer = ALboolean function(ALuint);
    alias palBufferData = void function(ALuint, ALenum, const(ALvoid)*, ALsizei, ALsizei);
    alias palBufferf = void function(ALuint, ALenum, ALfloat);
    alias palBuffer3f = void function(ALuint, ALenum, ALfloat, ALfloat, ALfloat);
    alias palBufferfv = void function(ALuint, ALenum, const(ALfloat)*);
    alias palBufferi = void function(ALuint, ALenum, ALint);
    alias palBuffer3i = void function(ALuint, ALenum, ALint, ALint, ALint);
    alias palBufferiv = void function(ALuint, ALenum, const(ALint)*);
    alias palGetBufferf = void function(ALuint, ALenum, ALfloat*);
    alias palGetBuffer3f = void function(ALuint, ALenum, ALfloat*, ALfloat*, ALfloat*);
    alias palGetBufferfv = void function(ALuint, ALenum, ALfloat*);
    alias palGetBufferi = void function(ALuint, ALenum, ALint*);
    alias palGetBuffer3i = void function(ALuint, ALenum, ALint*, ALint*, ALint*);
    alias palGetBufferiv = void function(ALuint, ALenum, ALint*);
    alias palDopplerFactor = void function(ALfloat);
    alias palDopplerVelocity = void function(ALfloat);
    alias palSpeedOfSound = void function(ALfloat);
    alias palDistanceModel = void function(ALenum);
    alias palcCreateContext = ALCcontext* function(ALCdevice*, const(ALCint)*);
    alias palcMakeContextCurrent = ALCboolean function(ALCcontext*);
    alias palcProcessContext = void function(ALCcontext*);
    alias palcSuspendContext = void function(ALCcontext*);
    alias palcDestroyContext = void function(ALCcontext*);
    alias palcGetCurrentContext = ALCcontext* function();
    alias palcGetContextsDevice = ALCdevice* function(ALCcontext*);
    alias palcOpenDevice = ALCdevice* function(const(char)*);
    alias palcCloseDevice = ALCboolean function(ALCdevice*);
    alias palcGetError = ALCenum function(ALCdevice*);
    alias palcIsExtensionPresent = ALCboolean function(ALCdevice*, const(char)*);
    alias palcGetProcAddress = void* function(ALCdevice*, const(char)*);
    alias palcGetEnumValue = ALCenum function(ALCdevice*, const(char)*);
    alias palcGetString = const(char)* function(ALCdevice*, ALCenum);
    alias palcGetIntegerv = void function(ALCdevice*, ALCenum, ALCsizei, ALCint*);
    alias palcCaptureOpenDevice = ALCdevice* function(const(char)*, ALCuint, ALCenum, ALCsizei);
    alias palcCaptureCloseDevice = ALCboolean function(ALCdevice*);
    alias palcCaptureStart = void function(ALCdevice*);
    alias palcCaptureStop = void function(ALCdevice*);
    alias palcCaptureSamples = void function(ALCdevice*, ALCvoid*, ALCsizei);

    //EFX Functions
    alias palGenEffects = void function(ALsizei n, ALuint *effects);
    alias palDeleteEffects = void function(ALsizei n, const ALuint *effects);
    alias palIsEffect = ALboolean function(ALuint effect);
    alias palEffecti = void function(ALuint effect, ALenum param, ALint iValue);
    alias palEffectiv = void function(ALuint effect, ALenum param, const (ALint)* piValues);
    alias palEffectf = void function(ALuint effect, ALenum param, ALfloat flValue);
    alias palEffectfv = void function(ALuint effect, ALenum param, const (ALfloat)* pflValues);
    alias palGetEffecti = void function(ALuint effect, ALenum param, ALint *piValue);
    alias palGetEffectiv = void function(ALuint effect, ALenum param, ALint *piValues);
    alias palGetEffectf = void function(ALuint effect, ALenum param, ALfloat *pflValue);
    alias palGetEffectfv = void function(ALuint effect, ALenum param, ALfloat *pflValues);

    alias palGenFilters = void function(ALsizei n, ALuint *filters);
    alias palDeleteFilters = void function(ALsizei n, const ALuint *filters);
    alias palIsFilter = ALboolean function(ALuint filter);
    alias palFilteri = void function(ALuint filter, ALenum param, ALint iValue);
    alias palFilteriv = void function(ALuint filter, ALenum param, const ALint *piValues);
    alias palFilterf = void function(ALuint filter, ALenum param, ALfloat flValue);
    alias palFilterfv = void function(ALuint filter, ALenum param, const ALfloat *pflValues);
    alias palGetFilteri = void function(ALuint filter, ALenum param, ALint *piValue);
    alias palGetFilteriv = void function(ALuint filter, ALenum param, ALint *piValues);
    alias palGetFilterf = void function(ALuint filter, ALenum param, ALfloat *pflValue);
    alias palGetFilterfv = void function(ALuint filter, ALenum param, ALfloat *pflValues);

    alias palGenAuxiliaryEffectSlots = void function(ALsizei n, ALuint *effectslots);
    alias palDeleteAuxiliaryEffectSlots = void function(ALsizei n, const ALuint *effectslots);
    alias palIsAuxiliaryEffectSlot = ALboolean function(ALuint effectslot);
    alias palAuxiliaryEffectSloti = void function(ALuint effectslot, ALenum param, ALint iValue);
    alias palAuxiliaryEffectSlotiv = void function(ALuint effectslot, ALenum param, const ALint *piValues);
    alias palAuxiliaryEffectSlotf = void function(ALuint effectslot, ALenum param, ALfloat flValue);
    alias palAuxiliaryEffectSlotfv = void function(ALuint effectslot, ALenum param, const ALfloat *pflValues);
    alias palGetAuxiliaryEffectSloti = void function(ALuint effectslot, ALenum param, ALint *piValue);
    alias palGetAuxiliaryEffectSlotiv = void function(ALuint effectslot, ALenum param, ALint *piValues);
    alias palGetAuxiliaryEffectSlotf = void function(ALuint effectslot, ALenum param, ALfloat *pflValue);
    alias palGetAuxiliaryEffectSlotfv = void function(ALuint effectslot, ALenum param, ALfloat *pflValues);

}

__gshared {
    palEnable alEnable;
    palDisable alDisable;
    palIsEnabled alIsEnabled;
    palGetString alGetString;
    palGetBooleanv alGetBooleanv;
    palGetIntegerv alGetIntegerv;
    palGetFloatv alGetFloatv;
    palGetDoublev alGetDoublev;
    palGetBoolean alGetBoolean;
    palGetInteger alGetInteger;
    palGetFloat alGetFloat;
    palGetDouble alGetDouble;
    palGetError alGetError;
    palIsExtensionPresent alIsExtensionPresent;
    palGetProcAddress alGetProcAddress;
    palGetEnumValue alGetEnumValue;
    palListenerf alListenerf;
    palListener3f alListener3f;
    palListenerfv alListenerfv;
    palListeneri alListeneri;
    palListener3i alListener3i;
    palListeneriv alListeneriv;
    palGetListenerf alGetListenerf;
    palGetListener3f alGetListener3f;
    palGetListenerfv alGetListenerfv;
    palGetListeneri alGetListeneri;
    palGetListener3i alGetListener3i;
    palGetListeneriv alGetListeneriv;
    palGenSources alGenSources;
    palDeleteSources alDeleteSources;
    palIsSource alIsSource;
    palSourcef alSourcef;
    palSource3f alSource3f;
    palSourcefv alSourcefv;
    palSourcei alSourcei;
    palSource3i alSource3i;
    palSourceiv alSourceiv;
    palGetSourcef alGetSourcef;
    palGetSource3f alGetSource3f;
    palGetSourcefv alGetSourcefv;
    palGetSourcei alGetSourcei;
    palGetSource3i alGetSource3i;
    palGetSourceiv alGetSourceiv;
    palSourcePlayv alSourcePlayv;
    palSourceStopv alSourceStopv;
    palSourceRewindv alSourceRewindv;
    palSourcePausev alSourcePausev;
    palSourcePlay alSourcePlay;
    palSourcePause alSourcePause;
    palSourceRewind alSourceRewind;
    palSourceStop alSourceStop;
    palSourceQueueBuffers alSourceQueueBuffers;
    palSourceUnqueueBuffers alSourceUnqueueBuffers;
    palGenBuffers alGenBuffers;
    palDeleteBuffers alDeleteBuffers;
    palIsBuffer alIsBuffer;
    palBufferData alBufferData;
    palBufferf alBufferf;
    palBuffer3f alBuffer3f;
    palBufferfv alBufferfv;
    palBufferi alBufferi;
    palBuffer3i alBuffer3i;
    palBufferiv alBufferiv;
    palGetBufferf alGetBufferf;
    palGetBuffer3f alGetBuffer3f;
    palGetBufferfv alGetBufferfv;
    palGetBufferi alGetBufferi;
    palGetBuffer3i alGetBuffer3i;
    palGetBufferiv alGetBufferiv;
    palDopplerFactor alDopplerFactor;
    palDopplerVelocity alDopplerVelocity;
    palSpeedOfSound alSpeedOfSound;
    palDistanceModel alDistanceModel;
    palcCreateContext alcCreateContext;
    palcMakeContextCurrent alcMakeContextCurrent;
    palcProcessContext alcProcessContext;
    palcSuspendContext alcSuspendContext;
    palcDestroyContext alcDestroyContext;
    palcGetCurrentContext alcGetCurrentContext;
    palcGetContextsDevice alcGetContextsDevice;
    palcOpenDevice alcOpenDevice;
    palcCloseDevice alcCloseDevice;
    palcGetError alcGetError;
    palcIsExtensionPresent alcIsExtensionPresent;
    palcGetProcAddress alcGetProcAddress;
    palcGetEnumValue alcGetEnumValue;
    palcGetString alcGetString;
    palcGetIntegerv alcGetIntegerv;
    palcCaptureOpenDevice alcCaptureOpenDevice;
    palcCaptureCloseDevice alcCaptureCloseDevice;
    palcCaptureStart alcCaptureStart;
    palcCaptureStop alcCaptureStop;
    palcCaptureSamples alcCaptureSamples;

    //EFX Functions
    palGenEffects alGenEffects;
    palDeleteEffects alDeleteEffects;
    palIsEffect alIsEffect;
    palEffecti alEffecti;
    palEffectiv alEffectiv;
    palEffectf alEffectf;
    palEffectfv alEffectfv;
    palGetEffecti alGetEffecti;
    palGetEffectiv alGetEffectiv;
    palGetEffectf alGetEffectf;
    palGetEffectfv alGetEffectfv;
    palGenFilters alGenFilters;
    palDeleteFilters alDeleteFilters;
    palIsFilter alIsFilter;
    palFilteri alFilteri;
    palFilteriv alFilteriv;
    palFilterf alFilterf;
    palFilterfv alFilterfv;
    palGetFilteri alGetFilteri;
    palGetFilteriv alGetFilteriv;
    palGetFilterf alGetFilterf;
    palGetFilterfv alGetFilterfv;
    palGenAuxiliaryEffectSlots alGenAuxiliaryEffectSlots;
    palDeleteAuxiliaryEffectSlots alDeleteAuxiliaryEffectSlots;
    palIsAuxiliaryEffectSlot alIsAuxiliaryEffectSlot;
    palAuxiliaryEffectSloti alAuxiliaryEffectSloti;
    palAuxiliaryEffectSlotiv alAuxiliaryEffectSlotiv;
    palAuxiliaryEffectSlotf alAuxiliaryEffectSlotf;
    palAuxiliaryEffectSlotfv alAuxiliaryEffectSlotfv;
    palGetAuxiliaryEffectSloti alGetAuxiliaryEffectSloti;
    palGetAuxiliaryEffectSlotiv alGetAuxiliaryEffectSlotiv;
    palGetAuxiliaryEffectSlotf alGetAuxiliaryEffectSlotf;
    palGetAuxiliaryEffectSlotfv alGetAuxiliaryEffectSlotfv;
}

private {
    SharedLib lib;
    ALSupport loadedVersion;
}

void unloadOpenAL()
{
    if(lib != invalidHandle) {
        lib.unload();
    }
}

ALSupport loadedOpenALVersion() { return loadedVersion; }
bool isOpenALLoaded() { return lib != invalidHandle; }

ALSupport loadOpenAL()
{
    version(Windows) {
        const(char)[][3] libNames = ["OpenAL32.dll", "soft-oal.dll", "soft_oal.dll"];
    }
    else version(OSX) {
        const(char)[][3] libNames = [
            "../Frameworks/OpenAL.framework/OpenAL",
            "/Library/Frameworks/OpenAL.framework/OpenAL",
            "/System/Library/Frameworks/OpenAL.framework/OpenAL"
        ];
    }
    else version(Posix) {
        const(char)[][5] libNames = [
            "libal.so", "libAL.so",
            "libopenal.so", "libopenal.so.1", "libopenal.so.0"
        ];
    }
    else static assert(0, "bindbc-openal is not yet supported on this platform");

    ALSupport ret;
    foreach(name; libNames) {
        ret = loadOpenAL(name.ptr);
        if(ret != ALSupport.noLibrary) break;
    }
    return ret;
}

ALSupport loadOpenAL(const(char)* libName)
{
    // If the library isn't yet loaded, load it now.
    if(lib == invalidHandle) {
        lib = load(libName);
        if(lib == invalidHandle) {
            return ALSupport.noLibrary;
        }
    }

    auto errCount = errorCount();
    lib.bindSymbol(cast(void**)&alEnable, "alEnable");
    lib.bindSymbol(cast(void**)&alDisable, "alDisable");
    lib.bindSymbol(cast(void**)&alIsEnabled, "alIsEnabled");
    lib.bindSymbol(cast(void**)&alGetString, "alGetString");
    lib.bindSymbol(cast(void**)&alGetBooleanv, "alGetBooleanv");
    lib.bindSymbol(cast(void**)&alGetIntegerv, "alGetIntegerv");
    lib.bindSymbol(cast(void**)&alGetFloatv, "alGetFloatv");
    lib.bindSymbol(cast(void**)&alGetDoublev, "alGetDoublev");
    lib.bindSymbol(cast(void**)&alGetInteger, "alGetInteger");
    lib.bindSymbol(cast(void**)&alGetFloat, "alGetFloat");
    lib.bindSymbol(cast(void**)&alGetDouble, "alGetDouble");
    lib.bindSymbol(cast(void**)&alGetError, "alGetError");
    lib.bindSymbol(cast(void**)&alIsExtensionPresent, "alIsExtensionPresent");
    lib.bindSymbol(cast(void**)&alGetProcAddress, "alGetProcAddress");
    lib.bindSymbol(cast(void**)&alGetEnumValue, "alGetEnumValue");
    lib.bindSymbol(cast(void**)&alListenerf, "alListenerf");
    lib.bindSymbol(cast(void**)&alListener3f, "alListener3f");
    lib.bindSymbol(cast(void**)&alListenerfv, "alListenerfv");
    lib.bindSymbol(cast(void**)&alListeneri, "alListeneri");
    lib.bindSymbol(cast(void**)&alListener3i, "alListener3i");
    lib.bindSymbol(cast(void**)&alListeneriv, "alListeneriv");
    lib.bindSymbol(cast(void**)&alGetListenerf, "alGetListenerf");
    lib.bindSymbol(cast(void**)&alGetListener3f, "alGetListener3f");
    lib.bindSymbol(cast(void**)&alGetListenerfv, "alGetListenerfv");
    lib.bindSymbol(cast(void**)&alGetListeneri, "alGetListeneri");
    lib.bindSymbol(cast(void**)&alGetListener3i, "alGetListener3i");
    lib.bindSymbol(cast(void**)&alGetListeneriv, "alGetListeneriv");
    lib.bindSymbol(cast(void**)&alGenSources, "alGenSources");
    lib.bindSymbol(cast(void**)&alDeleteSources, "alDeleteSources");
    lib.bindSymbol(cast(void**)&alIsSource, "alIsSource");
    lib.bindSymbol(cast(void**)&alSourcef, "alSourcef");
    lib.bindSymbol(cast(void**)&alSource3f, "alSource3f");
    lib.bindSymbol(cast(void**)&alSourcefv, "alSourcefv");
    lib.bindSymbol(cast(void**)&alSourcei, "alSourcei");
    lib.bindSymbol(cast(void**)&alSource3i, "alSource3i");
    lib.bindSymbol(cast(void**)&alSourceiv, "alSourceiv");
    lib.bindSymbol(cast(void**)&alGetSourcef, "alGetSourcef");
    lib.bindSymbol(cast(void**)&alGetSource3f, "alGetSource3f");
    lib.bindSymbol(cast(void**)&alGetSourcefv, "alGetSourcefv");
    lib.bindSymbol(cast(void**)&alGetSourcei, "alGetSourcei");
    lib.bindSymbol(cast(void**)&alGetSource3i, "alGetSource3i");
    lib.bindSymbol(cast(void**)&alGetSourceiv, "alGetSourceiv");
    lib.bindSymbol(cast(void**)&alSourcePlayv, "alSourcePlayv");
    lib.bindSymbol(cast(void**)&alSourceStopv, "alSourceStopv");
    lib.bindSymbol(cast(void**)&alSourceRewindv, "alSourceRewindv");
    lib.bindSymbol(cast(void**)&alSourcePausev, "alSourcePausev");
    lib.bindSymbol(cast(void**)&alSourcePlay, "alSourcePlay");
    lib.bindSymbol(cast(void**)&alSourcePause, "alSourcePause");
    lib.bindSymbol(cast(void**)&alSourceRewind, "alSourceRewind");
    lib.bindSymbol(cast(void**)&alSourceStop, "alSourceStop");
    lib.bindSymbol(cast(void**)&alSourceQueueBuffers, "alSourceQueueBuffers");
    lib.bindSymbol(cast(void**)&alSourceUnqueueBuffers, "alSourceUnqueueBuffers");
    lib.bindSymbol(cast(void**)&alGenBuffers, "alGenBuffers");
    lib.bindSymbol(cast(void**)&alDeleteBuffers, "alDeleteBuffers");
    lib.bindSymbol(cast(void**)&alIsBuffer, "alIsBuffer");
    lib.bindSymbol(cast(void**)&alBufferData, "alBufferData");
    lib.bindSymbol(cast(void**)&alBufferf, "alBufferf");
    lib.bindSymbol(cast(void**)&alBuffer3f, "alBuffer3f");
    lib.bindSymbol(cast(void**)&alBufferfv, "alBufferfv");
    lib.bindSymbol(cast(void**)&alBufferi, "alBufferi");
    lib.bindSymbol(cast(void**)&alBuffer3i, "alBuffer3i");
    lib.bindSymbol(cast(void**)&alBufferiv, "alBufferiv");
    lib.bindSymbol(cast(void**)&alGetBufferf, "alGetBufferf");
    lib.bindSymbol(cast(void**)&alGetBuffer3f, "alGetBuffer3f");
    lib.bindSymbol(cast(void**)&alGetBufferfv, "alGetBufferfv");
    lib.bindSymbol(cast(void**)&alGetBufferi, "alGetBufferi");
    lib.bindSymbol(cast(void**)&alGetBuffer3i, "alGetBuffer3i");
    lib.bindSymbol(cast(void**)&alGetBufferiv, "alGetBufferiv");
    lib.bindSymbol(cast(void**)&alDopplerFactor, "alDopplerFactor");
    lib.bindSymbol(cast(void**)&alDopplerVelocity, "alDopplerVelocity");
    lib.bindSymbol(cast(void**)&alSpeedOfSound, "alSpeedOfSound");
    lib.bindSymbol(cast(void**)&alDistanceModel, "alDistanceModel");
    lib.bindSymbol(cast(void**)&alcCreateContext, "alcCreateContext");
    lib.bindSymbol(cast(void**)&alcMakeContextCurrent, "alcMakeContextCurrent");
    lib.bindSymbol(cast(void**)&alcProcessContext, "alcProcessContext");
    lib.bindSymbol(cast(void**)&alcGetCurrentContext, "alcGetCurrentContext");
    lib.bindSymbol(cast(void**)&alcGetContextsDevice, "alcGetContextsDevice");
    lib.bindSymbol(cast(void**)&alcSuspendContext, "alcSuspendContext");
    lib.bindSymbol(cast(void**)&alcDestroyContext, "alcDestroyContext");
    lib.bindSymbol(cast(void**)&alcOpenDevice, "alcOpenDevice");
    lib.bindSymbol(cast(void**)&alcCloseDevice, "alcCloseDevice");
    lib.bindSymbol(cast(void**)&alcGetError, "alcGetError");
    lib.bindSymbol(cast(void**)&alcIsExtensionPresent, "alcIsExtensionPresent");
    lib.bindSymbol(cast(void**)&alcGetProcAddress, "alcGetProcAddress");
    lib.bindSymbol(cast(void**)&alcGetEnumValue, "alcGetEnumValue");
    lib.bindSymbol(cast(void**)&alcGetString, "alcGetString");
    lib.bindSymbol(cast(void**)&alcGetIntegerv, "alcGetIntegerv");
    lib.bindSymbol(cast(void**)&alcCaptureOpenDevice, "alcCaptureOpenDevice");
    lib.bindSymbol(cast(void**)&alcCaptureCloseDevice, "alcCaptureCloseDevice");
    lib.bindSymbol(cast(void**)&alcCaptureStart, "alcCaptureStart");
    lib.bindSymbol(cast(void**)&alcCaptureStop, "alcCaptureStop");
    lib.bindSymbol(cast(void**)&alcCaptureSamples, "alcCaptureSamples");

    //EFX Extension
    lib.bindSymbol(cast(void**)&alGenEffects, "alGenEffects");
    lib.bindSymbol(cast(void**)&alDeleteEffects, "alDeleteEffects");
    lib.bindSymbol(cast(void**)&alIsEffect, "alIsEffect");
    lib.bindSymbol(cast(void**)&alEffecti, "alEffecti");
    lib.bindSymbol(cast(void**)&alEffectiv, "alEffectiv");
    lib.bindSymbol(cast(void**)&alEffectf, "alEffectf");
    lib.bindSymbol(cast(void**)&alEffectfv, "alEffectfv");
    lib.bindSymbol(cast(void**)&alGetEffecti, "alGetEffecti");
    lib.bindSymbol(cast(void**)&alGetEffectiv, "alGetEffectiv");
    lib.bindSymbol(cast(void**)&alGetEffectf, "alGetEffectf");
    lib.bindSymbol(cast(void**)&alGetEffectfv, "alGetEffectfv");
    lib.bindSymbol(cast(void**)&alGenFilters, "alGenFilters");
    lib.bindSymbol(cast(void**)&alDeleteFilters, "alDeleteFilters");
    lib.bindSymbol(cast(void**)&alIsFilter, "alIsFilter");
    lib.bindSymbol(cast(void**)&alFilteri, "alFilteri");
    lib.bindSymbol(cast(void**)&alFilteriv, "alFilteriv");
    lib.bindSymbol(cast(void**)&alFilterf, "alFilterf");
    lib.bindSymbol(cast(void**)&alFilterfv, "alFilterfv");
    lib.bindSymbol(cast(void**)&alGetFilteri, "alGetFilteri");
    lib.bindSymbol(cast(void**)&alGetFilteriv, "alGetFilteriv");
    lib.bindSymbol(cast(void**)&alGetFilterf, "alGetFilterf");
    lib.bindSymbol(cast(void**)&alGetFilterfv, "alGetFilterfv");
    lib.bindSymbol(cast(void**)&alGenAuxiliaryEffectSlots, "alGenAuxiliaryEffectSlots");
    lib.bindSymbol(cast(void**)&alDeleteAuxiliaryEffectSlots, "alDeleteAuxiliaryEffectSlots");
    lib.bindSymbol(cast(void**)&alIsAuxiliaryEffectSlot, "alIsAuxiliaryEffectSlot");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSloti, "alAuxiliaryEffectSloti");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSlotiv, "alAuxiliaryEffectSlotiv");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSlotf, "alAuxiliaryEffectSlotf");
    lib.bindSymbol(cast(void**)&alAuxiliaryEffectSlotfv, "alAuxiliaryEffectSlotfv");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSloti, "alGetAuxiliaryEffectSloti");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSlotiv, "alGetAuxiliaryEffectSlotiv");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSlotf, "alGetAuxiliaryEffectSlotf");
    lib.bindSymbol(cast(void**)&alGetAuxiliaryEffectSlotfv, "alGetAuxiliaryEffectSlotfv");

    if(errorCount() != errCount) loadedVersion = ALSupport.badLibrary;
    else loadedVersion = ALSupport.al11;

    return loadedVersion;
}
