module directx.x3daudio;

version(Windows):
version(X3DAudio):

import directx.win32;

// test if type defined
static if ( !__traits(compiles, D3DVECTOR.sizeof) )
{
	alias D3DVECTOR = float[3];
}

// speaker geometry configuration flags, specifies assignment of channels to speaker positions, defined as per WAVEFORMATEXTENSIBLE.dwChannelMask
alias _SPEAKER_POSITIONS_ = int;
enum : _SPEAKER_POSITIONS_
{
    SPEAKER_FRONT_LEFT            = 0x00000001,
    SPEAKER_FRONT_RIGHT           = 0x00000002,
    SPEAKER_FRONT_CENTER          = 0x00000004,
    SPEAKER_LOW_FREQUENCY         = 0x00000008,
    SPEAKER_BACK_LEFT             = 0x00000010,
    SPEAKER_BACK_RIGHT            = 0x00000020,
    SPEAKER_FRONT_LEFT_OF_CENTER  = 0x00000040,
    SPEAKER_FRONT_RIGHT_OF_CENTER = 0x00000080,
    SPEAKER_BACK_CENTER           = 0x00000100,
    SPEAKER_SIDE_LEFT             = 0x00000200,
    SPEAKER_SIDE_RIGHT            = 0x00000400,
    SPEAKER_TOP_CENTER            = 0x00000800,
    SPEAKER_TOP_FRONT_LEFT        = 0x00001000,
    SPEAKER_TOP_FRONT_CENTER      = 0x00002000,
    SPEAKER_TOP_FRONT_RIGHT       = 0x00004000,
    SPEAKER_TOP_BACK_LEFT         = 0x00008000,
    SPEAKER_TOP_BACK_CENTER       = 0x00010000,
    SPEAKER_TOP_BACK_RIGHT        = 0x00020000,
    SPEAKER_RESERVED              = 0x7FFC0000, // bit mask locations reserved for future use
    SPEAKER_ALL                   = 0x80000000, // used to specify that any possible permutation of speaker configurations
}

// standard speaker geometry configurations, used with X3DAudioInitialize
enum
{
    SPEAKER_MONO             = SPEAKER_FRONT_CENTER,
    SPEAKER_STEREO           = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT),
    SPEAKER_2POINT1          = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_LOW_FREQUENCY),
    SPEAKER_SURROUND         = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_FRONT_CENTER | SPEAKER_BACK_CENTER),
    SPEAKER_QUAD             = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_BACK_LEFT | SPEAKER_BACK_RIGHT),
    SPEAKER_4POINT1          = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_LOW_FREQUENCY | SPEAKER_BACK_LEFT | SPEAKER_BACK_RIGHT),
    SPEAKER_5POINT1          = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_FRONT_CENTER | SPEAKER_LOW_FREQUENCY | SPEAKER_BACK_LEFT | SPEAKER_BACK_RIGHT),
    SPEAKER_7POINT1          = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_FRONT_CENTER | SPEAKER_LOW_FREQUENCY | SPEAKER_BACK_LEFT | SPEAKER_BACK_RIGHT | SPEAKER_FRONT_LEFT_OF_CENTER | SPEAKER_FRONT_RIGHT_OF_CENTER),
    SPEAKER_5POINT1_SURROUND = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_FRONT_CENTER | SPEAKER_LOW_FREQUENCY | SPEAKER_SIDE_LEFT  | SPEAKER_SIDE_RIGHT),
    SPEAKER_7POINT1_SURROUND = (SPEAKER_FRONT_LEFT | SPEAKER_FRONT_RIGHT | SPEAKER_FRONT_CENTER | SPEAKER_LOW_FREQUENCY | SPEAKER_BACK_LEFT | SPEAKER_BACK_RIGHT | SPEAKER_SIDE_LEFT  | SPEAKER_SIDE_RIGHT),
}

// Xbox360 speaker geometry configuration, used with X3DAudioInitialize
version(XBOX)
	alias SPEAKER_XBOX = SPEAKER_5POINT1;



// size of instance handle in bytes
enum X3DAUDIO_HANDLE_BYTESIZE = 20;

// float math constants
enum X3DAUDIO_PI  = 3.141592654f;
enum X3DAUDIO_2PI = 6.283185307f;

// speed of sound in meters per second for dry air at approximately 20C, used with X3DAudioInitialize
enum X3DAUDIO_SPEED_OF_SOUND = 343.5f;

// calculation control flags, used with X3DAudioCalculate
enum {
    X3DAUDIO_CALCULATE_MATRIX          = 0x00000001, // enable matrix coefficient table calculation
    X3DAUDIO_CALCULATE_DELAY           = 0x00000002, // enable delay time array calculation (stereo final mix only)
    X3DAUDIO_CALCULATE_LPF_DIRECT      = 0x00000004, // enable LPF direct-path coefficient calculation
    X3DAUDIO_CALCULATE_LPF_REVERB      = 0x00000008, // enable LPF reverb-path coefficient calculation
    X3DAUDIO_CALCULATE_REVERB          = 0x00000010, // enable reverb send level calculation
    X3DAUDIO_CALCULATE_DOPPLER         = 0x00000020, // enable doppler shift factor calculation
    X3DAUDIO_CALCULATE_EMITTER_ANGLE   = 0x00000040, // enable emitter-to-listener interior angle calculation

    X3DAUDIO_CALCULATE_ZEROCENTER      = 0x00010000, // do not position to front center speaker, signal positioned to remaining speakers instead, front center destination channel will be zero in returned matrix coefficient table, valid only for matrix calculations with final mix formats that have a front center channel
    X3DAUDIO_CALCULATE_REDIRECT_TO_LFE = 0x00020000, // apply equal mix of all source channels to LFE destination channel, valid only for matrix calculations with sources that have no LFE channel and final mix formats that have an LFE channel
}


//--------------<D-A-T-A---T-Y-P-E-S>---------------------------------------//
align(1): // set packing alignment to ensure consistency across arbitrary build environments


// primitive types
alias FLOAT32 = float; // 32-bit IEEE float
alias X3DAUDIO_VECTOR = D3DVECTOR; // float 3D vector

// instance handle of precalculated constants
alias BYTE[X3DAUDIO_HANDLE_BYTESIZE] X3DAUDIO_HANDLE;


// Distance curve point:
// Defines a DSP setting at a given normalized distance.
struct X3DAUDIO_DISTANCE_CURVE_POINT
{
    FLOAT32 Distance;   // normalized distance, must be within [0.0f, 1.0f]
    FLOAT32 DSPSetting; // DSP setting
}
alias LPX3DAUDIO_DISTANCE_CURVE_POINT = X3DAUDIO_DISTANCE_CURVE_POINT*;

// Distance curve:
// A piecewise curve made up of linear segments used to
// define DSP behaviour with respect to normalized distance.
//
// Note that curve point distances are normalized within [0.0f, 1.0f].
// X3DAUDIO_EMITTER.CurveDistanceScaler must be used to scale the
// normalized distances to user-defined world units.
// For distances beyond CurveDistanceScaler * 1.0f,
// pPoints[PointCount-1].DSPSetting is used as the DSP setting.
//
// All distance curve spans must be such that:
//      pPoints[k-1].DSPSetting + ((pPoints[k].DSPSetting-pPoints[k-1].DSPSetting) / (pPoints[k].Distance-pPoints[k-1].Distance)) * (pPoints[k].Distance-pPoints[k-1].Distance) != NAN or infinite values
// For all points in the distance curve where 1 <= k < PointCount.
struct X3DAUDIO_DISTANCE_CURVE
{
    X3DAUDIO_DISTANCE_CURVE_POINT* pPoints;    // distance curve point array, must have at least PointCount elements with no duplicates and be sorted in ascending order with respect to Distance
    UINT32                         PointCount; // number of distance curve points, must be >= 2 as all distance curves must have at least two endpoints, defining DSP settings at 0.0f and 1.0f normalized distance
}
alias LPX3DAUDIO_DISTANCE_CURVE = X3DAUDIO_DISTANCE_CURVE*;
enum : X3DAUDIO_DISTANCE_CURVE_POINT[2]
{
	X3DAudioDefault_LinearCurvePoints = [ X3DAUDIO_DISTANCE_CURVE_POINT(0.0f, 1.0f), X3DAUDIO_DISTANCE_CURVE_POINT(1.0f, 0.0f) ],
}
enum : X3DAUDIO_DISTANCE_CURVE
{
	X3DAudioDefault_LinearCurve = X3DAUDIO_DISTANCE_CURVE( X3DAudioDefault_LinearCurvePoints.ptr, 2 ),
}

// Cone:
// Specifies directionality for a listener or single-channel emitter by
// modifying DSP behaviour with respect to its front orientation.
// This is modeled using two sound cones: an inner cone and an outer cone.
// On/within the inner cone, DSP settings are scaled by the inner values.
// On/beyond the outer cone, DSP settings are scaled by the outer values.
// If on both the cones, DSP settings are scaled by the inner values only.
// Between the two cones, the scaler is linearly interpolated between the
// inner and outer values.  Set both cone angles to 0 or X3DAUDIO_2PI for
// omnidirectionality using only the outer or inner values respectively.
struct X3DAUDIO_CONE
{
    FLOAT32 InnerAngle; // inner cone angle in radians, must be within [0.0f, X3DAUDIO_2PI]
    FLOAT32 OuterAngle; // outer cone angle in radians, must be within [InnerAngle, X3DAUDIO_2PI]

    FLOAT32 InnerVolume; // volume level scaler on/within inner cone, used only for matrix calculations, must be within [0.0f, 2.0f] when used
    FLOAT32 OuterVolume; // volume level scaler on/beyond outer cone, used only for matrix calculations, must be within [0.0f, 2.0f] when used
    FLOAT32 InnerLPF;    // LPF (both direct and reverb paths) coefficient subtrahend on/within inner cone, used only for LPF (both direct and reverb paths) calculations, must be within [0.0f, 1.0f] when used
    FLOAT32 OuterLPF;    // LPF (both direct and reverb paths) coefficient subtrahend on/beyond outer cone, used only for LPF (both direct and reverb paths) calculations, must be within [0.0f, 1.0f] when used
    FLOAT32 InnerReverb; // reverb send level scaler on/within inner cone, used only for reverb calculations, must be within [0.0f, 2.0f] when used
    FLOAT32 OuterReverb; // reverb send level scaler on/beyond outer cone, used only for reverb calculations, must be within [0.0f, 2.0f] when used
}
alias LPX3DAUDIO_CONE = X3DAUDIO_CONE*;
enum : X3DAUDIO_CONE
{
	X3DAudioDefault_DirectionalCone = X3DAUDIO_CONE( X3DAUDIO_PI/2, X3DAUDIO_PI, 1.0f, 0.708f, 0.0f, 0.25f, 0.708f, 1.0f ),
}


// Listener:
// Defines a point of 3D audio reception.
//
// The cone is directed by the listener's front orientation.
struct X3DAUDIO_LISTENER
{
    X3DAUDIO_VECTOR OrientFront; // orientation of front direction, used only for matrix and delay calculations or listeners with cones for matrix, LPF (both direct and reverb paths), and reverb calculations, must be normalized when used
    X3DAUDIO_VECTOR OrientTop;   // orientation of top direction, used only for matrix and delay calculations, must be orthonormal with OrientFront when used

    X3DAUDIO_VECTOR Position; // position in user-defined world units, does not affect Velocity
    X3DAUDIO_VECTOR Velocity; // velocity vector in user-defined world units/second, used only for doppler calculations, does not affect Position

    X3DAUDIO_CONE* pCone; // sound cone, used only for matrix, LPF (both direct and reverb paths), and reverb calculations, NULL specifies omnidirectionality
} 
alias LPX3DAUDIO_LISTENER = X3DAUDIO_LISTENER*;

// Emitter:
// Defines a 3D audio source, divided into two classifications:
//
// Single-point -- For use with single-channel sounds.
//                 Positioned at the emitter base, i.e. the channel radius
//                 and azimuth are ignored if the number of channels == 1.
//
//                 May be omnidirectional or directional using a cone.
//                 The cone originates from the emitter base position,
//                 and is directed by the emitter's front orientation.
//
// Multi-point  -- For use with multi-channel sounds.
//                 Each non-LFE channel is positioned using an
//                 azimuth along the channel radius with respect to the
//                 front orientation vector in the plane orthogonal to the
//                 top orientation vector.  An azimuth of X3DAUDIO_2PI
//                 specifies a channel is an LFE.  Such channels are
//                 positioned at the emitter base and are calculated
//                 with respect to pLFECurve only, never pVolumeCurve.
//
//                 Multi-point emitters are always omnidirectional,
//                 i.e. the cone is ignored if the number of channels > 1.
//
// Note that many properties are shared among all channel points,
// locking certain behaviour with respect to the emitter base position.
// For example, doppler shift is always calculated with respect to the
// emitter base position and so is constant for all its channel points.
// Distance curve calculations are also with respect to the emitter base
// position, with the curves being calculated independently of each other.
// For instance, volume and LFE calculations do not affect one another.
struct X3DAUDIO_EMITTER
{
    X3DAUDIO_CONE* pCone; // sound cone, used only with single-channel emitters for matrix, LPF (both direct and reverb paths), and reverb calculations, NULL specifies omnidirectionality
    X3DAUDIO_VECTOR OrientFront; // orientation of front direction, used only for emitter angle calculations or with multi-channel emitters for matrix calculations or single-channel emitters with cones for matrix, LPF (both direct and reverb paths), and reverb calculations, must be normalized when used
    X3DAUDIO_VECTOR OrientTop;   // orientation of top direction, used only with multi-channel emitters for matrix calculations, must be orthonormal with OrientFront when used

    X3DAUDIO_VECTOR Position; // position in user-defined world units, does not affect Velocity
    X3DAUDIO_VECTOR Velocity; // velocity vector in user-defined world units/second, used only for doppler calculations, does not affect Position

    FLOAT32 InnerRadius;      // inner radius, must be within [0.0f, FLT_MAX]
    FLOAT32 InnerRadiusAngle; // inner radius angle, must be within [0.0f, X3DAUDIO_PI/4.0)

    UINT32 ChannelCount;       // number of sound channels, must be > 0
    FLOAT32 ChannelRadius;     // channel radius, used only with multi-channel emitters for matrix calculations, must be >= 0.0f when used
    FLOAT32* pChannelAzimuths; // channel azimuth array, used only with multi-channel emitters for matrix calculations, contains positions of each channel expressed in radians along the channel radius with respect to the front orientation vector in the plane orthogonal to the top orientation vector, or X3DAUDIO_2PI to specify an LFE channel, must have at least ChannelCount elements, all within [0.0f, X3DAUDIO_2PI] when used

    X3DAUDIO_DISTANCE_CURVE* pVolumeCurve;    // volume level distance curve, used only for matrix calculations, NULL specifies a default curve that conforms to the inverse square law, calculated in user-defined world units with distances <= CurveDistanceScaler clamped to no attenuation
    X3DAUDIO_DISTANCE_CURVE* pLFECurve;       // LFE level distance curve, used only for matrix calculations, NULL specifies a default curve that conforms to the inverse square law, calculated in user-defined world units with distances <= CurveDistanceScaler clamped to no attenuation
    X3DAUDIO_DISTANCE_CURVE* pLPFDirectCurve; // LPF direct-path coefficient distance curve, used only for LPF direct-path calculations, NULL specifies the default curve: [0.0f,1.0f], [1.0f,0.75f]
    X3DAUDIO_DISTANCE_CURVE* pLPFReverbCurve; // LPF reverb-path coefficient distance curve, used only for LPF reverb-path calculations, NULL specifies the default curve: [0.0f,0.75f], [1.0f,0.75f]
    X3DAUDIO_DISTANCE_CURVE* pReverbCurve;    // reverb send level distance curve, used only for reverb calculations, NULL specifies the default curve: [0.0f,1.0f], [1.0f,0.0f]

    FLOAT32 CurveDistanceScaler; // curve distance scaler, used to scale normalized distance curves to user-defined world units and/or exaggerate their effect, used only for matrix, LPF (both direct and reverb paths), and reverb calculations, must be within [FLT_MIN, FLT_MAX] when used
    FLOAT32 DopplerScaler;       // doppler shift scaler, used to exaggerate doppler shift effect, used only for doppler calculations, must be within [0.0f, FLT_MAX] when used
}
alias LPX3DAUDIO_EMITTER = X3DAUDIO_EMITTER*;


// DSP settings:
// Receives results from a call to X3DAudioCalculate to be sent
// to the low-level audio rendering API for 3D signal processing.
//
// The user is responsible for allocating the matrix coefficient table,
// delay time array, and initializing the channel counts when used.
struct X3DAUDIO_DSP_SETTINGS
{
    FLOAT32* pMatrixCoefficients; // [inout] matrix coefficient table, receives an array representing the volume level used to send from source channel S to destination channel D, stored as pMatrixCoefficients[SrcChannelCount * D + S], must have at least SrcChannelCount*DstChannelCount elements
    FLOAT32* pDelayTimes;         // [inout] delay time array, receives delays for each destination channel in milliseconds, must have at least DstChannelCount elements (stereo final mix only)
    UINT32 SrcChannelCount;       // [in] number of source channels, must equal number of channels in respective emitter
    UINT32 DstChannelCount;       // [in] number of destination channels, must equal number of channels of the final mix

    FLOAT32 LPFDirectCoefficient; // [out] LPF direct-path coefficient
    FLOAT32 LPFReverbCoefficient; // [out] LPF reverb-path coefficient
    FLOAT32 ReverbLevel; // [out] reverb send level
    FLOAT32 DopplerFactor; // [out] doppler shift factor, scales resampler ratio for doppler shift effect, where the effective frequency = DopplerFactor * original frequency
    FLOAT32 EmitterToListenerAngle; // [out] emitter-to-listener interior angle, expressed in radians with respect to the emitter's front orientation

    FLOAT32 EmitterToListenerDistance; // [out] distance in user-defined world units from the emitter base to listener position, always calculated
    FLOAT32 EmitterVelocityComponent; // [out] component of emitter velocity vector projected onto emitter->listener vector in user-defined world units/second, calculated only for doppler
    FLOAT32 ListenerVelocityComponent; // [out] component of listener velocity vector projected onto emitter->listener vector in user-defined world units/second, calculated only for doppler
}
alias LPX3DAUDIO_DSP_SETTINGS = X3DAUDIO_DSP_SETTINGS*;



//--------------<F-U-N-C-T-I-O-N-S>-----------------------------------------//
// initializes instance handle
extern(Windows) void X3DAudioInitialize (UINT32 SpeakerChannelMask, FLOAT32 SpeedOfSound, /*out*/ X3DAUDIO_HANDLE* Instance);

// calculates DSP settings with respect to 3D parameters
extern(Windows) void X3DAudioCalculate (const(X3DAUDIO_HANDLE) Instance, const(X3DAUDIO_LISTENER)* pListener, const(X3DAUDIO_EMITTER)* pEmitter, UINT32 Flags, /*inout*/X3DAUDIO_DSP_SETTINGS* pDSPSettings);

//---------------------------------<-EOF->----------------------------------//
