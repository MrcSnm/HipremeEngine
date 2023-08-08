# HipAudio

Able to use backends such as:

* SDL
* OpenAL
* OpenSL ES

HipAudio tries to mantain an intercompatible API for you being able to ship your game in every platform mantaining the same behaviour.

## Audio Engine initialization

***

For using the HipAudio API, you must first import it by doing the following import: `import hipaudio.audio`.

As the greater modules, it needs to be initialized by calling `HipAudio.initialize` and passing the target implementation. That is usually done automatically based on the target platform.

## Loading Audio Assets

***

After that, for loading any Audio asset, it is possible to do it by calling `HipAudio.load`, which will load the entire file and decode it in a blocking fashion.

If the decoding must be postponed and done non blocking, it must be called `HipAudio.loadStreamed`, that function will load the entire file and do one decode step. Its size is based on the argument `uint chunkSize`.

As every load function present in HipremeEngine, it accepts loading from memory, for not needing any file system access.

`HipAudio.load` returns an `HipAudioBuffer`, which is used as the buffer for the `HipAudioSource`.

`HipAudioSource` is never instantiated directly. For getting an instance, it must be called `HipAudio.getSource`, which receives `(bool isStreamed, HipAudioBuffer buffer)`.

## Attaching Buffer to Source

***

Streamed audio sources **can't** be created without a buffer, as they're tightly bound to each other. If you wish to create the source before the buffer, it can be done by the following code:

```d
HipAudioSource src = HipAudio.getSource(false);
HipAudioBuffer buf = HipAudio.load("some/audio/asset.mp3", HipAudioTypes.SFX);
src.setBuffer(buf);
```

## Managing Streaming

***

For updating the decoding status(only for the streamed audio buffers), the decoding part is controlled from the HipAudioSource, by calling the function `pullStreamData`. This function will do a decode step and fill the source buffer with the newly decoded data.
