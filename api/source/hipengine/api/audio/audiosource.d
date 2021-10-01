module hipengine.api.audio.audiosource;
public import hipengine.api.math.vector;
public import hipengine.api.audio.audioclip;

abstract class AHipAudioSource
{
    IHipAudioClip clip;
    bool isLooping;
    bool isPlaying;

    float time;
    float length;
    float pitch = 1;
    float panning = 0;
    float volume = 1;
    abstract float getProgress();
    abstract AHipAudioSource clean();
    abstract void pullStreamData();
    abstract void* getFreeBuffer();


    //3D Audio Only
    float maxDistance = 0;
    float rolloffFactor = 0;
    float referenceDistance = 0;
    Vector3 position;
    uint id;
}