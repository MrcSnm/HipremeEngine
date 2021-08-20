module directx.xaudio2;
/**************************************************************************
 *
 * Copyright (c) Microsoft Corporation.  All rights reserved.
 *
 * File:    xaudio2.h
 * Content: Declarations for the XAudio2 game audio API.
 *
 **************************************************************************/

/**************************************************************************
 *
 * XAudio2 COM object class and interface IDs.
 *
 **************************************************************************/

version(Windows):

import std.math;

import directx.com;

// oops, bad way defining it here
//version=DXSDK_2010_6;
//version=DXSDK_11_0;
version=XAUDIO2_HELPER_FUNCTIONS;

// it is outdated and i'm lazy, so maybe later i will upgrade it or remove at all.
/*
version(DXSDK_2008_3)
{
// XAudio 2.0 (March 2008 SDK)
DEFINE_CLSID!(XAudio2, fac23f48, 31f5, 45a8, b4, 9b, 52, 25, d6, 14, 01, aa);
DEFINE_CLSID!(XAudio2_Debug, fac23f48, 31f5, 45a8, b4, 9b, 52, 25, d6, 14, 01, db);
}

version(DXSDK_2008_6)
{
// XAudio 2.1 (June 2008 SDK)
DEFINE_CLSID!(XAudio2, e21a7345, eb21, 468e, be, 50, 80, 4d, b9, 7c, f7, 08);
DEFINE_CLSID!(XAudio2_Debug, f7a76c21, 53d4, 46bb, ac, 53, 8b, 45, 9c, ae, 46, bd);
}

version(DXSDK_2008_8)
{
// XAudio 2.2 (August 2008 SDK)
DEFINE_CLSID(XAudio2, b802058a, 464a, 42db, bc, 10, b6, 50, d6, f2, 58, 6a);
DEFINE_CLSID(XAudio2_Debug, 97dfb7e7, 5161, 4015, 87, a9, c7, 9e, 6a, 19, 52, cc);
}

version(DXSDK_2008_11)
{
// XAudio 2.3 (November 2008 SDK)
DEFINE_CLSID(XAudio2, 4c5e637a, 16c7, 4de3, 9c, 46, 5e, d2, 21, 81, 96, 2d);
DEFINE_CLSID(XAudio2_Debug, ef0aa05d, 8075, 4e5d, be, ad, 45, be, 0c, 3c, cb, b3);
}

version(DXSDK_2009_3)
{
// XAudio 2.4 (March 2009 SDK)
//DEFINE_CLSID(XAudio2, 03219e78, 5bc3, 44d1, b9, 2e, f6, 3d, 89, cc, 65, 26);
//DEFINE_CLSID(XAudio2_Debug, 4256535c, 1ea4, 4d4b, 8a, d5, f9, db, 76, 2e, ca, 9e);
}

version(DXSDK_2009_8)
{
// XAudio 2.5 (August 2009 SDK)
DEFINE_CLSID(XAudio2, 4c9b6dde, 6809, 46e6, a2, 78, 9b, 6a, 97, 58, 86, 70);
DEFINE_CLSID(XAudio2_Debug, 715bdd1a, aa82, 436b, b0, fa, 6a, ce, a3, 9b, d0, a1);
}

version(DXSDK_2010_2)
{
// XAudio 2.6 (February 2010 SDK)
DEFINE_CLSID(XAudio2, 3eda9b49, 2085, 498b, 9b, b2, 39, a6, 77, 84, 93, de);
DEFINE_CLSID(XAudio2_Debug, 47199894, 7cc2, 444d, 98, 73, ce, d2, 56, 2c, c6, 0e);
}
*/

version(DXSDK_2010_6)
{
	// XAudio 2.7 (June 2010 SDK)
	// this two should be CLSID but for now leave it as IID
	mixin(uuid!(XAudio2,"5a508685-a254-4fba-9b82-9a24b00306af"));
	mixin(uuid!(XAudio2_Debug, "db05ea35-0329-4d4b-a53a-6dead03d3852"));

	mixin(uuid!(IXAudio2, "8bcf1f58-9fe7-4583-8ac6-e2adc465c8bb"));
}

version(XAUDIO_2_8)
{
	// XAudio 2.8 ( Windows 8 )
	mixin(uuid!(IXAudio2, "60d8dac8-5aa1-4e8e-b597-2f5e2883d484"));
}


// Ignore the rest of this header if only the GUID definitions were requested
version(GUID_DEFS_ONLY)
{
}
else
{
	// required for uuid template
	interface XAudio2 : IUnknown{}
	interface XAudio2_Debug : IUnknown{}	

	version(XBOX)
		import xbox.xobjbase;   // Xbox COM declarations (IUnknown, etc)
	else
		import directx.com;   // Windows COM declarations

	// All structures defined in this file use tight field packing
	align(1):


	/**************************************************************************
	*
	* XAudio2 constants, flags and error codes.
	*
	**************************************************************************/

	// Numeric boundary values
	enum XAUDIO2_MAX_BUFFER_BYTES        = 0x80000000;    // Maximum bytes allowed in a source buffer
	enum XAUDIO2_MAX_QUEUED_BUFFERS      = 64;            // Maximum buffers allowed in a voice queue
	enum XAUDIO2_MAX_BUFFERS_SYSTEM      = 2;             // Maximum buffers allowed for system threads (Xbox 360 only)
	enum XAUDIO2_MAX_AUDIO_CHANNELS      = 64;            // Maximum channels in an audio stream
	enum XAUDIO2_MIN_SAMPLE_RATE         = 1000;          // Minimum audio sample rate supported
	enum XAUDIO2_MAX_SAMPLE_RATE         = 200000;        // Maximum audio sample rate supported
	enum XAUDIO2_MAX_VOLUME_LEVEL        = 16777216.0f;   // Maximum acceptable volume level (2^24)
	enum XAUDIO2_MIN_FREQ_RATIO          = (1/1024.0f);   // Minimum SetFrequencyRatio argument
	enum XAUDIO2_MAX_FREQ_RATIO          = 1024.0f;       // Maximum MaxFrequencyRatio argument
	enum XAUDIO2_DEFAULT_FREQ_RATIO      = 2.0f;          // Default MaxFrequencyRatio argument
	enum XAUDIO2_MAX_FILTER_ONEOVERQ     = 1.5f;          // Maximum XAUDIO2_FILTER_PARAMETERS.OneOverQ
	enum XAUDIO2_MAX_FILTER_FREQUENCY    = 1.0f;          // Maximum XAUDIO2_FILTER_PARAMETERS.Frequency
	enum XAUDIO2_MAX_LOOP_COUNT          = 254;           // Maximum non-infinite XAUDIO2_BUFFER.LoopCount
	enum XAUDIO2_MAX_INSTANCES           = 8;             // Maximum simultaneous XAudio2 objects on Xbox 360

	// For XMA voices on Xbox 360 there is an additional restriction on the MaxFrequencyRatio
	// argument and the voice's sample rate: the product of these numbers cannot exceed 600000
	// for one-channel voices or 300000 for voices with more than one channel.
	enum XAUDIO2_MAX_RATIO_TIMES_RATE_XMA_MONO         = 600000;
	enum XAUDIO2_MAX_RATIO_TIMES_RATE_XMA_MULTICHANNEL = 300000;

	// Numeric values with special meanings
	enum XAUDIO2_COMMIT_NOW              = 0;              // Used as an OperationSet argument
	enum XAUDIO2_COMMIT_ALL              = 0;              // Used in IXAudio2::CommitChanges
	enum XAUDIO2_INVALID_OPSET           = cast(uint)(-1); // Not allowed for OperationSet arguments
	enum XAUDIO2_NO_LOOP_REGION          = 0;              // Used in XAUDIO2_BUFFER.LoopCount
	enum XAUDIO2_LOOP_INFINITE           = 255;            // Used in XAUDIO2_BUFFER.LoopCount
	enum XAUDIO2_DEFAULT_CHANNELS        = 0;              // Used in CreateMasteringVoice
	enum XAUDIO2_DEFAULT_SAMPLERATE      = 0;              // Used in CreateMasteringVoice

	// Flags
	enum XAUDIO2_DEBUG_ENGINE            = 0x0001;         // Used in XAudio2Create on Windows only
	enum XAUDIO2_VOICE_NOPITCH           = 0x0002;         // Used in IXAudio2::CreateSourceVoice
	enum XAUDIO2_VOICE_NOSRC             = 0x0004;         // Used in IXAudio2::CreateSourceVoice
	enum XAUDIO2_VOICE_USEFILTER         = 0x0008;         // Used in IXAudio2::CreateSource/SubmixVoice
	enum XAUDIO2_VOICE_MUSIC             = 0x0010;         // Used in IXAudio2::CreateSourceVoice
	enum XAUDIO2_PLAY_TAILS              = 0x0020;         // Used in IXAudio2SourceVoice::Stop
	enum XAUDIO2_END_OF_STREAM           = 0x0040;         // Used in XAUDIO2_BUFFER.Flags
	enum XAUDIO2_SEND_USEFILTER          = 0x0080;         // Used in XAUDIO2_SEND_DESCRIPTOR.Flags

	// Default parameters for the built-in filter
	enum XAUDIO2_DEFAULT_FILTER_TYPE      = LowPassFilter;
	enum XAUDIO2_DEFAULT_FILTER_FREQUENCY = XAUDIO2_MAX_FILTER_FREQUENCY;
	enum XAUDIO2_DEFAULT_FILTER_ONEOVERQ  = 1.0f;

	// Internal XAudio2 constants
	version(XBOX)
	{
		enum XAUDIO2_QUANTUM_NUMERATOR   = 2;              // On Xbox 360, XAudio2 processes audio
		enum XAUDIO2_QUANTUM_DENOMINATOR = 375;            //  in 5.333ms chunks (= 2/375 seconds)
	}
	else
	{
		enum XAUDIO2_QUANTUM_NUMERATOR   = 1;              // On Windows, XAudio2 processes audio
		enum XAUDIO2_QUANTUM_DENOMINATOR = 100;            //  in 10ms chunks (= 1/100 seconds)
	}
	enum XAUDIO2_QUANTUM_MS = (1000.0f * XAUDIO2_QUANTUM_NUMERATOR / XAUDIO2_QUANTUM_DENOMINATOR);

	// XAudio2 error codes
	enum FACILITY_XAUDIO2 = 0x896;
	enum XAUDIO2_E_INVALID_CALL          = 0x88960001;     // An API call or one of its arguments was illegal
	enum XAUDIO2_E_XMA_DECODER_ERROR     = 0x88960002;     // The XMA hardware suffered an unrecoverable error
	enum XAUDIO2_E_XAPO_CREATION_FAILED  = 0x88960003;     // XAudio2 failed to initialize an XAPO effect
	enum XAUDIO2_E_DEVICE_INVALIDATED    = 0x88960004;     // An audio device became unusable (unplugged, etc)


	/**************************************************************************
	*
	* XAudio2 structures and enumerations.
	*
	**************************************************************************/

	// Used in IXAudio2::Initialize
	version(XBOX) {
		enum XAUDIO2_XBOX_HWTHREAD_SPECIFIER
		{
			XboxThread0 = 0x01,
			XboxThread1 = 0x02,
			XboxThread2 = 0x04,
			XboxThread3 = 0x08,
			XboxThread4 = 0x10,
			XboxThread5 = 0x20,
			XAUDIO2_ANY_PROCESSOR = XboxThread4,
			XAUDIO2_DEFAULT_PROCESSOR = XAUDIO2_ANY_PROCESSOR
		} 
		alias XAUDIO2_XBOX_HWTHREAD_SPECIFIER XAUDIO2_PROCESSOR;
	}
	else {
		alias XAUDIO2_WINDOWS_PROCESSOR_SPECIFIER = int;
		enum : XAUDIO2_WINDOWS_PROCESSOR_SPECIFIER
		{
			Processor1  = 0x00000001,
			Processor2  = 0x00000002,
			Processor3  = 0x00000004,
			Processor4  = 0x00000008,
			Processor5  = 0x00000010,
			Processor6  = 0x00000020,
			Processor7  = 0x00000040,
			Processor8  = 0x00000080,
			Processor9  = 0x00000100,
			Processor10 = 0x00000200,
			Processor11 = 0x00000400,
			Processor12 = 0x00000800,
			Processor13 = 0x00001000,
			Processor14 = 0x00002000,
			Processor15 = 0x00004000,
			Processor16 = 0x00008000,
			Processor17 = 0x00010000,
			Processor18 = 0x00020000,
			Processor19 = 0x00040000,
			Processor20 = 0x00080000,
			Processor21 = 0x00100000,
			Processor22 = 0x00200000,
			Processor23 = 0x00400000,
			Processor24 = 0x00800000,
			Processor25 = 0x01000000,
			Processor26 = 0x02000000,
			Processor27 = 0x04000000,
			Processor28 = 0x08000000,
			Processor29 = 0x10000000,
			Processor30 = 0x20000000,
			Processor31 = 0x40000000,
			Processor32 = 0x80000000,
			XAUDIO2_ANY_PROCESSOR = 0xffffffff,
			XAUDIO2_DEFAULT_PROCESSOR = XAUDIO2_ANY_PROCESSOR
		} 
		alias XAUDIO2_WINDOWS_PROCESSOR_SPECIFIER XAUDIO2_PROCESSOR;
	}


	// Used in XAUDIO2_DEVICE_DETAILS below to describe the types of applications
	// that the user has specified each device as a default for.  0 means that the
	// device isn't the default for any role.
    alias DWORD XAUDIO2_DEVICE_ROLE;
	enum : XAUDIO2_DEVICE_ROLE
	{
		NotDefaultDevice            = 0x0,
		DefaultConsoleDevice        = 0x1,
		DefaultMultimediaDevice     = 0x2,
		DefaultCommunicationsDevice = 0x4,
		DefaultGameDevice           = 0x8,
		GlobalDefaultDevice         = 0xf,
		InvalidDeviceRole = ~GlobalDefaultDevice
	}

	// Returned by IXAudio2::GetDeviceDetails
	struct XAUDIO2_DEVICE_DETAILS
	{
		WCHAR[256] DeviceID;                // String identifier for the audio device.
		WCHAR[256] DisplayName;             // Friendly name suitable for display to a human.
		XAUDIO2_DEVICE_ROLE Role;           // Roles that the device should be used for.
		WAVEFORMATEXTENSIBLE OutputFormat;  // The device's native PCM audio output format.
	}

	// Returned by IXAudio2Voice::GetVoiceDetails
	struct XAUDIO2_VOICE_DETAILS
	{	
		UINT32 CreationFlags;               // Flags the voice was created with.
		UINT32 InputChannels;               // Channels in the voice's input audio.
		UINT32 InputSampleRate;             // Sample rate of the voice's input audio.
	}

	// Used in XAUDIO2_VOICE_SENDS below
	struct XAUDIO2_SEND_DESCRIPTOR
	{
		UINT32 Flags;                       // Either 0 or XAUDIO2_SEND_USEFILTER.
		IXAudio2Voice pOutputVoice;        // This send's destination voice.
	}

	// Used in the voice creation functions and in IXAudio2Voice::SetOutputVoices
	struct XAUDIO2_VOICE_SENDS
	{
		UINT32 SendCount;                   // Number of sends from this voice.
		XAUDIO2_SEND_DESCRIPTOR* pSends;    // Array of SendCount send descriptors.
	}

	// Used in XAUDIO2_EFFECT_CHAIN below
	struct XAUDIO2_EFFECT_DESCRIPTOR
	{
		IUnknown pEffect;                  // Pointer to the effect object's IUnknown interface.
		BOOL InitialState;                  // TRUE if the effect should begin in the enabled state.
		UINT32 OutputChannels;              // How many output channels the effect should produce.
	}

	// Used in the voice creation functions and in IXAudio2Voice::SetEffectChain
	struct XAUDIO2_EFFECT_CHAIN
	{
		UINT32 EffectCount;                 // Number of effects in this voice's effect chain.
		XAUDIO2_EFFECT_DESCRIPTOR* pEffectDescriptors; // Array of effect descriptors.
	}

	// Used in XAUDIO2_FILTER_PARAMETERS below
	alias XAUDIO2_FILTER_TYPE = uint;
	enum : XAUDIO2_FILTER_TYPE
	{
		LowPassFilter,                      // Attenuates frequencies above the cutoff frequency.
		BandPassFilter,                     // Attenuates frequencies outside a given range.
		HighPassFilter,                     // Attenuates frequencies below the cutoff frequency.
		NotchFilter                         // Attenuates frequencies inside a given range.
	}

	// Used in IXAudio2Voice::Set/GetFilterParameters and Set/GetOutputFilterParameters
	struct XAUDIO2_FILTER_PARAMETERS
	{
		XAUDIO2_FILTER_TYPE Type;           // Low-pass, band-pass or high-pass.
		float Frequency;                    // Radian frequency (2 * sin(pi*CutoffFrequency/SampleRate));
		//  must be >= 0 and <= XAUDIO2_MAX_FILTER_FREQUENCY
		//  (giving a maximum CutoffFrequency of SampleRate/6).
		float OneOverQ;                     // Reciprocal of the filter's quality factor Q;
		//  must be > 0 and <= XAUDIO2_MAX_FILTER_ONEOVERQ.
	}

	// Used in IXAudio2SourceVoice::SubmitSourceBuffer
	struct XAUDIO2_BUFFER
	{
		UINT32 Flags;                       // Either 0 or XAUDIO2_END_OF_STREAM.
		UINT32 AudioBytes;                  // Size of the audio data buffer in bytes.
		const (ubyte)* pAudioData;             // Pointer to the audio data buffer.
		UINT32 PlayBegin;                   // First sample in this buffer to be played.
		UINT32 PlayLength;                  // Length of the region to be played in samples,
		//  or 0 to play the whole buffer.
		UINT32 LoopBegin;                   // First sample of the region to be looped.
		UINT32 LoopLength;                  // Length of the desired loop region in samples,
		//  or 0 to loop the entire buffer.
		UINT32 LoopCount;                   // Number of times to repeat the loop region,
		//  or XAUDIO2_LOOP_INFINITE to loop forever.
		void* pContext;                     // Context value to be passed back in callbacks.
	}

	// Used in IXAudio2SourceVoice::SubmitSourceBuffer when submitting XWMA data.
	// NOTE: If an XWMA sound is submitted in more than one buffer, each buffer's
	// pDecodedPacketCumulativeBytes[PacketCount-1] value must be subtracted from
	// all the entries in the next buffer's pDecodedPacketCumulativeBytes array.
	// And whether a sound is submitted in more than one buffer or not, the final
	// buffer of the sound should use the XAUDIO2_END_OF_STREAM flag, or else the
	// client must call IXAudio2SourceVoice::Discontinuity after submitting it.
	struct XAUDIO2_BUFFER_WMA
	{
		const (UINT32)* pDecodedPacketCumulativeBytes; // Decoded packet's cumulative size array.
		//  Each element is the number of bytes accumulated
		//  when the corresponding XWMA packet is decoded in
		//  order.  The array must have PacketCount elements.
		UINT32 PacketCount;                          // Number of XWMA packets submitted. Must be >= 1 and
		//  divide evenly into XAUDIO2_BUFFER.AudioBytes.
	}

	// Returned by IXAudio2SourceVoice::GetState
	struct XAUDIO2_VOICE_STATE
	{
		void* pCurrentBufferContext;        // The pContext value provided in the XAUDIO2_BUFFER
		//  that is currently being processed, or NULL if
		//	there are no buffers in the queue.
		UINT32 BuffersQueued;               // Number of buffers currently queued on the voice
		//  (including the one that is being processed).
		UINT64 SamplesPlayed;               // Total number of samples produced by the voice since
		//  it began processing the current audio stream.
	}

	// Returned by IXAudio2::GetPerformanceData
	struct XAUDIO2_PERFORMANCE_DATA
	{
		// CPU usage information
		UINT64 AudioCyclesSinceLastQuery;   // CPU cycles spent on audio processing since the
		//  last call to StartEngine or GetPerformanceData.
		UINT64 TotalCyclesSinceLastQuery;   // Total CPU cycles elapsed since the last call
		//  (only counts the CPU XAudio2 is running on).
		UINT32 MinimumCyclesPerQuantum;     // Fewest CPU cycles spent processing any one
		//  audio quantum since the last call.
		UINT32 MaximumCyclesPerQuantum;     // Most CPU cycles spent processing any one
		//  audio quantum since the last call.

		// Memory usage information
		UINT32 MemoryUsageInBytes;          // Total heap space currently in use.

		// Audio latency and glitching information
		UINT32 CurrentLatencyInSamples;     // Minimum delay from when a sample is read from a
		//  source buffer to when it reaches the speakers.
		UINT32 GlitchesSinceEngineStarted;  // Audio dropouts since the engine was started.

		// Data about XAudio2's current workload
		UINT32 ActiveSourceVoiceCount;      // Source voices currently playing.
		UINT32 TotalSourceVoiceCount;       // Source voices currently existing.
		UINT32 ActiveSubmixVoiceCount;      // Submix voices currently playing/existing.

		UINT32 ActiveResamplerCount;        // Resample xAPOs currently active.
		UINT32 ActiveMatrixMixCount;        // MatrixMix xAPOs currently active.

		// Usage of the hardware XMA decoder (Xbox 360 only)
		UINT32 ActiveXmaSourceVoices;       // Number of source voices decoding XMA data.
		UINT32 ActiveXmaStreams;            // A voice can use more than one XMA stream.
	}

	// Used in IXAudio2::SetDebugConfiguration
	struct XAUDIO2_DEBUG_CONFIGURATION
	{
		UINT32 TraceMask;                   // Bitmap of enabled debug message types.
		UINT32 BreakMask;                   // Message types that will break into the debugger.
		BOOL LogThreadID;                   // Whether to log the thread ID with each message.
		BOOL LogFileline;                   // Whether to log the source file and line number.
		BOOL LogFunctionName;               // Whether to log the function name.
		BOOL LogTiming;                     // Whether to log message timestamps.
	}

	// Values for the TraceMask and BreakMask bitmaps.  Only ERRORS and WARNINGS
	// are valid in BreakMask.  WARNINGS implies ERRORS, DETAIL implies INFO, and
	// FUNC_CALLS implies API_CALLS.  By default, TraceMask is ERRORS and WARNINGS
	// and all the other settings are zero.
	enum XAUDIO2_LOG_ERRORS     = 0x0001;   // For handled errors with serious effects.
	enum XAUDIO2_LOG_WARNINGS   = 0x0002;   // For handled errors that may be recoverable.
	enum XAUDIO2_LOG_INFO       = 0x0004;   // Informational chit-chat (e.g. state changes).
	enum XAUDIO2_LOG_DETAIL     = 0x0008;   // More detailed chit-chat.
	enum XAUDIO2_LOG_API_CALLS  = 0x0010;   // Public API function entries and exits.
	enum XAUDIO2_LOG_FUNC_CALLS = 0x0020;   // Internal function entries and exits.
	enum XAUDIO2_LOG_TIMING     = 0x0040;   // Delays detected and other timing data.
	enum XAUDIO2_LOG_LOCKS      = 0x0080;   // Usage of critical sections and mutexes.
	enum XAUDIO2_LOG_MEMORY     = 0x0100;   // Memory heap usage information.
	enum XAUDIO2_LOG_STREAMING  = 0x1000;   // Audio streaming information.


	/**************************************************************************
	*
	* IXAudio2: Top-level XAudio2 COM interface.
	*
	**************************************************************************/
	interface IXAudio2 : IUnknown
	{
		extern(Windows):
		version(DXSDK_2010_6)
		{
		// NAME: IXAudio2::GetDeviceCount
		// DESCRIPTION: Returns the number of audio output devices available.
		//
		// ARGUMENTS:
		//  pCount - Returns the device count.
		//
		HRESULT GetDeviceCount(UINT32* pCount);

		// NAME: IXAudio2::GetDeviceDetails
		// DESCRIPTION: Returns information about the device with the given index.
		//
		// ARGUMENTS:
		//  Index - Index of the device to be queried.
		//  pDeviceDetails - Returns the device details.
		//
		HRESULT GetDeviceDetails (UINT32 Index, XAUDIO2_DEVICE_DETAILS* pDeviceDetails);

		// NAME: IXAudio2::Initialize
		// DESCRIPTION: Sets global XAudio2 parameters and prepares it for use.
		//
		// ARGUMENTS:
		//  Flags - Flags specifying the XAudio2 object's behavior.  Currently unused.
		//  XAudio2Processor - An XAUDIO2_PROCESSOR enumeration value that specifies
		//  the hardware thread (Xbox) or processor (Windows) that XAudio2 will use.
		//  The enumeration values are platform-specific; platform-independent code
		//  can use XAUDIO2_DEFAULT_PROCESSOR to use the default on each platform.
		//
		HRESULT Initialize (
							UINT32 Flags = 0,
							XAUDIO2_PROCESSOR XAudio2Processor = XAUDIO2_DEFAULT_PROCESSOR); // XAUDIO2_WINDOWS_PROCESSOR_SPECIFIER.XAUDIO2_DEFAULT_PROCESSOR );
		}

		// NAME: IXAudio2::RegisterForCallbacks
		// DESCRIPTION: Adds a new client to receive XAudio2's engine callbacks.
		//
		// ARGUMENTS:
		//  pCallback - Callback interface to be called during each processing pass.
		//
		HRESULT RegisterForCallbacks (IXAudio2EngineCallback pCallback);

		// NAME: IXAudio2::UnregisterForCallbacks
		// DESCRIPTION: Removes an existing receiver of XAudio2 engine callbacks.
		//
		// ARGUMENTS:
		//  pCallback - Previously registered callback interface to be removed.
		//
		void UnregisterForCallbacks(IXAudio2EngineCallback pCallback);

		// NAME: IXAudio2::CreateSourceVoice
		// DESCRIPTION: Creates and configures a source voice.
		//
		// ARGUMENTS:
		//  ppSourceVoice - Returns the new object's IXAudio2SourceVoice interface.
		//  pSourceFormat - Format of the audio that will be fed to the voice.
		//  Flags - XAUDIO2_VOICE flags specifying the source voice's behavior.
		//  MaxFrequencyRatio - Maximum SetFrequencyRatio argument to be allowed.
		//	pCallback - Optional pointer to a client-provided callback interface.
		//  pSendList - Optional list of voices this voice should send audio to.
		//  pEffectChain - Optional list of effects to apply to the audio data.
		//
		HRESULT CreateSourceVoice (IXAudio2SourceVoice* ppSourceVoice,
								   const (WAVEFORMATEX)* pSourceFormat,
								   UINT32 Flags = 0,
								   float MaxFrequencyRatio = XAUDIO2_DEFAULT_FREQ_RATIO,
								   IXAudio2VoiceCallback pCallback = null,
								   const (XAUDIO2_VOICE_SENDS)* pSendList = null,
								   const (XAUDIO2_EFFECT_CHAIN)* pEffectChain = null);

		// NAME: IXAudio2::CreateSubmixVoice
		// DESCRIPTION: Creates and configures a submix voice.
		//
		// ARGUMENTS:
		//  ppSubmixVoice - Returns the new object's IXAudio2SubmixVoice interface.
		//  InputChannels - Number of channels in this voice's input audio data.
		//  InputSampleRate - Sample rate of this voice's input audio data.
		//  Flags - XAUDIO2_VOICE flags specifying the submix voice's behavior.
		//  ProcessingStage - Arbitrary number that determines the processing order.
		//  pSendList - Optional list of voices this voice should send audio to.
		//  pEffectChain - Optional list of effects to apply to the audio data.
		//
		HRESULT CreateSubmixVoice (IXAudio2SubmixVoice* ppSubmixVoice,
								   UINT32 InputChannels, UINT32 InputSampleRate,
								   UINT32 Flags = 0, UINT32 ProcessingStage = 0,
								   const (XAUDIO2_VOICE_SENDS)* pSendList = null,
								   const (XAUDIO2_EFFECT_CHAIN)* pEffectChain = null);


		// NAME: IXAudio2::CreateMasteringVoice
		// DESCRIPTION: Creates and configures a mastering voice.
		//
		// ARGUMENTS:
		//  ppMasteringVoice - Returns the new object's IXAudio2MasteringVoice interface.
		//  InputChannels - Number of channels in this voice's input audio data.
		//  InputSampleRate - Sample rate of this voice's input audio data.
		//  Flags - XAUDIO2_VOICE flags specifying the mastering voice's behavior.
		//  DeviceIndex - Identifier of the device to receive the output audio.
		//  pEffectChain - Optional list of effects to apply to the audio data.
		//
		HRESULT CreateMasteringVoice (IXAudio2MasteringVoice* ppMasteringVoice,
									  UINT32 InputChannels = XAUDIO2_DEFAULT_CHANNELS,
									  UINT32 InputSampleRate = XAUDIO2_DEFAULT_SAMPLERATE,
									  UINT32 Flags = 0, UINT32 DeviceIndex = 0,
									  const (XAUDIO2_EFFECT_CHAIN)* pEffectChain = null);

		// NAME: IXAudio2::StartEngine
		// DESCRIPTION: Creates and starts the audio processing thread.
		//
		HRESULT StartEngine ();

		// NAME: IXAudio2::StopEngine
		// DESCRIPTION: Stops and destroys the audio processing thread.
		//
		void StopEngine ();

		// NAME: IXAudio2::CommitChanges
		// DESCRIPTION: Atomically applies a set of operations previously tagged
		//              with a given identifier.
		//
		// ARGUMENTS:
		//  OperationSet - Identifier of the set of operations to be applied.
		//
		HRESULT CommitChanges (UINT32 OperationSet);

		// NAME: IXAudio2::GetPerformanceData
		// DESCRIPTION: Returns current resource usage details: memory, CPU, etc.
		//
		// ARGUMENTS:
		//  pPerfData - Returns the performance data structure.
		//
		void GetPerformanceData (XAUDIO2_PERFORMANCE_DATA* pPerfData);

		// NAME: IXAudio2::SetDebugConfiguration
		// DESCRIPTION: Configures XAudio2's debug output (in debug builds only).
		//
		// ARGUMENTS:
		//  pDebugConfiguration - Structure describing the debug output behavior.
		//	pReserved - Optional parameter; must be NULL.
		//
		void SetDebugConfiguration (const (XAUDIO2_DEBUG_CONFIGURATION)* pDebugConfiguration,
									void* pReserved = null);
	}


	/**************************************************************************
	*
	* IXAudio2Voice: Base voice management interface.
	*
	**************************************************************************/

	extern(C++) interface IXAudio2Voice
	{
			extern(Windows):
			/* NAME: IXAudio2Voice::GetVoiceDetails
			// DESCRIPTION: Returns the basic characteristics of this voice.
			//
			// ARGUMENTS:
			//  pVoiceDetails - Returns the voice's details.
			*/
			void GetVoiceDetails (XAUDIO2_VOICE_DETAILS* pVoiceDetails);

			/* NAME: IXAudio2Voice::SetOutputVoices
			// DESCRIPTION: Replaces the set of submix/mastering voices that receive
			//              this voice's output.
			//
			// ARGUMENTS:
			//  pSendList - Optional list of voices this voice should send audio to.
			*/
			HRESULT SetOutputVoices (const (XAUDIO2_VOICE_SENDS)* pSendList);

			/* NAME: IXAudio2Voice::SetEffectChain
			// DESCRIPTION: Replaces this voice's current effect chain with a new one.
			//
			// ARGUMENTS:
			//  pEffectChain - Structure describing the new effect chain to be used.
			*/
			HRESULT SetEffectChain (const (XAUDIO2_EFFECT_CHAIN)* pEffectChain);

			/* NAME: IXAudio2Voice::EnableEffect
			// DESCRIPTION: Enables an effect in this voice's effect chain.
			//
			// ARGUMENTS:
			//  EffectIndex - Index of an effect within this voice's effect chain.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT EnableEffect (UINT32 EffectIndex,
									UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::DisableEffect
			// DESCRIPTION: Disables an effect in this voice's effect chain.
			//
			// ARGUMENTS:
			//  EffectIndex - Index of an effect within this voice's effect chain.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT DisableEffect (UINT32 EffectIndex,
									UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::GetEffectState
			// DESCRIPTION: Returns the running state of an effect.
			//
			// ARGUMENTS:
			//  EffectIndex - Index of an effect within this voice's effect chain.
			//  pEnabled - Returns the enabled/disabled state of the given effect.
			*/
			void GetEffectState (UINT32 EffectIndex, /*out*/ BOOL* pEnabled);

			/* NAME: IXAudio2Voice::SetEffectParameters
			// DESCRIPTION: Sets effect-specific parameters.
			//
			// REMARKS: Unlike IXAPOParameters::SetParameters, this method may
			//          be called from any thread.  XAudio2 implements
			//          appropriate synchronization to copy the parameters to the
			//          realtime audio processing thread.
			//
			// ARGUMENTS:
			//  EffectIndex - Index of an effect within this voice's effect chain.
			//  pParameters - Pointer to an effect-specific parameters block.
			//  ParametersByteSize - Size of the pParameters array  in bytes.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/

			HRESULT SetEffectParameters (UINT32 EffectIndex,
											const (void)* pParameters,
											UINT32 ParametersByteSize,
											UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::GetEffectParameters
			// DESCRIPTION: Obtains the current effect-specific parameters.
			//
			// ARGUMENTS:
			//  EffectIndex - Index of an effect within this voice's effect chain.
			//  pParameters - Returns the current values of the effect-specific parameters.
			//  ParametersByteSize - Size of the pParameters array in bytes.
			*/
			HRESULT GetEffectParameters ( UINT32 EffectIndex,
											void* pParameters,
											UINT32 ParametersByteSize);

			/* NAME: IXAudio2Voice::SetFilterParameters
			// DESCRIPTION: Sets this voice's filter parameters.
			//
			// ARGUMENTS:
			//  pParameters - Pointer to the filter's parameter structure.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT SetFilterParameters ( const(XAUDIO2_FILTER_PARAMETERS)* pParameters,
											UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::GetFilterParameters
			// DESCRIPTION: Returns this voice's current filter parameters.
			//
			// ARGUMENTS:
			//  pParameters - Returns the filter parameters.
			*/
			void GetFilterParameters (XAUDIO2_FILTER_PARAMETERS* pParameters);

			/* NAME: IXAudio2Voice::SetOutputFilterParameters
			// DESCRIPTION: Sets the filter parameters on one of this voice's sends.
			//
			// ARGUMENTS:
			//  pDestinationVoice - Destination voice of the send whose filter parameters will be set.
			//  pParameters - Pointer to the filter's parameter structure.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT SetOutputFilterParameters (IXAudio2Voice pDestinationVoice,
												const (XAUDIO2_FILTER_PARAMETERS)* pParameters,
												UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::GetOutputFilterParameters
			// DESCRIPTION: Returns the filter parameters from one of this voice's sends.
			//
			// ARGUMENTS:
			//  pDestinationVoice - Destination voice of the send whose filter parameters will be read.
			//  pParameters - Returns the filter parameters.
			*/
			void GetOutputFilterParameters (IXAudio2Voice pDestinationVoice,
												XAUDIO2_FILTER_PARAMETERS* pParameters); 

			/* NAME: IXAudio2Voice::SetVolume
			// DESCRIPTION: Sets this voice's overall volume level.
			//
			// ARGUMENTS:
			//  Volume - New overall volume level to be used, as an amplitude factor.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT SetVolume (float Volume,
								UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::GetVolume
			// DESCRIPTION: Obtains this voice's current overall volume level.
			//
			// ARGUMENTS:
			//  pVolume: Returns the voice's current overall volume level.
			*/
			void GetVolume (float* pVolume);

			/* NAME: IXAudio2Voice::SetChannelVolumes
			// DESCRIPTION: Sets this voice's per-channel volume levels.
			//
			// ARGUMENTS:
			//  Channels - Used to confirm the voice's channel count.
			//  pVolumes - Array of per-channel volume levels to be used.
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT SetChannelVolumes (UINT32 Channels, const (float)* pVolumes,
											UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

			/* NAME: IXAudio2Voice::GetChannelVolumes
			// DESCRIPTION: Returns this voice's current per-channel volume levels.
			//
			// ARGUMENTS:
			//  Channels - Used to confirm the voice's channel count.
			//  pVolumes - Returns an array of the current per-channel volume levels.
			*/
			void GetChannelVolumes (UINT32 Channels, float* pVolumes);

			/* NAME: IXAudio2Voice::SetOutputMatrix
			// DESCRIPTION: Sets the volume levels used to mix from each channel of this
			//              voice's output audio to each channel of a given destination
			//              voice's input audio.
			//
			// ARGUMENTS:
			//  pDestinationVoice - The destination voice whose mix matrix to change.
			//  SourceChannels - Used to confirm this voice's output channel count
			//   (the number of channels produced by the last effect in the chain).
			//  DestinationChannels - Confirms the destination voice's input channels.
			//  pLevelMatrix - Array of [SourceChannels * DestinationChannels] send
			//   levels.  The level used to send from source channel S to destination
			//   channel D should be in pLevelMatrix[S + SourceChannels * D].
			//  OperationSet - Used to identify this call as part of a deferred batch.
			*/
			HRESULT SetOutputMatrix (IXAudio2Voice pDestinationVoice,
										UINT32 SourceChannels, UINT32 DestinationChannels,
										const (float)* pLevelMatrix,
										UINT32 OperationSet = XAUDIO2_COMMIT_NOW);
	
			/* NAME: IXAudio2Voice::GetOutputMatrix
			// DESCRIPTION: Obtains the volume levels used to send each channel of this
			//              voice's output audio to each channel of a given destination
			//              voice's input audio.
			//
			// ARGUMENTS:
			//  pDestinationVoice - The destination voice whose mix matrix to obtain.
			//  SourceChannels - Used to confirm this voice's output channel count
			//   (the number of channels produced by the last effect in the chain).
			//  DestinationChannels - Confirms the destination voice's input channels.
			//  pLevelMatrix - Array of send levels, as above.
			*/
			void GetOutputMatrix (IXAudio2Voice pDestinationVoice,
									UINT32 SourceChannels, 
									UINT32 DestinationChannels,
									float* pLevelMatrix);

			/* NAME: IXAudio2Voice::DestroyVoice
			// DESCRIPTION: Destroys this voice, stopping it if necessary and removing
			//              it from the XAudio2 graph.
			*/
			void DestroyVoice ();
	}


	/**************************************************************************
	*
	* IXAudio2SourceVoice: Source voice management interface.
	*
	**************************************************************************/

	extern(C++) interface IXAudio2SourceVoice : IXAudio2Voice
	{
		extern(Windows):
		
		// NAME: IXAudio2SourceVoice::Start
		// DESCRIPTION: Makes this voice start consuming and processing audio.
		//
		// ARGUMENTS:
		//  Flags - Flags controlling how the voice should be started.
		//  OperationSet - Used to identify this call as part of a deferred batch.
		//
		HRESULT Start (UINT32 Flags = 0, UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

		// NAME: IXAudio2SourceVoice::Stop
		// DESCRIPTION: Makes this voice stop consuming audio.
		//
		// ARGUMENTS:
		//  Flags - Flags controlling how the voice should be stopped.
		//  OperationSet - Used to identify this call as part of a deferred batch.
		//
		HRESULT Stop (UINT32 Flags = 0, UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

		// NAME: IXAudio2SourceVoice::SubmitSourceBuffer
		// DESCRIPTION: Adds a new audio buffer to this voice's input queue.
		//
		// ARGUMENTS:
		//  pBuffer - Pointer to the buffer structure to be queued.
		//  pBufferWMA - Additional structure used only when submitting XWMA data.
		//
		HRESULT SubmitSourceBuffer (const (XAUDIO2_BUFFER)* pBuffer, const (XAUDIO2_BUFFER_WMA)* pBufferWMA = null);

		// NAME: IXAudio2SourceVoice::FlushSourceBuffers
		// DESCRIPTION: Removes all pending audio buffers from this voice's queue.
		//
		HRESULT FlushSourceBuffers ();

		// NAME: IXAudio2SourceVoice::Discontinuity
		// DESCRIPTION: Notifies the voice of an intentional break in the stream of
		//              audio buffers (e.g. the end of a sound), to prevent XAudio2
		//              from interpreting an empty buffer queue as a glitch.
		//
		HRESULT Discontinuity ();

		// NAME: IXAudio2SourceVoice::ExitLoop
		// DESCRIPTION: Breaks out of the current loop when its end is reached.
		//
		// ARGUMENTS:
		//  OperationSet - Used to identify this call as part of a deferred batch.
		//
		HRESULT ExitLoop (UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

		// NAME: IXAudio2SourceVoice::GetState
		// DESCRIPTION: Returns the number of buffers currently queued on this voice,
		//              the pContext value associated with the currently processing
		//              buffer (if any), and other voice state information.
		//
		// ARGUMENTS:
		//  pVoiceState - Returns the state information.
		//
		void GetState (XAUDIO2_VOICE_STATE* pVoiceState); // may differ with DirectX versions

		// NAME: IXAudio2SourceVoice::SetFrequencyRatio
		// DESCRIPTION: Sets this voice's frequency adjustment, i.e. its pitch.
		//
		// ARGUMENTS:
		//  Ratio - Frequency change, expressed as source frequency / target frequency.
		//  OperationSet - Used to identify this call as part of a deferred batch.
		//
		HRESULT SetFrequencyRatio (float Ratio,
								   UINT32 OperationSet = XAUDIO2_COMMIT_NOW);

		// NAME: IXAudio2SourceVoice::GetFrequencyRatio
		// DESCRIPTION: Returns this voice's current frequency adjustment ratio.
		//
		// ARGUMENTS:
		//  pRatio - Returns the frequency adjustment.
		//
		void GetFrequencyRatio (float* pRatio);

		// NAME: IXAudio2SourceVoice::SetSourceSampleRate
		// DESCRIPTION: Reconfigures this voice to treat its source data as being
		//              at a different sample rate than the original one specified
		//              in CreateSourceVoice's pSourceFormat argument.
		//
		// ARGUMENTS:
		//  UINT32 - The intended sample rate of further submitted source data.
		//
		HRESULT SetSourceSampleRate (UINT32 NewSourceSampleRate);
	}

	/**************************************************************************
	*
	* IXAudio2SubmixVoice: Submixing voice management interface.
	*
	**************************************************************************/

	interface IXAudio2SubmixVoice : IXAudio2Voice
	{
		// There are currently no methods specific to submix voices.
	}


	/**************************************************************************
	*
	* IXAudio2MasteringVoice: Mastering voice management interface.
	*
	**************************************************************************/

	interface IXAudio2MasteringVoice : IXAudio2Voice
	{
		version(XAUDIO_2_8)
		HRESULT GetChannelMask(DWORD* pChannelmask);
	}


	/**************************************************************************
	*
	* IXAudio2EngineCallback: Client notification interface for engine events.
	*
	* REMARKS: Contains methods to notify the client when certain events happen
	*          in the XAudio2 engine.  This interface should be implemented by
	*          the client.  XAudio2 will call these methods via the interface
	*          pointer provided by the client when it calls XAudio2Create or
	*          IXAudio2::Initialize.
	*
	**************************************************************************/

	extern(C++) interface IXAudio2EngineCallback
	{
		extern(Windows):
		// Called by XAudio2 just before an audio processing pass begins.
		void OnProcessingPassStart ();

		// Called just after an audio processing pass ends.
		void OnProcessingPassEnd ();

		// Called in the event of a critical system error which requires XAudio2
		// to be closed down and restarted.  The error code is given in Error.
		void OnCriticalError (HRESULT Error);
	}


	/**************************************************************************
	*
	* IXAudio2VoiceCallback: Client notification interface for voice events.
	*
	* REMARKS: Contains methods to notify the client when certain events happen
	*          in an XAudio2 voice.  This interface should be implemented by the
	*          client.  XAudio2 will call these methods via an interface pointer
	*          provided by the client in the IXAudio2::CreateSourceVoice call.
	*
	**************************************************************************/

	extern(C++) interface IXAudio2VoiceCallback
	{
		// Called just before this voice's processing pass begins.
		void OnVoiceProcessingPassStart (UINT32 BytesRequired);

		// Called just after this voice's processing pass ends.
		void OnVoiceProcessingPassEnd ();

		// Called when this voice has just finished playing a buffer stream
		// (as marked with the XAUDIO2_END_OF_STREAM flag on the last buffer).
		void OnStreamEnd ();

		// Called when this voice is about to start processing a new buffer.
		void OnBufferStart (void* pBufferContext);

		// Called when this voice has just finished processing a buffer.
		// The buffer can now be reused or destroyed.
		void OnBufferEnd (void* pBufferContext);

		// Called when this voice has just reached the end position of a loop.
		void OnLoopEnd (void* pBufferContext);

		// Called in the event of a critical error during voice processing,
		// such as a failing xAPO or an error from the hardware XMA decoder.
		// The voice may have to be destroyed and re-created to recover from
		// the error.  The callback arguments report which buffer was being
		// processed when the error occurred, and its HRESULT code.
		void OnVoiceError (void* pBufferContext, HRESULT Error);
	}

	version (XAUDIO2_HELPER_FUNCTIONS)
	{

		// Calculate the argument to SetVolume from a decibel value
		float XAudio2DecibelsToAmplitudeRatio(float Decibels)
		{
			return pow(10.0f, Decibels / 20.0f);
		}

		// Recover a volume in decibels from an amplitude factor
		float XAudio2AmplitudeRatioToDecibels(float Volume)
		{
			if (Volume == 0)
			{
				return -3.402823466e+38f; // Smallest float value (-FLT_MAX)
			}
			return 20.0f * log10(Volume);
		}

		// Calculate the argument to SetFrequencyRatio from a semitone value
		float XAudio2SemitonesToFrequencyRatio(float Semitones)
		{
			// FrequencyRatio = 2 ^ Octaves
			//                = 2 ^ (Semitones / 12)
			return pow(2.0f, Semitones / 12.0f);
		}

		// Recover a pitch in semitones from a frequency ratio
		float XAudio2FrequencyRatioToSemitones(float FrequencyRatio)
		{
			// Semitones = 12 * log2(FrequencyRatio)
			//           = 12 * log2(10) * log10(FrequencyRatio)
			return 39.86313713864835f * log10(FrequencyRatio);
		}

		// Convert from filter cutoff frequencies expressed in Hertz to the radian
		// frequency values used in XAUDIO2_FILTER_PARAMETERS.Frequency.  Note that
		// the highest CutoffFrequency supported is SampleRate/6.  Higher values of
		// CutoffFrequency will return XAUDIO2_MAX_FILTER_FREQUENCY.
		float XAudio2CutoffFrequencyToRadians(float CutoffFrequency, UINT32 SampleRate)
		{
			if (cast(UINT32)(CutoffFrequency * 6.0f) >= SampleRate)
			{
				return XAUDIO2_MAX_FILTER_FREQUENCY;
			}
			return 2.0f * sin(cast(float)PI * CutoffFrequency / SampleRate);
		}

		// Convert from radian frequencies back to absolute frequencies in Hertz
		float XAudio2RadiansToCutoffFrequency(float Radians, float SampleRate)
		{
			return SampleRate * asin(Radians / 2.0f) / cast(float)PI;
		}

	}

	/**************************************************************************
	*
	* XAudio2Create: Top-level function that creates an XAudio2 instance.
	*
	* On Windows this is just an inline function that calls CoCreateInstance
	* and Initialize.  The arguments are described above, under Initialize,
	* except that the XAUDIO2_DEBUG_ENGINE flag can be used here to select
	* the debug version of XAudio2.
	*
	* On Xbox, this function is implemented in the XAudio2 library, and the
	* XAUDIO2_DEBUG_ENGINE flag has no effect; the client must explicitly
	* link with the debug version of the library to obtain debug behavior.
	*
	**************************************************************************/

	version(XBOX) 
	{

		STDAPI XAudio2Create(IXAudio2* ppXAudio2, UINT32 Flags = 0,
							 XAUDIO2_PROCESSOR XAudio2Processor = XAUDIO2_DEFAULT_PROCESSOR);
	}
	else // Windows
	{
		extern(Windows):
		version(DXSDK_2010_6)
			HRESULT XAudio2Create(out IXAudio2 ppXAudio2, UINT32 Flags = 0,
								  XAUDIO2_PROCESSOR XAudio2Processor = XAUDIO2_DEFAULT_PROCESSOR)
		{
			// Instantiate the appropriate XAudio2 engine
			IXAudio2 pXAudio2;

			HRESULT hr = CoCreateInstance((Flags & XAUDIO2_DEBUG_ENGINE) ? &IID_XAudio2_Debug : &IID_XAudio2,

			null, CLSCTX_INPROC_SERVER, &IID_IXAudio2, cast(void**)&pXAudio2);
			if (SUCCEEDED(hr))
			{
				hr = pXAudio2.Initialize(Flags, XAudio2Processor);

				if (SUCCEEDED(hr))
				{
					ppXAudio2 = pXAudio2;
				}
				else
				{
					pXAudio2.Release();
				}
			}

			return hr;
		}
		else version(XAUDIO_2_8)
		{
		HRESULT XAudio2Create(out IXAudio2 ppXAudio2, UINT32 Flags = 0,
								XAUDIO2_PROCESSOR XAudio2Processor = XAUDIO2_DEFAULT_PROCESSOR);
		}

	}
}
