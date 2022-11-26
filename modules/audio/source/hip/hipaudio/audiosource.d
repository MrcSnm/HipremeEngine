/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.hipaudio.audiosource;
import hip.hipaudio.audioclip : HipAudioClip;
import hip.hipaudio.audio;
public import hip.api.audio.audiosource;

import hip.math.vector;

/** 
*   Wraps properties for the AudioPlayer. The closest graphical represetantion
*   to that would be the Material class, but for Audios.
*
*/
public class HipAudioSource : AHipAudioSource
{
    public:
    //Functions
        void attachToPosition(){}
        void attachOnDestroy(){}
        override float getProgress(){return time/length;}
        override void pullStreamData(){}
        override HipAudioBufferWrapper2* getFreeBuffer(){return null;}

        final void sendAvailableBuffer(HipAudioBuffer buffer)
        {
            (cast(HipAudioClip)clip).setBufferAvailable(buffer);
        }

        override HipAudioSource clean()
        {
            loop = false;
            isPlaying = false;
            length = 0;
            position = [0,0,0];
            clip = null;
            return this;
        }
}
