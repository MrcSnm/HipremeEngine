module implementations.audio.backend.audiosource;
import math.vector;
import implementations.audio.audiobase : AudioBuffer;
import implementations.audio.audio;
import bindbc.openal;

public class AudioSource
{
    public:
    //Functions
        void attachToPosition(){}
        void attachOnDestroy(){}
        float getProgress(){return time/length;}
        void setBuffer(AudioBuffer buf)
        {
            buffer = buf;
        }

    //Properties
        AudioBuffer buffer;

        bool isLooping;
        bool isPlaying;

        float time;
        float length;
        float pitch;
        float panning;
        float volume;

        //3D Audio Only
        float maxDistance;
        float rolloffFactor;
        float referenceDistance;

        public AudioSource clean()
        {
            isLooping = false;
            isPlaying = false;
            Audio.stop(this);
            length = 0;
            Audio.setPitch(this, 1f);
            Audio.setPanning(this, 0f);
            Audio.setVolume(this, 1f);
            Audio.setMaxDistance(this, 0f);
            Audio.setRolloffFactor(this, 1f);
            Audio.setReferenceDistance(this, 0f);
            position = Vector!float.Zero();
            // id = -1;
            buffer = null;
            return this;
        }

        
        //Making 3D concept available for every audio, it can be useful
        Vector!float position;
        uint id;
}

public class AudioSource3D : AudioSource
{   
    import std.stdio:writeln;

    override void setBuffer(AudioBuffer buf)
    {
        import implementations.audio.backend.audio3d : OpenALBuffer;
        super.setBuffer(buf);
        writeln((cast(OpenALBuffer)buf).bufferId);
        writeln(id);
        alSourcei(id, AL_BUFFER, (cast(OpenALBuffer)buf).bufferId);
    }
    ~this()
    {
        writeln("AudioSource Killed!");
        alDeleteSources(1, &id);
        id = -1;
    }
}