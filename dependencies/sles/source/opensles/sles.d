module opensles.sles;

import core.stdc.config;
import core.stdc.stdarg: va_list;
static import core.simd;
static import std.conv;

struct Int128 { long lower; long upper; }
struct UInt128 { ulong lower; ulong upper; }

struct __locale_data { int dummy; }



alias _Bool = bool;
struct dpp {
    static struct Opaque(int N) {
        void[N] bytes;
    }

    static bool isEmpty(T)() {
        return T.tupleof.length == 0;
    }
    static struct Move(T) {
        T* ptr;
    }


    static auto move(T)(ref T value) {
        return Move!T(&value);
    }
    mixin template EnumD(string name, T, string prefix) if(is(T == enum)) {
        private static string _memberMixinStr(string member) {
            import std.conv: text;
            import std.array: replace;
            return text(` `, member.replace(prefix, ""), ` = `, T.stringof, `.`, member, `,`);
        }
        private static string _enumMixinStr() {
            import std.array: join;
            string[] ret;
            ret ~= "enum " ~ name ~ "{";
            static foreach(member; __traits(allMembers, T)) {
                ret ~= _memberMixinStr(member);
            }
            ret ~= "}";
            return ret.join("\n");
        }
        mixin(_enumMixinStr());
    }
}

extern(C)
{
    alias sl_uint64_t = ulong;
    alias sl_int64_t = long;
    alias sl_int32_t = int;
    alias sl_uint32_t = uint;
    alias sl_int16_t = short;
    alias sl_uint16_t = ushort;
    alias sl_int8_t = byte;
    alias sl_uint8_t = ubyte;
    uint slQuerySupportedEngineInterfaces(uint, const(SLInterfaceID_)**) @nogc nothrow;
    uint slQueryNumSupportedEngineInterfaces(uint*) @nogc nothrow;
    uint slCreateEngine(const(const(SLObjectItf_)*)**, uint, const(SLEngineOption_)*, uint, const(const(SLInterfaceID_)*)*, const(uint)*) @nogc nothrow;
    struct SLEngineOption_
    {
        uint feature;
        uint data;
    }
    alias SLEngineOption = SLEngineOption_;
    alias SLThreadSyncItf = const(const(SLThreadSyncItf_)*)*;
    struct SLThreadSyncItf_
    {
        uint function(const(const(SLThreadSyncItf_)*)*) EnterCriticalSection;
        uint function(const(const(SLThreadSyncItf_)*)*) ExitCriticalSection;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_THREADSYNC;
    alias SLEngineCapabilitiesItf = const(const(SLEngineCapabilitiesItf_)*)*;
    struct SLEngineCapabilitiesItf_
    {
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, ushort*) QuerySupportedProfiles;
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, ushort, short*, uint*, short*) QueryAvailableVoices;
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, short*) QueryNumberOfMIDISynthesizers;
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, short*, short*, short*) QueryAPIVersion;
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, uint*, uint*, SLLEDDescriptor_*) QueryLEDCapabilities;
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, uint*, uint*, SLVibraDescriptor_*) QueryVibraCapabilities;
        uint function(const(const(SLEngineCapabilitiesItf_)*)*, uint*) IsThreadSafe;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_ENGINECAPABILITIES;
    alias SLEngineItf = const(const(SLEngineItf_)*)*;
    struct SLEngineItf_
    {
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, uint, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateLEDDevice;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, uint, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateVibraDevice;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, SLDataSource_*, SLDataSink_*, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateAudioPlayer;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, SLDataSource_*, SLDataSink_*, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateAudioRecorder;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, SLDataSource_*, SLDataSource_*, SLDataSink_*, SLDataSink_*, SLDataSink_*, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateMidiPlayer;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateListener;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, uint, const(const(SLInterfaceID_)*)*, const(uint)*) Create3DGroup;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateOutputMix;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, SLDataSource_*, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateMetadataExtractor;
        uint function(const(const(SLEngineItf_)*)*, const(const(SLObjectItf_)*)**, void*, uint, uint, const(const(SLInterfaceID_)*)*, const(uint)*) CreateExtensionObject;
        uint function(const(const(SLEngineItf_)*)*, uint, uint*) QueryNumSupportedInterfaces;
        uint function(const(const(SLEngineItf_)*)*, uint, uint, const(SLInterfaceID_)**) QuerySupportedInterfaces;
        uint function(const(const(SLEngineItf_)*)*, uint*) QueryNumSupportedExtensions;
        uint function(const(const(SLEngineItf_)*)*, uint, ubyte*, short*) QuerySupportedExtension;
        uint function(const(const(SLEngineItf_)*)*, const(ubyte)*, uint*) IsExtensionSupported;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_ENGINE;
    alias slVisualizationCallback = void function(void*, const(ubyte)*, const(ubyte)*, uint);
    alias SLVisualizationItf = const(const(SLVisualizationItf_)*)*;
    struct SLVisualizationItf_
    {
        uint function(const(const(SLVisualizationItf_)*)*, void function(void*, const(ubyte)[0], const(ubyte)[0], uint), void*, uint) RegisterVisualizationCallback;
        uint function(const(const(SLVisualizationItf_)*)*, uint*) GetMaxRate;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_VISUALIZATION;
    alias SLVirtualizerItf = const(const(SLVirtualizerItf_)*)*;
    struct SLVirtualizerItf_
    {
        uint function(const(const(SLVirtualizerItf_)*)*, uint) SetEnabled;
        uint function(const(const(SLVirtualizerItf_)*)*, uint*) IsEnabled;
        uint function(const(const(SLVirtualizerItf_)*)*, short) SetStrength;
        uint function(const(const(SLVirtualizerItf_)*)*, short*) GetRoundedStrength;
        uint function(const(const(SLVirtualizerItf_)*)*, uint*) IsStrengthSupported;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_VIRTUALIZER;
    alias SLRatePitchItf = const(const(SLRatePitchItf_)*)*;
    struct SLRatePitchItf_
    {
        uint function(const(const(SLRatePitchItf_)*)*, short) SetRate;
        uint function(const(const(SLRatePitchItf_)*)*, short*) GetRate;
        uint function(const(const(SLRatePitchItf_)*)*, short*, short*) GetRatePitchCapabilities;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_RATEPITCH;
    alias SLPitchItf = const(const(SLPitchItf_)*)*;
    struct SLPitchItf_
    {
        uint function(const(const(SLPitchItf_)*)*, short) SetPitch;
        uint function(const(const(SLPitchItf_)*)*, short*) GetPitch;
        uint function(const(const(SLPitchItf_)*)*, short*, short*) GetPitchCapabilities;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_PITCH;
    alias SLBassBoostItf = const(const(SLBassBoostItf_)*)*;
    struct SLBassBoostItf_
    {
        uint function(const(const(SLBassBoostItf_)*)*, uint) SetEnabled;
        uint function(const(const(SLBassBoostItf_)*)*, uint*) IsEnabled;
        uint function(const(const(SLBassBoostItf_)*)*, short) SetStrength;
        uint function(const(const(SLBassBoostItf_)*)*, short*) GetRoundedStrength;
        uint function(const(const(SLBassBoostItf_)*)*, uint*) IsStrengthSupported;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_BASSBOOST;
    alias SLAudioEncoderItf = const(const(SLAudioEncoderItf_)*)*;
    struct SLAudioEncoderItf_
    {
        uint function(const(const(SLAudioEncoderItf_)*)*, SLAudioEncoderSettings_*) SetEncoderSettings;
        uint function(const(const(SLAudioEncoderItf_)*)*, SLAudioEncoderSettings_*) GetEncoderSettings;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_AUDIOENCODER;
    alias SLAudioEncoderCapabilitiesItf = const(const(SLAudioEncoderCapabilitiesItf_)*)*;
    struct SLAudioEncoderCapabilitiesItf_
    {
        uint function(const(const(SLAudioEncoderCapabilitiesItf_)*)*, uint*, uint*) GetAudioEncoders;
        uint function(const(const(SLAudioEncoderCapabilitiesItf_)*)*, uint, uint*, SLAudioCodecDescriptor_*) GetAudioEncoderCapabilities;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_AUDIOENCODERCAPABILITIES;
    struct SLAudioEncoderSettings_
    {
        uint encoderId;
        uint channelsIn;
        uint channelsOut;
        uint sampleRate;
        uint bitRate;
        uint bitsPerSample;
        uint rateControl;
        uint profileSetting;
        uint levelSetting;
        uint channelMode;
        uint streamFormat;
        uint encodeOptions;
        uint blockAlignment;
    }
    alias SLAudioEncoderSettings = SLAudioEncoderSettings_;
    alias SLAudioDecoderCapabilitiesItf = const(const(SLAudioDecoderCapabilitiesItf_)*)*;
    struct SLAudioDecoderCapabilitiesItf_
    {
        uint function(const(const(SLAudioDecoderCapabilitiesItf_)*)*, uint*, uint*) GetAudioDecoders;
        uint function(const(const(SLAudioDecoderCapabilitiesItf_)*)*, uint, uint*, SLAudioCodecDescriptor_*) GetAudioDecoderCapabilities;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_AUDIODECODERCAPABILITIES;
    struct SLAudioCodecProfileMode_
    {
        uint profileSetting;
        uint modeSetting;
    }
    alias SLAudioCodecProfileMode = SLAudioCodecProfileMode_;
    struct SLAudioCodecDescriptor_
    {
        uint maxChannels;
        uint minBitsPerSample;
        uint maxBitsPerSample;
        uint minSampleRate;
        uint maxSampleRate;
        uint isFreqRangeContinuous;
        uint* pSampleRatesSupported;
        uint numSampleRatesSupported;
        uint minBitRate;
        uint maxBitRate;
        uint isBitrateRangeContinuous;
        uint* pBitratesSupported;
        uint numBitratesSupported;
        uint profileSetting;
        uint modeSetting;
    }
    alias SLAudioCodecDescriptor = SLAudioCodecDescriptor_;
    alias SLMIDITimeItf = const(const(SLMIDITimeItf_)*)*;
    struct SLMIDITimeItf_
    {
        uint function(const(const(SLMIDITimeItf_)*)*, uint*) GetDuration;
        uint function(const(const(SLMIDITimeItf_)*)*, uint) SetPosition;
        uint function(const(const(SLMIDITimeItf_)*)*, uint*) GetPosition;
        uint function(const(const(SLMIDITimeItf_)*)*, uint, uint) SetLoopPoints;
        uint function(const(const(SLMIDITimeItf_)*)*, uint*, uint*) GetLoopPoints;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_MIDITIME;
    alias SLMIDITempoItf = const(const(SLMIDITempoItf_)*)*;
    struct SLMIDITempoItf_
    {
        uint function(const(const(SLMIDITempoItf_)*)*, uint) SetTicksPerQuarterNote;
        uint function(const(const(SLMIDITempoItf_)*)*, uint*) GetTicksPerQuarterNote;
        uint function(const(const(SLMIDITempoItf_)*)*, uint) SetMicrosecondsPerQuarterNote;
        uint function(const(const(SLMIDITempoItf_)*)*, uint*) GetMicrosecondsPerQuarterNote;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_MIDITEMPO;
    alias SLMIDIMuteSoloItf = const(const(SLMIDIMuteSoloItf_)*)*;
    struct SLMIDIMuteSoloItf_
    {
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ubyte, uint) SetChannelMute;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ubyte, uint*) GetChannelMute;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ubyte, uint) SetChannelSolo;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ubyte, uint*) GetChannelSolo;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ushort*) GetTrackCount;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ushort, uint) SetTrackMute;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ushort, uint*) GetTrackMute;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ushort, uint) SetTrackSolo;
        uint function(const(const(SLMIDIMuteSoloItf_)*)*, ushort, uint*) GetTrackSolo;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_MIDIMUTESOLO;
    alias slMIDIMessageCallback = void function(const(const(SLMIDIMessageItf_)*)*, void*, ubyte, uint, const(ubyte)*, uint, ushort);
    alias slMetaEventCallback = void function(const(const(SLMIDIMessageItf_)*)*, void*, ubyte, uint, const(ubyte)*, uint, ushort);
    alias SLMIDIMessageItf = const(const(SLMIDIMessageItf_)*)*;
    struct SLMIDIMessageItf_
    {
        uint function(const(const(SLMIDIMessageItf_)*)*, const(ubyte)*, uint) SendMessage;
        uint function(const(const(SLMIDIMessageItf_)*)*, void function(const(const(SLMIDIMessageItf_)*)*, void*, ubyte, uint, const(ubyte)*, uint, ushort), void*) RegisterMetaEventCallback;
        uint function(const(const(SLMIDIMessageItf_)*)*, void function(const(const(SLMIDIMessageItf_)*)*, void*, ubyte, uint, const(ubyte)*, uint, ushort), void*) RegisterMIDIMessageCallback;
        uint function(const(const(SLMIDIMessageItf_)*)*, uint) AddMIDIMessageCallbackFilter;
        uint function(const(const(SLMIDIMessageItf_)*)*) ClearMIDIMessageCallbackFilter;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_MIDIMESSAGE;
    alias slDynamicInterfaceManagementCallback = void function(const(const(SLDynamicInterfaceManagementItf_)*)*, void*, uint, uint, const(SLInterfaceID_)*);
    alias SLDynamicInterfaceManagementItf = const(const(SLDynamicInterfaceManagementItf_)*)*;
    struct SLDynamicInterfaceManagementItf_
    {
        uint function(const(const(SLDynamicInterfaceManagementItf_)*)*, const(const(SLInterfaceID_)*), uint) AddInterface;
        uint function(const(const(SLDynamicInterfaceManagementItf_)*)*, const(const(SLInterfaceID_)*)) RemoveInterface;
        uint function(const(const(SLDynamicInterfaceManagementItf_)*)*, const(const(SLInterfaceID_)*), uint) ResumeInterface;
        uint function(const(const(SLDynamicInterfaceManagementItf_)*)*, void function(const(const(SLDynamicInterfaceManagementItf_)*)*, void*, uint, uint, const(const(SLInterfaceID_)*)), void*) RegisterCallback;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_DYNAMICINTERFACEMANAGEMENT;
    alias SLMuteSoloItf = const(const(SLMuteSoloItf_)*)*;
    struct SLMuteSoloItf_
    {
        uint function(const(const(SLMuteSoloItf_)*)*, ubyte, uint) SetChannelMute;
        uint function(const(const(SLMuteSoloItf_)*)*, ubyte, uint*) GetChannelMute;
        uint function(const(const(SLMuteSoloItf_)*)*, ubyte, uint) SetChannelSolo;
        uint function(const(const(SLMuteSoloItf_)*)*, ubyte, uint*) GetChannelSolo;
        uint function(const(const(SLMuteSoloItf_)*)*, ubyte*) GetNumChannels;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_MUTESOLO;
    alias SL3DMacroscopicItf = const(const(SL3DMacroscopicItf_)*)*;
    struct SL3DMacroscopicItf_
    {
        uint function(const(const(SL3DMacroscopicItf_)*)*, int, int, int) SetSize;
        uint function(const(const(SL3DMacroscopicItf_)*)*, int*, int*, int*) GetSize;
        uint function(const(const(SL3DMacroscopicItf_)*)*, int, int, int) SetOrientationAngles;
        uint function(const(const(SL3DMacroscopicItf_)*)*, const(SLVec3D_)*, const(SLVec3D_)*) SetOrientationVectors;
        uint function(const(const(SL3DMacroscopicItf_)*)*, int, const(SLVec3D_)*) Rotate;
        uint function(const(const(SL3DMacroscopicItf_)*)*, SLVec3D_*, SLVec3D_*) GetOrientationVectors;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_3DMACROSCOPIC;
    alias SL3DSourceItf = const(const(SL3DSourceItf_)*)*;
    struct SL3DSourceItf_
    {
        uint function(const(const(SL3DSourceItf_)*)*, uint) SetHeadRelative;
        uint function(const(const(SL3DSourceItf_)*)*, uint*) GetHeadRelative;
        uint function(const(const(SL3DSourceItf_)*)*, int, int) SetRolloffDistances;
        uint function(const(const(SL3DSourceItf_)*)*, int*, int*) GetRolloffDistances;
        uint function(const(const(SL3DSourceItf_)*)*, uint) SetRolloffMaxDistanceMute;
        uint function(const(const(SL3DSourceItf_)*)*, uint*) GetRolloffMaxDistanceMute;
        uint function(const(const(SL3DSourceItf_)*)*, short) SetRolloffFactor;
        uint function(const(const(SL3DSourceItf_)*)*, short*) GetRolloffFactor;
        uint function(const(const(SL3DSourceItf_)*)*, short) SetRoomRolloffFactor;
        uint function(const(const(SL3DSourceItf_)*)*, short*) GetRoomRolloffFactor;
        uint function(const(const(SL3DSourceItf_)*)*, ubyte) SetRolloffModel;
        uint function(const(const(SL3DSourceItf_)*)*, ubyte*) GetRolloffModel;
        uint function(const(const(SL3DSourceItf_)*)*, int, int, short) SetCone;
        uint function(const(const(SL3DSourceItf_)*)*, int*, int*, short*) GetCone;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_3DSOURCE;
    alias SL3DDopplerItf = const(const(SL3DDopplerItf_)*)*;
    struct SL3DDopplerItf_
    {
        uint function(const(const(SL3DDopplerItf_)*)*, const(SLVec3D_)*) SetVelocityCartesian;
        uint function(const(const(SL3DDopplerItf_)*)*, int, int, int) SetVelocitySpherical;
        uint function(const(const(SL3DDopplerItf_)*)*, SLVec3D_*) GetVelocityCartesian;
        uint function(const(const(SL3DDopplerItf_)*)*, short) SetDopplerFactor;
        uint function(const(const(SL3DDopplerItf_)*)*, short*) GetDopplerFactor;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_3DDOPPLER;
    alias SL3DLocationItf = const(const(SL3DLocationItf_)*)*;
    struct SL3DLocationItf_
    {
        uint function(const(const(SL3DLocationItf_)*)*, const(SLVec3D_)*) SetLocationCartesian;
        uint function(const(const(SL3DLocationItf_)*)*, int, int, int) SetLocationSpherical;
        uint function(const(const(SL3DLocationItf_)*)*, const(SLVec3D_)*) Move;
        uint function(const(const(SL3DLocationItf_)*)*, SLVec3D_*) GetLocationCartesian;
        uint function(const(const(SL3DLocationItf_)*)*, const(SLVec3D_)*, const(SLVec3D_)*) SetOrientationVectors;
        uint function(const(const(SL3DLocationItf_)*)*, int, int, int) SetOrientationAngles;
        uint function(const(const(SL3DLocationItf_)*)*, int, const(SLVec3D_)*) Rotate;
        uint function(const(const(SL3DLocationItf_)*)*, SLVec3D_*, SLVec3D_*) GetOrientationVectors;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_3DLOCATION;
    struct SLVec3D_
    {
        int x;
        int y;
        int z;
    }
    alias SLVec3D = SLVec3D_;
    alias SL3DCommitItf = const(const(SL3DCommitItf_)*)*;
    struct SL3DCommitItf_
    {
        uint function(const(const(SL3DCommitItf_)*)*) Commit;
        uint function(const(const(SL3DCommitItf_)*)*, uint) SetDeferred;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_3DCOMMIT;
    alias SL3DGroupingItf = const(const(SL3DGroupingItf_)*)*;
    struct SL3DGroupingItf_
    {
        uint function(const(const(SL3DGroupingItf_)*)*, const(const(SLObjectItf_)*)*) Set3DGroup;
        uint function(const(const(SL3DGroupingItf_)*)*, const(const(SLObjectItf_)*)**) Get3DGroup;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_3DGROUPING;
    alias SLEffectSendItf = const(const(SLEffectSendItf_)*)*;
    struct SLEffectSendItf_
    {
        uint function(const(const(SLEffectSendItf_)*)*, const(void)*, uint, short) EnableEffectSend;
        uint function(const(const(SLEffectSendItf_)*)*, const(void)*, uint*) IsEnabled;
        uint function(const(const(SLEffectSendItf_)*)*, short) SetDirectLevel;
        uint function(const(const(SLEffectSendItf_)*)*, short*) GetDirectLevel;
        uint function(const(const(SLEffectSendItf_)*)*, const(void)*, short) SetSendLevel;
        uint function(const(const(SLEffectSendItf_)*)*, const(void)*, short*) GetSendLevel;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_EFFECTSEND;
    alias SLEnvironmentalReverbItf = const(const(SLEnvironmentalReverbItf_)*)*;
    struct SLEnvironmentalReverbItf_
    {
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetRoomLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetRoomLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetRoomHFLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetRoomHFLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, uint) SetDecayTime;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, uint*) GetDecayTime;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetDecayHFRatio;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetDecayHFRatio;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetReflectionsLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetReflectionsLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, uint) SetReflectionsDelay;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, uint*) GetReflectionsDelay;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetReverbLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetReverbLevel;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, uint) SetReverbDelay;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, uint*) GetReverbDelay;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetDiffusion;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetDiffusion;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short) SetDensity;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, short*) GetDensity;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, const(SLEnvironmentalReverbSettings_)*) SetEnvironmentalReverbProperties;
        uint function(const(const(SLEnvironmentalReverbItf_)*)*, SLEnvironmentalReverbSettings_*) GetEnvironmentalReverbProperties;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_ENVIRONMENTALREVERB;
    struct SLEnvironmentalReverbSettings_
    {
        short roomLevel;
        short roomHFLevel;
        uint decayTime;
        short decayHFRatio;
        short reflectionsLevel;
        uint reflectionsDelay;
        short reverbLevel;
        uint reverbDelay;
        short diffusion;
        short density;
    }
    alias SLEnvironmentalReverbSettings = SLEnvironmentalReverbSettings_;
    alias SLPresetReverbItf = const(const(SLPresetReverbItf_)*)*;
    struct SLPresetReverbItf_
    {
        uint function(const(const(SLPresetReverbItf_)*)*, ushort) SetPreset;
        uint function(const(const(SLPresetReverbItf_)*)*, ushort*) GetPreset;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_PRESETREVERB;
    struct SLBufferQueueState_
    {
        uint count;
        uint playIndex;
    }
    alias SLBufferQueueState = SLBufferQueueState_;
    alias slBufferQueueCallback = void function(const(const(SLBufferQueueItf_)*)*, void*);
    alias SLBufferQueueItf = const(const(SLBufferQueueItf_)*)*;
    struct SLBufferQueueItf_
    {
        uint function(const(const(SLBufferQueueItf_)*)*, const(void)*, uint) Enqueue;
        uint function(const(const(SLBufferQueueItf_)*)*) Clear;
        uint function(const(const(SLBufferQueueItf_)*)*, SLBufferQueueState_*) GetState;
        uint function(const(const(SLBufferQueueItf_)*)*, void function(const(const(SLBufferQueueItf_)*)*, void*), void*) RegisterCallback;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_BUFFERQUEUE;
    alias SLDeviceVolumeItf = const(const(SLDeviceVolumeItf_)*)*;
    struct SLDeviceVolumeItf_
    {
        uint function(const(const(SLDeviceVolumeItf_)*)*, uint, int*, int*, uint*) GetVolumeScale;
        uint function(const(const(SLDeviceVolumeItf_)*)*, uint, int) SetVolume;
        uint function(const(const(SLDeviceVolumeItf_)*)*, uint, int*) GetVolume;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_DEVICEVOLUME;
    alias SLVolumeItf = const(const(SLVolumeItf_)*)*;
    struct SLVolumeItf_
    {
        uint function(const(const(SLVolumeItf_)*)*, short) SetVolumeLevel;
        uint function(const(const(SLVolumeItf_)*)*, short*) GetVolumeLevel;
        uint function(const(const(SLVolumeItf_)*)*, short*) GetMaxVolumeLevel;
        uint function(const(const(SLVolumeItf_)*)*, uint) SetMute;
        uint function(const(const(SLVolumeItf_)*)*, uint*) GetMute;
        uint function(const(const(SLVolumeItf_)*)*, uint) EnableStereoPosition;
        uint function(const(const(SLVolumeItf_)*)*, uint*) IsEnabledStereoPosition;
        uint function(const(const(SLVolumeItf_)*)*, short) SetStereoPosition;
        uint function(const(const(SLVolumeItf_)*)*, short*) GetStereoPosition;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_VOLUME;
    alias SLEqualizerItf = const(const(SLEqualizerItf_)*)*;
    struct SLEqualizerItf_
    {
        uint function(const(const(SLEqualizerItf_)*)*, uint) SetEnabled;
        uint function(const(const(SLEqualizerItf_)*)*, uint*) IsEnabled;
        uint function(const(const(SLEqualizerItf_)*)*, ushort*) GetNumberOfBands;
        uint function(const(const(SLEqualizerItf_)*)*, short*, short*) GetBandLevelRange;
        uint function(const(const(SLEqualizerItf_)*)*, ushort, short) SetBandLevel;
        uint function(const(const(SLEqualizerItf_)*)*, ushort, short*) GetBandLevel;
        uint function(const(const(SLEqualizerItf_)*)*, ushort, uint*) GetCenterFreq;
        uint function(const(const(SLEqualizerItf_)*)*, ushort, uint*, uint*) GetBandFreqRange;
        uint function(const(const(SLEqualizerItf_)*)*, uint, ushort*) GetBand;
        uint function(const(const(SLEqualizerItf_)*)*, ushort*) GetCurrentPreset;
        uint function(const(const(SLEqualizerItf_)*)*, ushort) UsePreset;
        uint function(const(const(SLEqualizerItf_)*)*, ushort*) GetNumberOfPresets;
        uint function(const(const(SLEqualizerItf_)*)*, ushort, const(ubyte)**) GetPresetName;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_EQUALIZER;
    alias slRecordCallback = void function(const(const(SLRecordItf_)*)*, void*, uint);
    alias SLRecordItf = const(const(SLRecordItf_)*)*;
    struct SLRecordItf_
    {
        uint function(const(const(SLRecordItf_)*)*, uint) SetRecordState;
        uint function(const(const(SLRecordItf_)*)*, uint*) GetRecordState;
        uint function(const(const(SLRecordItf_)*)*, uint) SetDurationLimit;
        uint function(const(const(SLRecordItf_)*)*, uint*) GetPosition;
        uint function(const(const(SLRecordItf_)*)*, void function(const(const(SLRecordItf_)*)*, void*, uint), void*) RegisterCallback;
        uint function(const(const(SLRecordItf_)*)*, uint) SetCallbackEventsMask;
        uint function(const(const(SLRecordItf_)*)*, uint*) GetCallbackEventsMask;
        uint function(const(const(SLRecordItf_)*)*, uint) SetMarkerPosition;
        uint function(const(const(SLRecordItf_)*)*) ClearMarkerPosition;
        uint function(const(const(SLRecordItf_)*)*, uint*) GetMarkerPosition;
        uint function(const(const(SLRecordItf_)*)*, uint) SetPositionUpdatePeriod;
        uint function(const(const(SLRecordItf_)*)*, uint*) GetPositionUpdatePeriod;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_RECORD;
    alias SLSeekItf = const(const(SLSeekItf_)*)*;
    struct SLSeekItf_
    {
        uint function(const(const(SLSeekItf_)*)*, uint, uint) SetPosition;
        uint function(const(const(SLSeekItf_)*)*, uint, uint, uint) SetLoop;
        uint function(const(const(SLSeekItf_)*)*, uint*, uint*, uint*) GetLoop;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_SEEK;
    alias SLPlaybackRateItf = const(const(SLPlaybackRateItf_)*)*;
    struct SLPlaybackRateItf_
    {
        uint function(const(const(SLPlaybackRateItf_)*)*, short) SetRate;
        uint function(const(const(SLPlaybackRateItf_)*)*, short*) GetRate;
        uint function(const(const(SLPlaybackRateItf_)*)*, uint) SetPropertyConstraints;
        uint function(const(const(SLPlaybackRateItf_)*)*, uint*) GetProperties;
        uint function(const(const(SLPlaybackRateItf_)*)*, short, uint*) GetCapabilitiesOfRate;
        uint function(const(const(SLPlaybackRateItf_)*)*, ubyte, short*, short*, short*, uint*) GetRateRange;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_PLAYBACKRATE;
    alias slPrefetchCallback = void function(const(const(SLPrefetchStatusItf_)*)*, void*, uint);
    alias SLPrefetchStatusItf = const(const(SLPrefetchStatusItf_)*)*;
    struct SLPrefetchStatusItf_
    {
        uint function(const(const(SLPrefetchStatusItf_)*)*, uint*) GetPrefetchStatus;
        uint function(const(const(SLPrefetchStatusItf_)*)*, short*) GetFillLevel;
        uint function(const(const(SLPrefetchStatusItf_)*)*, void function(const(const(SLPrefetchStatusItf_)*)*, void*, uint), void*) RegisterCallback;
        uint function(const(const(SLPrefetchStatusItf_)*)*, uint) SetCallbackEventsMask;
        uint function(const(const(SLPrefetchStatusItf_)*)*, uint*) GetCallbackEventsMask;
        uint function(const(const(SLPrefetchStatusItf_)*)*, short) SetFillUpdatePeriod;
        uint function(const(const(SLPrefetchStatusItf_)*)*, short*) GetFillUpdatePeriod;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_PREFETCHSTATUS;
    alias slPlayCallback = void function(const(const(SLPlayItf_)*)*, void*, uint);
    alias SLPlayItf = const(const(SLPlayItf_)*)*;
    struct SLPlayItf_
    {
        uint function(const(const(SLPlayItf_)*)*, uint) SetPlayState;
        uint function(const(const(SLPlayItf_)*)*, uint*) GetPlayState;
        uint function(const(const(SLPlayItf_)*)*, uint*) GetDuration;
        uint function(const(const(SLPlayItf_)*)*, uint*) GetPosition;
        uint function(const(const(SLPlayItf_)*)*, void function(const(const(SLPlayItf_)*)*, void*, uint), void*) RegisterCallback;
        uint function(const(const(SLPlayItf_)*)*, uint) SetCallbackEventsMask;
        uint function(const(const(SLPlayItf_)*)*, uint*) GetCallbackEventsMask;
        uint function(const(const(SLPlayItf_)*)*, uint) SetMarkerPosition;
        uint function(const(const(SLPlayItf_)*)*) ClearMarkerPosition;
        uint function(const(const(SLPlayItf_)*)*, uint*) GetMarkerPosition;
        uint function(const(const(SLPlayItf_)*)*, uint) SetPositionUpdatePeriod;
        uint function(const(const(SLPlayItf_)*)*, uint*) GetPositionUpdatePeriod;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_PLAY;
    alias slMixDeviceChangeCallback = void function(const(const(SLOutputMixItf_)*)*, void*);
    alias SLOutputMixItf = const(const(SLOutputMixItf_)*)*;
    struct SLOutputMixItf_
    {
        uint function(const(const(SLOutputMixItf_)*)*, int*, uint*) GetDestinationOutputDeviceIDs;
        uint function(const(const(SLOutputMixItf_)*)*, void function(const(const(SLOutputMixItf_)*)*, void*), void*) RegisterDeviceChangeCallback;
        uint function(const(const(SLOutputMixItf_)*)*, int, uint*) ReRoute;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_OUTPUTMIX;
    alias SLDynamicSourceItf = const(const(SLDynamicSourceItf_)*)*;
    struct SLDynamicSourceItf_
    {
        uint function(const(const(SLDynamicSourceItf_)*)*, SLDataSource_*) SetSource;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_DYNAMICSOURCE;
    alias SLMetadataTraversalItf = const(const(SLMetadataTraversalItf_)*)*;
    struct SLMetadataTraversalItf_
    {
        uint function(const(const(SLMetadataTraversalItf_)*)*, uint) SetMode;
        uint function(const(const(SLMetadataTraversalItf_)*)*, uint*) GetChildCount;
        uint function(const(const(SLMetadataTraversalItf_)*)*, uint, uint*) GetChildMIMETypeSize;
        uint function(const(const(SLMetadataTraversalItf_)*)*, uint, int*, uint*, uint, ubyte*) GetChildInfo;
        uint function(const(const(SLMetadataTraversalItf_)*)*, uint) SetActiveNode;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_METADATATRAVERSAL;
    alias SLMetadataExtractionItf = const(const(SLMetadataExtractionItf_)*)*;
    struct SLMetadataExtractionItf_
    {
        uint function(const(const(SLMetadataExtractionItf_)*)*, uint*) GetItemCount;
        uint function(const(const(SLMetadataExtractionItf_)*)*, uint, uint*) GetKeySize;
        uint function(const(const(SLMetadataExtractionItf_)*)*, uint, uint, SLMetadataInfo_*) GetKey;
        uint function(const(const(SLMetadataExtractionItf_)*)*, uint, uint*) GetValueSize;
        uint function(const(const(SLMetadataExtractionItf_)*)*, uint, uint, SLMetadataInfo_*) GetValue;
        uint function(const(const(SLMetadataExtractionItf_)*)*, uint, const(void)*, uint, const(ubyte)*, uint, ubyte) AddKeyFilter;
        uint function(const(const(SLMetadataExtractionItf_)*)*) ClearKeyFilter;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_METADATAEXTRACTION;
    struct SLMetadataInfo_
    {
        uint size;
        uint encoding;
        ubyte[16] langCountry;
        ubyte[1] data;
    }
    alias SLMetadataInfo = SLMetadataInfo_;
    alias SLVibraItf = const(const(SLVibraItf_)*)*;
    struct SLVibraItf_
    {
        uint function(const(const(SLVibraItf_)*)*, uint) Vibrate;
        uint function(const(const(SLVibraItf_)*)*, uint*) IsVibrating;
        uint function(const(const(SLVibraItf_)*)*, uint) SetFrequency;
        uint function(const(const(SLVibraItf_)*)*, uint*) GetFrequency;
        uint function(const(const(SLVibraItf_)*)*, short) SetIntensity;
        uint function(const(const(SLVibraItf_)*)*, short*) GetIntensity;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_VIBRA;
    struct SLVibraDescriptor_
    {
        uint supportsFrequency;
        uint supportsIntensity;
        uint minFrequency;
        uint maxFrequency;
    }
    alias SLVibraDescriptor = SLVibraDescriptor_;
    alias SLLEDArrayItf = const(const(SLLEDArrayItf_)*)*;
    struct SLLEDArrayItf_
    {
        uint function(const(const(SLLEDArrayItf_)*)*, uint) ActivateLEDArray;
        uint function(const(const(SLLEDArrayItf_)*)*, uint*) IsLEDArrayActivated;
        uint function(const(const(SLLEDArrayItf_)*)*, ubyte, const(SLHSL_)*) SetColor;
        uint function(const(const(SLLEDArrayItf_)*)*, ubyte, SLHSL_*) GetColor;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_LED;
    struct SLHSL_
    {
        int hue;
        short saturation;
        short lightness;
    }
    alias SLHSL = SLHSL_;
    struct SLLEDDescriptor_
    {
        ubyte ledCount;
        ubyte primaryLED;
        uint colorMask;
    }
    alias SLLEDDescriptor = SLLEDDescriptor_;
    alias slDefaultDeviceIDMapChangedCallback = void function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void*, uint, int);
    alias slAvailableAudioOutputsChangedCallback = void function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void*, uint, int, uint);
    alias slAvailableAudioInputsChangedCallback = void function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void*, uint, int, uint);
    alias SLAudioIODeviceCapabilitiesItf = const(const(SLAudioIODeviceCapabilitiesItf_)*)*;
    struct SLAudioIODeviceCapabilitiesItf_
    {
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, int*, uint*) GetAvailableAudioInputs;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, uint, SLAudioInputDescriptor_*) QueryAudioInputCapabilities;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void*, uint, int, uint), void*) RegisterAvailableAudioInputsChangedCallback;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, int*, uint*) GetAvailableAudioOutputs;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, uint, SLAudioOutputDescriptor_*) QueryAudioOutputCapabilities;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void*, uint, int, uint), void*) RegisterAvailableAudioOutputsChangedCallback;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, void*, uint, int), void*) RegisterDefaultDeviceIDMapChangedCallback;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, uint, int*, uint*) GetAssociatedAudioInputs;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, uint, int*, uint*) GetAssociatedAudioOutputs;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, uint, int*, uint*) GetDefaultAudioDevices;
        uint function(const(const(SLAudioIODeviceCapabilitiesItf_)*)*, uint, uint, int*, int*) QuerySampleFormatsSupported;
    }
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_AUDIOIODEVICECAPABILITIES;
    struct SLAudioOutputDescriptor_
    {
        ubyte* pDeviceName;
        short deviceConnection;
        short deviceScope;
        short deviceLocation;
        uint isForTelephony;
        uint minSampleRate;
        uint maxSampleRate;
        uint isFreqRangeContinuous;
        uint* samplingRatesSupported;
        short numOfSamplingRatesSupported;
        short maxChannels;
    }
    alias SLAudioOutputDescriptor = SLAudioOutputDescriptor_;
    struct SLAudioInputDescriptor_
    {
        ubyte* deviceName;
        short deviceConnection;
        short deviceScope;
        short deviceLocation;
        uint isForTelephony;
        uint minSampleRate;
        uint maxSampleRate;
        uint isFreqRangeContinuous;
        uint* samplingRatesSupported;
        short numOfSamplingRatesSupported;
        short maxChannels;
    }
    alias SLAudioInputDescriptor = SLAudioInputDescriptor_;
    alias slObjectCallback = void function(const(const(SLObjectItf_)*)*, const(void)*, uint, uint, uint, void*);
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_OBJECT;
    struct SLDataSink_
    {
        void* pLocator;
        void* pFormat;
    }
    alias SLDataSink = SLDataSink_;
    struct SLDataSource_
    {
        void* pLocator;
        void* pFormat;
    }
    alias SLDataSource = SLDataSource_;
    struct SLDataFormat_PCM_
    {
        uint formatType;
        uint numChannels;
        uint samplesPerSec;
        uint bitsPerSample;
        uint containerSize;
        uint channelMask;
        uint endianness;
    }
    alias SLDataFormat_PCM = SLDataFormat_PCM_;
    struct SLDataFormat_MIME_
    {
        uint formatType;
        ubyte* mimeType;
        uint containerType;
    }
    alias SLDataFormat_MIME = SLDataFormat_MIME_;
    struct SLDataLocator_MIDIBufferQueue
    {
        uint locatorType;
        uint tpqn;
        uint numBuffers;
    }
    struct SLDataLocator_BufferQueue
    {
        uint locatorType;
        uint numBuffers;
    }
    struct SLDataLocator_OutputMix
    {
        uint locatorType;
        const(const(SLObjectItf_)*)* outputMix;
    }
    struct SLDataLocator_IODevice_
    {
        uint locatorType;
        uint deviceType;
        uint deviceID;
        const(const(SLObjectItf_)*)* device;
    }
    alias SLDataLocator_IODevice = SLDataLocator_IODevice_;
    struct SLDataLocator_Address_
    {
        uint locatorType;
        void* pAddress;
        uint length;
    }
    alias SLDataLocator_Address = SLDataLocator_Address_;
    struct SLDataLocator_URI_
    {
        uint locatorType;
        ubyte* URI;
    }
    alias SLDataLocator_URI = SLDataLocator_URI_;
    extern __gshared const(const(SLInterfaceID_)*) SL_IID_NULL;
    alias SLObjectItf = const(const(SLObjectItf_)*)*;
    struct SLObjectItf_
    {
        uint function(const(const(SLObjectItf_)*)*, uint) Realize;
        uint function(const(const(SLObjectItf_)*)*, uint) Resume;
        uint function(const(const(SLObjectItf_)*)*, uint*) GetState;
        uint function(const(const(SLObjectItf_)*)*, const(const(SLInterfaceID_)*), void*) GetInterface;
        uint function(const(const(SLObjectItf_)*)*, void function(const(const(SLObjectItf_)*)*, const(void)*, uint, uint, uint, void*), void*) RegisterCallback;
        void function(const(const(SLObjectItf_)*)*) AbortAsyncOperation;
        void function(const(const(SLObjectItf_)*)*) Destroy;
        uint function(const(const(SLObjectItf_)*)*, int, uint) SetPriority;
        uint function(const(const(SLObjectItf_)*)*, int*, uint*) GetPriority;
        uint function(const(const(SLObjectItf_)*)*, short, const(SLInterfaceID_)**, uint) SetLossOfControlInterfaces;
    }
    struct SLInterfaceID_
    {
        uint time_low;
        ushort time_mid;
        ushort time_hi_and_version;
        ushort clock_seq;
        ubyte[6] node;
    }
    alias SLInterfaceID = const(SLInterfaceID_)*;
    alias SLresult = uint;
    alias SLmicrosecond = uint;
    alias SLpermille = short;
    alias SLmillidegree = int;
    alias SLmillimeter = int;
    alias SLmilliHertz = uint;
    alias SLmillisecond = uint;
    alias SLmillibel = short;
    alias SLchar = ubyte;
    alias SLboolean = uint;
    alias SLuint32 = uint;
    alias SLint32 = int;
    alias SLuint16 = ushort;
    alias SLint16 = short;
    alias SLuint8 = ubyte;
    alias SLint8 = byte;

    enum KHRONOS_TITLE = "KhronosTitle";
    enum KHRONOS_ALBUM = "KhronosAlbum";
    enum KHRONOS_TRACK_NUMBER = "KhronosTrackNumber";
    enum KHRONOS_ARTIST = "KhronosArtist";
    enum KHRONOS_GENRE = "KhronosGenre";
    enum KHRONOS_YEAR = "KhronosYear";
    enum KHRONOS_COMMENT = "KhronosComment";
    enum KHRONOS_ARTIST_URL = "KhronosArtistURL";
    enum KHRONOS_CONTENT_URL = "KhronosContentURL";
    enum KHRONOS_RATING = "KhronosRating";
    enum KHRONOS_ALBUM_ART = "KhronosAlbumArt";
    enum KHRONOS_COPYRIGHT = "KhronosCopyright";
    enum SL_BOOLEAN_FALSE = ( cast( SLboolean ) 0x00000000 );
    enum SL_BOOLEAN_TRUE = ( cast( SLboolean ) 0x00000001 );
    enum SL_MILLIBEL_MAX = ( cast( SLmillibel ) 0x7FFF );
    enum SL_MILLIBEL_MIN = ( cast( SLmillibel ) ( - ( cast( SLmillibel ) 0x7FFF ) - 1 ) );
    enum SL_MILLIHERTZ_MAX = ( cast( SLmilliHertz ) 0xFFFFFFFF );
    enum SL_MILLIMETER_MAX = ( cast( SLmillimeter ) 0x7FFFFFFF );
    enum SL_OBJECTID_ENGINE = ( cast( SLuint32 ) 0x00001001 );
    enum SL_OBJECTID_LEDDEVICE = ( cast( SLuint32 ) 0x00001002 );
    enum SL_OBJECTID_VIBRADEVICE = ( cast( SLuint32 ) 0x00001003 );
    enum SL_OBJECTID_AUDIOPLAYER = ( cast( SLuint32 ) 0x00001004 );
    enum SL_OBJECTID_AUDIORECORDER = ( cast( SLuint32 ) 0x00001005 );
    enum SL_OBJECTID_MIDIPLAYER = ( cast( SLuint32 ) 0x00001006 );
    enum SL_OBJECTID_LISTENER = ( cast( SLuint32 ) 0x00001007 );
    enum SL_OBJECTID_3DGROUP = ( cast( SLuint32 ) 0x00001008 );
    enum SL_OBJECTID_OUTPUTMIX = ( cast( SLuint32 ) 0x00001009 );
    enum SL_OBJECTID_METADATAEXTRACTOR = ( cast( SLuint32 ) 0x0000100A );
    enum SL_PROFILES_PHONE = ( cast( SLuint16 ) 0x0001 );
    enum SL_PROFILES_MUSIC = ( cast( SLuint16 ) 0x0002 );
    enum SL_PROFILES_GAME = ( cast( SLuint16 ) 0x0004 );
    enum SL_VOICETYPE_2D_AUDIO = ( cast( SLuint16 ) 0x0001 );
    enum SL_VOICETYPE_MIDI = ( cast( SLuint16 ) 0x0002 );
    enum SL_VOICETYPE_3D_AUDIO = ( cast( SLuint16 ) 0x0004 );
    enum SL_VOICETYPE_3D_MIDIOUTPUT = ( cast( SLuint16 ) 0x0008 );
    enum SL_PRIORITY_LOWEST = ( cast( SLint32 ) ( - 0x7FFFFFFF - 1 ) );
    enum SL_PRIORITY_VERYLOW = ( cast( SLint32 ) - 0x60000000 );
    enum SL_PRIORITY_LOW = ( cast( SLint32 ) - 0x40000000 );
    enum SL_PRIORITY_BELOWNORMAL = ( cast( SLint32 ) - 0x20000000 );
    enum SL_PRIORITY_NORMAL = ( cast( SLint32 ) 0x00000000 );
    enum SL_PRIORITY_ABOVENORMAL = ( cast( SLint32 ) 0x20000000 );
    enum SL_PRIORITY_HIGH = ( cast( SLint32 ) 0x40000000 );
    enum SL_PRIORITY_VERYHIGH = ( cast( SLint32 ) 0x60000000 );
    enum SL_PRIORITY_HIGHEST = ( cast( SLint32 ) 0x7FFFFFFF );
    enum SL_PCMSAMPLEFORMAT_FIXED_8 = ( cast( SLuint16 ) 0x0008 );
    enum SL_PCMSAMPLEFORMAT_FIXED_16 = ( cast( SLuint16 ) 0x0010 );
    enum SL_PCMSAMPLEFORMAT_FIXED_20 = ( cast( SLuint16 ) 0x0014 );
    enum SL_PCMSAMPLEFORMAT_FIXED_24 = ( cast( SLuint16 ) 0x0018 );
    enum SL_PCMSAMPLEFORMAT_FIXED_28 = ( cast( SLuint16 ) 0x001C );
    enum SL_PCMSAMPLEFORMAT_FIXED_32 = ( cast( SLuint16 ) 0x0020 );
    enum SL_SAMPLINGRATE_8 = ( cast( SLuint32 ) 8000000 );
    enum SL_SAMPLINGRATE_11_025 = ( cast( SLuint32 ) 11025000 );
    enum SL_SAMPLINGRATE_12 = ( cast( SLuint32 ) 12000000 );
    enum SL_SAMPLINGRATE_16 = ( cast( SLuint32 ) 16000000 );
    enum SL_SAMPLINGRATE_22_05 = ( cast( SLuint32 ) 22050000 );
    enum SL_SAMPLINGRATE_24 = ( cast( SLuint32 ) 24000000 );
    enum SL_SAMPLINGRATE_32 = ( cast( SLuint32 ) 32000000 );
    enum SL_SAMPLINGRATE_44_1 = ( cast( SLuint32 ) 44100000 );
    enum SL_SAMPLINGRATE_48 = ( cast( SLuint32 ) 48000000 );
    enum SL_SAMPLINGRATE_64 = ( cast( SLuint32 ) 64000000 );
    enum SL_SAMPLINGRATE_88_2 = ( cast( SLuint32 ) 88200000 );
    enum SL_SAMPLINGRATE_96 = ( cast( SLuint32 ) 96000000 );
    enum SL_SAMPLINGRATE_192 = ( cast( SLuint32 ) 192000000 );
    enum SL_SPEAKER_FRONT_LEFT = ( cast( SLuint32 ) 0x00000001 );
    enum SL_SPEAKER_FRONT_RIGHT = ( cast( SLuint32 ) 0x00000002 );
    enum SL_SPEAKER_FRONT_CENTER = ( cast( SLuint32 ) 0x00000004 );
    enum SL_SPEAKER_LOW_FREQUENCY = ( cast( SLuint32 ) 0x00000008 );
    enum SL_SPEAKER_BACK_LEFT = ( cast( SLuint32 ) 0x00000010 );
    enum SL_SPEAKER_BACK_RIGHT = ( cast( SLuint32 ) 0x00000020 );
    enum SL_SPEAKER_FRONT_LEFT_OF_CENTER = ( cast( SLuint32 ) 0x00000040 );
    enum SL_SPEAKER_FRONT_RIGHT_OF_CENTER = ( cast( SLuint32 ) 0x00000080 );
    enum SL_SPEAKER_BACK_CENTER = ( cast( SLuint32 ) 0x00000100 );
    enum SL_SPEAKER_SIDE_LEFT = ( cast( SLuint32 ) 0x00000200 );
    enum SL_SPEAKER_SIDE_RIGHT = ( cast( SLuint32 ) 0x00000400 );
    enum SL_SPEAKER_TOP_CENTER = ( cast( SLuint32 ) 0x00000800 );
    enum SL_SPEAKER_TOP_FRONT_LEFT = ( cast( SLuint32 ) 0x00001000 );
    enum SL_SPEAKER_TOP_FRONT_CENTER = ( cast( SLuint32 ) 0x00002000 );
    enum SL_SPEAKER_TOP_FRONT_RIGHT = ( cast( SLuint32 ) 0x00004000 );
    enum SL_SPEAKER_TOP_BACK_LEFT = ( cast( SLuint32 ) 0x00008000 );
    enum SL_SPEAKER_TOP_BACK_CENTER = ( cast( SLuint32 ) 0x00010000 );
    enum SL_SPEAKER_TOP_BACK_RIGHT = ( cast( SLuint32 ) 0x00020000 );
    enum SL_RESULT_SUCCESS = ( cast( SLuint32 ) 0x00000000 );
    enum SL_RESULT_PRECONDITIONS_VIOLATED = ( cast( SLuint32 ) 0x00000001 );
    enum SL_RESULT_PARAMETER_INVALID = ( cast( SLuint32 ) 0x00000002 );
    enum SL_RESULT_MEMORY_FAILURE = ( cast( SLuint32 ) 0x00000003 );
    enum SL_RESULT_RESOURCE_ERROR = ( cast( SLuint32 ) 0x00000004 );
    enum SL_RESULT_RESOURCE_LOST = ( cast( SLuint32 ) 0x00000005 );
    enum SL_RESULT_IO_ERROR = ( cast( SLuint32 ) 0x00000006 );
    enum SL_RESULT_BUFFER_INSUFFICIENT = ( cast( SLuint32 ) 0x00000007 );
    enum SL_RESULT_CONTENT_CORRUPTED = ( cast( SLuint32 ) 0x00000008 );
    enum SL_RESULT_CONTENT_UNSUPPORTED = ( cast( SLuint32 ) 0x00000009 );
    enum SL_RESULT_CONTENT_NOT_FOUND = ( cast( SLuint32 ) 0x0000000A );
    enum SL_RESULT_PERMISSION_DENIED = ( cast( SLuint32 ) 0x0000000B );
    enum SL_RESULT_FEATURE_UNSUPPORTED = ( cast( SLuint32 ) 0x0000000C );
    enum SL_RESULT_INTERNAL_ERROR = ( cast( SLuint32 ) 0x0000000D );
    enum SL_RESULT_UNKNOWN_ERROR = ( cast( SLuint32 ) 0x0000000E );
    enum SL_RESULT_OPERATION_ABORTED = ( cast( SLuint32 ) 0x0000000F );
    enum SL_RESULT_CONTROL_LOST = ( cast( SLuint32 ) 0x00000010 );
    enum SL_OBJECT_STATE_UNREALIZED = ( cast( SLuint32 ) 0x00000001 );
    enum SL_OBJECT_STATE_REALIZED = ( cast( SLuint32 ) 0x00000002 );
    enum SL_OBJECT_STATE_SUSPENDED = ( cast( SLuint32 ) 0x00000003 );
    enum SL_OBJECT_EVENT_RUNTIME_ERROR = ( cast( SLuint32 ) 0x00000001 );
    enum SL_OBJECT_EVENT_ASYNC_TERMINATION = ( cast( SLuint32 ) 0x00000002 );
    enum SL_OBJECT_EVENT_RESOURCES_LOST = ( cast( SLuint32 ) 0x00000003 );
    enum SL_OBJECT_EVENT_RESOURCES_AVAILABLE = ( cast( SLuint32 ) 0x00000004 );
    enum SL_OBJECT_EVENT_ITF_CONTROL_TAKEN = ( cast( SLuint32 ) 0x00000005 );
    enum SL_OBJECT_EVENT_ITF_CONTROL_RETURNED = ( cast( SLuint32 ) 0x00000006 );
    enum SL_OBJECT_EVENT_ITF_PARAMETERS_CHANGED = ( cast( SLuint32 ) 0x00000007 );
    enum SL_DATALOCATOR_URI = ( cast( SLuint32 ) 0x00000001 );
    enum SL_DATALOCATOR_ADDRESS = ( cast( SLuint32 ) 0x00000002 );
    enum SL_DATALOCATOR_IODEVICE = ( cast( SLuint32 ) 0x00000003 );
    enum SL_DATALOCATOR_OUTPUTMIX = ( cast( SLuint32 ) 0x00000004 );
    enum SL_DATALOCATOR_RESERVED5 = ( cast( SLuint32 ) 0x00000005 );
    enum SL_DATALOCATOR_BUFFERQUEUE = ( cast( SLuint32 ) 0x00000006 );
    enum SL_DATALOCATOR_MIDIBUFFERQUEUE = ( cast( SLuint32 ) 0x00000007 );
    enum SL_DATALOCATOR_RESERVED8 = ( cast( SLuint32 ) 0x00000008 );
    enum SL_IODEVICE_AUDIOINPUT = ( cast( SLuint32 ) 0x00000001 );
    enum SL_IODEVICE_LEDARRAY = ( cast( SLuint32 ) 0x00000002 );
    enum SL_IODEVICE_VIBRA = ( cast( SLuint32 ) 0x00000003 );
    enum SL_IODEVICE_RESERVED4 = ( cast( SLuint32 ) 0x00000004 );
    enum SL_IODEVICE_RESERVED5 = ( cast( SLuint32 ) 0x00000005 );
    enum SL_DATAFORMAT_MIME = ( cast( SLuint32 ) 0x00000001 );
    enum SL_DATAFORMAT_PCM = ( cast( SLuint32 ) 0x00000002 );
    enum SL_DATAFORMAT_RESERVED3 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_BYTEORDER_BIGENDIAN = ( cast( SLuint32 ) 0x00000001 );
    enum SL_BYTEORDER_LITTLEENDIAN = ( cast( SLuint32 ) 0x00000002 );
    enum SL_CONTAINERTYPE_UNSPECIFIED = ( cast( SLuint32 ) 0x00000001 );
    enum SL_CONTAINERTYPE_RAW = ( cast( SLuint32 ) 0x00000002 );
    enum SL_CONTAINERTYPE_ASF = ( cast( SLuint32 ) 0x00000003 );
    enum SL_CONTAINERTYPE_AVI = ( cast( SLuint32 ) 0x00000004 );
    enum SL_CONTAINERTYPE_BMP = ( cast( SLuint32 ) 0x00000005 );
    enum SL_CONTAINERTYPE_JPG = ( cast( SLuint32 ) 0x00000006 );
    enum SL_CONTAINERTYPE_JPG2000 = ( cast( SLuint32 ) 0x00000007 );
    enum SL_CONTAINERTYPE_M4A = ( cast( SLuint32 ) 0x00000008 );
    enum SL_CONTAINERTYPE_MP3 = ( cast( SLuint32 ) 0x00000009 );
    enum SL_CONTAINERTYPE_MP4 = ( cast( SLuint32 ) 0x0000000A );
    enum SL_CONTAINERTYPE_MPEG_ES = ( cast( SLuint32 ) 0x0000000B );
    enum SL_CONTAINERTYPE_MPEG_PS = ( cast( SLuint32 ) 0x0000000C );
    enum SL_CONTAINERTYPE_MPEG_TS = ( cast( SLuint32 ) 0x0000000D );
    enum SL_CONTAINERTYPE_QT = ( cast( SLuint32 ) 0x0000000E );
    enum SL_CONTAINERTYPE_WAV = ( cast( SLuint32 ) 0x0000000F );
    enum SL_CONTAINERTYPE_XMF_0 = ( cast( SLuint32 ) 0x00000010 );
    enum SL_CONTAINERTYPE_XMF_1 = ( cast( SLuint32 ) 0x00000011 );
    enum SL_CONTAINERTYPE_XMF_2 = ( cast( SLuint32 ) 0x00000012 );
    enum SL_CONTAINERTYPE_XMF_3 = ( cast( SLuint32 ) 0x00000013 );
    enum SL_CONTAINERTYPE_XMF_GENERIC = ( cast( SLuint32 ) 0x00000014 );
    enum SL_CONTAINERTYPE_AMR = ( cast( SLuint32 ) 0x00000015 );
    enum SL_CONTAINERTYPE_AAC = ( cast( SLuint32 ) 0x00000016 );
    enum SL_CONTAINERTYPE_3GPP = ( cast( SLuint32 ) 0x00000017 );
    enum SL_CONTAINERTYPE_3GA = ( cast( SLuint32 ) 0x00000018 );
    enum SL_CONTAINERTYPE_RM = ( cast( SLuint32 ) 0x00000019 );
    enum SL_CONTAINERTYPE_DMF = ( cast( SLuint32 ) 0x0000001A );
    enum SL_CONTAINERTYPE_SMF = ( cast( SLuint32 ) 0x0000001B );
    enum SL_CONTAINERTYPE_MOBILE_DLS = ( cast( SLuint32 ) 0x0000001C );
    enum SL_CONTAINERTYPE_OGG = ( cast( SLuint32 ) 0x0000001D );
    enum SL_DEFAULTDEVICEID_AUDIOINPUT = ( cast( SLuint32 ) 0xFFFFFFFF );
    enum SL_DEFAULTDEVICEID_AUDIOOUTPUT = ( cast( SLuint32 ) 0xFFFFFFFE );
    enum SL_DEFAULTDEVICEID_LED = ( cast( SLuint32 ) 0xFFFFFFFD );
    enum SL_DEFAULTDEVICEID_VIBRA = ( cast( SLuint32 ) 0xFFFFFFFC );
    enum SL_DEFAULTDEVICEID_RESERVED1 = ( cast( SLuint32 ) 0xFFFFFFFB );
    enum SL_DEVCONNECTION_INTEGRATED = ( cast( SLint16 ) 0x0001 );
    enum SL_DEVCONNECTION_ATTACHED_WIRED = ( cast( SLint16 ) 0x0100 );
    enum SL_DEVCONNECTION_ATTACHED_WIRELESS = ( cast( SLint16 ) 0x0200 );
    enum SL_DEVCONNECTION_NETWORK = ( cast( SLint16 ) 0x0400 );
    enum SL_DEVLOCATION_HANDSET = ( cast( SLuint16 ) 0x0001 );
    enum SL_DEVLOCATION_HEADSET = ( cast( SLuint16 ) 0x0002 );
    enum SL_DEVLOCATION_CARKIT = ( cast( SLuint16 ) 0x0003 );
    enum SL_DEVLOCATION_DOCK = ( cast( SLuint16 ) 0x0004 );
    enum SL_DEVLOCATION_REMOTE = ( cast( SLuint16 ) 0x0005 );
    enum SL_DEVLOCATION_RESLTE = ( cast( SLuint16 ) 0x0005 );
    enum SL_DEVSCOPE_UNKNOWN = ( cast( SLuint16 ) 0x0001 );
    enum SL_DEVSCOPE_ENVIRONMENT = ( cast( SLuint16 ) 0x0002 );
    enum SL_DEVSCOPE_USER = ( cast( SLuint16 ) 0x0003 );
    enum SL_CHARACTERENCODING_UNKNOWN = ( cast( SLuint32 ) 0x00000000 );
    enum SL_CHARACTERENCODING_BINARY = ( cast( SLuint32 ) 0x00000001 );
    enum SL_CHARACTERENCODING_ASCII = ( cast( SLuint32 ) 0x00000002 );
    enum SL_CHARACTERENCODING_BIG5 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_CHARACTERENCODING_CODEPAGE1252 = ( cast( SLuint32 ) 0x00000004 );
    enum SL_CHARACTERENCODING_GB2312 = ( cast( SLuint32 ) 0x00000005 );
    enum SL_CHARACTERENCODING_HZGB2312 = ( cast( SLuint32 ) 0x00000006 );
    enum SL_CHARACTERENCODING_GB12345 = ( cast( SLuint32 ) 0x00000007 );
    enum SL_CHARACTERENCODING_GB18030 = ( cast( SLuint32 ) 0x00000008 );
    enum SL_CHARACTERENCODING_GBK = ( cast( SLuint32 ) 0x00000009 );
    enum SL_CHARACTERENCODING_IMAPUTF7 = ( cast( SLuint32 ) 0x0000000A );
    enum SL_CHARACTERENCODING_ISO2022JP = ( cast( SLuint32 ) 0x0000000B );
    enum SL_CHARACTERENCODING_ISO2022JP1 = ( cast( SLuint32 ) 0x0000000B );
    enum SL_CHARACTERENCODING_ISO88591 = ( cast( SLuint32 ) 0x0000000C );
    enum SL_CHARACTERENCODING_ISO885910 = ( cast( SLuint32 ) 0x0000000D );
    enum SL_CHARACTERENCODING_ISO885913 = ( cast( SLuint32 ) 0x0000000E );
    enum SL_CHARACTERENCODING_ISO885914 = ( cast( SLuint32 ) 0x0000000F );
    enum SL_CHARACTERENCODING_ISO885915 = ( cast( SLuint32 ) 0x00000010 );
    enum SL_CHARACTERENCODING_ISO88592 = ( cast( SLuint32 ) 0x00000011 );
    enum SL_CHARACTERENCODING_ISO88593 = ( cast( SLuint32 ) 0x00000012 );
    enum SL_CHARACTERENCODING_ISO88594 = ( cast( SLuint32 ) 0x00000013 );
    enum SL_CHARACTERENCODING_ISO88595 = ( cast( SLuint32 ) 0x00000014 );
    enum SL_CHARACTERENCODING_ISO88596 = ( cast( SLuint32 ) 0x00000015 );
    enum SL_CHARACTERENCODING_ISO88597 = ( cast( SLuint32 ) 0x00000016 );
    enum SL_CHARACTERENCODING_ISO88598 = ( cast( SLuint32 ) 0x00000017 );
    enum SL_CHARACTERENCODING_ISO88599 = ( cast( SLuint32 ) 0x00000018 );
    enum SL_CHARACTERENCODING_ISOEUCJP = ( cast( SLuint32 ) 0x00000019 );
    enum SL_CHARACTERENCODING_SHIFTJIS = ( cast( SLuint32 ) 0x0000001A );
    enum SL_CHARACTERENCODING_SMS7BIT = ( cast( SLuint32 ) 0x0000001B );
    enum SL_CHARACTERENCODING_UTF7 = ( cast( SLuint32 ) 0x0000001C );
    enum SL_CHARACTERENCODING_UTF8 = ( cast( SLuint32 ) 0x0000001D );
    enum SL_CHARACTERENCODING_JAVACONFORMANTUTF8 = ( cast( SLuint32 ) 0x0000001E );
    enum SL_CHARACTERENCODING_UTF16BE = ( cast( SLuint32 ) 0x0000001F );
    enum SL_CHARACTERENCODING_UTF16LE = ( cast( SLuint32 ) 0x00000020 );
    enum SL_METADATA_FILTER_KEY = ( cast( SLuint8 ) 0x01 );
    enum SL_METADATA_FILTER_LANG = ( cast( SLuint8 ) 0x02 );
    enum SL_METADATA_FILTER_ENCODING = ( cast( SLuint8 ) 0x04 );
    enum SL_METADATATRAVERSALMODE_ALL = ( cast( SLuint32 ) 0x00000001 );
    enum SL_METADATATRAVERSALMODE_NODE = ( cast( SLuint32 ) 0x00000002 );
    enum SL_NODETYPE_UNSPECIFIED = ( cast( SLuint32 ) 0x00000001 );
    enum SL_NODETYPE_AUDIO = ( cast( SLuint32 ) 0x00000002 );
    enum SL_NODETYPE_VIDEO = ( cast( SLuint32 ) 0x00000003 );
    enum SL_NODETYPE_IMAGE = ( cast( SLuint32 ) 0x00000004 );
    enum SL_NODE_PARENT = 0xFFFFFFFF;
    enum SL_PLAYSTATE_STOPPED = ( cast( SLuint32 ) 0x00000001 );
    enum SL_PLAYSTATE_PAUSED = ( cast( SLuint32 ) 0x00000002 );
    enum SL_PLAYSTATE_PLAYING = ( cast( SLuint32 ) 0x00000003 );
    enum SL_PLAYEVENT_HEADATEND = ( cast( SLuint32 ) 0x00000001 );
    enum SL_PLAYEVENT_HEADATMARKER = ( cast( SLuint32 ) 0x00000002 );
    enum SL_PLAYEVENT_HEADATNEWPOS = ( cast( SLuint32 ) 0x00000004 );
    enum SL_PLAYEVENT_HEADMOVING = ( cast( SLuint32 ) 0x00000008 );
    enum SL_PLAYEVENT_HEADSTALLED = ( cast( SLuint32 ) 0x00000010 );
    enum SL_TIME_UNKNOWN = ( cast( SLuint32 ) 0xFFFFFFFF );
    enum SL_PREFETCHEVENT_STATUSCHANGE = ( cast( SLuint32 ) 0x00000001 );
    enum SL_PREFETCHEVENT_FILLLEVELCHANGE = ( cast( SLuint32 ) 0x00000002 );
    enum SL_PREFETCHSTATUS_UNDERFLOW = ( cast( SLuint32 ) 0x00000001 );
    enum SL_PREFETCHSTATUS_SUFFICIENTDATA = ( cast( SLuint32 ) 0x00000002 );
    enum SL_PREFETCHSTATUS_OVERFLOW = ( cast( SLuint32 ) 0x00000003 );
    enum SL_RATEPROP_RESERVED1 = ( cast( SLuint32 ) 0x00000001 );
    enum SL_RATEPROP_RESERVED2 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_RATEPROP_SILENTAUDIO = ( cast( SLuint32 ) 0x00000100 );
    enum SL_RATEPROP_STAGGEREDAUDIO = ( cast( SLuint32 ) 0x00000200 );
    enum SL_RATEPROP_NOPITCHCORAUDIO = ( cast( SLuint32 ) 0x00000400 );
    enum SL_RATEPROP_PITCHCORAUDIO = ( cast( SLuint32 ) 0x00000800 );
    enum SL_SEEKMODE_FAST = ( cast( SLuint32 ) 0x0001 );
    enum SL_SEEKMODE_ACCURATE = ( cast( SLuint32 ) 0x0002 );
    enum SL_RECORDSTATE_STOPPED = ( cast( SLuint32 ) 0x00000001 );
    enum SL_RECORDSTATE_PAUSED = ( cast( SLuint32 ) 0x00000002 );
    enum SL_RECORDSTATE_RECORDING = ( cast( SLuint32 ) 0x00000003 );
    enum SL_RECORDEVENT_HEADATLIMIT = ( cast( SLuint32 ) 0x00000001 );
    enum SL_RECORDEVENT_HEADATMARKER = ( cast( SLuint32 ) 0x00000002 );
    enum SL_RECORDEVENT_HEADATNEWPOS = ( cast( SLuint32 ) 0x00000004 );
    enum SL_RECORDEVENT_HEADMOVING = ( cast( SLuint32 ) 0x00000008 );
    enum SL_RECORDEVENT_HEADSTALLED = ( cast( SLuint32 ) 0x00000010 );
    enum SL_RECORDEVENT_BUFFER_INSUFFICIENT = ( cast( SLuint32 ) 0x00000020 );
    enum SL_RECORDEVENT_BUFFER_FULL = ( cast( SLuint32 ) 0x00000020 );
    enum SL_EQUALIZER_UNDEFINED = ( cast( SLuint16 ) 0xFFFF );
    enum SL_REVERBPRESET_NONE = ( cast( SLuint16 ) 0x0000 );
    enum SL_REVERBPRESET_SMALLROOM = ( cast( SLuint16 ) 0x0001 );
    enum SL_REVERBPRESET_MEDIUMROOM = ( cast( SLuint16 ) 0x0002 );
    enum SL_REVERBPRESET_LARGEROOM = ( cast( SLuint16 ) 0x0003 );
    enum SL_REVERBPRESET_MEDIUMHALL = ( cast( SLuint16 ) 0x0004 );
    enum SL_REVERBPRESET_LARGEHALL = ( cast( SLuint16 ) 0x0005 );
    enum SL_REVERBPRESET_PLATE = ( cast( SLuint16 ) 0x0006 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_DEFAULT =         SLEnvironmentalReverbSettings(( cast( SLmillibel ) ( - ( cast( SLmillibel ) 0x7FFF ) - 1 ) ) , 0 , 1000 , 500 , ( cast( SLmillibel ) ( - ( cast( SLmillibel ) 0x7FFF ) - 1 ) ) , 20 , ( cast( SLmillibel ) ( - ( cast( SLmillibel ) 0x7FFF ) - 1 ) ) , 40 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_GENERIC =         SLEnvironmentalReverbSettings(- 1000 , - 100 , 1490 , 830 , - 2602 , 7 , 200 , 11 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_PADDEDCELL =      SLEnvironmentalReverbSettings(- 1000 , - 6000 , 170 , 100 , - 1204 , 1 , 207 , 2 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_ROOM =            SLEnvironmentalReverbSettings(- 1000 , - 454 , 400 , 830 , - 1646 , 2 , 53 , 3 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_BATHROOM =        SLEnvironmentalReverbSettings(- 1000 , - 1200 , 1490 , 540 , - 370 , 7 , 1030 , 11 , 1000 , 600 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_LIVINGROOM =      SLEnvironmentalReverbSettings(- 1000 , - 6000 , 500 , 100 , - 1376 , 3 , - 1104 , 4 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_STONEROOM =       SLEnvironmentalReverbSettings(- 1000 , - 300 , 2310 , 640 , - 711 , 12 , 83 , 17 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_AUDITORIUM =      SLEnvironmentalReverbSettings(- 1000 , - 476 , 4320 , 590 , - 789 , 20 , - 289 , 30 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_CONCERTHALL =     SLEnvironmentalReverbSettings(- 1000 , - 500 , 3920 , 700 , - 1230 , 20 , - 2 , 29 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_CAVE =            SLEnvironmentalReverbSettings(- 1000 , 0 , 2910 , 1300 , - 602 , 15 , - 302 , 22 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_ARENA =           SLEnvironmentalReverbSettings(- 1000 , - 698 , 7240 , 330 , - 1166 , 20 , 16 , 30 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_HANGAR =          SLEnvironmentalReverbSettings(- 1000 , - 1000 , 10050 , 230 , - 602 , 20 , 198 , 30 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_CARPETEDHALLWAY = SLEnvironmentalReverbSettings(- 1000 , - 4000 , 300 , 100 , - 1831 , 2 , - 1630 , 30 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_HALLWAY =         SLEnvironmentalReverbSettings(- 1000 , - 300 , 1490 , 590 , - 1219 , 7 , 441 , 11 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_STONECORRIDOR =   SLEnvironmentalReverbSettings(- 1000 , - 237 , 2700 , 790 , - 1214 , 13 , 395 , 20 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_ALLEY =           SLEnvironmentalReverbSettings(- 1000 , - 270 , 1490 , 860 , - 1204 , 7 , - 4 , 11 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_FOREST =          SLEnvironmentalReverbSettings(- 1000 , - 3300 , 1490 , 540 , - 2560 , 162 , - 613 , 88 , 790 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_CITY =            SLEnvironmentalReverbSettings(- 1000 , - 800 , 1490 , 670 , - 2273 , 7 , - 2217 , 11 , 500 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_MOUNTAINS =       SLEnvironmentalReverbSettings(- 1000 , - 2500 , 1490 , 210 , - 2780 , 300 , - 2014 , 100 , 270 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_QUARRY =          SLEnvironmentalReverbSettings(- 1000 , - 1000 , 1490 , 830 , ( cast( SLmillibel ) ( - ( cast( SLmillibel ) 0x7FFF ) - 1 ) ) , 61 , 500 , 25 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_PLAIN =           SLEnvironmentalReverbSettings(- 1000 , - 2000 , 1490 , 500 , - 2466 , 179 , - 2514 , 100 , 210 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_PARKINGLOT =      SLEnvironmentalReverbSettings(- 1000 , 0 , 1650 , 1500 , - 1363 , 8 , - 1153 , 12 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_SEWERPIPE =       SLEnvironmentalReverbSettings(- 1000 , - 1000 , 2810 , 140 , 429 , 14 , 648 , 21 , 800 , 600 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_UNDERWATER =      SLEnvironmentalReverbSettings(- 1000 , - 4000 , 1490 , 100 , - 449 , 7 , 1700 , 11 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_SMALLROOM =       SLEnvironmentalReverbSettings(- 1000 , - 600 , 1100 , 830 , - 400 , 5 , 500 , 10 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_MEDIUMROOM =      SLEnvironmentalReverbSettings(- 1000 , - 600 , 1300 , 830 , - 1000 , 20 , - 200 , 20 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_LARGEROOM =       SLEnvironmentalReverbSettings(- 1000 , - 600 , 1500 , 830 , - 1600 , 5 , - 1000 , 40 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_MEDIUMHALL =      SLEnvironmentalReverbSettings(- 1000 , - 600 , 1800 , 700 , - 1300 , 15 , - 800 , 30 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_LARGEHALL =       SLEnvironmentalReverbSettings(- 1000 , - 600 , 1800 , 700 , - 2000 , 30 , - 1400 , 60 , 1000 , 1000 );
    enum SL_I3DL2_ENVIRONMENT_PRESET_PLATE =           SLEnvironmentalReverbSettings(- 1000 , - 200 , 1300 , 900 , 0 , 2 , 0 , 10 , 1000 , 750 );
    enum SL_ROLLOFFMODEL_EXPONENTIAL = ( cast( SLuint32 ) 0x00000000 );
    enum SL_ROLLOFFMODEL_LINEAR = ( cast( SLuint32 ) 0x00000001 );
    enum SL_DYNAMIC_ITF_EVENT_RUNTIME_ERROR = ( cast( SLuint32 ) 0x00000001 );
    enum SL_DYNAMIC_ITF_EVENT_ASYNC_TERMINATION = ( cast( SLuint32 ) 0x00000002 );
    enum SL_DYNAMIC_ITF_EVENT_RESOURCES_LOST = ( cast( SLuint32 ) 0x00000003 );
    enum SL_DYNAMIC_ITF_EVENT_RESOURCES_LOST_PERMANENTLY = ( cast( SLuint32 ) 0x00000004 );
    enum SL_DYNAMIC_ITF_EVENT_RESOURCES_AVAILABLE = ( cast( SLuint32 ) 0x00000005 );
    enum SL_MIDIMESSAGETYPE_NOTE_ON_OFF = ( cast( SLuint32 ) 0x00000001 );
    enum SL_MIDIMESSAGETYPE_POLY_PRESSURE = ( cast( SLuint32 ) 0x00000002 );
    enum SL_MIDIMESSAGETYPE_CONTROL_CHANGE = ( cast( SLuint32 ) 0x00000003 );
    enum SL_MIDIMESSAGETYPE_PROGRAM_CHANGE = ( cast( SLuint32 ) 0x00000004 );
    enum SL_MIDIMESSAGETYPE_CHANNEL_PRESSURE = ( cast( SLuint32 ) 0x00000005 );
    enum SL_MIDIMESSAGETYPE_PITCH_BEND = ( cast( SLuint32 ) 0x00000006 );
    enum SL_MIDIMESSAGETYPE_SYSTEM_MESSAGE = ( cast( SLuint32 ) 0x00000007 );
    enum SL_RATECONTROLMODE_CONSTANTBITRATE = ( cast( SLuint32 ) 0x00000001 );
    enum SL_RATECONTROLMODE_VARIABLEBITRATE = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOCODEC_PCM = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOCODEC_MP3 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOCODEC_AMR = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOCODEC_AMRWB = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOCODEC_AMRWBPLUS = ( cast( SLuint32 ) 0x00000005 );
    enum SL_AUDIOCODEC_AAC = ( cast( SLuint32 ) 0x00000006 );
    enum SL_AUDIOCODEC_WMA = ( cast( SLuint32 ) 0x00000007 );
    enum SL_AUDIOCODEC_REAL = ( cast( SLuint32 ) 0x00000008 );
    enum SL_AUDIOPROFILE_PCM = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOPROFILE_MPEG1_L3 = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOPROFILE_MPEG2_L3 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOPROFILE_MPEG25_L3 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOCHANMODE_MP3_MONO = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOCHANMODE_MP3_STEREO = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOCHANMODE_MP3_JOINTSTEREO = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOCHANMODE_MP3_DUAL = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOPROFILE_AMR = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOSTREAMFORMAT_CONFORMANCE = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOSTREAMFORMAT_IF1 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOSTREAMFORMAT_IF2 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOSTREAMFORMAT_FSF = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOSTREAMFORMAT_RTPPAYLOAD = ( cast( SLuint32 ) 0x00000005 );
    enum SL_AUDIOSTREAMFORMAT_ITU = ( cast( SLuint32 ) 0x00000006 );
    enum SL_AUDIOPROFILE_AMRWB = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOPROFILE_AMRWBPLUS = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOPROFILE_AAC_AAC = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOMODE_AAC_MAIN = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOMODE_AAC_LC = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOMODE_AAC_SSR = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOMODE_AAC_LTP = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOMODE_AAC_HE = ( cast( SLuint32 ) 0x00000005 );
    enum SL_AUDIOMODE_AAC_SCALABLE = ( cast( SLuint32 ) 0x00000006 );
    enum SL_AUDIOMODE_AAC_ERLC = ( cast( SLuint32 ) 0x00000007 );
    enum SL_AUDIOMODE_AAC_LD = ( cast( SLuint32 ) 0x00000008 );
    enum SL_AUDIOMODE_AAC_HE_PS = ( cast( SLuint32 ) 0x00000009 );
    enum SL_AUDIOMODE_AAC_HE_MPS = ( cast( SLuint32 ) 0x0000000A );
    enum SL_AUDIOSTREAMFORMAT_MP2ADTS = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOSTREAMFORMAT_MP4ADTS = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOSTREAMFORMAT_MP4LOAS = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOSTREAMFORMAT_MP4LATM = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOSTREAMFORMAT_ADIF = ( cast( SLuint32 ) 0x00000005 );
    enum SL_AUDIOSTREAMFORMAT_MP4FF = ( cast( SLuint32 ) 0x00000006 );
    enum SL_AUDIOSTREAMFORMAT_RAW = ( cast( SLuint32 ) 0x00000007 );
    enum SL_AUDIOPROFILE_WMA7 = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOPROFILE_WMA8 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOPROFILE_WMA9 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOPROFILE_WMA10 = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOMODE_WMA_LEVEL1 = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOMODE_WMA_LEVEL2 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOMODE_WMA_LEVEL3 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOMODE_WMA_LEVEL4 = ( cast( SLuint32 ) 0x00000004 );
    enum SL_AUDIOMODE_WMAPRO_LEVELM0 = ( cast( SLuint32 ) 0x00000005 );
    enum SL_AUDIOMODE_WMAPRO_LEVELM1 = ( cast( SLuint32 ) 0x00000006 );
    enum SL_AUDIOMODE_WMAPRO_LEVELM2 = ( cast( SLuint32 ) 0x00000007 );
    enum SL_AUDIOMODE_WMAPRO_LEVELM3 = ( cast( SLuint32 ) 0x00000008 );
    enum SL_AUDIOPROFILE_REALAUDIO = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOMODE_REALAUDIO_G2 = ( cast( SLuint32 ) 0x00000001 );
    enum SL_AUDIOMODE_REALAUDIO_8 = ( cast( SLuint32 ) 0x00000002 );
    enum SL_AUDIOMODE_REALAUDIO_10 = ( cast( SLuint32 ) 0x00000003 );
    enum SL_AUDIOMODE_REALAUDIO_SURROUND = ( cast( SLuint32 ) 0x00000004 );
    enum SL_ENGINEOPTION_THREADSAFE = ( cast( SLuint32 ) 0x00000001 );
    enum SL_ENGINEOPTION_LOSSOFCONTROL = ( cast( SLuint32 ) 0x00000002 );

}
