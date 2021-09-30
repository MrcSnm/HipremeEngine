module hipengine.api.audio;

/**
* Controls how the gain will falloff
*/
enum DistanceModel
{
    DISTANCE_MODEL,
    /**
    * Very similar to the exponential curve
    */
    INVERSE,
    INVERSE_CLAMPED,
    /**
    * Linear curve, the only which can achieve 0 volume
    */
    LINEAR,
    LINEAR_CLAMPED,

    /**
    * Exponential curve for the model
    */
    EXPONENT,
    /**
    * When the distance is below the reference, it will clamp the volume to 1
    * When the distance is higher than max distance, it will not decrease volume any longer
    */
    EXPONENT_CLAMPED
}

enum HipAudioImplementation
{
    OPENAL,
    SDL,
    OPENSLES
}


enum HipAudioEncoding
{
    WAV,
    MP3,
    OGG,
    MIDI, //Probably won't support
    FLAC
}
enum HipAudioType
{
    SFX,
    MUSIC
}


version(Script)
    public import HipAudio = hipengine.api.audio.audio;