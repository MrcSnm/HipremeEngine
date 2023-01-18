

function initializeWebaudioContext()
{
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    /**
     * @type {AudioContext}
     */
    const audioContext = new AudioContext();

    const addObject = WasmUtils.addObject;
    const _objects = WasmUtils._objects;
    const removeObject = WasmUtils.removeObject;


    class AudioObject
    {
        /**
         * 
         * @param {HTMLMediaElement} htmlMediaObject 
         */
        constructor(htmlMediaObject)
        {
            this.track = audioContext.createMediaElementSource(htmlMediaObject);
            this.gainNode = audioContext.createGain();
            this.panNode = audioContext.createStereoPanner();

            this.track.connect(this.gainNode).connect(this.panNode).connect(audioContext.destination);
        }
        setPlaying(playing)
        {
            if(playing)
                this.track.mediaElement.play()
            else
                this.track.mediaElement.pause();

        }
        setGain(gain)
        {
            this.gainNode.gain.value = gain;
        }
        setPan(pan)
        {
            if(pan < -1 || pan > 1) throw new RangeError(`Panning out of range '${pan}', valid range is [-1..1]`);
            this.panNode.pan.value = pan;
        }
    }

    return {
        WasmCreateAudio()
        {
            return addObject(new AudioObject(null));
        },

        WasmPlayAudio(audio){_objects[audio].play();},
        WasmPauseAudio(audio){_objects[audio].pause();},
    }

}