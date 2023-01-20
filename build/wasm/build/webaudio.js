

function initializeWebaudioContext()
{
    const AudioContext = window.AudioContext || window.webkitAudioContext;
    /**
     * @type {AudioContext}
     */
    const audioContext = new AudioContext({latencyHint: "interactive"});

    const addObject = WasmUtils.addObject;
    const _objects = WasmUtils._objects;
    const removeObject = WasmUtils.removeObject;


    class AudioObject
    {
        /**
         * 
         * @param {HTMLMediaElement} htmlMediaObject 
         */
        constructor()
        {
            this.isPlaying = false;
            this.isLooping = false;
            this.bufferHandle = -1;
            this._reloadAudio();
        }
        _reloadAudio()
        {
            if(this.isLooping)
            {
                this.track.stop();
                this.track.loop = false;
            }
            this.track = audioContext.createBufferSource();
            this.gainNode = audioContext.createGain();
            this.panNode = audioContext.createStereoPanner();
            this.track.connect(this.gainNode).connect(this.panNode).connect(audioContext.destination);
            if(this.bufferHandle !== -1)
                this.setBufferData(this.bufferHandle);
            this.setLooping(this.isLooping);
        }
        load(sndNameLength, sndNamePtr, ptr, length, dFunction, dgFunc, delegateCtx)
        {
            const sndName = WasmUtils.fromDString(sndNameLength, sndNamePtr);
            audioContext.decodeAudioData(WasmUtils.fromDBinary(length, ptr))
                .then((buffer) =>
                {
                    // buffer.
                })
        }
        setBufferData(dataHandle)
        {
            /**@type {AudioBuffer} */
            const buffer = _objects[dataHandle];
            this.bufferHandle = dataHandle;
            if(Object.getPrototypeOf(buffer) != AudioBuffer.prototype)
                throw new Error("Invalid buffer received.");
            if(this.track.buffer !== buffer)
                this.track.buffer = buffer;
        }
        loadStreamed()
        {
            throw new Error("Unsupported yet...");
        }
        setPlaying(playing)
        {
            if(playing)
            {
                if(this.isPlaying)
                    this._reloadAudio();
                this.track.start();
            }
            else if(this.isPlaying)
                this.track.stop();
            this.isPlaying = playing;
        }
        stop()
        {
            if(this.isPlaying)
            {
                this.isPlaying = false;
                this.track.stop(0);
            }
        }
        setLooping(loop)
        {
            this.track.loop = this.isLooping = Boolean(loop);
        }
        setPlaybackRate(rate){this.track.playbackRate.value = rate;}
        setPitch(pitch)
        {
            this.track.detune.value = pitch;
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
        ///WebAudio API
            WebAudioSourceCreate()
            {
                return addObject(new AudioObject(null));
            },
            WebAudioSourceSetData(sourceHandle, bufferHandle)
            {
                const audioObject = _objects[sourceHandle];
                audioObject.setBufferData(bufferHandle);
            },
            WebAudioSourceStop(src){_objects[src].stop()},
            WebAudioSourceSetPlaying(src, playing){_objects[src].setPlaying(playing);},
            WebAudioSourceSetLooping(src, shouldLoop){_objects[src].setLooping(shouldLoop);},
            WebAudioSourceSetPitch(src, pitch){_objects[src].setPitch(pitch);},
            WebAudioSourceSetVolume(src, volume){_objects[src].setGain(volume);},
            WebAudioSourceSetPlaybackRate(src,rate){_objects[src].setPlaybackRate(rate);},

        ///

        ///DECODING
            WasmDecodeAudio(length, ptr, dFunction, dgFunc, delegateCtx)
            {
                const handle = addObject({}); //Reserves the handle.
                //Binary copy is needed as currently the binary is detached while decoding..
                audioContext.decodeAudioData(WasmUtils.copyFromDBinary(length, ptr).buffer).then((audioBuffer) =>
                {
                    _objects[handle] = audioBuffer
                    exports.__callDFunction(dFunction, WasmUtils.toDArguments(dgFunc, delegateCtx, handle));
                });
                return handle;
            },
            WasmGetClipChannels(buffer)/**@returns {size_t} */
            {
                /**@type {AudioBuffer} */
                const b = _objects[buffer];
                return b.numberOfChannels;
            },
            WasmGetClipSize(buffer) /**@returns {size_t} */
            {
                /**@type {AudioBuffer} */
                const b = _objects[buffer];
                return b.length;
            },
            WasmGetClipDuration(buffer) /**@returns {double} */
            {
                /**@type {AudioBuffer} */
                const b = _objects[buffer];
                return b.duration;
            },
            WasmGetClipSamplerate(buffer) /**@returns {float} */
            {
                /**@type {AudioBuffer} */
                const b = _objects[buffer];
                return b.sampleRate;
            },
        ///DECODING END

        WasmDisposeBuffer(buffer)
        {
            removeObject(buffer);
        },




        WasmPlayAudio(audio){_objects[audio].play();},
        WasmPauseAudio(audio){_objects[audio].pause();},
    }

}