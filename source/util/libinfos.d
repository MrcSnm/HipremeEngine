/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module util.libinfos;
import bindbc.openal;
import bindbc.freeimage;
import implementations.renderer.backend.gl.renderer;
import def.debugging.log;
import core.stdc.string:strlen;
import std.conv:to;

void list_audio_devices(const ALCchar *devices)
{
	const(char)* device = devices;
	const(char)* next = devices + 1;
	size_t len = 0;

	rawlog("Devices list:\n");
	rawlog("----------\n");
	while (device && *device != '\0' && next && *next != '\0') 
	{
		rawlog!"%s\n"(to!string(device));
		len = strlen(device);
		device += (len + 1);
		next += (len + 2);
	}
	rawlog("----------\n");
}

void show_opengl_info()
{
	version(Android){}
	else{
		if(!isOpenGLLoaded())
		{
			rawlog("OpenGL is not loaded for being able to show info!");
			return;
		}
	}
	rawlog!`OpenGL Infos:
    Vendor:   %s
    Renderer: %s
    Version:  %s`(to!string(glGetString(GL_VENDOR)),
    to!string(glGetString(GL_RENDERER)),
    to!string(glGetString(GL_VERSION)));
}

void show_FreeImage_info()
{
	string ver = to!string(FreeImage_GetVersion());
	rawlog("libFreeImage version: ", ver,"\n", to!string(FreeImage_GetCopyrightMessage()));
}




/** Current OpenSL ES Version*/
immutable SLESVersion = "1.0.1";

/**
* Is feature compatible with...
*/
struct SLESCompatibility
{
    ///Feature compatible with AudioPlayer
    immutable bool AudioPlayer;
    ///Feature compatible with AudioRecorder
    immutable bool AudioRecorder;
    ///Feature compatible with Engine
    immutable bool Engine;
    ///Feature compatible with OutputMix
    immutable bool OutputMix;
}

/**
*   Documentation for permissions needed on android side when using SLES
*/
enum SLESAndroidRequiredPermissions
{
    ///When using any kind of output mix effect
    MODIFY_AUDIO_SETTINGS = `<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>`,
    ///When messing with AudioRecorder
    RECORD_AUDIO = `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`
}

/**
*   Immutable table on how is compatibility at Android, keeping that only as a reference.
*/
enum Android_NDK_Compatibility : SLESCompatibility
{
    //                                            Player  Rec   Engine Output
    BassBoost                  = SLESCompatibility(true, false, false, true),
    BufferQueue                = SLESCompatibility(true, false, false, false),
    BufferQueueDataLocator     = SLESCompatibility(true, false, false, false), //Source
    DynamicInterfaceManagement = SLESCompatibility(true, true, true, true),
    EffectSend                 = SLESCompatibility(true, false, false, false),
    Engine                     = SLESCompatibility(false, false, true, false),
    EnvironmentalReverb        = SLESCompatibility(false, false, false, true),
    Equalize                   = SLESCompatibility(true, false, false, true),
    IODeviceDataLocator        = SLESCompatibility(false, true, false, false),
    MetadataExtraction         = SLESCompatibility(true, false, false, false),
    MuteSolo                   = SLESCompatibility(true, false, false, false),
    OObject                    = SLESCompatibility(true, true, true, true),
    OutputMixLocator           = SLESCompatibility(true, false, false, false), //Sink
    Play                       = SLESCompatibility(true, false, false, false),
    PlaybackRate               = SLESCompatibility(true, false, false, false),
    PrefetchStatus             = SLESCompatibility(true, false, false, false),
    PresetReverb               = SLESCompatibility(false, false, false, true),
    Record                     = SLESCompatibility(false, true, false, false),
    Seek                       = SLESCompatibility(true, false, false, false),
    URIDataLocator             = SLESCompatibility(true, false, false, false), //Source
    Virtualizer                = SLESCompatibility(true, false, false, true),
    Volume                     = SLESCompatibility(true, false, false, false)
    //                                            Player  Rec   Engine Output
}
