
module bind.libinfos;
import bindbc.openal;
import bindbc.opengl;
import console.log;
import core.stdc.string : strlen;
import std.conv : to;
void list_audio_devices(const ALCchar* devices);
void show_sdl_sound_info();
void show_opengl_info();
immutable SLESVersion = "1.0.1";
struct SLESCompatibility
{
	immutable bool AudioPlayer;
	immutable bool AudioRecorder;
	immutable bool Engine;
	immutable bool OutputMix;
}
enum SLESAndroidRequiredPermissions 
{
	MODIFY_AUDIO_SETTINGS = "<uses-permission android:name=\"android.permission.MODIFY_AUDIO_SETTINGS\"/>",
	RECORD_AUDIO = "<uses-permission android:name=\"android.permission.RECORD_AUDIO\"/>",
}
enum Android_NDK_Compatibility : SLESCompatibility
{
	BassBoost = SLESCompatibility(true, false, false, true),
	BufferQueue = SLESCompatibility(true, false, false, false),
	BufferQueueDataLocator = SLESCompatibility(true, false, false, false),
	DynamicInterfaceManagement = SLESCompatibility(true, true, true, true),
	EffectSend = SLESCompatibility(true, false, false, false),
	Engine = SLESCompatibility(false, false, true, false),
	EnvironmentalReverb = SLESCompatibility(false, false, false, true),
	Equalize = SLESCompatibility(true, false, false, true),
	IODeviceDataLocator = SLESCompatibility(false, true, false, false),
	MetadataExtraction = SLESCompatibility(true, false, false, false),
	MuteSolo = SLESCompatibility(true, false, false, false),
	OObject = SLESCompatibility(true, true, true, true),
	OutputMixLocator = SLESCompatibility(true, false, false, false),
	Play = SLESCompatibility(true, false, false, false),
	PlaybackRate = SLESCompatibility(true, false, false, false),
	PrefetchStatus = SLESCompatibility(true, false, false, false),
	PresetReverb = SLESCompatibility(false, false, false, true),
	Record = SLESCompatibility(false, true, false, false),
	Seek = SLESCompatibility(true, false, false, false),
	URIDataLocator = SLESCompatibility(true, false, false, false),
	Virtualizer = SLESCompatibility(true, false, false, true),
	Volume = SLESCompatibility(true, false, false, false),
}
