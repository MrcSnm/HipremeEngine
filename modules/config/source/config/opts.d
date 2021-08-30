/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

/**
* This module is used for mantaining global options related to the engine
*/ 
module config.opts;

/**
*   Use that for mainly mantaining engine related debug things
*/
enum HIP_DEBUG = true;

/**
*   Used for disabling every engine log function
*/
enum HE_NO_LOG = false;

/**
*   Mantain only error related logging
*/
enum HE_ERR_ONLY = false; 

///Unused yet?
enum HIP_OPTIMIZE = false;

/**
*	Will use OpenSL ES optimal sample rate for output and buffer size multiple. 
*/
enum HIP_OPENSLES_OPTIMAL = false;

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