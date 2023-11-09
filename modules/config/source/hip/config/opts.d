/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
/**
* This module is used for mantaining global options related to the engine
*/ 
module hip.config.opts;

/**
*   Use that for mainly mantaining engine related debug things
*/
enum HIP_DEBUG = true;

/** 
 * Will call HipRenderer.exitOnError for each glCall
 */
enum HIP_DEBUG_GL = true;

/** 
 * Will call HipRenderer.exitOnError for each glCall.
 *	WebGL has a bizarre glGetError in terms of performance, it can degradate it alone. This will possibily never be enabled.
 */
enum HIP_DEBUG_WEBGL = false;

/**
*   Used for disabling every engine log function
*/
enum HE_NO_LOG = false;

/**
*	Used to track calls to find where the print call is located.
*/
enum HIP_TRACK_HIPLOG = false;

/**
*   Mantain only error related logging
*/
enum HE_ERR_ONLY = false; 

///Unused yet?
enum HIP_OPTIMIZE = false;

///Default time in millis to restart the click count on Mouse and Keyboard
enum HIP_DEFAULT_TIME_UNTIL_CLICK_COUNT_RESTART = 400;

///////////////////////////////// Default Asset Files /////////////////////////////////
enum HIP_ASSETMANAGER_WORKER_POOL = 8;
enum HIP_DEFAULT_FONT = "defaults/fonts/WarsawGothic-BnBV.otf";
enum HIP_DEFAULT_FONT_SIZE = 32;
enum HIP_DEFAULT_TEXTURE = "defaults/graphics/sprites/default.png";

/**
*	Will use OpenSL ES optimal sample rate for output and buffer size multiple. 
*/
enum HIP_OPENSLES_OPTIMAL = true;

/**
*	Beware that a lot of effects are disabled on Android when using low latency, aka Fast Mixer.
*	So, it is better to have a deep thought before allowing its low latency.
*	You will also lose sample rate conversion, so it is a lot problematic. Until there's a hand made sample
*	converter, it will be almost impossible to use.
*
*	The following interfaces are unsupported on the fast mixer:
*
*   - SL_IID_BASSBOOST
*
*   - SL_IID_EFFECTSEND
*
*   - SL_IID_ENVIRONMENTALREVERB
*
*   - SL_IID_EQUALIZER
*
*   - SL_IID_PLAYBACKRATE
*
*   - SL_IID_PRESETREVERB
*
*   - SL_IID_VIRTUALIZER
*
*   - SL_IID_ANDROIDEFFECT
*
*   - SL_IID_ANDROIDEFFECTSEND
*
*/
enum HIP_OPENSLES_FAST_MIXER = false;



static if(HIP_OPENSLES_FAST_MIXER)
{
	static assert(HIP_OPENSLES_OPTIMAL, "Can't use OpenSL ES fast mixer without using its optimal 
buffer size and sample rate");
}

extern(C) char* getDebugInfo(){return cast(char*)"Debug Info?".ptr;}