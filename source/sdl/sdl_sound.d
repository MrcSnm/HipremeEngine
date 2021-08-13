/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module sdl.sdl_sound;
import bindbc.loader;
import bindbc.sdl : SDL_RWops;
import bindbc.sdl.config : staticBinding;
public import bindbc.sdl.bind.sdlaudio : SDL_AudioFormat;

private
{
    SharedLib lib;
}

bool loadSDLSound()
{
     version(Windows) {
        const(char)[][1] libNames = ["SDL2_sound.dll"];
    }
    else version(OSX) {
        const(char)[][7] libNames = [
            "libSDL2_sound.dylib",
            "/usr/local/lib/libSDL2_sound.dylib",
            "/usr/local/lib/libSDL2_sound/libSDL2_sound.dylib",
            "../Frameworks/SDL2.framework/SDL2_sound",
            "/Library/Frameworks/SDL2.framework/SDL2_sound",
            "/System/Library/Frameworks/SDL2.framework/SDL2_sound",
            "/opt/local/lib/libSDL2_sound.dylib"
        ];
    }
    else version(Posix) {
        const(char)[][4] libNames = [
            "libSDL2_sound.so",
            "/usr/local/lib/libSDL2_sound.so",
            "libSDL2_sound.so.1.9.0",
            "/usr/local/lib/libSDL2_sound.so.1.9.0"
        ];
    }
    else static assert(0, "bindbc-sdl is not yet supported on this platform.");

    foreach(name; libNames) 
    {
        lib = load(name.ptr);
        if(lib != invalidHandle)
            return _load();
    }
    return false;
}

private bool _load()
{
    bool isOkay = true;
    const size_t errs = errorCount();
    bindSymbols();
    if(errs != errorCount())
        isOkay = false;
    return isOkay;
}


extern(C):

enum SOUND_VER_MAJOR = 1;
enum SOUND_VER_MINOR = 0;
enum SOUND_VER_PATCH = 1;

/**
*Information about an existing sample's format
*/
struct Sound_AudioInfo
{
    /**
    * Equivalent of SDL_AudioSpec.format
    */
    SDL_AudioFormat format;
    /**
    * Number of sound channels. 1 == mono, 2 == stereo
    */
    ubyte channels;
    /**
     *Sample rate; frequency of sample points per second
    */
    uint rate;
}
/**
*Information about available soudn decoders
*/
struct Sound_DecoderInfo
{
    /**
    * File extensions, list ends with NULL
    */
    const char** extensions;
    /**
    * Human readable description of decoder.
    */
    const char* description;
    /**
    * "Name Of Author <email@emailhost.dom>"
    */
    const char* author;
    /**
    * URL specific to this decoder
    */
    const char* url;
}

/**
*Represents sound data in the process of being decoded
*/
struct Sound_Sample
{
    /**
    * Internal use only. Don't touch
    */
    void* opaque;
    /**
    * Decoder used for this sample
    */
    const Sound_DecoderInfo* decoder;
    /**
    * Desired audio format for conversion.
    */
    Sound_AudioInfo desired;
    /**
    *   Actual audio format of sample.
    */
    Sound_AudioInfo actual;
    /**
    * Decoded sound data lands in here
    */
    void* buffer;
    /**
    * Current size of (buffer), in bytes (Uint8)
    */
    uint buffer_size;
    /**
    * Flags relating to this sample
    */
    Sound_SampleFlags flags;
}

/**
*Information the version of SDL_sound in use
*/
struct Sound_Version
{
    /**
    * Major revision
    */
    int major;
    /**
    * Minor revision
    */
    int minor;
    /**
    * Patchlevel
    */
    int patch;
}

static if(staticBinding)
{
    /**
* Get a list of sound formats supported by this version of SDL_sound.
* This is for informational purposes only. Note that the extension listed is merely convention: if we list "MP3", you can open an MPEG-1 Layer 3 audio file with an extension of "XYZ", if you like. The file extensions are informational, and only required as a hint to choosing the correct decoder, since the sound data may not be coming from a file at all, thanks to the abstraction that an SDL_RWops provides.
* The returned value is an array of pointers to Sound_DecoderInfo structures, with a NULL entry to signify the end of the list:
*/
const(Sound_DecoderInfo)** Sound_AvailableDecoders();
/**
* Clear the current error message.
* The next call to Sound_GetError() after Sound_ClearError() will return NULL.
*/
void Sound_ClearError();
/**
* Decode more of the sound data in a Sound_Sample.
* It will decode at most sample->buffer_size bytes into sample->buffer in the desired format, and return the number of decoded bytes. If sample->buffer_size bytes could not be decoded, then please refer to sample->flags to determine if this was an end-of-stream or error condition.
*/
uint Sound_Decode(Sound_Sample* sample);
/**
* Decode the remainder of the sound data in a Sound_Sample.
* This will dynamically allocate memory for the ENTIRE remaining sample. sample->buffer_size and sample->buffer will be updated to reflect the new buffer. Please refer to sample->flags to determine if the decoding finished due to an End-of-stream or error condition.
* Be aware that sound data can take a large amount of memory, and that this function may block for quite awhile while processing. Also note that a streaming source (for example, from a SDL_RWops that is getting fed from an Internet radio feed that doesn't end) may fill all available memory before giving up...be sure to use this on finite sound sources only!
* When decoding the sample in its entirety, the work is done one buffer at a time. That is, sound is decoded in sample->buffer_size blocks, and appended to a continually-growing buffer until the decoding completes. That means that this function will need enough RAM to hold approximately sample->buffer_size bytes plus the complete decoded sample at most. The larger your buffer size, the less overhead this function needs, but beware the possibility of paging to disk. Best to make this user-configurable if the sample isn't specific and small.
*/
uint Sound_DecodeAll(Sound_Sample* sample);
/**
* Dispose of a Sound_Sample.
* This will also close/dispose of the SDL_RWops that was used at creation time, so there's no need to keep a reference to that around. The Sound_Sample pointer is invalid after this call, and will almost certainly result in a crash if you attempt to keep using it.
*/
void Sound_FreeSample(Sound_Sample* sample);
/**
* Get the last SDL_sound error message as a null-terminated string.
* This will be NULL if there's been no error since the last call to this function. The pointer returned by this call points to an internal buffer, and should not be deallocated. Each thread has a unique error state associated with it, but each time a new error message is set, it will overwrite the previous one associated with that thread. It is safe to call this function at anytime, even before Sound_Init().
*/
const (char)* Sound_GetError();
/**
* Get the version of SDL_sound that is linked against your program.
* If you are using a shared library (DLL) version of SDL_sound, then it is possible that it will be different than the version you compiled against.
* This is a real function; the macro SOUND_VERSION tells you what version of SDL_sound you compiled against:
* This function may be called safely at any time, even before Sound_Init().
*/
void Sound_GetLinkedVersion(Sound_Version* ver);
/**
* Initialize SDL_sound.
* This must be called before any other SDL_sound function (except perhaps Sound_GetLinkedVersion()). You should call SDL_Init() before calling this. Sound_Init() will attempt to call SDL_Init(SDL_INIT_AUDIO), just in case. This is a safe behaviour, but it may not configure SDL to your liking by itself.
*/
int Sound_Init();
/**
* Start decoding a new sound sample.
* The data is read via an SDL_RWops structure (see SDL_rwops.h in the SDL include directory), so it may be coming from memory, disk, network stream, etc. The (ext) parameter is merely a hint to determining the correct decoder; if you specify, for example, "mp3" for an extension, and one of the decoders lists that as a handled extension, then that decoder is given first shot at trying to claim the data for decoding. If none of the extensions match (or the extension is NULL), then every decoder examines the data to determine if it can handle it, until one accepts it. In such a case your SDL_RWops will need to be capable of rewinding to the start of the stream.
* If no decoders can handle the data, a NULL value is returned, and a human readable error message can be fetched from Sound_GetError().
* Optionally, a desired audio format can be specified. If the incoming data is in a different format, SDL_sound will convert it to the desired format on the fly. Note that this can be an expensive operation, so it may be wise to convert data before you need to play it back, if possible, or make sure your data is initially in the format that you need it in. If you don't want to convert the data, you can specify NULL for a desired format. The incoming format of the data, preconversion, can be found in the Sound_Sample structure.
* Note that the raw sound data "decoder" needs you to specify both the extension "RAW" and a "desired" format, or it will refuse to handle the data. This is to prevent it from catching all formats unsupported by the other decoders.
* Finally, specify an initial buffer size; this is the number of bytes that will be allocated to store each read from the sound buffer. The more you can safely allocate, the more decoding can be done in one block, but the more resources you have to use up, and the longer each decoding call will take. Note that different data formats require more or less space to store. This buffer can be resized via Sound_SetBufferSize() ...
* The buffer size specified must be a multiple of the size of a single sample point. So, if you want 16-bit, stereo samples, then your sample point size is (2 channels * 16 bits), or 32 bits per sample, which is four bytes. In such a case, you could specify 128 or 132 bytes for a buffer, but not 129, 130, or 131 (although in reality, you'll want to specify a MUCH larger buffer).
* When you are done with this Sound_Sample pointer, you can dispose of it via Sound_FreeSample().
* You do not have to keep a reference to (rw) around. If this function suceeds, it stores (rw) internally (and disposes of it during the call to Sound_FreeSample()). If this function fails, it will dispose of the SDL_RWops for you.
* 
* Parameters:
*     rw 	SDL_RWops with sound data.
*     ext 	File extension normally associated with a data format. Can usually be NULL.
*     desired 	Format to convert sound data into. Can usually be NULL, if you don't need conversion.
*     bufferSize 	Size, in bytes, to allocate for the decoding buffer.
* Returns:
*     Sound_Sample pointer, which is used as a handle to several other SDL_sound APIs. NULL on error. If error, use Sound_GetError() to see what went wrong.
*/
Sound_Sample* Sound_NewSample(SDL_RWops* rw, const char* ext, Sound_AudioInfo* desired, uint bufferSize);
/**
* Start decoding a new sound sample from a file on disk.
* This is identical to Sound_NewSample(), but it creates an SDL_RWops for you from the file located in (filename). Note that (filename) is specified in platform-dependent notation. ("C:\\music\\mysong.mp3" on windows, and "/home/icculus/music/mysong.mp3" or whatever on Unix, etc.) Sound_NewSample()'s "ext" parameter is gleaned from the contents of (filename).
* Parameters:
*     filename 	file containing sound data.
*     desired 	Format to convert sound data into. Can usually be NULL, if you don't need conversion.
*     bufferSize 	size, in bytes, of initial read buffer.
* Returns:
*     Sound_Sample pointer, which is used as a handle to several other SDL_sound APIs. NULL on error. If error, use Sound_GetError() to see what went wrong.
*/
Sound_Sample* Sound_NewSampleFromFile(const char* filename, Sound_AudioInfo* desired, uint bufferSize);
/**
* Shutdown SDL_sound.
* This closes any SDL_RWops that were being used as sound sources, and frees any resources in use by SDL_sound.
* All Sound_Sample pointers you had prior to this call are INVALIDATED.
* Once successfully deinitialized, Sound_Init() can be called again to restart the subsystem. All default API states are restored at this point.
* You should call this BEFORE SDL_Quit(). This will NOT call SDL_Quit() for you!
* Returns:
*     nonzero on success, zero on error. Specifics of the error can be gleaned from Sound_GetError(). If failure, state of SDL_sound is undefined, and probably badly screwed up
*/
int Sound_Quit();
/**
* Rewind a sample to the start.
* Restart a sample at the start of its waveform data, as if newly created with Sound_NewSample(). If successful, the next call to Sound_Decode[All]() will give audio data from the earliest point in the stream.
* Beware that this function will fail if the SDL_RWops that feeds the decoder can not be rewound via it's seek method, but this can theoretically be avoided by wrapping it in some sort of buffering SDL_RWops.
* This function should ONLY fail if the RWops is not seekable, or SDL_sound is not initialized. Both can be controlled by the application, and thus, it is up to the developer's paranoia to dictate whether this function's return value need be checked at all.
* If this function fails, the state of the sample is undefined, but it is still safe to call Sound_FreeSample() to dispose of it.
* On success, ERROR, EOF, and EAGAIN are cleared from sample->flags. The ERROR flag is set on error.
* Parameters:
*     sample 	The Sound_Sample to rewind.
* Returns:
*     nonzero on success, zero on error. Specifics of the error can be gleaned from Sound_GetError().
*/
int Sound_Rewind(Sound_Sample* sample);
/**
* Seek to a different point in a sample.
* Reposition a sample's stream. If successful, the next call to Sound_Decode[All]() will give audio data from the offset you specified.
* The offset is specified in milliseconds from the start of the sample.
* Beware that this function can fail for several reasons. If the SDL_RWops that feeds the decoder can not seek, this call will almost certainly fail, but this can theoretically be avoided by wrapping it in some sort of buffering SDL_RWops. Some decoders can never seek, others can only seek with certain files. The decoders will set a flag in the sample at creation time to help you determine this.
* You should check sample->flags & SOUND_SAMPLEFLAG_CANSEEK before attempting. Sound_Seek() reports failure immediately if this flag isn't set. This function can still fail for other reasons if the flag is set.
* This function can be emulated in the application with Sound_Rewind() and predecoding a specific amount of the sample, but this can be extremely inefficient. Sound_Seek() accelerates the seek on a with decoder-specific code.
* If this function fails, the sample should continue to function as if this call was never made. If there was an unrecoverable error, sample->flags & SOUND_SAMPLEFLAG_ERROR will be set, which you regular decoding loop can pick up.
* On success, ERROR, EOF, and EAGAIN are cleared from sample->flags.
* Parameters:
*     sample 	The Sound_Sample to seek.
*     ms 	The new position, in milliseconds from start of sample.
* Returns:
*     nonzero on success, zero on error. Specifics of the error can be gleaned from Sound_GetError().
*/
int Sound_Seek(Sound_Sample* sample, uint ms);
/**
* Change the current buffer size for a sample.
* If the buffer size could be changed, then the sample->buffer and sample->buffer_size fields will reflect that. If they could not be changed, then your original sample state is preserved. If the buffer is shrinking, the data at the end of buffer is truncated. If the buffer is growing, the contents of the new space at the end is undefined until you decode more into it or initialize it yourself.
* The buffer size specified must be a multiple of the size of a single sample point. So, if you want 16-bit, stereo samples, then your sample point size is (2 channels * 16 bits), or 32 bits per sample, which is four bytes. In such a case, you could specify 128 or 132 bytes for a buffer, but not 129, 130, or 131 (although in reality, you'll want to specify a MUCH larger buffer).
* Parameters:
*     sample 	The Sound_Sample whose buffer to modify.
*     new_size 	The desired size, in bytes, of the new buffer.
* Returns:
*     non-zero if buffer size changed, zero on failure.
*/
int Sound_SetBufferSize(Sound_Sample* sample, uint newSize);
}
else
{
    alias pSound_AvailableDecoders = const(Sound_DecoderInfo)**function();
    alias pSound_ClearError = void function();
    alias pSound_Decode = uint function(Sound_Sample*);
    alias pSound_DecodeAll = uint function(Sound_Sample*);
    alias pSound_FreeSample = void function(Sound_Sample*);
    alias pSound_GetError =  const(char)* function();
    alias pSound_GetLinkedVersion = void function(Sound_Version*);
    alias pSound_Init = int function();
    alias pSound_NewSample = Sound_Sample* function(SDL_RWops*, const (char)*, Sound_AudioInfo*, uint);
    alias pSound_NewSampleFromFile = Sound_Sample* function(const(char)*, Sound_AudioInfo*, uint);
    alias pSound_Quit = int function();
    alias pSound_Rewind = int function (Sound_Sample*);
    alias pSound_Seek = int function(Sound_Sample*, uint);
    alias pSound_SetBufferSize = int function(Sound_Sample*, uint);

    __gshared
    {
        pSound_AvailableDecoders Sound_AvailableDecoders;
        pSound_ClearError Sound_ClearError;
        pSound_Decode Sound_Decode;
        pSound_DecodeAll Sound_DecodeAll;
        pSound_FreeSample Sound_FreeSample;
        pSound_GetError Sound_GetError;
        pSound_GetLinkedVersion Sound_GetLinkedVersion;
        pSound_Init Sound_Init;
        pSound_NewSample Sound_NewSample;
        pSound_NewSampleFromFile Sound_NewSampleFromFile;
        pSound_Quit Sound_Quit;
        pSound_Rewind Sound_Rewind;
        pSound_Seek Sound_Seek;
        pSound_SetBufferSize Sound_SetBufferSize;
    }
}

enum Sound_SampleFlags
{
    /**
    * No special attributes.
    */
    SOUND_SAMPLEFLAG_NONE = 0,
    /**
    * Sample can seek to arbitrary points.
    */
    SOUND_SAMPLEFLAG_CANSEEK = 1,
    /**
    * End of input stream.
    */
    SOUND_SAMPLEFLAG_EOF = 1 << 29,
    /**
    * Unrecoverable error.
    */
    SOUND_SAMPLEFLAG_ERROR = 1 << 30,
    /**
    * Function would block, or temp error.
    */
    SOUND_SAMPLEFLAG_EAGAIN = 1 << 31
}

void SOUND_VERSION(ref Sound_Version* vers)
{
    vers.major = SOUND_VER_MAJOR;
    vers.minor = SOUND_VER_MINOR;
    vers.patch = SOUND_VER_PATCH;
}

private void bindSymbols()
{
    lib.bindSymbol(cast(void**)&Sound_AvailableDecoders, "Sound_AvailableDecoders");
    lib.bindSymbol(cast(void**)&Sound_ClearError, "Sound_ClearError");
    lib.bindSymbol(cast(void**)&Sound_Decode, "Sound_Decode");
    lib.bindSymbol(cast(void**)&Sound_DecodeAll, "Sound_DecodeAll");
    lib.bindSymbol(cast(void**)&Sound_FreeSample, "Sound_FreeSample");
    lib.bindSymbol(cast(void**)&Sound_GetError, "Sound_GetError");
    lib.bindSymbol(cast(void**)&Sound_GetLinkedVersion, "Sound_GetLinkedVersion");
    lib.bindSymbol(cast(void**)&Sound_Init, "Sound_Init");
    lib.bindSymbol(cast(void**)&Sound_NewSample, "Sound_NewSample");
    lib.bindSymbol(cast(void**)&Sound_NewSampleFromFile, "Sound_NewSampleFromFile");
    lib.bindSymbol(cast(void**)&Sound_Quit, "Sound_Quit");
    lib.bindSymbol(cast(void**)&Sound_Rewind, "Sound_Rewind");
    lib.bindSymbol(cast(void**)&Sound_Seek, "Sound_Seek");
    lib.bindSymbol(cast(void**)&Sound_SetBufferSize, "Sound_SetBufferSize");
}