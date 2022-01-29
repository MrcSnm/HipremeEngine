/*
 * Copyright (c) 2007-2009 The Khronos Group Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and /or associated documentation files (the "Materials "), to
 * deal in the Materials without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Materials, and to permit persons to whom the Materials are
 * furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Materials.
 *
 * THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE MATERIALS OR THE USE OR OTHER DEALINGS IN THE
 * MATERIALS.
 *
 * OpenSLES.h - OpenSL ES version 1.0.1
 *
 */

/****************************************************************************/
/* NOTE: This file is a standard OpenSL ES header file and should not be    */
/* modified in any way.                                                     */
/****************************************************************************/

module opensles.sles;

extern(C):

/*****************************************************************************/
/* Common types, structures, and defines                                */
/*****************************************************************************/

enum _KHRONOS_KEYS_ = true;

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


/* remap common types to SL types for clarity */
alias sl_uint8_t = ubyte;
alias sl_int8_t = byte;
alias sl_uint16_t = ushort;
alias sl_int16_t = short;
alias sl_uint32_t = uint;
alias sl_int32_t = int;
alias sl_int64_t = long;
alias sl_uint64_t = ulong;
alias SLint8 = sl_int8_t;          /* 8 bit signed integer  */
alias SLuint8 = sl_uint8_t;         /* 8 bit unsigned integer */
alias SLint16 = sl_int16_t;         /* 16 bit signed integer */
alias SLuint16 = sl_uint16_t;        /* 16 bit unsigned integer */
alias SLint32 = sl_int32_t;           /* 32 bit signed integer */
alias SLuint32 = sl_uint32_t;          /* 32 bit unsigned integer */

alias SLboolean =  SLuint32;
enum SL_BOOLEAN_FALSE =         (cast(SLboolean) 0x00000000);
enum SL_BOOLEAN_TRUE  =         (cast(SLboolean) 0x00000001);

alias SLchar =  SLuint8;			/* UTF-8 is to be used */
alias SLmillibel =  SLint16;
alias SLmillisecond =  SLuint32;
alias SLmilliHertz =  SLuint32;
alias SLmillimeter =  SLint32;
alias SLmillidegree =  SLint32;
alias SLpermille =  SLint16;
alias SLmicrosecond =  SLuint32;
alias SLresult =  SLuint32;

enum SL_MILLIBEL_MAX= 	(cast(SLmillibel) 0x7FFF);
enum SL_MILLIBEL_MIN= 	SLmillibel.min;

enum SL_MILLIHERTZ_MAX=	(cast(SLmilliHertz) 0xFFFFFFFF);
enum SL_MILLIMETER_MAX=	(cast(SLmillimeter) 0x7FFFFFFF);

/** Interface ID defined as a UUID */
struct SLInterfaceID_ {
    SLuint32 time_low;
    SLuint16 time_mid;
    SLuint16 time_hi_and_version;
    SLuint16 clock_seq;
    SLuint8[6] node;
}
alias SLInterfaceID = SLInterfaceID_*;

/* Forward declaration for the object interface */


alias SLObjectItf = const(SLObjectItf_*)*;

/* Objects ID's */

enum SL_OBJECTID_ENGINE				 = (cast(SLuint32) 0x00001001);
enum SL_OBJECTID_LEDDEVICE			 = (cast(SLuint32) 0x00001002);
enum SL_OBJECTID_VIBRADEVICE		 = (cast(SLuint32) 0x00001003);
enum SL_OBJECTID_AUDIOPLAYER		 = (cast(SLuint32) 0x00001004);
enum SL_OBJECTID_AUDIORECORDER	 	 = (cast(SLuint32) 0x00001005);
enum SL_OBJECTID_MIDIPLAYER		 	 = (cast(SLuint32) 0x00001006);
enum SL_OBJECTID_LISTENER		 	 = (cast(SLuint32) 0x00001007);
enum SL_OBJECTID_3DGROUP			 = (cast(SLuint32) 0x00001008);
enum SL_OBJECTID_OUTPUTMIX			 = (cast(SLuint32) 0x00001009);
enum SL_OBJECTID_METADATAEXTRACTOR	 = (cast(SLuint32) 0x0000100A);


/* SL Profiles */

enum SL_PROFILES_PHONE	= (cast(SLuint16) 0x0001);
enum SL_PROFILES_MUSIC	= (cast(SLuint16) 0x0002);
enum SL_PROFILES_GAME	= (cast(SLuint16) 0x0004);

/* Types of voices supported by the system */

enum SL_VOICETYPE_2D_AUDIO		=(cast(SLuint16) 0x0001);
enum SL_VOICETYPE_MIDI			=(cast(SLuint16) 0x0002);
enum SL_VOICETYPE_3D_AUDIO 		=(cast(SLuint16) 0x0004);
enum SL_VOICETYPE_3D_MIDIOUTPUT =(cast(SLuint16) 0x0008);

/* Convenient macros representing various different priority levels, for use with the SetPriority method */

enum SL_PRIORITY_LOWEST		= (cast(SLint32) (-0x7FFFFFFF-1));
enum SL_PRIORITY_VERYLOW	= (cast(SLint32) -0x60000000);
enum SL_PRIORITY_LOW		= (cast(SLint32) -0x40000000);
enum SL_PRIORITY_BELOWNORMAL= (cast(SLint32) -0x20000000);
enum SL_PRIORITY_NORMAL		= (cast(SLint32) 0x00000000);
enum SL_PRIORITY_ABOVENORMAL= (cast(SLint32) 0x20000000);
enum SL_PRIORITY_HIGH		= (cast(SLint32) 0x40000000);
enum SL_PRIORITY_VERYHIGH	= (cast(SLint32) 0x60000000);
enum SL_PRIORITY_HIGHEST	= (cast(SLint32) 0x7FFFFFFF);


/** These macros list the various sample formats that are possible on audio input and output devices. */

enum SL_PCMSAMPLEFORMAT_FIXED_8 = 	(cast(SLuint16) 0x0008);
enum SL_PCMSAMPLEFORMAT_FIXED_16 = 	(cast(SLuint16) 0x0010);
enum SL_PCMSAMPLEFORMAT_FIXED_20 =  (cast(SLuint16) 0x0014);
enum SL_PCMSAMPLEFORMAT_FIXED_24 = 	(cast(SLuint16) 0x0018);
enum SL_PCMSAMPLEFORMAT_FIXED_28 =  (cast(SLuint16) 0x001C);
enum SL_PCMSAMPLEFORMAT_FIXED_32 = 	(cast(SLuint16) 0x0020);


/** These macros specify the commonly used sampling rates (in milliHertz) supported by most audio I/O devices. */

enum SL_SAMPLINGRATE_8		= (cast(SLuint32) 8000000);
enum SL_SAMPLINGRATE_11_025	= (cast(SLuint32) 11025000);
enum SL_SAMPLINGRATE_12		= (cast(SLuint32) 12000000);
enum SL_SAMPLINGRATE_16		= (cast(SLuint32) 16000000);
enum SL_SAMPLINGRATE_22_05	= (cast(SLuint32) 22050000);
enum SL_SAMPLINGRATE_24		= (cast(SLuint32) 24000000);
enum SL_SAMPLINGRATE_32		= (cast(SLuint32) 32000000);
enum SL_SAMPLINGRATE_44_1	= (cast(SLuint32) 44100000);
enum SL_SAMPLINGRATE_48		= (cast(SLuint32) 48000000);
enum SL_SAMPLINGRATE_64		= (cast(SLuint32) 64000000);
enum SL_SAMPLINGRATE_88_2	= (cast(SLuint32) 88200000);
enum SL_SAMPLINGRATE_96		= (cast(SLuint32) 96000000);
enum SL_SAMPLINGRATE_192	= (cast(SLuint32) 192000000);

enum SL_SPEAKER_FRONT_LEFT			 = (cast(SLuint32) 0x00000001);
enum SL_SPEAKER_FRONT_RIGHT			 = (cast(SLuint32) 0x00000002);
enum SL_SPEAKER_FRONT_CENTER		 = (cast(SLuint32) 0x00000004);
enum SL_SPEAKER_LOW_FREQUENCY		 = (cast(SLuint32) 0x00000008);
enum SL_SPEAKER_BACK_LEFT			 = (cast(SLuint32) 0x00000010);
enum SL_SPEAKER_BACK_RIGHT			 = (cast(SLuint32) 0x00000020);
enum SL_SPEAKER_FRONT_LEFT_OF_CENTER = (cast(SLuint32) 0x00000040);
enum SL_SPEAKER_FRONT_RIGHT_OF_CENTER= (cast(SLuint32) 0x00000080);
enum SL_SPEAKER_BACK_CENTER			 = (cast(SLuint32) 0x00000100);
enum SL_SPEAKER_SIDE_LEFT			 = (cast(SLuint32) 0x00000200);
enum SL_SPEAKER_SIDE_RIGHT			 = (cast(SLuint32) 0x00000400);
enum SL_SPEAKER_TOP_CENTER			 = (cast(SLuint32) 0x00000800);
enum SL_SPEAKER_TOP_FRONT_LEFT		 = (cast(SLuint32) 0x00001000);
enum SL_SPEAKER_TOP_FRONT_CENTER	 = (cast(SLuint32) 0x00002000);
enum SL_SPEAKER_TOP_FRONT_RIGHT		 = (cast(SLuint32) 0x00004000);
enum SL_SPEAKER_TOP_BACK_LEFT		 = (cast(SLuint32) 0x00008000);
enum SL_SPEAKER_TOP_BACK_CENTER		 = (cast(SLuint32) 0x00010000);
enum SL_SPEAKER_TOP_BACK_RIGHT		 = (cast(SLuint32) 0x00020000);


/*****************************************************************************/
/* Errors                                                                    */
/*                                                                           */
/*****************************************************************************/

enum SL_RESULT_SUCCESS					= (cast(SLuint32) 0x00000000);
enum SL_RESULT_PRECONDITIONS_VIOLATED	= (cast(SLuint32) 0x00000001);
enum SL_RESULT_PARAMETER_INVALID		= (cast(SLuint32) 0x00000002);
enum SL_RESULT_MEMORY_FAILURE			= (cast(SLuint32) 0x00000003);
enum SL_RESULT_RESOURCE_ERROR			= (cast(SLuint32) 0x00000004);
enum SL_RESULT_RESOURCE_LOST			= (cast(SLuint32) 0x00000005);
enum SL_RESULT_IO_ERROR					= (cast(SLuint32) 0x00000006);
enum SL_RESULT_BUFFER_INSUFFICIENT		= (cast(SLuint32) 0x00000007);
enum SL_RESULT_CONTENT_CORRUPTED		= (cast(SLuint32) 0x00000008);
enum SL_RESULT_CONTENT_UNSUPPORTED		= (cast(SLuint32) 0x00000009);
enum SL_RESULT_CONTENT_NOT_FOUND		= (cast(SLuint32) 0x0000000A);
enum SL_RESULT_PERMISSION_DENIED		= (cast(SLuint32) 0x0000000B);
enum SL_RESULT_FEATURE_UNSUPPORTED		= (cast(SLuint32) 0x0000000C);
enum SL_RESULT_INTERNAL_ERROR			= (cast(SLuint32) 0x0000000D);
enum SL_RESULT_UNKNOWN_ERROR			= (cast(SLuint32) 0x0000000E);
enum SL_RESULT_OPERATION_ABORTED		= (cast(SLuint32) 0x0000000F);
enum SL_RESULT_CONTROL_LOST				= (cast(SLuint32) 0x00000010);


/* Object state definitions */

enum SL_OBJECT_STATE_UNREALIZED	= (cast(SLuint32) 0x00000001);
enum SL_OBJECT_STATE_REALIZED	= (cast(SLuint32) 0x00000002);
enum SL_OBJECT_STATE_SUSPENDED	= (cast(SLuint32) 0x00000003);

/* Object event definitions */

enum SL_OBJECT_EVENT_RUNTIME_ERROR			= (cast(SLuint32) 0x00000001);
enum SL_OBJECT_EVENT_ASYNC_TERMINATION		= (cast(SLuint32) 0x00000002);
enum SL_OBJECT_EVENT_RESOURCES_LOST			= (cast(SLuint32) 0x00000003);
enum SL_OBJECT_EVENT_RESOURCES_AVAILABLE	= (cast(SLuint32) 0x00000004);
enum SL_OBJECT_EVENT_ITF_CONTROL_TAKEN		= (cast(SLuint32) 0x00000005);
enum SL_OBJECT_EVENT_ITF_CONTROL_RETURNED	= (cast(SLuint32) 0x00000006);
enum SL_OBJECT_EVENT_ITF_PARAMETERS_CHANGED	= (cast(SLuint32) 0x00000007);


/*****************************************************************************/
/* Interface definitions                                                     */
/*****************************************************************************/

/** NULL Interface */

extern const(SLInterfaceID) SL_IID_NULL;

/*---------------------------------------------------------------------------*/
/* Data Source and Data Sink Structures                                      */
/*---------------------------------------------------------------------------*/

/** Data locator macros  */
enum SL_DATALOCATOR_URI			     = (cast(SLuint32) 0x00000001);
enum SL_DATALOCATOR_ADDRESS		     = (cast(SLuint32) 0x00000002);
enum SL_DATALOCATOR_IODEVICE		 = (cast(SLuint32) 0x00000003);
enum SL_DATALOCATOR_OUTPUTMIX		 = (cast(SLuint32) 0x00000004);
enum SL_DATALOCATOR_RESERVED5		 = (cast(SLuint32) 0x00000005);
enum SL_DATALOCATOR_BUFFERQUEUE	     = (cast(SLuint32) 0x00000006);
enum SL_DATALOCATOR_MIDIBUFFERQUEUE	 = (cast(SLuint32) 0x00000007);
enum SL_DATALOCATOR_RESERVED8		 = (cast(SLuint32) 0x00000008);



/** URI-based data locator definition where locatorType must be SL_DATALOCATOR_URI*/
struct SLDataLocator_URI_ {
	SLuint32 		locatorType;
	SLchar *		URI;
}

alias SLDataLocator_URI = SLDataLocator_URI_;

/** Address-based data locator definition where locatorType must be SL_DATALOCATOR_ADDRESS*/
struct SLDataLocator_Address_ {
	SLuint32 	locatorType;
	void 		*pAddress;
	SLuint32	length;
}
alias SLDataLocator_Address = SLDataLocator_Address_;

/** IODevice-types */
enum SL_IODEVICE_AUDIOINPUT	= (cast(SLuint32) 0x00000001);
enum SL_IODEVICE_LEDARRAY	= (cast(SLuint32) 0x00000002);
enum SL_IODEVICE_VIBRA		= (cast(SLuint32) 0x00000003);
enum SL_IODEVICE_RESERVED4	= (cast(SLuint32) 0x00000004);
enum SL_IODEVICE_RESERVED5	= (cast(SLuint32) 0x00000005);

/** IODevice-based data locator definition where locatorType must be SL_DATALOCATOR_IODEVICE*/
struct SLDataLocator_IODevice_ {
	SLuint32	locatorType;
	SLuint32	deviceType;
	SLuint32	deviceID;
	SLObjectItf	device;
}

alias SLDataLocator_IODevice = SLDataLocator_IODevice_;

/** OutputMix-based data locator definition where locatorType must be SL_DATALOCATOR_OUTPUTMIX*/
struct SLDataLocator_OutputMix {
	SLuint32 		locatorType;
	SLObjectItf		outputMix;
}


/** BufferQueue-based data locator definition where locatorType must be SL_DATALOCATOR_BUFFERQUEUE*/
struct SLDataLocator_BufferQueue {
	SLuint32	locatorType;
	SLuint32	numBuffers;
}

/** MidiBufferQueue-based data locator definition where locatorType must be SL_DATALOCATOR_MIDIBUFFERQUEUE*/
struct SLDataLocator_MIDIBufferQueue {
	SLuint32	locatorType;
	SLuint32	tpqn;
	SLuint32	numBuffers;
}

/** Data format defines */
enum SL_DATAFORMAT_MIME 		 = (cast(SLuint32)  0x00000001);
enum SL_DATAFORMAT_PCM 		 = (cast(SLuint32)  0x00000002);
enum SL_DATAFORMAT_RESERVED3 	 = (cast(SLuint32)  0x00000003);


/** MIME-type-based data format definition where formatType must be SL_DATAFORMAT_MIME*/
struct SLDataFormat_MIME_ {
	SLuint32 		formatType;
	SLchar * 		mimeType;
	SLuint32		containerType;
}
alias  SLDataFormat_MIME =  SLDataFormat_MIME_;

/* Byte order of a block of 16- or 32-bit data */
enum SL_BYTEORDER_BIGENDIAN 				 = (cast(SLuint32)  0x00000001);
enum SL_BYTEORDER_LITTLEENDIAN 			 = (cast(SLuint32)  0x00000002);

/* Container type */
enum SL_CONTAINERTYPE_UNSPECIFIED 	 = (cast(SLuint32)  0x00000001);
enum SL_CONTAINERTYPE_RAW 		 = (cast(SLuint32)  0x00000002);
enum SL_CONTAINERTYPE_ASF 		 = (cast(SLuint32)  0x00000003);
enum SL_CONTAINERTYPE_AVI 		 = (cast(SLuint32)  0x00000004);
enum SL_CONTAINERTYPE_BMP 		 = (cast(SLuint32)  0x00000005);
enum SL_CONTAINERTYPE_JPG 		 = (cast(SLuint32)  0x00000006);
enum SL_CONTAINERTYPE_JPG2000 		 = (cast(SLuint32)  0x00000007);
enum SL_CONTAINERTYPE_M4A 		 = (cast(SLuint32)  0x00000008);
enum SL_CONTAINERTYPE_MP3 		 = (cast(SLuint32)  0x00000009);
enum SL_CONTAINERTYPE_MP4 		 = (cast(SLuint32)  0x0000000A);
enum SL_CONTAINERTYPE_MPEG_ES 		 = (cast(SLuint32)  0x0000000B);
enum SL_CONTAINERTYPE_MPEG_PS 		 = (cast(SLuint32)  0x0000000C);
enum SL_CONTAINERTYPE_MPEG_TS 		 = (cast(SLuint32)  0x0000000D);
enum SL_CONTAINERTYPE_QT 		 = (cast(SLuint32)  0x0000000E);
enum SL_CONTAINERTYPE_WAV 		 = (cast(SLuint32)  0x0000000F);
enum SL_CONTAINERTYPE_XMF_0 		 = (cast(SLuint32)  0x00000010);
enum SL_CONTAINERTYPE_XMF_1 		 = (cast(SLuint32)  0x00000011);
enum SL_CONTAINERTYPE_XMF_2 		 = (cast(SLuint32)  0x00000012);
enum SL_CONTAINERTYPE_XMF_3 		 = (cast(SLuint32)  0x00000013);
enum SL_CONTAINERTYPE_XMF_GENERIC 	 = (cast(SLuint32)  0x00000014);
enum SL_CONTAINERTYPE_AMR   		 = (cast(SLuint32)  0x00000015);
enum SL_CONTAINERTYPE_AAC 		 = (cast(SLuint32)  0x00000016);
enum SL_CONTAINERTYPE_3GPP 		 = (cast(SLuint32)  0x00000017);
enum SL_CONTAINERTYPE_3GA 		 = (cast(SLuint32)  0x00000018);
enum SL_CONTAINERTYPE_RM 		 = (cast(SLuint32)  0x00000019);
enum SL_CONTAINERTYPE_DMF 		 = (cast(SLuint32)  0x0000001A);
enum SL_CONTAINERTYPE_SMF 		 = (cast(SLuint32)  0x0000001B);
enum SL_CONTAINERTYPE_MOBILE_DLS 	 = (cast(SLuint32)  0x0000001C);
enum SL_CONTAINERTYPE_OGG 	 = (cast(SLuint32)  0x0000001D);


/** PCM-type-based data format definition where formatType must be SL_DATAFORMAT_PCM*/
struct SLDataFormat_PCM_ {
	SLuint32 		formatType;
	SLuint32 		numChannels;
	SLuint32 		samplesPerSec;
	SLuint32 		bitsPerSample;
	SLuint32 		containerSize;
	SLuint32 		channelMask;
	SLuint32		endianness;
}
alias SLDataFormat_PCM =  SLDataFormat_PCM_;

struct SLDataSource_ {
	void *pLocator;
	void *pFormat;
}
alias SLDataSource = SLDataSource_;


struct SLDataSink_ {
	void *pLocator;
	void *pFormat;
}
alias SLDataSink = SLDataSink_;



/*---------------------------------------------------------------------------*/
/* Standard Object Interface                                                 */
/*---------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_OBJECT;

/** Object callback */


alias slObjectCallback = void function (
	SLObjectItf caller,
	const void * pContext,
	SLuint32 event,
	SLresult result,
    SLuint32 param,
    void *pInterface
);


struct SLObjectItf_ {
	SLresult function(
		SLObjectItf self,
		SLboolean async
	)  Realize;
	SLresult function (
		SLObjectItf self,
		SLboolean async
	) Resume;
	SLresult function  (
		SLObjectItf self,
		SLuint32 * pState
	) GetState;
	SLresult function (
		SLObjectItf self,
		const SLInterfaceID iid,
		void * pInterface
	) GetInterface;
	SLresult function (
		SLObjectItf self,
		slObjectCallback callback,
		void * pContext
	) RegisterCallback;
	void function (
		SLObjectItf self
	) AbortAsyncOperation;
	void function (
		SLObjectItf self
	) Destroy;
	SLresult function (
		SLObjectItf self,
		SLint32 priority,
		SLboolean preemptable
	) SetPriority;
	SLresult function (
		SLObjectItf self,
		SLint32 *pPriority,
		SLboolean *pPreemptable
	) GetPriority;
	SLresult function  (
		SLObjectItf self,
		SLint16 numInterfaces,
		SLInterfaceID * pInterfaceIDs,
		SLboolean enabled
	) SetLossOfControlInterfaces;
};


/*---------------------------------------------------------------------------*/
/* Audio IO Device capabilities interface                                    */
/*---------------------------------------------------------------------------*/

enum SL_DEFAULTDEVICEID_AUDIOINPUT  	 = (cast(SLuint32)  0xFFFFFFFF);
enum SL_DEFAULTDEVICEID_AUDIOOUTPUT  	 = (cast(SLuint32)  0xFFFFFFFE);
enum SL_DEFAULTDEVICEID_LED            = (cast(SLuint32)  0xFFFFFFFD);
enum SL_DEFAULTDEVICEID_VIBRA          = (cast(SLuint32)  0xFFFFFFFC);
enum SL_DEFAULTDEVICEID_RESERVED1      = (cast(SLuint32)  0xFFFFFFFB);


enum SL_DEVCONNECTION_INTEGRATED           = (cast(SLint16)  0x0001);
enum SL_DEVCONNECTION_ATTACHED_WIRED       = (cast(SLint16)  0x0100);
enum SL_DEVCONNECTION_ATTACHED_WIRELESS    = (cast(SLint16)  0x0200);
enum SL_DEVCONNECTION_NETWORK  		     = (cast(SLint16)  0x0400);


enum SL_DEVLOCATION_HANDSET  	 = (cast(SLuint16)  0x0001);
enum SL_DEVLOCATION_HEADSET  	 = (cast(SLuint16)  0x0002);
enum SL_DEVLOCATION_CARKIT  	 = (cast(SLuint16)  0x0003);
enum SL_DEVLOCATION_DOCK  	 = (cast(SLuint16)  0x0004);
enum SL_DEVLOCATION_REMOTE  	 = (cast(SLuint16)  0x0005);
/* Note: SL_DEVLOCATION_RESLTE is deprecated, use SL_DEVLOCATION_REMOTE instead. */
enum SL_DEVLOCATION_RESLTE  	 = (cast(SLuint16)  0x0005);


enum SL_DEVSCOPE_UNKNOWN       = (cast(SLuint16)  0x0001);
enum SL_DEVSCOPE_ENVIRONMENT   = (cast(SLuint16)  0x0002);
enum SL_DEVSCOPE_USER          = (cast(SLuint16)  0x0003);


struct SLAudioInputDescriptor_ {
	SLchar *deviceName;
	SLint16 deviceConnection;
	SLint16 deviceScope;
	SLint16 deviceLocation;
	SLboolean isForTelephony;
	SLmilliHertz minSampleRate;
	SLmilliHertz maxSampleRate;
	SLboolean isFreqRangeContinuous;
	SLmilliHertz *samplingRatesSupported;
	SLint16 numOfSamplingRatesSupported;
	SLint16 maxChannels;
}
alias SLAudioInputDescriptor = SLAudioInputDescriptor_;


struct SLAudioOutputDescriptor_ {
	SLchar *pDeviceName;
	SLint16 deviceConnection;
	SLint16 deviceScope;
	SLint16 deviceLocation;
	SLboolean isForTelephony;
	SLmilliHertz minSampleRate;
	SLmilliHertz maxSampleRate;
	SLboolean isFreqRangeContinuous;
	SLmilliHertz *samplingRatesSupported;
	SLint16 numOfSamplingRatesSupported;
	SLint16 maxChannels;
}
alias SLAudioOutputDescriptor = SLAudioOutputDescriptor_;



extern const(SLInterfaceID) SL_IID_AUDIOIODEVICECAPABILITIES;


alias SLAudioIODeviceCapabilitiesItf = const(SLAudioIODeviceCapabilitiesItf_*)*;


alias slAvailableAudioInputsChangedCallback = void function (
	SLAudioIODeviceCapabilitiesItf caller,
	void *pContext,
	SLuint32 deviceID,
	SLint32 numInputs,
	SLboolean isNew
);


alias slAvailableAudioOutputsChangedCallback = void function (
	SLAudioIODeviceCapabilitiesItf caller,
	void *pContext,
	SLuint32 deviceID,
	SLint32 numOutputs,
	SLboolean isNew
);

alias slDefaultDeviceIDMapChangedCallback = void function (
	SLAudioIODeviceCapabilitiesItf caller,
	void *pContext,
	SLboolean isOutput,
	SLint32 numDevices
);


struct SLAudioIODeviceCapabilitiesItf_ {
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLint32  *pNumInputs,
		SLuint32 *pInputDeviceIDs
	) GetAvailableAudioInputs;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLuint32 deviceId,
		SLAudioInputDescriptor *pDescriptor
	) QueryAudioInputCapabilities;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		slAvailableAudioInputsChangedCallback callback,
		void *pContext
	) RegisterAvailableAudioInputsChangedCallback;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLint32 *pNumOutputs,
		SLuint32 *pOutputDeviceIDs
	) GetAvailableAudioOutputs;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLuint32 deviceId,
		SLAudioOutputDescriptor *pDescriptor
	) QueryAudioOutputCapabilities;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		slAvailableAudioOutputsChangedCallback callback,
		void *pContext
	) RegisterAvailableAudioOutputsChangedCallback;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		slDefaultDeviceIDMapChangedCallback callback,
		void *pContext
	) RegisterDefaultDeviceIDMapChangedCallback;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLuint32 deviceId,
		SLint32 *pNumAudioInputs,
		SLuint32 *pAudioInputDeviceIDs
	) GetAssociatedAudioInputs;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLuint32 deviceId,
		SLint32 *pNumAudioOutputs,
		SLuint32 *pAudioOutputDeviceIDs
	) GetAssociatedAudioOutputs;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLuint32 defaultDeviceID,
		SLint32 *pNumAudioDevices,
		SLuint32 *pAudioDeviceIDs
	) GetDefaultAudioDevices;
	SLresult function (
		SLAudioIODeviceCapabilitiesItf self,
		SLuint32 deviceId,
		SLmilliHertz samplingRate,
		SLint32 *pSampleFormats,
		SLint32 *pNumOfSampleFormats
	) QuerySampleFormatsSupported;
};



/*---------------------------------------------------------------------------*/
/* Capabilities of the LED array IODevice                                    */
/*---------------------------------------------------------------------------*/

struct SLLEDDescriptor_ {
	SLuint8   ledCount;
	SLuint8   primaryLED;
	SLuint32  colorMask;
}
alias  SLLEDDescriptor =  SLLEDDescriptor_;


/*---------------------------------------------------------------------------*/
/* LED Array interface                                                       */
/*---------------------------------------------------------------------------*/

struct SLHSL_ {
    SLmillidegree  hue;
    SLpermille     saturation;
    SLpermille     lightness;
}
alias SLHSL = SLHSL_;


extern const(SLInterfaceID) SL_IID_LED;


alias SLLEDArrayItf = const(SLLEDArrayItf_*)*;

struct SLLEDArrayItf_ {
	SLresult function (
		SLLEDArrayItf self,
		SLuint32 lightMask
	) ActivateLEDArray;
	SLresult function (
		SLLEDArrayItf self,
		SLuint32 *lightMask
	) IsLEDArrayActivated;
	SLresult function (
		SLLEDArrayItf self,
		SLuint8 index,
		const SLHSL *color
	) SetColor;
	SLresult function (
		SLLEDArrayItf self,
		SLuint8 index,
		SLHSL *color
	) GetColor;
};

/*---------------------------------------------------------------------------*/
/* Capabilities of the Vibra IODevice                                        */
/*---------------------------------------------------------------------------*/

struct SLVibraDescriptor_ {
	SLboolean supportsFrequency;
	SLboolean supportsIntensity;
	SLmilliHertz  minFrequency;
	SLmilliHertz  maxFrequency;
}
alias SLVibraDescriptor = SLVibraDescriptor_;



/*---------------------------------------------------------------------------*/
/* Vibra interface                                                           */
/*---------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_VIBRA;



alias SLVibraItf = const(SLVibraItf_*)*;

struct SLVibraItf_ {
	SLresult function (
		SLVibraItf self,
		SLboolean vibrate
	) Vibrate;
	SLresult function (
		SLVibraItf self,
		SLboolean *pVibrating
	) IsVibrating;
	SLresult function (
		SLVibraItf self,
		SLmilliHertz frequency
	) SetFrequency;
	SLresult function (
		SLVibraItf self,
		SLmilliHertz *pFrequency
	) GetFrequency;
	SLresult function (
		SLVibraItf self,
		SLpermille intensity
	) SetIntensity;
	SLresult function (
		SLVibraItf self,
		SLpermille *pIntensity
	) GetIntensity;
}


/*---------------------------------------------------------------------------*/
/* Meta data extraction related types and interface                          */
/*---------------------------------------------------------------------------*/

enum SL_CHARACTERENCODING_UNKNOWN 			 = (cast(SLuint32)  0x00000000);
enum SL_CHARACTERENCODING_BINARY         = (cast(SLuint32)  0x00000001);
enum SL_CHARACTERENCODING_ASCII          = (cast(SLuint32)  0x00000002);
enum SL_CHARACTERENCODING_BIG5           = (cast(SLuint32)  0x00000003);
enum SL_CHARACTERENCODING_CODEPAGE1252 		 = (cast(SLuint32)  0x00000004);
enum SL_CHARACTERENCODING_GB2312 			 = (cast(SLuint32)  0x00000005);
enum SL_CHARACTERENCODING_HZGB2312 			 = (cast(SLuint32)  0x00000006);
enum SL_CHARACTERENCODING_GB12345 			 = (cast(SLuint32)  0x00000007);
enum SL_CHARACTERENCODING_GB18030 			 = (cast(SLuint32)  0x00000008);
enum SL_CHARACTERENCODING_GBK 				 = (cast(SLuint32)  0x00000009);
enum SL_CHARACTERENCODING_IMAPUTF7 			 = (cast(SLuint32)  0x0000000A);
enum SL_CHARACTERENCODING_ISO2022JP 			 = (cast(SLuint32)  0x0000000B);
enum SL_CHARACTERENCODING_ISO2022JP1 		 = (cast(SLuint32)  0x0000000B);
enum SL_CHARACTERENCODING_ISO88591 			 = (cast(SLuint32)  0x0000000C);
enum SL_CHARACTERENCODING_ISO885910 			 = (cast(SLuint32)  0x0000000D);
enum SL_CHARACTERENCODING_ISO885913 			 = (cast(SLuint32)  0x0000000E);
enum SL_CHARACTERENCODING_ISO885914 			 = (cast(SLuint32)  0x0000000F);
enum SL_CHARACTERENCODING_ISO885915 			 = (cast(SLuint32)  0x00000010);
enum SL_CHARACTERENCODING_ISO88592 			 = (cast(SLuint32)  0x00000011);
enum SL_CHARACTERENCODING_ISO88593 			 = (cast(SLuint32)  0x00000012);
enum SL_CHARACTERENCODING_ISO88594 			 = (cast(SLuint32)  0x00000013);
enum SL_CHARACTERENCODING_ISO88595 			 = (cast(SLuint32)  0x00000014);
enum SL_CHARACTERENCODING_ISO88596 			 = (cast(SLuint32)  0x00000015);
enum SL_CHARACTERENCODING_ISO88597 			 = (cast(SLuint32)  0x00000016);
enum SL_CHARACTERENCODING_ISO88598 			 = (cast(SLuint32)  0x00000017);
enum SL_CHARACTERENCODING_ISO88599 			 = (cast(SLuint32)  0x00000018);
enum SL_CHARACTERENCODING_ISOEUCJP 			 = (cast(SLuint32)  0x00000019);
enum SL_CHARACTERENCODING_SHIFTJIS 			 = (cast(SLuint32)  0x0000001A);
enum SL_CHARACTERENCODING_SMS7BIT 			 = (cast(SLuint32)  0x0000001B);
enum SL_CHARACTERENCODING_UTF7 			 = (cast(SLuint32)  0x0000001C);
enum SL_CHARACTERENCODING_UTF8 			 = (cast(SLuint32)  0x0000001D);
enum SL_CHARACTERENCODING_JAVACONFORMANTUTF8 	 = (cast(SLuint32)  0x0000001E);
enum SL_CHARACTERENCODING_UTF16BE 			 = (cast(SLuint32)  0x0000001F);
enum SL_CHARACTERENCODING_UTF16LE 			 = (cast(SLuint32)  0x00000020);


enum SL_METADATA_FILTER_KEY 		 = (cast(SLuint8)  0x01);
enum SL_METADATA_FILTER_LANG 		 = (cast(SLuint8)  0x02);
enum SL_METADATA_FILTER_ENCODING 	 = (cast(SLuint8)  0x04);


struct SLMetadataInfo_ {
    SLuint32     size;
    SLuint32     encoding;
    SLchar[16]   langCountry;
    SLuint8[1]   data;
}

alias SLMetadataInfo = SLMetadataInfo_;

extern const(SLInterfaceID) SL_IID_METADATAEXTRACTION;


alias SLMetadataExtractionItf = const(SLMetadataExtractionItf_*)*;


struct SLMetadataExtractionItf_ {
	SLresult function (
		SLMetadataExtractionItf self,
		SLuint32 *pItemCount
	) GetItemCount;
	SLresult function (
		SLMetadataExtractionItf self,
		SLuint32 index,
		SLuint32 *pKeySize
	)  GetKeySize;
	SLresult function (
		SLMetadataExtractionItf self,
		SLuint32 index,
		SLuint32 keySize,
		SLMetadataInfo *pKey
	)  GetKey;
	SLresult function (
		SLMetadataExtractionItf self,
		SLuint32 index,
		SLuint32 *pValueSize
	) GetValueSize;
	SLresult function (
		SLMetadataExtractionItf self,
		SLuint32 index,
		SLuint32 valueSize,
		SLMetadataInfo *pValue
	)  GetValue;
	SLresult function (
		SLMetadataExtractionItf self,
		SLuint32 keySize,
		const void *pKey,
		SLuint32 keyEncoding,
		const SLchar *pValueLangCountry,
		SLuint32 valueEncoding,
		SLuint8 filterMask
	)  AddKeyFilter;
	SLresult function (
		SLMetadataExtractionItf self
	) ClearKeyFilter;
}


/*---------------------------------------------------------------------------*/
/* Meta data traversal related types and interface                          */
/*---------------------------------------------------------------------------*/

enum SL_METADATATRAVERSALMODE_ALL 	 = (cast(SLuint32)  0x00000001);
enum SL_METADATATRAVERSALMODE_NODE 	 = (cast(SLuint32)  0x00000002);


enum SL_NODETYPE_UNSPECIFIED 	 = (cast(SLuint32)  0x00000001);
enum SL_NODETYPE_AUDIO 		 = (cast(SLuint32)  0x00000002);
enum SL_NODETYPE_VIDEO 		 = (cast(SLuint32)  0x00000003);
enum SL_NODETYPE_IMAGE 		 = (cast(SLuint32)  0x00000004);

enum SL_NODE_PARENT =  0xFFFFFFFF;

extern const(SLInterfaceID) SL_IID_METADATATRAVERSAL;


alias SLMetadataTraversalItf = const(SLMetadataTraversalItf_*)*;

struct SLMetadataTraversalItf_ {
	SLresult function (
		SLMetadataTraversalItf self,
		SLuint32 mode
	) SetMode;
	SLresult function (
		SLMetadataTraversalItf self,
		SLuint32 *pCount
	) GetChildCount;
	SLresult function (
		SLMetadataTraversalItf self,
		SLuint32 index,
		SLuint32 *pSize
	)  GetChildMIMETypeSize;
	SLresult function  (
		SLMetadataTraversalItf self,
		SLuint32 index,
		SLint32 *pNodeID,
		SLuint32 *pType,
		SLuint32 size,
		SLchar *pMimeType
	) GetChildInfo;
	SLresult function (
		SLMetadataTraversalItf self,
		SLuint32 index
	) SetActiveNode;
}

/*---------------------------------------------------------------------------*/
/* Dynamic Source types and interface                                        */
/*---------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_DYNAMICSOURCE;


alias SLDynamicSourceItf = const(SLDynamicSourceItf_*)*;

struct SLDynamicSourceItf_ {
	SLresult function (
		SLDynamicSourceItf self,
		SLDataSource *pDataSource
	) SetSource;
}

/*---------------------------------------------------------------------------*/
/* Output Mix interface                                                      */
/*---------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_OUTPUTMIX;


alias SLOutputMixItf = const(SLOutputMixItf_*)*;

alias slMixDeviceChangeCallback = void function(
	SLOutputMixItf caller,
    void *pContext
);


struct SLOutputMixItf_ {
	SLresult function (
		SLOutputMixItf self,
		SLint32 *pNumDevices,
		SLuint32 *pDeviceIDs
	) GetDestinationOutputDeviceIDs;
	SLresult function (
		SLOutputMixItf self,
		slMixDeviceChangeCallback callback,
		void *pContext
    ) RegisterDeviceChangeCallback;
    SLresult function (
        SLOutputMixItf self,
        SLint32 numOutputDevices,
        SLuint32 *pOutputDeviceIDs
    ) ReRoute;
};


/*---------------------------------------------------------------------------*/
/* Playback interface                                                        */
/*---------------------------------------------------------------------------*/

/** Playback states */
enum SL_PLAYSTATE_STOPPED 	 = (cast(SLuint32)  0x00000001);
enum SL_PLAYSTATE_PAUSED 	 = (cast(SLuint32)  0x00000002);
enum SL_PLAYSTATE_PLAYING 	 = (cast(SLuint32)  0x00000003);

/** Play events **/
enum SL_PLAYEVENT_HEADATEND 		 = (cast(SLuint32)  0x00000001);
enum SL_PLAYEVENT_HEADATMARKER 	 = (cast(SLuint32)  0x00000002);
enum SL_PLAYEVENT_HEADATNEWPOS 	 = (cast(SLuint32)  0x00000004);
enum SL_PLAYEVENT_HEADMOVING 		 = (cast(SLuint32)  0x00000008);
enum SL_PLAYEVENT_HEADSTALLED 	 = (cast(SLuint32)  0x00000010);

enum SL_TIME_UNKNOWN 	 = (cast(SLuint32)  0xFFFFFFFF);


extern const(SLInterfaceID) SL_IID_PLAY;

/** Playback interface methods */


alias SLPlayItf = const(SLPlayItf_*)*;

alias slPlayCallback = void function(
	SLPlayItf caller,
	void *pContext,
	SLuint32 event
);

struct SLPlayItf_ {
	SLresult function (
		SLPlayItf self,
		SLuint32 state
	) SetPlayState;
	SLresult function (
		SLPlayItf self,
		SLuint32 *pState
	) GetPlayState;
	SLresult function (
		SLPlayItf self,
		SLmillisecond *pMsec
	) GetDuration;
	SLresult function (
		SLPlayItf self,
		SLmillisecond *pMsec
	) GetPosition;
	SLresult function (
		SLPlayItf self,
		slPlayCallback callback,
		void *pContext
	) RegisterCallback;
	SLresult function (
		SLPlayItf self,
		SLuint32 eventFlags
	) SetCallbackEventsMask;
	SLresult function (
		SLPlayItf self,
		SLuint32 *pEventFlags
	) GetCallbackEventsMask;
	SLresult function (
		SLPlayItf self,
		SLmillisecond mSec
	) SetMarkerPosition;
	SLresult function (
		SLPlayItf self
	) ClearMarkerPosition;
	SLresult function (
		SLPlayItf self,
		SLmillisecond *pMsec
	) GetMarkerPosition;
	SLresult function (
		SLPlayItf self,
		SLmillisecond mSec
	) SetPositionUpdatePeriod;
	SLresult function (
		SLPlayItf self,
		SLmillisecond *pMsec
	) GetPositionUpdatePeriod;
}

/*---------------------------------------------------------------------------*/
/* Prefetch status interface                                                 */
/*---------------------------------------------------------------------------*/

enum SL_PREFETCHEVENT_STATUSCHANGE 		 = (cast(SLuint32)  0x00000001);
enum SL_PREFETCHEVENT_FILLLEVELCHANGE 	 = (cast(SLuint32)  0x00000002);

enum SL_PREFETCHSTATUS_UNDERFLOW 		 = (cast(SLuint32)  0x00000001);
enum SL_PREFETCHSTATUS_SUFFICIENTDATA 	 = (cast(SLuint32)  0x00000002);
enum SL_PREFETCHSTATUS_OVERFLOW 		 = (cast(SLuint32)  0x00000003);


extern const(SLInterfaceID) SL_IID_PREFETCHSTATUS;


/** Prefetch status interface methods */


alias SLPrefetchStatusItf = const(SLPrefetchStatusItf_*)*;

alias slPrefetchCallback = void function (
	SLPrefetchStatusItf caller,
	void *pContext,
	SLuint32 event
);

struct SLPrefetchStatusItf_ {
	SLresult function (
		SLPrefetchStatusItf self,
		SLuint32 *pStatus
	) GetPrefetchStatus;
	SLresult function (
		SLPrefetchStatusItf self,
		SLpermille *pLevel
	) GetFillLevel;
	SLresult function (
		SLPrefetchStatusItf self,
		slPrefetchCallback callback,
		void *pContext
	) RegisterCallback;
	SLresult function (
		SLPrefetchStatusItf self,
		SLuint32 eventFlags
	) SetCallbackEventsMask;
	SLresult function (
		SLPrefetchStatusItf self,
		SLuint32 *pEventFlags
	) GetCallbackEventsMask;
	SLresult function (
		SLPrefetchStatusItf self,
		SLpermille period
	) SetFillUpdatePeriod;
	SLresult function (
		SLPrefetchStatusItf self,
		SLpermille *pPeriod
	) GetFillUpdatePeriod;
}

/*---------------------------------------------------------------------------*/
/* Playback Rate interface                                                   */
/*---------------------------------------------------------------------------*/

enum SL_RATEPROP_RESERVED1 		  		 = (cast(SLuint32)  0x00000001);
enum SL_RATEPROP_RESERVED2 		  		 = (cast(SLuint32)  0x00000002);
enum SL_RATEPROP_SILENTAUDIO 				 = (cast(SLuint32)  0x00000100);
enum SL_RATEPROP_STAGGEREDAUDIO 	 = (cast(SLuint32)  0x00000200);
enum SL_RATEPROP_NOPITCHCORAUDIO 	 = (cast(SLuint32)  0x00000400);
enum SL_RATEPROP_PITCHCORAUDIO 	 = (cast(SLuint32)  0x00000800);


extern const(SLInterfaceID) SL_IID_PLAYBACKRATE;


alias SLPlaybackRateItf = const(SLPlaybackRateItf_*)*;

struct SLPlaybackRateItf_ {
	SLresult function (
		SLPlaybackRateItf self,
		SLpermille rate
	) SetRate;
	SLresult function (
		SLPlaybackRateItf self,
		SLpermille *pRate
	) GetRate;
	SLresult function (
		SLPlaybackRateItf self,
		SLuint32 constraints
	) SetPropertyConstraints;
	SLresult function (
		SLPlaybackRateItf self,
		SLuint32 *pProperties
	) GetProperties;
	SLresult function (
		SLPlaybackRateItf self,
		SLpermille rate,
		SLuint32 *pCapabilities
	) GetCapabilitiesOfRate;
	SLresult function (
		SLPlaybackRateItf self,
		SLuint8 index,
		SLpermille *pMinRate,
		SLpermille *pMaxRate,
		SLpermille *pStepSize,
		SLuint32 *pCapabilities
	) GetRateRange;
}

/*---------------------------------------------------------------------------*/
/* Seek Interface                                                            */
/*---------------------------------------------------------------------------*/

enum SL_SEEKMODE_FAST 		 = (cast(SLuint32)  0x0001);
enum SL_SEEKMODE_ACCURATE 	 = (cast(SLuint32)  0x0002);

extern const(SLInterfaceID) SL_IID_SEEK;


alias SLSeekItf = const(SLSeekItf_*)*;

struct SLSeekItf_ {
	SLresult function(
		SLSeekItf self,
		SLmillisecond pos,
		SLuint32 seekMode
	) SetPosition;
	SLresult function(
		SLSeekItf self,
		SLboolean loopEnable,
		SLmillisecond startPos,
		SLmillisecond endPos
	) SetLoop;
	SLresult function(
		SLSeekItf self,
		SLboolean *pLoopEnabled,
		SLmillisecond *pStartPos,
		SLmillisecond *pEndPos
	) GetLoop;
}

/*---------------------------------------------------------------------------*/
/* Standard Recording Interface                                              */
/*---------------------------------------------------------------------------*/

/** Recording states */
enum SL_RECORDSTATE_STOPPED  	 = (cast(SLuint32)  0x00000001);
enum SL_RECORDSTATE_PAUSED 	 = (cast(SLuint32)  0x00000002);
enum SL_RECORDSTATE_RECORDING 	 = (cast(SLuint32)  0x00000003);


/** Record event **/
enum SL_RECORDEVENT_HEADATLIMIT 	 = (cast(SLuint32)  0x00000001);
enum SL_RECORDEVENT_HEADATMARKER 	 = (cast(SLuint32)  0x00000002);
enum SL_RECORDEVENT_HEADATNEWPOS 	 = (cast(SLuint32)  0x00000004);
enum SL_RECORDEVENT_HEADMOVING 	 = (cast(SLuint32)  0x00000008);
enum SL_RECORDEVENT_HEADSTALLED  	 = (cast(SLuint32)  0x00000010);
/* Note: SL_RECORDEVENT_BUFFER_INSUFFICIENT is deprecated, use SL_RECORDEVENT_BUFFER_FULL instead. */
enum SL_RECORDEVENT_BUFFER_INSUFFICIENT        = (cast(SLuint32)  0x00000020);
enum SL_RECORDEVENT_BUFFER_FULL 	 = (cast(SLuint32)  0x00000020);


extern const(SLInterfaceID) SL_IID_RECORD;


alias SLRecordItf = const(SLRecordItf_*)*;

alias slRecordCallback = void function (
	SLRecordItf caller,
	void *pContext,
	SLuint32 event
);

/** Recording interface methods */
struct SLRecordItf_ {
	SLresult function (
		SLRecordItf self,
		SLuint32 state
	) SetRecordState;
	SLresult function (
		SLRecordItf self,
		SLuint32 *pState
	) GetRecordState;
	SLresult function (
		SLRecordItf self,
		SLmillisecond msec
	) SetDurationLimit;
	SLresult function (
		SLRecordItf self,
		SLmillisecond *pMsec
	) GetPosition;
	SLresult function (
		SLRecordItf self,
		slRecordCallback callback,
		void *pContext
	) RegisterCallback;
	SLresult function (
		SLRecordItf self,
		SLuint32 eventFlags
	) SetCallbackEventsMask;
	SLresult function (
		SLRecordItf self,
		SLuint32 *pEventFlags
	) GetCallbackEventsMask;
	SLresult function (
		SLRecordItf self,
		SLmillisecond mSec
	) SetMarkerPosition;
	SLresult function (
		SLRecordItf self
	) ClearMarkerPosition;
	SLresult function (
		SLRecordItf self,
		SLmillisecond *pMsec
	) GetMarkerPosition;
	SLresult function (
		SLRecordItf self,
		SLmillisecond mSec
	) SetPositionUpdatePeriod;
	SLresult function (
		SLRecordItf self,
		SLmillisecond *pMsec
	) GetPositionUpdatePeriod;
};

/*---------------------------------------------------------------------------*/
/* Equalizer interface                                                       */
/*---------------------------------------------------------------------------*/

enum SL_EQUALIZER_UNDEFINED 				 = (cast(SLuint16)  0xFFFF);

extern const(SLInterfaceID) SL_IID_EQUALIZER;


alias SLEqualizerItf = const(SLEqualizerItf_*)*;

struct SLEqualizerItf_ {
	SLresult function (
		SLEqualizerItf self,
		SLboolean enabled
	) SetEnabled;
	SLresult function (
		SLEqualizerItf self,
		SLboolean *pEnabled
	) IsEnabled;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 *pAmount
	) GetNumberOfBands;
	SLresult function (
		SLEqualizerItf self,
		SLmillibel *pMin,
		SLmillibel *pMax
	) GetBandLevelRange;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 band,
		SLmillibel level
	) SetBandLevel;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 band,
		SLmillibel *pLevel
	) GetBandLevel;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 band,
		SLmilliHertz *pCenter
	) GetCenterFreq;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 band,
		SLmilliHertz *pMin,
		SLmilliHertz *pMax
	) GetBandFreqRange;
	SLresult function (
		SLEqualizerItf self,
		SLmilliHertz frequency,
		SLuint16 *pBand
	) GetBand;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 *pPreset
	) GetCurrentPreset;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 index
	) UsePreset;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 *pNumPresets
	) GetNumberOfPresets;
	SLresult function (
		SLEqualizerItf self,
		SLuint16 index,
		const SLchar ** ppName
	) GetPresetName;
}

/*---------------------------------------------------------------------------*/
/* Volume Interface                                                           */
/* --------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_VOLUME;


alias SLVolumeItf = const(SLVolumeItf_*)*;

struct SLVolumeItf_ {
	SLresult function (
		SLVolumeItf self,
		SLmillibel level
	) SetVolumeLevel;
	SLresult function (
		SLVolumeItf self,
		SLmillibel *pLevel
	) GetVolumeLevel;
	SLresult function (
		SLVolumeItf  self,
		SLmillibel *pMaxLevel
	) GetMaxVolumeLevel;
	SLresult function (
		SLVolumeItf self,
		SLboolean mute
	) SetMute;
	SLresult function (
		SLVolumeItf self,
		SLboolean *pMute
	) GetMute;
	SLresult function (
		SLVolumeItf self,
		SLboolean enable
	) EnableStereoPosition;
	SLresult function (
		SLVolumeItf self,
		SLboolean *pEnable
	) IsEnabledStereoPosition;
	SLresult function (
		SLVolumeItf self,
		SLpermille stereoPosition
	) SetStereoPosition;
	SLresult function (
		SLVolumeItf self,
		SLpermille *pStereoPosition
	) GetStereoPosition;
}


/*---------------------------------------------------------------------------*/
/* Device Volume Interface                                                   */
/* --------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_DEVICEVOLUME;


alias SLDeviceVolumeItf = const(SLDeviceVolumeItf_*)*;

struct SLDeviceVolumeItf_ {
	SLresult function (
		SLDeviceVolumeItf self,
		SLuint32 deviceID,
		SLint32 *pMinValue,
		SLint32 *pMaxValue,
		SLboolean *pIsMillibelScale
	) GetVolumeScale;
	SLresult function (
		SLDeviceVolumeItf self,
		SLuint32 deviceID,
		SLint32 volume
	) SetVolume;
	SLresult function (
		SLDeviceVolumeItf self,
		SLuint32 deviceID,
		SLint32 *pVolume
	) GetVolume;
};


/*---------------------------------------------------------------------------*/
/* Buffer Queue Interface                                                    */
/*---------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_BUFFERQUEUE;


alias SLBufferQueueItf = const(SLBufferQueueItf_*)*;

alias slBufferQueueCallback = void function (
	SLBufferQueueItf caller,
	void *pContext
);

/** Buffer queue state **/

struct SLBufferQueueState_ {
	SLuint32	count;
	SLuint32	playIndex;
}
alias  SLBufferQueueState =  SLBufferQueueState_;


struct SLBufferQueueItf_ {
	SLresult function (
		SLBufferQueueItf self,
		const void *pBuffer,
		SLuint32 size
	)Enqueue ;
	SLresult function (
		SLBufferQueueItf self
	)  Clear;
	SLresult function (
		SLBufferQueueItf self,
		SLBufferQueueState *pState
	) GetState;
	SLresult function (
		SLBufferQueueItf self,
		slBufferQueueCallback callback,
		void* pContext
	) RegisterCallback;
}


/*---------------------------------------------------------------------------*/
/* PresetReverb                                                              */
/*---------------------------------------------------------------------------*/

enum SL_REVERBPRESET_NONE 		 = (cast(SLuint16)  0x0000);
enum SL_REVERBPRESET_SMALLROOM 	 = (cast(SLuint16)  0x0001);
enum SL_REVERBPRESET_MEDIUMROOM  = (cast(SLuint16)  0x0002);
enum SL_REVERBPRESET_LARGEROOM 	 = (cast(SLuint16)  0x0003);
enum SL_REVERBPRESET_MEDIUMHALL  = (cast(SLuint16)  0x0004);
enum SL_REVERBPRESET_LARGEHALL 	 = (cast(SLuint16)  0x0005);
enum SL_REVERBPRESET_PLATE  	 = (cast(SLuint16)  0x0006);


extern const(SLInterfaceID) SL_IID_PRESETREVERB;

alias SLPresetReverbItf = const(SLPrefetchStatusItf_*)*;

struct SLPresetReverbItf_ {
	SLresult function (
		SLPresetReverbItf self,
		SLuint16 preset
	) SetPreset;
	SLresult function (
		SLPresetReverbItf self,
		SLuint16 *pPreset
	) GetPreset;
}


/*---------------------------------------------------------------------------*/
/* EnvironmentalReverb                                                       */
/*---------------------------------------------------------------------------*/

enum SL_I3DL2_ENVIRONMENT_PRESET_DEFAULT =
	SLEnvironmentalReverbSettings(SL_MILLIBEL_MIN,    0,  1000,   500, SL_MILLIBEL_MIN,  20, SL_MILLIBEL_MIN,  40, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_GENERIC =
	SLEnvironmentalReverbSettings(-1000, -100, 1490,  830, -2602,   7,   200,  11, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_PADDEDCELL =
	SLEnvironmentalReverbSettings(-1000,-6000,  170,  100, -1204,   1,   207,   2, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_ROOM =
	SLEnvironmentalReverbSettings(-1000, -454,  400,  830, -1646,   2,    53,   3, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_BATHROOM =
	SLEnvironmentalReverbSettings(-1000,-1200, 1490,  540,  -370,   7,  1030,  11, 1000, 600 );
enum SL_I3DL2_ENVIRONMENT_PRESET_LIVINGROOM =
	SLEnvironmentalReverbSettings(-1000,-6000,  500,  100, -1376,   3, -1104,   4, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_STONEROOM =
	SLEnvironmentalReverbSettings(-1000, -300, 2310,  640,  -711,  12,    83,  17, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_AUDITORIUM =
	SLEnvironmentalReverbSettings(-1000, -476, 4320,  590,  -789,  20,  -289,  30, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_CONCERTHALL =
	SLEnvironmentalReverbSettings(-1000, -500, 3920,  700, -1230,  20,    -2,  29, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_CAVE =
	SLEnvironmentalReverbSettings(-1000,    0, 2910, 1300,  -602,  15,  -302,  22, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_ARENA =
	SLEnvironmentalReverbSettings(-1000, -698, 7240,  330, -1166,  20,    16,  30, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_HANGAR =
	SLEnvironmentalReverbSettings(-1000,-1000, 10050,  230,  -602,  20,   198,  30, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_CARPETEDHALLWAY =
	SLEnvironmentalReverbSettings(-1000,-4000,  300,  100, -1831,   2, -1630,  30, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_HALLWAY =
	SLEnvironmentalReverbSettings(-1000, -300, 1490,  590, -1219,   7,   441,  11, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_STONECORRIDOR =
	SLEnvironmentalReverbSettings(-1000, -237, 2700,  790, -1214,  13,   395,  20, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_ALLEY =
	SLEnvironmentalReverbSettings(-1000, -270, 1490,  860, -1204,   7,    -4,  11, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_FOREST =
	SLEnvironmentalReverbSettings(-1000,-3300, 1490,  540, -2560, 162,  -613,  88,  790,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_CITY =
	SLEnvironmentalReverbSettings(-1000, -800, 1490,  670, -2273,   7, -2217,  11,  500,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_MOUNTAINS =
	SLEnvironmentalReverbSettings(-1000,-2500, 1490,  210, -2780, 300, -2014, 100,  270,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_QUARRY =
	SLEnvironmentalReverbSettings(-1000,-1000, 1490,  830, SL_MILLIBEL_MIN,  61,   500,  25, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_PLAIN =
	SLEnvironmentalReverbSettings(-1000,-2000, 1490,  500, -2466, 179, -2514, 100,  210,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_PARKINGLOT =
	SLEnvironmentalReverbSettings(-1000,    0, 1650, 1500, -1363,   8, -1153,  12, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_SEWERPIPE =
	SLEnvironmentalReverbSettings(-1000,-1000, 2810,  140,   429,  14,   648,  21,  800, 600 );
enum SL_I3DL2_ENVIRONMENT_PRESET_UNDERWATER =
	SLEnvironmentalReverbSettings(-1000,-4000, 1490,  100,  -449,   7,  1700,  11, 1000,1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_SMALLROOM =
	SLEnvironmentalReverbSettings(-1000,-600, 1100, 830, -400, 5, 500, 10, 1000, 1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_MEDIUMROOM =
	SLEnvironmentalReverbSettings(-1000,-600, 1300, 830, -1000, 20, -200, 20, 1000, 1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_LARGEROOM =
	SLEnvironmentalReverbSettings(-1000,-600, 1500, 830, -1600, 5, -1000, 40, 1000, 1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_MEDIUMHALL =
	SLEnvironmentalReverbSettings(-1000,-600, 1800, 700, -1300, 15, -800, 30, 1000, 1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_LARGEHALL =
	SLEnvironmentalReverbSettings(-1000,-600, 1800, 700, -2000, 30, -1400, 60, 1000, 1000 );
enum SL_I3DL2_ENVIRONMENT_PRESET_PLATE =
	SLEnvironmentalReverbSettings(-1000,-200, 1300, 900, 0, 2, 0, 10, 1000, 750 );


struct SLEnvironmentalReverbSettings_ {
	SLmillibel    roomLevel;
	SLmillibel    roomHFLevel;
	SLmillisecond decayTime;
	SLpermille    decayHFRatio;
	SLmillibel    reflectionsLevel;
	SLmillisecond reflectionsDelay;
	SLmillibel    reverbLevel;
	SLmillisecond reverbDelay;
	SLpermille    diffusion;
	SLpermille    density;
}
alias SLEnvironmentalReverbSettings = SLEnvironmentalReverbSettings_;


extern const(SLInterfaceID) SL_IID_ENVIRONMENTALREVERB;



alias SLEnvironmentalReverbItf = const(SLEnvironmentalReverbItf_*)*;

struct SLEnvironmentalReverbItf_ {
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel room
	) SetRoomLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel *pRoom
	) GetRoomLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel roomHF
	) SetRoomHFLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel *pRoomHF
	) GetRoomHFLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillisecond decayTime
	) SetDecayTime;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillisecond *pDecayTime
	) GetDecayTime;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLpermille decayHFRatio
	) SetDecayHFRatio;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLpermille *pDecayHFRatio
	) GetDecayHFRatio;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel reflectionsLevel
	) SetReflectionsLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel *pReflectionsLevel
	) GetReflectionsLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillisecond reflectionsDelay
	) SetReflectionsDelay;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillisecond *pReflectionsDelay
	) GetReflectionsDelay;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel reverbLevel
	) SetReverbLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillibel *pReverbLevel
	) GetReverbLevel;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillisecond reverbDelay
	) SetReverbDelay;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLmillisecond *pReverbDelay
	) GetReverbDelay;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLpermille diffusion
	) SetDiffusion;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLpermille *pDiffusion
	) GetDiffusion;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLpermille density
	) SetDensity;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLpermille *pDensity
	) GetDensity;
	SLresult function (
		SLEnvironmentalReverbItf self,
		const SLEnvironmentalReverbSettings *pProperties
	) SetEnvironmentalReverbProperties;
	SLresult function (
		SLEnvironmentalReverbItf self,
		SLEnvironmentalReverbSettings *pProperties
	) GetEnvironmentalReverbProperties;
};

/*---------------------------------------------------------------------------*/
/* Effects Send Interface                                                    */
/*---------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_EFFECTSEND;


alias SLEffectSendItf = const(SLEffectSendItf_*)*;

struct SLEffectSendItf_ {
	SLresult function(
		SLEffectSendItf self,
		const void *pAuxEffect,
		SLboolean enable,
		SLmillibel initialLevel
	) EnableEffectSend;
	SLresult function (
		SLEffectSendItf self,
		const void * pAuxEffect,
		SLboolean *pEnable
	) IsEnabled;
	SLresult function (
		SLEffectSendItf self,
		SLmillibel directLevel
	) SetDirectLevel;
	SLresult function  (
		SLEffectSendItf self,
		SLmillibel *pDirectLevel
	) GetDirectLevel;
	SLresult function (
		SLEffectSendItf self,
		const void *pAuxEffect,
		SLmillibel sendLevel
	) SetSendLevel;
	SLresult function (
		SLEffectSendItf self,
		const void *pAuxEffect,
		SLmillibel *pSendLevel
	) GetSendLevel;
};


/*---------------------------------------------------------------------------*/
/* 3D Grouping Interface                                                     */
/*---------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_3DGROUPING;


alias SL3DGroupingItf = const(SL3DGroupingItf_*)*;

struct SL3DGroupingItf_ {
	SLresult function (
		SL3DGroupingItf self,
		SLObjectItf group
	) Set3DGroup;
	SLresult function (
		SL3DGroupingItf self,
		SLObjectItf *pGroup
	) Get3DGroup;
};


/*---------------------------------------------------------------------------*/
/* 3D Commit Interface                                                       */
/*---------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_3DCOMMIT;


alias SL3DCommitItf = const(SL3DCommitItf_*)*;

struct SL3DCommitItf_ {
	SLresult function (
		SL3DCommitItf self
	) Commit;
	SLresult function (
		SL3DCommitItf self,
		SLboolean deferred
	) SetDeferred;
};


/*---------------------------------------------------------------------------*/
/* 3D Location Interface                                                     */
/*---------------------------------------------------------------------------*/

struct SLVec3D_ {
	SLint32	x;
	SLint32	y;
	SLint32	z;
}
alias SLVec3D = SLVec3D_;

extern const(SLInterfaceID) SL_IID_3DLOCATION;


alias SL3DLocationItf = const(SL3DLocationItf_*)*;

struct SL3DLocationItf_ {
	SLresult function (
		SL3DLocationItf self,
		const SLVec3D *pLocation
	) SetLocationCartesian;
	SLresult function (
		SL3DLocationItf self,
		SLmillidegree azimuth,
		SLmillidegree elevation,
		SLmillimeter distance
	) SetLocationSpherical;
	SLresult function (
		SL3DLocationItf self,
		const SLVec3D *pMovement
	) Move;
	SLresult function (
		SL3DLocationItf self,
		SLVec3D *pLocation
	) GetLocationCartesian;
	SLresult function (
		SL3DLocationItf self,
		const SLVec3D *pFront,
		const SLVec3D *pAbove
	) SetOrientationVectors;
	SLresult function (
		SL3DLocationItf self,
		SLmillidegree heading,
		SLmillidegree pitch,
		SLmillidegree roll
	) SetOrientationAngles;
	SLresult function (
		SL3DLocationItf self,
		SLmillidegree theta,
		const SLVec3D *pAxis
	) Rotate;
	SLresult function (
		SL3DLocationItf self,
		SLVec3D *pFront,
		SLVec3D *pUp
	) GetOrientationVectors;
};


/*---------------------------------------------------------------------------*/
/* 3D Doppler Interface                                                      */
/*---------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_3DDOPPLER;


alias SL3DDopplerItf = const(SL3DDopplerItf_*)*;

struct SL3DDopplerItf_ {
	SLresult function  (
		SL3DDopplerItf self,
		const SLVec3D *pVelocity
	) SetVelocityCartesian;
	SLresult function  (
		SL3DDopplerItf self,
		SLmillidegree azimuth,
		SLmillidegree elevation,
		SLmillimeter speed
	) SetVelocitySpherical;
	SLresult function  (
		SL3DDopplerItf self,
		SLVec3D *pVelocity
	) GetVelocityCartesian;
	SLresult function  (
		SL3DDopplerItf self,
		SLpermille dopplerFactor
	) SetDopplerFactor;
	SLresult function  (
		SL3DDopplerItf self,
		SLpermille *pDopplerFactor
	) GetDopplerFactor;
};

/*---------------------------------------------------------------------------*/
/* 3D Source Interface and associated defines                                */
/* --------------------------------------------------------------------------*/

enum SL_ROLLOFFMODEL_EXPONENTIAL 	 = (cast(SLuint32)  0x00000000);
enum SL_ROLLOFFMODEL_LINEAR 		 = (cast(SLuint32)  0x00000001);


extern const(SLInterfaceID) SL_IID_3DSOURCE;


alias SL3DSourceItf = const(SL3DSourceItf_*)*;

struct SL3DSourceItf_ {
	SLresult function (
		SL3DSourceItf self,
		SLboolean headRelative
	) SetHeadRelative;
	SLresult function (
		SL3DSourceItf self,
		SLboolean *pHeadRelative
	) GetHeadRelative;
	SLresult function (
		SL3DSourceItf self,
		SLmillimeter minDistance,
		SLmillimeter maxDistance
	) SetRolloffDistances;
	SLresult function (
		SL3DSourceItf self,
		SLmillimeter *pMinDistance,
		SLmillimeter *pMaxDistance
	) GetRolloffDistances;
	SLresult function (
		SL3DSourceItf self,
		SLboolean mute
	) SetRolloffMaxDistanceMute;
	SLresult function (
		SL3DSourceItf self,
		SLboolean *pMute
	) GetRolloffMaxDistanceMute;
	SLresult function (
		SL3DSourceItf self,
		SLpermille rolloffFactor
	) SetRolloffFactor;
	SLresult function (
		SL3DSourceItf self,
		SLpermille *pRolloffFactor
	) GetRolloffFactor;
	SLresult function (
		SL3DSourceItf self,
		SLpermille roomRolloffFactor
	) SetRoomRolloffFactor;
	SLresult function (
		SL3DSourceItf self,
		SLpermille *pRoomRolloffFactor
	) GetRoomRolloffFactor;
	SLresult function (
		SL3DSourceItf self,
		SLuint8 model
	) SetRolloffModel;
	SLresult function (
		SL3DSourceItf self,
		SLuint8 *pModel
	) GetRolloffModel;
	SLresult function (
		SL3DSourceItf self,
		SLmillidegree innerAngle,
		SLmillidegree outerAngle,
		SLmillibel outerLevel
	) SetCone;
	SLresult function (
		SL3DSourceItf self,
		SLmillidegree *pInnerAngle,
		SLmillidegree *pOuterAngle,
		SLmillibel *pOuterLevel
	) GetCone;
};

/*---------------------------------------------------------------------------*/
/* 3D Macroscopic Interface                                                  */
/* --------------------------------------------------------------------------*/

extern const(SLInterfaceID) SL_IID_3DMACROSCOPIC;


alias SL3DMacroscopicItf = const(SL3DMacroscopicItf_*)*;

struct SL3DMacroscopicItf_ {
	SLresult function (
		SL3DMacroscopicItf self,
		SLmillimeter width,
		SLmillimeter height,
		SLmillimeter depth
	) SetSize;
	SLresult function (
		SL3DMacroscopicItf self,
		SLmillimeter *pWidth,
		SLmillimeter *pHeight,
		SLmillimeter *pDepth
	) GetSize;
	SLresult function (
		SL3DMacroscopicItf self,
		SLmillidegree heading,
		SLmillidegree pitch,
		SLmillidegree roll
	) SetOrientationAngles;

	SLresult function (
		SL3DMacroscopicItf self,
		const SLVec3D *pFront,
		const SLVec3D *pAbove
	) SetOrientationVectors;
	SLresult function (
		SL3DMacroscopicItf self,
		SLmillidegree theta,
		const SLVec3D *pAxis
	) Rotate;
	SLresult function (
		SL3DMacroscopicItf self,
		SLVec3D *pFront,
		SLVec3D *pUp
	) GetOrientationVectors;
};

/*---------------------------------------------------------------------------*/
/* Mute Solo Interface                                                       */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_MUTESOLO;


alias SLMuteSoloItf = const(SLMuteSoloItf_*)*;

struct SLMuteSoloItf_ {
	SLresult function (
		SLMuteSoloItf self,
		SLuint8 chan,
		SLboolean mute
	) SetChannelMute;
	SLresult function (
		SLMuteSoloItf self,
		SLuint8 chan,
		SLboolean *pMute
	) GetChannelMute;
	SLresult function (
		SLMuteSoloItf self,
		SLuint8 chan,
		SLboolean solo
	) SetChannelSolo;
	SLresult function (
		SLMuteSoloItf self,
		SLuint8 chan,
		SLboolean *pSolo
	) GetChannelSolo;
	SLresult function (
		SLMuteSoloItf self,
		SLuint8 *pNumChannels
	) GetNumChannels;
};


/*---------------------------------------------------------------------------*/
/* Dynamic Interface Management Interface and associated types and macros    */
/* --------------------------------------------------------------------------*/

enum SL_DYNAMIC_ITF_EVENT_RUNTIME_ERROR 			 = (cast(SLuint32)  0x00000001);
enum SL_DYNAMIC_ITF_EVENT_ASYNC_TERMINATION 		 = (cast(SLuint32)  0x00000002);
enum SL_DYNAMIC_ITF_EVENT_RESOURCES_LOST 			 = (cast(SLuint32)  0x00000003);
enum SL_DYNAMIC_ITF_EVENT_RESOURCES_LOST_PERMANENTLY 	 = (cast(SLuint32)  0x00000004);
enum SL_DYNAMIC_ITF_EVENT_RESOURCES_AVAILABLE 		 = (cast(SLuint32)  0x00000005);




extern const(SLInterfaceID) SL_IID_DYNAMICINTERFACEMANAGEMENT;


alias SLDynamicInterfaceManagementItf = const(SLDynamicInterfaceManagementItf_*)*;


alias slDynamicInterfaceManagementCallback = void function(
	SLDynamicInterfaceManagementItf caller,
	void * pContext,
	SLuint32 event,
	SLresult result,
	const SLInterfaceID iid
);


struct SLDynamicInterfaceManagementItf_ {
	SLresult function (
		SLDynamicInterfaceManagementItf self,
		const SLInterfaceID iid,
		SLboolean async
	) AddInterface;
	SLresult function (
		SLDynamicInterfaceManagementItf self,
		const SLInterfaceID iid
	) RemoveInterface;
	SLresult function (
		SLDynamicInterfaceManagementItf self,
		const SLInterfaceID iid,
		SLboolean async
	) ResumeInterface;
	SLresult function (
		SLDynamicInterfaceManagementItf self,
		slDynamicInterfaceManagementCallback callback,
		void * pContext
	) RegisterCallback;
};

/*---------------------------------------------------------------------------*/
/* Midi Message Interface and associated types                               */
/* --------------------------------------------------------------------------*/

enum SL_MIDIMESSAGETYPE_NOTE_ON_OFF 		 = (cast(SLuint32)  0x00000001);
enum SL_MIDIMESSAGETYPE_POLY_PRESSURE 	 = (cast(SLuint32)  0x00000002);
enum SL_MIDIMESSAGETYPE_CONTROL_CHANGE 	 = (cast(SLuint32)  0x00000003);
enum SL_MIDIMESSAGETYPE_PROGRAM_CHANGE 	 = (cast(SLuint32)  0x00000004);
enum SL_MIDIMESSAGETYPE_CHANNEL_PRESSURE 	 = (cast(SLuint32)  0x00000005);
enum SL_MIDIMESSAGETYPE_PITCH_BEND 		 = (cast(SLuint32)  0x00000006);
enum SL_MIDIMESSAGETYPE_SYSTEM_MESSAGE 	 = (cast(SLuint32)  0x00000007);


extern const(SLInterfaceID) SL_IID_MIDIMESSAGE;


alias SLMIDIMessageItf = const(SLMIDIMessageItf_*)*;


alias slMetaEventCallback = void function (
	SLMIDIMessageItf caller,
	void *pContext,
	SLuint8 type,
    SLuint32 length,
	const SLuint8 *pData,
	SLuint32 tick,
	SLuint16 track
);


alias slMIDIMessageCallback = void function (
	SLMIDIMessageItf caller,
	void *pContext,
	SLuint8 statusByte,
	SLuint32 length,
	const SLuint8 *pData,
	SLuint32 tick,
	SLuint16 track
);

struct SLMIDIMessageItf_ {
	SLresult function (
		SLMIDIMessageItf self,
		const SLuint8 *data,
		SLuint32 length
	) SendMessage;
	SLresult function (
		SLMIDIMessageItf self,
		slMetaEventCallback callback,
		void *pContext
	) RegisterMetaEventCallback;
	SLresult function (
		SLMIDIMessageItf self,
		slMIDIMessageCallback callback,
		void *pContext
	) RegisterMIDIMessageCallback;
	
	SLresult function (
		SLMIDIMessageItf self,
		SLuint32 messageType
	) AddMIDIMessageCallbackFilter;
	SLresult function (
		SLMIDIMessageItf self
	) ClearMIDIMessageCallbackFilter;
};


/*---------------------------------------------------------------------------*/
/* Midi Mute Solo interface                                                  */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_MIDIMUTESOLO;


alias SLMIDIMuteSoloItf = const(SLMIDIMuteSoloItf_*)*;

struct SLMIDIMuteSoloItf_ {
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint8 channel,
		SLboolean mute
	) SetChannelMute;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint8 channel,
		SLboolean *pMute
	) GetChannelMute;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint8 channel,
		SLboolean solo
	) SetChannelSolo;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint8 channel,
		SLboolean *pSolo
	) GetChannelSolo;

	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint16 *pCount
	) GetTrackCount;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint16 track,
		SLboolean mute
	) SetTrackMute;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint16 track,
		SLboolean *pMute
	) GetTrackMute;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint16 track,
		SLboolean solo
	) SetTrackSolo;
	SLresult function (
		SLMIDIMuteSoloItf self,
		SLuint16 track,
		SLboolean *pSolo
	) GetTrackSolo;
};


/*---------------------------------------------------------------------------*/
/* Midi Tempo interface                                                      */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_MIDITEMPO;


alias SLMIDITempoItf = const(SLMIDITempoItf_*)*;

struct SLMIDITempoItf_ {
	SLresult function (
		SLMIDITempoItf self,
		SLuint32 tpqn
	) SetTicksPerQuarterNote;
	SLresult function (
		SLMIDITempoItf self,
		SLuint32 *pTpqn
	) GetTicksPerQuarterNote;
	SLresult function (
		SLMIDITempoItf self,
		SLmicrosecond uspqn
	) SetMicrosecondsPerQuarterNote;
	SLresult function (
		SLMIDITempoItf self,
		SLmicrosecond *uspqn
	) GetMicrosecondsPerQuarterNote;
};


/*---------------------------------------------------------------------------*/
/* Midi Time interface                                                       */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_MIDITIME;


alias SLMIDITimeItf = const(SLMIDITimeItf_*)*;

struct SLMIDITimeItf_ {
	SLresult function (
		SLMIDITimeItf self,
		SLuint32 *pDuration
	) GetDuration;
	SLresult function (
		SLMIDITimeItf self,
		SLuint32 position
	) SetPosition;
	SLresult function (
		SLMIDITimeItf self,
		SLuint32 *pPosition
	) GetPosition;
	SLresult function (
		SLMIDITimeItf self,
		SLuint32 startTick,
		SLuint32 numTicks
	) SetLoopPoints;
	SLresult function (
		SLMIDITimeItf self,
		SLuint32 *pStartTick,
		SLuint32 *pNumTicks
	) GetLoopPoints;
};


/*---------------------------------------------------------------------------*/
/* Audio Decoder Capabilities Interface                                      */
/* --------------------------------------------------------------------------*/

/*Audio Codec related defines*/

enum SL_RATECONTROLMODE_CONSTANTBITRATE 	 = (cast(SLuint32)  0x00000001);
enum SL_RATECONTROLMODE_VARIABLEBITRATE 	 = (cast(SLuint32)  0x00000002);

enum SL_AUDIOCODEC_PCM           = (cast(SLuint32)  0x00000001);
enum SL_AUDIOCODEC_MP3           = (cast(SLuint32)  0x00000002);
enum SL_AUDIOCODEC_AMR           = (cast(SLuint32)  0x00000003);
enum SL_AUDIOCODEC_AMRWB         = (cast(SLuint32)  0x00000004);
enum SL_AUDIOCODEC_AMRWBPLUS     = (cast(SLuint32)  0x00000005);
enum SL_AUDIOCODEC_AAC           = (cast(SLuint32)  0x00000006);
enum SL_AUDIOCODEC_WMA           = (cast(SLuint32)  0x00000007);
enum SL_AUDIOCODEC_REAL          = (cast(SLuint32)  0x00000008);

enum SL_AUDIOPROFILE_PCM                     = (cast(SLuint32)  0x00000001);

enum SL_AUDIOPROFILE_MPEG1_L3                = (cast(SLuint32)  0x00000001);
enum SL_AUDIOPROFILE_MPEG2_L3                = (cast(SLuint32)  0x00000002);
enum SL_AUDIOPROFILE_MPEG25_L3               = (cast(SLuint32)  0x00000003);

enum SL_AUDIOCHANMODE_MP3_MONO               = (cast(SLuint32)  0x00000001);
enum SL_AUDIOCHANMODE_MP3_STEREO             = (cast(SLuint32)  0x00000002);
enum SL_AUDIOCHANMODE_MP3_JOINTSTEREO        = (cast(SLuint32)  0x00000003);
enum SL_AUDIOCHANMODE_MP3_DUAL               = (cast(SLuint32)  0x00000004);

enum SL_AUDIOPROFILE_AMR 			 = (cast(SLuint32)  0x00000001);

enum SL_AUDIOSTREAMFORMAT_CONFORMANCE 	 = (cast(SLuint32)  0x00000001);
enum SL_AUDIOSTREAMFORMAT_IF1 			 = (cast(SLuint32)  0x00000002);
enum SL_AUDIOSTREAMFORMAT_IF2 			 = (cast(SLuint32)  0x00000003);
enum SL_AUDIOSTREAMFORMAT_FSF 			 = (cast(SLuint32)  0x00000004);
enum SL_AUDIOSTREAMFORMAT_RTPPAYLOAD 	 = (cast(SLuint32)  0x00000005);
enum SL_AUDIOSTREAMFORMAT_ITU 			 = (cast(SLuint32)  0x00000006);

enum SL_AUDIOPROFILE_AMRWB 			 = (cast(SLuint32)  0x00000001);

enum SL_AUDIOPROFILE_AMRWBPLUS 		 = (cast(SLuint32)  0x00000001);

enum SL_AUDIOPROFILE_AAC_AAC 			 = (cast(SLuint32)  0x00000001);

enum SL_AUDIOMODE_AAC_MAIN 			 = (cast(SLuint32)  0x00000001);
enum SL_AUDIOMODE_AAC_LC 			 = (cast(SLuint32)  0x00000002);
enum SL_AUDIOMODE_AAC_SSR 			 = (cast(SLuint32)  0x00000003);
enum SL_AUDIOMODE_AAC_LTP 			 = (cast(SLuint32)  0x00000004);
enum SL_AUDIOMODE_AAC_HE 			 = (cast(SLuint32)  0x00000005);
enum SL_AUDIOMODE_AAC_SCALABLE 		 = (cast(SLuint32)  0x00000006);
enum SL_AUDIOMODE_AAC_ERLC 			 = (cast(SLuint32)  0x00000007);
enum SL_AUDIOMODE_AAC_LD 			 = (cast(SLuint32)  0x00000008);
enum SL_AUDIOMODE_AAC_HE_PS 			 = (cast(SLuint32)  0x00000009);
enum SL_AUDIOMODE_AAC_HE_MPS 			 = (cast(SLuint32)  0x0000000A);

enum SL_AUDIOSTREAMFORMAT_MP2ADTS 		 = (cast(SLuint32)  0x00000001);
enum SL_AUDIOSTREAMFORMAT_MP4ADTS 		 = (cast(SLuint32)  0x00000002);
enum SL_AUDIOSTREAMFORMAT_MP4LOAS 		 = (cast(SLuint32)  0x00000003);
enum SL_AUDIOSTREAMFORMAT_MP4LATM 		 = (cast(SLuint32)  0x00000004);
enum SL_AUDIOSTREAMFORMAT_ADIF 		 = (cast(SLuint32)  0x00000005);
enum SL_AUDIOSTREAMFORMAT_MP4FF 		 = (cast(SLuint32)  0x00000006);
enum SL_AUDIOSTREAMFORMAT_RAW 			 = (cast(SLuint32)  0x00000007);

enum SL_AUDIOPROFILE_WMA7 		 = (cast(SLuint32)  0x00000001);
enum SL_AUDIOPROFILE_WMA8 		 = (cast(SLuint32)  0x00000002);
enum SL_AUDIOPROFILE_WMA9 		 = (cast(SLuint32)  0x00000003);
enum SL_AUDIOPROFILE_WMA10 		 = (cast(SLuint32)  0x00000004);

enum SL_AUDIOMODE_WMA_LEVEL1 		 = (cast(SLuint32)  0x00000001);
enum SL_AUDIOMODE_WMA_LEVEL2 		 = (cast(SLuint32)  0x00000002);
enum SL_AUDIOMODE_WMA_LEVEL3 		 = (cast(SLuint32)  0x00000003);
enum SL_AUDIOMODE_WMA_LEVEL4 		 = (cast(SLuint32)  0x00000004);
enum SL_AUDIOMODE_WMAPRO_LEVELM0 	 = (cast(SLuint32)  0x00000005);
enum SL_AUDIOMODE_WMAPRO_LEVELM1 	 = (cast(SLuint32)  0x00000006);
enum SL_AUDIOMODE_WMAPRO_LEVELM2 	 = (cast(SLuint32)  0x00000007);
enum SL_AUDIOMODE_WMAPRO_LEVELM3 	 = (cast(SLuint32)  0x00000008);

enum SL_AUDIOPROFILE_REALAUDIO 		 = (cast(SLuint32)  0x00000001);

enum SL_AUDIOMODE_REALAUDIO_G2 		 = (cast(SLuint32)  0x00000001);
enum SL_AUDIOMODE_REALAUDIO_8 			 = (cast(SLuint32)  0x00000002);
enum SL_AUDIOMODE_REALAUDIO_10 		 = (cast(SLuint32)  0x00000003);
enum SL_AUDIOMODE_REALAUDIO_SURROUND 	 = (cast(SLuint32)  0x00000004);

struct SLAudioCodecDescriptor_ {
    SLuint32      maxChannels;
    SLuint32      minBitsPerSample;
    SLuint32      maxBitsPerSample;
    SLmilliHertz  minSampleRate;
    SLmilliHertz  maxSampleRate;
    SLboolean     isFreqRangeContinuous;
    SLmilliHertz *pSampleRatesSupported;
    SLuint32      numSampleRatesSupported;
    SLuint32      minBitRate;
    SLuint32      maxBitRate;
    SLboolean     isBitrateRangeContinuous;
    SLuint32     *pBitratesSupported;
    SLuint32      numBitratesSupported;
    SLuint32	  profileSetting;
    SLuint32      modeSetting;
}
alias SLAudioCodecDescriptor = SLAudioCodecDescriptor_;

/*Structure used to retrieve the profile and level settings supported by an audio encoder */

struct SLAudioCodecProfileMode_ {
    SLuint32 profileSetting;
    SLuint32 modeSetting;
}
alias SLAudioCodecProfileMode = SLAudioCodecProfileMode_;

extern const(SLInterfaceID) SL_IID_AUDIODECODERCAPABILITIES;


alias SLAudioDecoderCapabilitiesItf = const(SLAudioDecoderCapabilitiesItf_*)*;

struct SLAudioDecoderCapabilitiesItf_ {
    SLresult function (
        SLAudioDecoderCapabilitiesItf self,
        SLuint32 * pNumDecoders ,
        SLuint32 *pDecoderIds
    ) GetAudioDecoders;
    SLresult function (
        SLAudioDecoderCapabilitiesItf self,
        SLuint32 decoderId,
        SLuint32 *pIndex,
        SLAudioCodecDescriptor *pDescriptor
    ) GetAudioDecoderCapabilities;
};




/*---------------------------------------------------------------------------*/
/* Audio Encoder Capabilities Interface                                      */
/* --------------------------------------------------------------------------*/

/* Structure used when setting audio encoding parameters */

struct SLAudioEncoderSettings_ {
    SLuint32 encoderId;
    SLuint32 channelsIn;
    SLuint32 channelsOut;
    SLmilliHertz sampleRate;
    SLuint32 bitRate;
    SLuint32 bitsPerSample;
    SLuint32 rateControl;
    SLuint32 profileSetting;
    SLuint32 levelSetting;
    SLuint32 channelMode;
    SLuint32 streamFormat;
    SLuint32 encodeOptions;
    SLuint32 blockAlignment;
}
alias SLAudioEncoderSettings = SLAudioEncoderSettings_;

extern const(SLInterfaceID) SL_IID_AUDIOENCODERCAPABILITIES;


alias SLAudioEncoderCapabilitiesItf = const(SLAudioEncoderCapabilitiesItf_*)*;

struct SLAudioEncoderCapabilitiesItf_ {
    SLresult function (
        SLAudioEncoderCapabilitiesItf self,
        SLuint32 *pNumEncoders ,
        SLuint32 *pEncoderIds
    ) GetAudioEncoders ;
    SLresult function (
        SLAudioEncoderCapabilitiesItf self,
        SLuint32 encoderId,
        SLuint32 *pIndex,
        SLAudioCodecDescriptor * pDescriptor
    ) GetAudioEncoderCapabilities;
};


/*---------------------------------------------------------------------------*/
/* Audio Encoder Interface                                                   */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_AUDIOENCODER;


alias SLAudioEncoderItf = const(SLAudioEncoderItf_*)*;

struct SLAudioEncoderItf_ {
    SLresult function (
        SLAudioEncoderItf		self,
        SLAudioEncoderSettings 	*pSettings
    ) SetEncoderSettings;
    SLresult function (
        SLAudioEncoderItf		self,
        SLAudioEncoderSettings	*pSettings
    ) GetEncoderSettings;
};


/*---------------------------------------------------------------------------*/
/* Bass Boost Interface                                                      */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_BASSBOOST;


alias SLBassBoostItf = const(SLBassBoostItf_*)*;

struct SLBassBoostItf_ {
	SLresult function (
		SLBassBoostItf self,
		SLboolean enabled
	) SetEnabled;
	SLresult function (
		SLBassBoostItf self,
		SLboolean *pEnabled
	) IsEnabled;
	SLresult function (
		SLBassBoostItf self,
		SLpermille strength
	) SetStrength;
	SLresult function (
		SLBassBoostItf self,
		SLpermille *pStrength
	) GetRoundedStrength;
	SLresult function (
		SLBassBoostItf self,
		SLboolean *pSupported
	) IsStrengthSupported;
}

/*---------------------------------------------------------------------------*/
/* Pitch Interface                                                           */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_PITCH;


alias SLPitchItf = const(SLPitchItf_*)*;

struct SLPitchItf_ {
	SLresult function (
		SLPitchItf self,
		SLpermille pitch
	) SetPitch;
	SLresult function (
		SLPitchItf self,
		SLpermille *pPitch
	) GetPitch;
	SLresult function (
		SLPitchItf self,
		SLpermille *pMinPitch,
		SLpermille *pMaxPitch
	) GetPitchCapabilities;
};


/*---------------------------------------------------------------------------*/
/* Rate Pitch Interface                                                      */
/* RatePitchItf is an interface for controlling the rate a sound is played   */
/* back. A change in rate will cause a change in pitch.                      */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_RATEPITCH;


alias SLRatePitchItf = const(SLRatePitchItf_*)*;

struct SLRatePitchItf_ {
	SLresult function (
		SLRatePitchItf self,
		SLpermille rate
	) SetRate;
	SLresult function (
		SLRatePitchItf self,
		SLpermille *pRate
	) GetRate;
	SLresult function (
		SLRatePitchItf self,
		SLpermille *pMinRate,
		SLpermille *pMaxRate
	) GetRatePitchCapabilities;
};


/*---------------------------------------------------------------------------*/
/* Virtualizer Interface                                                      */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_VIRTUALIZER;


alias SLVirtualizerItf = const(SLVirtualizerItf_*)*;

struct SLVirtualizerItf_ {
	SLresult function (
		SLVirtualizerItf self,
		SLboolean enabled
	) SetEnabled;
	SLresult function (
		SLVirtualizerItf self,
		SLboolean *pEnabled
	) IsEnabled;
	SLresult function (
		SLVirtualizerItf self,
		SLpermille strength
	) SetStrength;
	SLresult function (
		SLVirtualizerItf self,
		SLpermille *pStrength
	) GetRoundedStrength;
	SLresult function (
		SLVirtualizerItf self,
		SLboolean *pSupported
	) IsStrengthSupported;
};

/*---------------------------------------------------------------------------*/
/* Visualization Interface                                                   */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_VISUALIZATION;


alias SLVisualizationItf = const(SLVisualizationItf_*)*;


alias slVisualizationCallback = void function(
	void *pContext,
	const SLuint8* waveform,
	const SLuint8* fft,
	SLmilliHertz samplerate
);

struct SLVisualizationItf_{
	SLresult function (
		SLVisualizationItf self,
		slVisualizationCallback callback,
		void *pContext,
		SLmilliHertz rate
	) RegisterVisualizationCallback;
	SLresult function (
		SLVisualizationItf self,
		SLmilliHertz* pRate
	) GetMaxRate;
};


/*---------------------------------------------------------------------------*/
/* Engine Interface                                                          */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_ENGINE;


alias SLEngineItf = const(SLEngineItf_*)*;


struct SLEngineItf_ {

	SLresult function (
		SLEngineItf self,
		SLObjectItf * pDevice,
		SLuint32 deviceID,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateLEDDevice;

	SLresult function (
		SLEngineItf self,
		SLObjectItf * pDevice,
		SLuint32 deviceID,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateVibraDevice;
	SLresult function (
		SLEngineItf self,
		SLObjectItf * pPlayer,
		SLDataSource *pAudioSrc,
		SLDataSink *pAudioSnk,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateAudioPlayer;
	SLresult function (
		SLEngineItf self,
		SLObjectItf * pRecorder,
		SLDataSource *pAudioSrc,
		SLDataSink *pAudioSnk,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateAudioRecorder;
	SLresult function (
		SLEngineItf self,
		SLObjectItf * pPlayer,
		SLDataSource *pMIDISrc,
		SLDataSource *pBankSrc,
		SLDataSink *pAudioOutput,
		SLDataSink *pVibra,
		SLDataSink *pLEDArray,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateMidiPlayer;
	SLresult function (
		SLEngineItf self,
		SLObjectItf * pListener,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateListener;
	SLresult function (
		SLEngineItf self,
		SLObjectItf * pGroup,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) Create3DGroup;
	SLresult function(
		SLEngineItf self,
		SLObjectItf * pMix,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateOutputMix;

	SLresult function (
		SLEngineItf self,
		SLObjectItf * pMetadataExtractor,
		SLDataSource * pDataSource,
		SLuint32 numInterfaces,
		const SLInterfaceID * pInterfaceIds,
		const SLboolean * pInterfaceRequired
	) CreateMetadataExtractor;
    SLresult function (
        SLEngineItf self,
        SLObjectItf * pObject,
        void * pParameters,
        SLuint32 objectID,
        SLuint32 numInterfaces,
        const SLInterfaceID * pInterfaceIds,
        const SLboolean * pInterfaceRequired
    ) CreateExtensionObject;
	SLresult function (
		SLEngineItf self,
		SLuint32 objectID,
		SLuint32 * pNumSupportedInterfaces
	) QueryNumSupportedInterfaces;
	SLresult function (
		SLEngineItf self,
		SLuint32 objectID,
		SLuint32 index,
		SLInterfaceID * pInterfaceId
	) QuerySupportedInterfaces;
    SLresult function (
        SLEngineItf self,
        SLuint32 * pNumExtensions
    ) QueryNumSupportedExtensions;
    SLresult function (
        SLEngineItf self,
        SLuint32 index,
        SLchar * pExtensionName,
        SLint16 * pNameLength
    ) QuerySupportedExtension;
    SLresult function (
        SLEngineItf self,
        const SLchar * pExtensionName,
        SLboolean * pSupported
    ) IsExtensionSupported;
};


/*---------------------------------------------------------------------------*/
/* Engine Capabilities Interface                                             */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_ENGINECAPABILITIES;


alias SLEngineCapabilitiesItf = const(SLEngineCapabilitiesItf_*)*;

struct SLEngineCapabilitiesItf_ {

	SLresult function (
		SLEngineCapabilitiesItf self,
		SLuint16 *pProfilesSupported
	) QuerySupportedProfiles;
	SLresult function (
		SLEngineCapabilitiesItf self,
		SLuint16 voiceType,
		SLint16 *pNumMaxVoices,
		SLboolean *pIsAbsoluteMax,
		SLint16 *pNumFreeVoices
	) QueryAvailableVoices;
	SLresult function (
		SLEngineCapabilitiesItf self,
		SLint16 *pNumMIDIsynthesizers
	) QueryNumberOfMIDISynthesizers;
	SLresult function (
		SLEngineCapabilitiesItf self,
		SLint16 *pMajor,
		SLint16 *pMinor,
		SLint16 *pStep
	) QueryAPIVersion;
	SLresult function (
		SLEngineCapabilitiesItf self,
        SLuint32 *pIndex,
		SLuint32 *pLEDDeviceID,
		SLLEDDescriptor *pDescriptor
	) QueryLEDCapabilities;
	SLresult function (
		SLEngineCapabilitiesItf self,
        SLuint32 *pIndex,
		SLuint32 *pVibraDeviceID,
		SLVibraDescriptor *pDescriptor
	) QueryVibraCapabilities;
	SLresult function (
		SLEngineCapabilitiesItf self,
		SLboolean *pIsThreadSafe
	) IsThreadSafe;
};

/*---------------------------------------------------------------------------*/
/* Thread Sync Interface                                                     */
/* --------------------------------------------------------------------------*/


extern const(SLInterfaceID) SL_IID_THREADSYNC;


alias SLThreadSyncItf = const(SLThreadSyncItf_*)*;


struct SLThreadSyncItf_ {
	SLresult function (
		SLThreadSyncItf self
	) EnterCriticalSection;
	SLresult function (
		SLThreadSyncItf self
	) ExitCriticalSection;
};


/*****************************************************************************/
/* SL engine constructor                                                     */
/*****************************************************************************/

enum SL_ENGINEOPTION_THREADSAFE 	 = (cast(SLuint32)  0x00000001);
enum SL_ENGINEOPTION_LOSSOFCONTROL 	 = (cast(SLuint32)  0x00000002);

struct SLEngineOption_ {
	SLuint32 feature;
	SLuint32 data;
}
alias SLEngineOption = SLEngineOption_;



SLresult slCreateEngine(
	SLObjectItf             *pEngine,
	SLuint32                numOptions,
	const SLEngineOption    *pEngineOptions,
	SLuint32                numInterfaces,
	const SLInterfaceID     *pInterfaceIds,
	const SLboolean         * pInterfaceRequired
);// SL_API_DEPRECATED(30);

SLresult slQueryNumSupportedEngineInterfaces(
	SLuint32 * pNumSupportedInterfaces
); //SL_API_DEPRECATED(30);

SLresult slQuerySupportedEngineInterfaces(
	SLuint32 index,
	SLInterfaceID * pInterfaceId
);// SL_API_DEPRECATED(30);
