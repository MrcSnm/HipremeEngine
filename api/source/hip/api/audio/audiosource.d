module hip.api.audio.audiosource;

version(HipAudioAPI)
{
    public import hip.api.audio.audioclip;

    abstract class AHipAudioSource
    {
        protected IHipAudioClip _clip;

        IHipAudioClip clip(){return _clip;}
        IHipAudioClip clip(IHipAudioClip newClip){return _clip = newClip;}
        
        protected bool isDirty;
        protected bool _loop;
        bool isPlaying;
        bool isPaused;

        protected float _time = 0;
        protected float _length = -1;
        protected float _pitch = 1;
        protected float _panning = 0;
        protected float _volume = 1;
        protected float[3] _position = [0,0,0];



        final float length() const => _length;
        final float time() const => _time;
        final float pitch() const => _pitch;
        final float panning() const => _panning;
        final float volume() const => _volume;
        final bool loop() const => _loop;



        float length(float value) => _length = value;
        float time(float value) => _time = value;

        float pitch(float value)
        in(value != float.nan)
        {
            isDirty = isDirty || pitch != value;
            return _pitch = value;
        }

        float panning(float value)
        in(value >= -1 && value <= 1)
        {
            isDirty = isDirty || panning != value;
            return _panning = value;
        }
        float volume(float value)
        in(value != float.nan)
        {
            isDirty = isDirty || pitch != value;
            return _volume = value;
        }

        float[3] position() => _position;
        float[3] position(float[3] value)
        {
            isDirty = isDirty || position != value;
            return _position = value;
        }

        bool loop(bool value)
        {
            isDirty = isDirty || _loop != value;
            return _loop = value;
        }

        
        bool play()
        {
            isPlaying = true;
            return false;
        }
        bool stop()
        {
            isPlaying = false;
            return false;
        }
        bool pause()
        {
            isPaused = true;
            return false;
        }
        bool play_streamed() => false;


        abstract float getProgress();
        abstract AHipAudioSource clean();
        abstract void pullStreamData();
        abstract void* getFreeBuffer();


        


        //3D Audio Only
        float maxDistance = 0;
        float rolloffFactor = 0;
        float referenceDistance = 0;
    }
}