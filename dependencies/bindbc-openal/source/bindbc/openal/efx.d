
//          Copyright Michael D. Parker 2018 & Marcelo S. N. Mancini 2020.
// Distributed under the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE_1_0.txt or copy at
//          http://www.boost.org/LICENSE_1_0.txt)

module bindbc.openal.efx;
import bindbc.openal.types;

version = OpenAL_EFX;
enum ALC_EXT_EFX_NAME        = "ALC_EXT_EFX";
enum ALC_EFX_MAJOR_VERSION   = 0x20001;
enum ALC_EFX_MINOR_VERSION   = 0x20002;
enum ALC_MAX_AUXILIARY_SENDS = 0x20003;

///Listener Properties
enum AL_METERS_PER_UNIT      = 0x20004;

///Source Properties
enum AL_DIRECT_FILTER                     = 0x20005;
enum AL_AUXILIARY_SEND_FILTER             = 0x20006;
enum AL_AIR_ABSORPTION_FACTOR             = 0x20007;
enum AL_ROOM_ROLLOFF_FACTOR               = 0x20008;
enum AL_CONE_OUTER_GAINHF                 = 0x20009;
enum AL_DIRECT_FILTER_GAINHF_AUTO         = 0x2000A;
enum AL_AUXILIARY_SEND_FILTER_GAIN_AUTO   = 0x2000B;
enum AL_AUXILIARY_SEND_FILTER_GAINHF_AUTO = 0x2000C;


///Effect Properties

///Reverb effect parameters
enum : ALuint
{
    AL_REVERB_DENSITY                = 0x0001,
    AL_REVERB_DIFFUSION              = 0x0002,
    AL_REVERB_GAIN                   = 0x0003,
    AL_REVERB_GAINHF                 = 0x0004,
    AL_REVERB_DECAY_TIME             = 0x0005,
    AL_REVERB_DECAY_HFRATIO          = 0x0006,
    AL_REVERB_REFLECTIONS_GAIN       = 0x0007,
    AL_REVERB_REFLECTIONS_DELAY      = 0x0008,
    AL_REVERB_LATE_REVERB_GAIN       = 0x0009,
    AL_REVERB_LATE_REVERB_DELAY      = 0x000A,
    AL_REVERB_AIR_ABSORPTION_GAINHF  = 0x000B,
    AL_REVERB_ROOM_ROLLOFF_FACTOR    = 0x000C,
    AL_REVERB_DECAY_HFLIMIT          = 0x000D,
}

///EAX Reverb effect parameters
enum : ALuint
{
    AL_EAXREVERB_DENSITY               = 0x0001,
    AL_EAXREVERB_DIFFUSION             = 0x0002,
    AL_EAXREVERB_GAIN                  = 0x0003,
    AL_EAXREVERB_GAINHF                = 0x0004,
    AL_EAXREVERB_GAINLF                = 0x0005,
    AL_EAXREVERB_DECAY_TIME            = 0x0006,
    AL_EAXREVERB_DECAY_HFRATIO         = 0x0007,
    AL_EAXREVERB_DECAY_LFRATIO         = 0x0008,
    AL_EAXREVERB_REFLECTIONS_GAIN      = 0x0009,
    AL_EAXREVERB_REFLECTIONS_DELAY     = 0x000A,
    AL_EAXREVERB_REFLECTIONS_PAN       = 0x000B,
    AL_EAXREVERB_LATE_REVERB_GAIN      = 0x000C,
    AL_EAXREVERB_LATE_REVERB_DELAY     = 0x000D,
    AL_EAXREVERB_LATE_REVERB_PAN       = 0x000E,
    AL_EAXREVERB_ECHO_TIME             = 0x000F,
    AL_EAXREVERB_ECHO_DEPTH            = 0x0010,
    AL_EAXREVERB_MODULATION_TIME       = 0x0011,
    AL_EAXREVERB_MODULATION_DEPTH      = 0x0012,
    AL_EAXREVERB_AIR_ABSORPTION_GAINHF = 0x0013,
    AL_EAXREVERB_HFREFERENCE           = 0x0014,
    AL_EAXREVERB_LFREFERENCE           = 0x0015,
    AL_EAXREVERB_ROOM_ROLLOFF_FACTOR   = 0x0016,
    AL_EAXREVERB_DECAY_HFLIMIT         = 0x0017
}

/* Chorus effect parameters */
enum : ALuint
{
    AL_CHORUS_WAVEFORM =  0x0001,
    AL_CHORUS_PHASE    =  0x0002,
    AL_CHORUS_RATE     =  0x0003,
    AL_CHORUS_DEPTH    =  0x0004,
    AL_CHORUS_FEEDBACK =  0x0005,
    AL_CHORUS_DELAY    =  0x0006
}

///Distortion effect parameters
enum : ALuint
{
    AL_DISTORTION_EDGE                       = 0x0001,
    AL_DISTORTION_GAIN                       = 0x0002,
    AL_DISTORTION_LOWPASS_CUTOFF             = 0x0003,
    AL_DISTORTION_EQCENTER                   = 0x0004,
    AL_DISTORTION_EQBANDWIDTH                = 0x0005,
}

///Echo effect parameters
enum : ALuint
{
    AL_ECHO_DELAY                            = 0x0001,
    AL_ECHO_LRDELAY                          = 0x0002,
    AL_ECHO_DAMPING                          = 0x0003,
    AL_ECHO_FEEDBACK                         = 0x0004,
    AL_ECHO_SPREAD                           = 0x0005
}

/* Flanger effect parameters */
enum : ALuint
{
    AL_FLANGER_WAVEFORM                      = 0x0001,
    AL_FLANGER_PHASE                         = 0x0002,
    AL_FLANGER_RATE                          = 0x0003,
    AL_FLANGER_DEPTH                         = 0x0004,
    AL_FLANGER_FEEDBACK                      = 0x0005,
    AL_FLANGER_DELAY                         = 0x0006
}
    

/* Frequency shifter effect parameters */
enum : ALuint
{
    AL_FREQUENCY_SHIFTER_FREQUENCY           = 0x0001,
    AL_FREQUENCY_SHIFTER_LEFT_DIRECTION      = 0x0002,
    AL_FREQUENCY_SHIFTER_RIGHT_DIRECTION     = 0x0003
}

/* Vocal morpher effect parameters */

enum : ALuint
{
    AL_VOCAL_MORPHER_PHONEMEA                = 0x0001,
    AL_VOCAL_MORPHER_PHONEMEA_COARSE_TUNING  = 0x0002,
    AL_VOCAL_MORPHER_PHONEMEB                = 0x0003,
    AL_VOCAL_MORPHER_PHONEMEB_COARSE_TUNING  = 0x0004,
    AL_VOCAL_MORPHER_WAVEFORM                = 0x0005,
    AL_VOCAL_MORPHER_RATE                    = 0x0006
}

/* Pitchshifter effect parameters */

enum : ALuint
{
    AL_PITCH_SHIFTER_COARSE_TUNE             = 0x0001,
    AL_PITCH_SHIFTER_FINE_TUNE               = 0x0002
}

/* Ringmodulator effect parameters */
enum : ALuint
{
    AL_RING_MODULATOR_FREQUENCY              = 0x0001,
    AL_RING_MODULATOR_HIGHPASS_CUTOFF        = 0x0002,
    AL_RING_MODULATOR_WAVEFORM               = 0x0003
}

/* Autowah effect parameters */
enum : ALuint
{
    AL_AUTOWAH_ATTACK_TIME                   = 0x0001,
    AL_AUTOWAH_RELEASE_TIME                  = 0x0002,
    AL_AUTOWAH_RESONANCE                     = 0x0003,
    AL_AUTOWAH_PEAK_GAIN                     = 0x0004
}

/* Compressor effect parameters */
enum : ALuint
{
    AL_COMPRESSOR_ONOFF                      = 0x0001
}

/* Equalizer effect parameters */
enum : ALuint
{
    AL_EQUALIZER_LOW_GAIN                    = 0x0001,
    AL_EQUALIZER_LOW_CUTOFF                  = 0x0002,
    AL_EQUALIZER_MID1_GAIN                   = 0x0003,
    AL_EQUALIZER_MID1_CENTER                 = 0x0004,
    AL_EQUALIZER_MID1_WIDTH                  = 0x0005,
    AL_EQUALIZER_MID2_GAIN                   = 0x0006,
    AL_EQUALIZER_MID2_CENTER                 = 0x0007,
    AL_EQUALIZER_MID2_WIDTH                  = 0x0008,
    AL_EQUALIZER_HIGH_GAIN                   = 0x0009,
    AL_EQUALIZER_HIGH_CUTOFF                 = 0x000A
}

/* Effect type */
enum AL_EFFECT_FIRST_PARAMETER  = 0x0000;
enum AL_EFFECT_LAST_PARAMETER   = 0x8000;
enum AL_EFFECT_TYPE             = 0x8001;

/* Effect types, used with the AL_EFFECT_TYPE property */
enum : ALuint
{
    AL_EFFECT_NULL                           = 0x0000,
    AL_EFFECT_REVERB                         = 0x0001,
    AL_EFFECT_CHORUS                         = 0x0002,
    AL_EFFECT_DISTORTION                     = 0x0003,
    AL_EFFECT_ECHO                           = 0x0004,
    AL_EFFECT_FLANGER                        = 0x0005,
    AL_EFFECT_FREQUENCY_SHIFTER              = 0x0006,
    AL_EFFECT_VOCAL_MORPHER                  = 0x0007,
    AL_EFFECT_PITCH_SHIFTER                  = 0x0008,
    AL_EFFECT_RING_MODULATOR                 = 0x0009,
    AL_EFFECT_AUTOWAH                        = 0x000A,
    AL_EFFECT_COMPRESSOR                     = 0x000B,
    AL_EFFECT_EQUALIZER                      = 0x000C,
    AL_EFFECT_EAXREVERB                      = 0x8000
}

/* Auxiliary Effect Slot properties. */
enum : ALuint
{
    AL_EFFECTSLOT_EFFECT                     = 0x0001,
    AL_EFFECTSLOT_GAIN                       = 0x0002,
    AL_EFFECTSLOT_AUXILIARY_SEND_AUTO        = 0x0003
}

/* NULL Auxiliary Slot ID to disable a source send. */
enum AL_EFFECTSLOT_NULL                       = 0x0000;


/* Filter properties. */

/* Lowpass filter parameters */
enum : ALuint
{
    AL_LOWPASS_GAIN                          = 0x0001,
    AL_LOWPASS_GAINHF                        = 0x0002
}

/* Highpass filter parameters */
enum : ALuint
{
    AL_HIGHPASS_GAIN                         = 0x0001,
    AL_HIGHPASS_GAINLF                       = 0x0002
}

/* Bandpass filter parameters */
enum : ALuint
{
    AL_BANDPASS_GAIN                         = 0x0001,
    AL_BANDPASS_GAINLF                       = 0x0002,
    AL_BANDPASS_GAINHF                       = 0x0003
}

/* Filter type */

enum AL_FILTER_FIRST_PARAMETER                = 0x0000;
enum AL_FILTER_LAST_PARAMETER                 = 0x8000;
enum AL_FILTER_TYPE                           = 0x8001;

/* Filter types, used with the AL_FILTER_TYPE property */
enum : ALuint
{
    AL_FILTER_NULL                           = 0x0000,
    AL_FILTER_LOWPASS                        = 0x0001,
    AL_FILTER_HIGHPASS                       = 0x0002,
    AL_FILTER_BANDPASS                       = 0x0003,
}



/* Lowpass filter */
enum AL_LOWPASS_MIN_GAIN =                      (0.0f);
enum AL_LOWPASS_MAX_GAIN =                      (1.0f);
enum AL_LOWPASS_DEFAULT_GAIN =                  (1.0f);

enum AL_LOWPASS_MIN_GAINHF =                    (0.0f);
enum AL_LOWPASS_MAX_GAINHF =                    (1.0f);
enum AL_LOWPASS_DEFAULT_GAINHF =                (1.0f);

/* Highpass filter */
enum AL_HIGHPASS_MIN_GAIN =                     (0.0f);
enum AL_HIGHPASS_MAX_GAIN =                     (1.0f);
enum AL_HIGHPASS_DEFAULT_GAIN =                 (1.0f);

enum AL_HIGHPASS_MIN_GAINLF =                   (0.0f);
enum AL_HIGHPASS_MAX_GAINLF =                   (1.0f);
enum AL_HIGHPASS_DEFAULT_GAINLF =               (1.0f);

/* Bandpass filter */
enum AL_BANDPASS_MIN_GAIN =                     (0.0f);
enum AL_BANDPASS_MAX_GAIN =                     (1.0f);
enum AL_BANDPASS_DEFAULT_GAIN =                 (1.0f);

enum AL_BANDPASS_MIN_GAINHF =                   (0.0f);
enum AL_BANDPASS_MAX_GAINHF =                   (1.0f);
enum AL_BANDPASS_DEFAULT_GAINHF =               (1.0f);

enum AL_BANDPASS_MIN_GAINLF =                   (0.0f);
enum AL_BANDPASS_MAX_GAINLF =                   (1.0f);
enum AL_BANDPASS_DEFAULT_GAINLF =               (1.0f);


/* Effect parameter ranges and defaults. */

/* Standard reverb effect */
enum AL_REVERB_MIN_DENSITY =                    (0.0f);
enum AL_REVERB_MAX_DENSITY =                    (1.0f);
enum AL_REVERB_DEFAULT_DENSITY =                (1.0f);

enum AL_REVERB_MIN_DIFFUSION =                  (0.0f);
enum AL_REVERB_MAX_DIFFUSION =                  (1.0f);
enum AL_REVERB_DEFAULT_DIFFUSION =              (1.0f);

enum AL_REVERB_MIN_GAIN =                       (0.0f);
enum AL_REVERB_MAX_GAIN =                       (1.0f);
enum AL_REVERB_DEFAULT_GAIN =                   (0.32f);

enum AL_REVERB_MIN_GAINHF =                     (0.0f);
enum AL_REVERB_MAX_GAINHF =                     (1.0f);
enum AL_REVERB_DEFAULT_GAINHF =                 (0.89f);

enum AL_REVERB_MIN_DECAY_TIME =                 (0.1f);
enum AL_REVERB_MAX_DECAY_TIME =                 (20.0f);
enum AL_REVERB_DEFAULT_DECAY_TIME =             (1.49f);

enum AL_REVERB_MIN_DECAY_HFRATIO =              (0.1f);
enum AL_REVERB_MAX_DECAY_HFRATIO =              (2.0f);
enum AL_REVERB_DEFAULT_DECAY_HFRATIO =          (0.83f);

enum AL_REVERB_MIN_REFLECTIONS_GAIN =           (0.0f);
enum AL_REVERB_MAX_REFLECTIONS_GAIN =           (3.16f);
enum AL_REVERB_DEFAULT_REFLECTIONS_GAIN =       (0.05f);

enum AL_REVERB_MIN_REFLECTIONS_DELAY =          (0.0f);
enum AL_REVERB_MAX_REFLECTIONS_DELAY =          (0.3f);
enum AL_REVERB_DEFAULT_REFLECTIONS_DELAY =      (0.007f);

enum AL_REVERB_MIN_LATE_REVERB_GAIN =           (0.0f);
enum AL_REVERB_MAX_LATE_REVERB_GAIN =           (10.0f);
enum AL_REVERB_DEFAULT_LATE_REVERB_GAIN =       (1.26f);

enum AL_REVERB_MIN_LATE_REVERB_DELAY =          (0.0f);
enum AL_REVERB_MAX_LATE_REVERB_DELAY =          (0.1f);
enum AL_REVERB_DEFAULT_LATE_REVERB_DELAY =      (0.011f);

enum AL_REVERB_MIN_AIR_ABSORPTION_GAINHF =      (0.892f);
enum AL_REVERB_MAX_AIR_ABSORPTION_GAINHF =      (1.0f);
enum AL_REVERB_DEFAULT_AIR_ABSORPTION_GAINHF =  (0.994f);

enum AL_REVERB_MIN_ROOM_ROLLOFF_FACTOR =        (0.0f);
enum AL_REVERB_MAX_ROOM_ROLLOFF_FACTOR =        (10.0f);
enum AL_REVERB_DEFAULT_ROOM_ROLLOFF_FACTOR =    (0.0f);

enum AL_REVERB_MIN_DECAY_HFLIMIT =              AL_FALSE;
enum AL_REVERB_MAX_DECAY_HFLIMIT =              AL_TRUE;
enum AL_REVERB_DEFAULT_DECAY_HFLIMIT =          AL_TRUE;

/* EAX reverb effect */
enum AL_EAXREVERB_MIN_DENSITY =                 (0.0f);
enum AL_EAXREVERB_MAX_DENSITY =                 (1.0f);
enum AL_EAXREVERB_DEFAULT_DENSITY =             (1.0f);

enum AL_EAXREVERB_MIN_DIFFUSION =               (0.0f);
enum AL_EAXREVERB_MAX_DIFFUSION =               (1.0f);
enum AL_EAXREVERB_DEFAULT_DIFFUSION =           (1.0f);

enum AL_EAXREVERB_MIN_GAIN =                    (0.0f);
enum AL_EAXREVERB_MAX_GAIN =                    (1.0f);
enum AL_EAXREVERB_DEFAULT_GAIN =                (0.32f);

enum AL_EAXREVERB_MIN_GAINHF =                  (0.0f);
enum AL_EAXREVERB_MAX_GAINHF =                  (1.0f);
enum AL_EAXREVERB_DEFAULT_GAINHF =              (0.89f);

enum AL_EAXREVERB_MIN_GAINLF =                  (0.0f);
enum AL_EAXREVERB_MAX_GAINLF =                  (1.0f);
enum AL_EAXREVERB_DEFAULT_GAINLF =              (1.0f);

enum AL_EAXREVERB_MIN_DECAY_TIME =              (0.1f);
enum AL_EAXREVERB_MAX_DECAY_TIME =              (20.0f);
enum AL_EAXREVERB_DEFAULT_DECAY_TIME =          (1.49f);

enum AL_EAXREVERB_MIN_DECAY_HFRATIO =           (0.1f);
enum AL_EAXREVERB_MAX_DECAY_HFRATIO =           (2.0f);
enum AL_EAXREVERB_DEFAULT_DECAY_HFRATIO =       (0.83f);

enum AL_EAXREVERB_MIN_DECAY_LFRATIO =           (0.1f);
enum AL_EAXREVERB_MAX_DECAY_LFRATIO =           (2.0f);
enum AL_EAXREVERB_DEFAULT_DECAY_LFRATIO =       (1.0f);

enum AL_EAXREVERB_MIN_REFLECTIONS_GAIN =        (0.0f);
enum AL_EAXREVERB_MAX_REFLECTIONS_GAIN =        (3.16f);
enum AL_EAXREVERB_DEFAULT_REFLECTIONS_GAIN =    (0.05f);

enum AL_EAXREVERB_MIN_REFLECTIONS_DELAY =       (0.0f);
enum AL_EAXREVERB_MAX_REFLECTIONS_DELAY =       (0.3f);
enum AL_EAXREVERB_DEFAULT_REFLECTIONS_DELAY =   (0.007f);

enum AL_EAXREVERB_DEFAULT_REFLECTIONS_PAN_XYZ = (0.0f);

enum AL_EAXREVERB_MIN_LATE_REVERB_GAIN =        (0.0f);
enum AL_EAXREVERB_MAX_LATE_REVERB_GAIN =        (10.0f);
enum AL_EAXREVERB_DEFAULT_LATE_REVERB_GAIN =    (1.26f);

enum AL_EAXREVERB_MIN_LATE_REVERB_DELAY =       (0.0f);
enum AL_EAXREVERB_MAX_LATE_REVERB_DELAY =       (0.1f);
enum AL_EAXREVERB_DEFAULT_LATE_REVERB_DELAY =   (0.011f);

enum AL_EAXREVERB_DEFAULT_LATE_REVERB_PAN_XYZ = (0.0f);

enum AL_EAXREVERB_MIN_ECHO_TIME =               (0.075f);
enum AL_EAXREVERB_MAX_ECHO_TIME =               (0.25f);
enum AL_EAXREVERB_DEFAULT_ECHO_TIME =           (0.25f);

enum AL_EAXREVERB_MIN_ECHO_DEPTH =              (0.0f);
enum AL_EAXREVERB_MAX_ECHO_DEPTH =              (1.0f);
enum AL_EAXREVERB_DEFAULT_ECHO_DEPTH =          (0.0f);

enum AL_EAXREVERB_MIN_MODULATION_TIME =         (0.04f);
enum AL_EAXREVERB_MAX_MODULATION_TIME =         (4.0f);
enum AL_EAXREVERB_DEFAULT_MODULATION_TIME =     (0.25f);

enum AL_EAXREVERB_MIN_MODULATION_DEPTH =        (0.0f);
enum AL_EAXREVERB_MAX_MODULATION_DEPTH =        (1.0f);
enum AL_EAXREVERB_DEFAULT_MODULATION_DEPTH =    (0.0f);

enum AL_EAXREVERB_MIN_AIR_ABSORPTION_GAINHF =   (0.892f);
enum AL_EAXREVERB_MAX_AIR_ABSORPTION_GAINHF =   (1.0f);
enum AL_EAXREVERB_DEFAULT_AIR_ABSORPTION_GAINHF = (0.994f);

enum AL_EAXREVERB_MIN_HFREFERENCE =             (1000.0f);
enum AL_EAXREVERB_MAX_HFREFERENCE =             (20000.0f);
enum AL_EAXREVERB_DEFAULT_HFREFERENCE =         (5000.0f);

enum AL_EAXREVERB_MIN_LFREFERENCE =             (20.0f);
enum AL_EAXREVERB_MAX_LFREFERENCE =             (1000.0f);
enum AL_EAXREVERB_DEFAULT_LFREFERENCE =         (250.0f);

enum AL_EAXREVERB_MIN_ROOM_ROLLOFF_FACTOR =     (0.0f);
enum AL_EAXREVERB_MAX_ROOM_ROLLOFF_FACTOR =     (10.0f);
enum AL_EAXREVERB_DEFAULT_ROOM_ROLLOFF_FACTOR = (0.0f);

enum AL_EAXREVERB_MIN_DECAY_HFLIMIT =           AL_FALSE;
enum AL_EAXREVERB_MAX_DECAY_HFLIMIT =           AL_TRUE;
enum AL_EAXREVERB_DEFAULT_DECAY_HFLIMIT =       AL_TRUE;

/* Chorus effect */
enum AL_CHORUS_WAVEFORM_SINUSOID =              (0);
enum AL_CHORUS_WAVEFORM_TRIANGLE =              (1);

enum AL_CHORUS_MIN_WAVEFORM =                   (0);
enum AL_CHORUS_MAX_WAVEFORM =                   (1);
enum AL_CHORUS_DEFAULT_WAVEFORM =               (1);

enum AL_CHORUS_MIN_PHASE =                      (-180);
enum AL_CHORUS_MAX_PHASE =                      (180);
enum AL_CHORUS_DEFAULT_PHASE =                  (90);

enum AL_CHORUS_MIN_RATE =                       (0.0f);
enum AL_CHORUS_MAX_RATE =                       (10.0f);
enum AL_CHORUS_DEFAULT_RATE =                   (1.1f);

enum AL_CHORUS_MIN_DEPTH =                      (0.0f);
enum AL_CHORUS_MAX_DEPTH =                      (1.0f);
enum AL_CHORUS_DEFAULT_DEPTH =                  (0.1f);

enum AL_CHORUS_MIN_FEEDBACK =                   (-1.0f);
enum AL_CHORUS_MAX_FEEDBACK =                   (1.0f);
enum AL_CHORUS_DEFAULT_FEEDBACK =               (0.25f);

enum AL_CHORUS_MIN_DELAY =                      (0.0f);
enum AL_CHORUS_MAX_DELAY =                      (0.016f);
enum AL_CHORUS_DEFAULT_DELAY =                  (0.016f);

/* Distortion effect */
enum AL_DISTORTION_MIN_EDGE =                   (0.0f);
enum AL_DISTORTION_MAX_EDGE =                   (1.0f);
enum AL_DISTORTION_DEFAULT_EDGE =               (0.2f);

enum AL_DISTORTION_MIN_GAIN =                   (0.01f);
enum AL_DISTORTION_MAX_GAIN =                   (1.0f);
enum AL_DISTORTION_DEFAULT_GAIN =               (0.05f);

enum AL_DISTORTION_MIN_LOWPASS_CUTOFF =         (80.0f);
enum AL_DISTORTION_MAX_LOWPASS_CUTOFF =         (24000.0f);
enum AL_DISTORTION_DEFAULT_LOWPASS_CUTOFF =     (8000.0f);

enum AL_DISTORTION_MIN_EQCENTER =               (80.0f);
enum AL_DISTORTION_MAX_EQCENTER =               (24000.0f);
enum AL_DISTORTION_DEFAULT_EQCENTER =           (3600.0f);

enum AL_DISTORTION_MIN_EQBANDWIDTH =            (80.0f);
enum AL_DISTORTION_MAX_EQBANDWIDTH =            (24000.0f);
enum AL_DISTORTION_DEFAULT_EQBANDWIDTH =        (3600.0f);

/* Echo effect */
enum AL_ECHO_MIN_DELAY =                        (0.0f);
enum AL_ECHO_MAX_DELAY =                        (0.207f);
enum AL_ECHO_DEFAULT_DELAY =                    (0.1f);

enum AL_ECHO_MIN_LRDELAY =                      (0.0f);
enum AL_ECHO_MAX_LRDELAY =                      (0.404f);
enum AL_ECHO_DEFAULT_LRDELAY =                  (0.1f);

enum AL_ECHO_MIN_DAMPING =                      (0.0f);
enum AL_ECHO_MAX_DAMPING =                      (0.99f);
enum AL_ECHO_DEFAULT_DAMPING =                  (0.5f);

enum AL_ECHO_MIN_FEEDBACK =                     (0.0f);
enum AL_ECHO_MAX_FEEDBACK =                     (1.0f);
enum AL_ECHO_DEFAULT_FEEDBACK =                 (0.5f);

enum AL_ECHO_MIN_SPREAD =                       (-1.0f);
enum AL_ECHO_MAX_SPREAD =                       (1.0f);
enum AL_ECHO_DEFAULT_SPREAD =                   (-1.0f);

/* Flanger effect */
enum AL_FLANGER_WAVEFORM_SINUSOID =             (0);
enum AL_FLANGER_WAVEFORM_TRIANGLE =             (1);

enum AL_FLANGER_MIN_WAVEFORM =                  (0);
enum AL_FLANGER_MAX_WAVEFORM =                  (1);
enum AL_FLANGER_DEFAULT_WAVEFORM =              (1);

enum AL_FLANGER_MIN_PHASE =                     (-180);
enum AL_FLANGER_MAX_PHASE =                     (180);
enum AL_FLANGER_DEFAULT_PHASE =                 (0);

enum AL_FLANGER_MIN_RATE =                      (0.0f);
enum AL_FLANGER_MAX_RATE =                      (10.0f);
enum AL_FLANGER_DEFAULT_RATE =                  (0.27f);

enum AL_FLANGER_MIN_DEPTH =                     (0.0f);
enum AL_FLANGER_MAX_DEPTH =                     (1.0f);
enum AL_FLANGER_DEFAULT_DEPTH =                 (1.0f);

enum AL_FLANGER_MIN_FEEDBACK =                  (-1.0f);
enum AL_FLANGER_MAX_FEEDBACK =                  (1.0f);
enum AL_FLANGER_DEFAULT_FEEDBACK =              (-0.5f);

enum AL_FLANGER_MIN_DELAY =                     (0.0f);
enum AL_FLANGER_MAX_DELAY =                     (0.004f);
enum AL_FLANGER_DEFAULT_DELAY =                 (0.002f);

/* Frequency shifter effect */
enum AL_FREQUENCY_SHIFTER_MIN_FREQUENCY =       (0.0f);
enum AL_FREQUENCY_SHIFTER_MAX_FREQUENCY =       (24000.0f);
enum AL_FREQUENCY_SHIFTER_DEFAULT_FREQUENCY =   (0.0f);

enum AL_FREQUENCY_SHIFTER_MIN_LEFT_DIRECTION =  (0);
enum AL_FREQUENCY_SHIFTER_MAX_LEFT_DIRECTION =  (2);
enum AL_FREQUENCY_SHIFTER_DEFAULT_LEFT_DIRECTION = (0);

enum AL_FREQUENCY_SHIFTER_DIRECTION_DOWN =      (0);
enum AL_FREQUENCY_SHIFTER_DIRECTION_UP =        (1);
enum AL_FREQUENCY_SHIFTER_DIRECTION_OFF =       (2);

enum AL_FREQUENCY_SHIFTER_MIN_RIGHT_DIRECTION = (0);
enum AL_FREQUENCY_SHIFTER_MAX_RIGHT_DIRECTION = (2);
enum AL_FREQUENCY_SHIFTER_DEFAULT_RIGHT_DIRECTION = (0);

/* Vocal morpher effect */
enum AL_VOCAL_MORPHER_MIN_PHONEMEA =            (0);
enum AL_VOCAL_MORPHER_MAX_PHONEMEA =            (29);
enum AL_VOCAL_MORPHER_DEFAULT_PHONEMEA =        (0);

enum AL_VOCAL_MORPHER_MIN_PHONEMEA_COARSE_TUNING = (-24);
enum AL_VOCAL_MORPHER_MAX_PHONEMEA_COARSE_TUNING = (24);
enum AL_VOCAL_MORPHER_DEFAULT_PHONEMEA_COARSE_TUNING = (0);

enum AL_VOCAL_MORPHER_MIN_PHONEMEB =            (0);
enum AL_VOCAL_MORPHER_MAX_PHONEMEB =            (29);
enum AL_VOCAL_MORPHER_DEFAULT_PHONEMEB =        (10);

enum AL_VOCAL_MORPHER_MIN_PHONEMEB_COARSE_TUNING = (-24);
enum AL_VOCAL_MORPHER_MAX_PHONEMEB_COARSE_TUNING = (24);
enum AL_VOCAL_MORPHER_DEFAULT_PHONEMEB_COARSE_TUNING = (0);

enum AL_VOCAL_MORPHER_PHONEME_A =               (0);
enum AL_VOCAL_MORPHER_PHONEME_E =               (1);
enum AL_VOCAL_MORPHER_PHONEME_I =               (2);
enum AL_VOCAL_MORPHER_PHONEME_O =               (3);
enum AL_VOCAL_MORPHER_PHONEME_U =               (4);
enum AL_VOCAL_MORPHER_PHONEME_AA =              (5);
enum AL_VOCAL_MORPHER_PHONEME_AE =              (6);
enum AL_VOCAL_MORPHER_PHONEME_AH =              (7);
enum AL_VOCAL_MORPHER_PHONEME_AO =              (8);
enum AL_VOCAL_MORPHER_PHONEME_EH =              (9);
enum AL_VOCAL_MORPHER_PHONEME_ER =              (10);
enum AL_VOCAL_MORPHER_PHONEME_IH =              (11);
enum AL_VOCAL_MORPHER_PHONEME_IY =              (12);
enum AL_VOCAL_MORPHER_PHONEME_UH =              (13);
enum AL_VOCAL_MORPHER_PHONEME_UW =              (14);
enum AL_VOCAL_MORPHER_PHONEME_B =               (15);
enum AL_VOCAL_MORPHER_PHONEME_D =               (16);
enum AL_VOCAL_MORPHER_PHONEME_F =               (17);
enum AL_VOCAL_MORPHER_PHONEME_G =               (18);
enum AL_VOCAL_MORPHER_PHONEME_J =               (19);
enum AL_VOCAL_MORPHER_PHONEME_K =               (20);
enum AL_VOCAL_MORPHER_PHONEME_L =               (21);
enum AL_VOCAL_MORPHER_PHONEME_M =               (22);
enum AL_VOCAL_MORPHER_PHONEME_N =               (23);
enum AL_VOCAL_MORPHER_PHONEME_P =               (24);
enum AL_VOCAL_MORPHER_PHONEME_R =               (25);
enum AL_VOCAL_MORPHER_PHONEME_S =               (26);
enum AL_VOCAL_MORPHER_PHONEME_T =               (27);
enum AL_VOCAL_MORPHER_PHONEME_V =               (28);
enum AL_VOCAL_MORPHER_PHONEME_Z =               (29);

enum AL_VOCAL_MORPHER_WAVEFORM_SINUSOID =       (0);
enum AL_VOCAL_MORPHER_WAVEFORM_TRIANGLE =       (1);
enum AL_VOCAL_MORPHER_WAVEFORM_SAWTOOTH =       (2);

enum AL_VOCAL_MORPHER_MIN_WAVEFORM =            (0);
enum AL_VOCAL_MORPHER_MAX_WAVEFORM =            (2);
enum AL_VOCAL_MORPHER_DEFAULT_WAVEFORM =        (0);

enum AL_VOCAL_MORPHER_MIN_RATE =                (0.0f);
enum AL_VOCAL_MORPHER_MAX_RATE =                (10.0f);
enum AL_VOCAL_MORPHER_DEFAULT_RATE =            (1.41f);

/* Pitch shifter effect */
enum AL_PITCH_SHIFTER_MIN_COARSE_TUNE =         (-12);
enum AL_PITCH_SHIFTER_MAX_COARSE_TUNE =         (12);
enum AL_PITCH_SHIFTER_DEFAULT_COARSE_TUNE =     (12);

enum AL_PITCH_SHIFTER_MIN_FINE_TUNE =           (-50);
enum AL_PITCH_SHIFTER_MAX_FINE_TUNE =           (50);
enum AL_PITCH_SHIFTER_DEFAULT_FINE_TUNE =       (0);

/* Ring modulator effect */
enum AL_RING_MODULATOR_MIN_FREQUENCY =          (0.0f);
enum AL_RING_MODULATOR_MAX_FREQUENCY =          (8000.0f);
enum AL_RING_MODULATOR_DEFAULT_FREQUENCY =      (440.0f);

enum AL_RING_MODULATOR_MIN_HIGHPASS_CUTOFF =    (0.0f);
enum AL_RING_MODULATOR_MAX_HIGHPASS_CUTOFF =    (24000.0f);
enum AL_RING_MODULATOR_DEFAULT_HIGHPASS_CUTOFF = (800.0f);

enum AL_RING_MODULATOR_SINUSOID =               (0);
enum AL_RING_MODULATOR_SAWTOOTH =               (1);
enum AL_RING_MODULATOR_SQUARE =                 (2);

enum AL_RING_MODULATOR_MIN_WAVEFORM =           (0);
enum AL_RING_MODULATOR_MAX_WAVEFORM =           (2);
enum AL_RING_MODULATOR_DEFAULT_WAVEFORM =       (0);

/* Autowah effect */
enum AL_AUTOWAH_MIN_ATTACK_TIME =               (0.0001f);
enum AL_AUTOWAH_MAX_ATTACK_TIME =               (1.0f);
enum AL_AUTOWAH_DEFAULT_ATTACK_TIME =           (0.06f);

enum AL_AUTOWAH_MIN_RELEASE_TIME =              (0.0001f);
enum AL_AUTOWAH_MAX_RELEASE_TIME =              (1.0f);
enum AL_AUTOWAH_DEFAULT_RELEASE_TIME =          (0.06f);

enum AL_AUTOWAH_MIN_RESONANCE =                 (2.0f);
enum AL_AUTOWAH_MAX_RESONANCE =                 (1000.0f);
enum AL_AUTOWAH_DEFAULT_RESONANCE =             (1000.0f);

enum AL_AUTOWAH_MIN_PEAK_GAIN =                 (0.00003f);
enum AL_AUTOWAH_MAX_PEAK_GAIN =                 (31621.0f);
enum AL_AUTOWAH_DEFAULT_PEAK_GAIN =             (11.22f);

/* Compressor effect */
enum AL_COMPRESSOR_MIN_ONOFF =                  (0);
enum AL_COMPRESSOR_MAX_ONOFF =                  (1);
enum AL_COMPRESSOR_DEFAULT_ONOFF =              (1);

/* Equalizer effect */
enum AL_EQUALIZER_MIN_LOW_GAIN =                (0.126f);
enum AL_EQUALIZER_MAX_LOW_GAIN =                (7.943f);
enum AL_EQUALIZER_DEFAULT_LOW_GAIN =            (1.0f);

enum AL_EQUALIZER_MIN_LOW_CUTOFF =              (50.0f);
enum AL_EQUALIZER_MAX_LOW_CUTOFF =              (800.0f);
enum AL_EQUALIZER_DEFAULT_LOW_CUTOFF =          (200.0f);

enum AL_EQUALIZER_MIN_MID1_GAIN =               (0.126f);
enum AL_EQUALIZER_MAX_MID1_GAIN =               (7.943f);
enum AL_EQUALIZER_DEFAULT_MID1_GAIN =           (1.0f);

enum AL_EQUALIZER_MIN_MID1_CENTER =             (200.0f);
enum AL_EQUALIZER_MAX_MID1_CENTER =             (3000.0f);
enum AL_EQUALIZER_DEFAULT_MID1_CENTER =         (500.0f);

enum AL_EQUALIZER_MIN_MID1_WIDTH =              (0.01f);
enum AL_EQUALIZER_MAX_MID1_WIDTH =              (1.0f);
enum AL_EQUALIZER_DEFAULT_MID1_WIDTH =          (1.0f);

enum AL_EQUALIZER_MIN_MID2_GAIN =               (0.126f);
enum AL_EQUALIZER_MAX_MID2_GAIN =               (7.943f);
enum AL_EQUALIZER_DEFAULT_MID2_GAIN =           (1.0f);

enum AL_EQUALIZER_MIN_MID2_CENTER =             (1000.0f);
enum AL_EQUALIZER_MAX_MID2_CENTER =             (8000.0f);
enum AL_EQUALIZER_DEFAULT_MID2_CENTER =         (3000.0f);

enum AL_EQUALIZER_MIN_MID2_WIDTH =              (0.01f);
enum AL_EQUALIZER_MAX_MID2_WIDTH =              (1.0f);
enum AL_EQUALIZER_DEFAULT_MID2_WIDTH =          (1.0f);

enum AL_EQUALIZER_MIN_HIGH_GAIN =               (0.126f);
enum AL_EQUALIZER_MAX_HIGH_GAIN =               (7.943f);
enum AL_EQUALIZER_DEFAULT_HIGH_GAIN =           (1.0f);

enum AL_EQUALIZER_MIN_HIGH_CUTOFF =             (4000.0f);
enum AL_EQUALIZER_MAX_HIGH_CUTOFF =             (16000.0f);
enum AL_EQUALIZER_DEFAULT_HIGH_CUTOFF =         (6000.0f);


/* Source parameter value ranges and defaults. */
enum AL_MIN_AIR_ABSORPTION_FACTOR =             (0.0f);
enum AL_MAX_AIR_ABSORPTION_FACTOR =             (10.0f);
enum AL_DEFAULT_AIR_ABSORPTION_FACTOR =         (0.0f);

enum AL_MIN_ROOM_ROLLOFF_FACTOR =               (0.0f);
enum AL_MAX_ROOM_ROLLOFF_FACTOR =               (10.0f);
enum AL_DEFAULT_ROOM_ROLLOFF_FACTOR =           (0.0f);

enum AL_MIN_CONE_OUTER_GAINHF =                 (0.0f);
enum AL_MAX_CONE_OUTER_GAINHF =                 (1.0f);
enum AL_DEFAULT_CONE_OUTER_GAINHF =             (1.0f);

enum AL_MIN_DIRECT_FILTER_GAINHF_AUTO =         AL_FALSE;
enum AL_MAX_DIRECT_FILTER_GAINHF_AUTO =         AL_TRUE;
enum AL_DEFAULT_DIRECT_FILTER_GAINHF_AUTO =     AL_TRUE;

enum AL_MIN_AUXILIARY_SEND_FILTER_GAIN_AUTO =   AL_FALSE;
enum AL_MAX_AUXILIARY_SEND_FILTER_GAIN_AUTO =   AL_TRUE;
enum AL_DEFAULT_AUXILIARY_SEND_FILTER_GAIN_AUTO = AL_TRUE;

enum AL_MIN_AUXILIARY_SEND_FILTER_GAINHF_AUTO = AL_FALSE;
enum AL_MAX_AUXILIARY_SEND_FILTER_GAINHF_AUTO = AL_TRUE;
enum AL_DEFAULT_AUXILIARY_SEND_FILTER_GAINHF_AUTO = AL_TRUE;


/* Listener parameter value ranges and defaults. */
enum AL_MIN_METERS_PER_UNIT =                   float.min_normal;
enum AL_MAX_METERS_PER_UNIT =                   float.max;
enum AL_DEFAULT_METERS_PER_UNIT =               (1.0f);