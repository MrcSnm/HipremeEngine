module hip.audio_decoding.format_utils;

///Gets Mp3 duration in seconds
float HipMp3GetDuration(ulong bufferSize, uint sampleRate)
{
    return (cast(float)(bufferSize) / sampleRate);
}