/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.config.audio;

version(Android) enum HasOpenSLES = true;
else enum HasOpenSLES = false;

version(XAudio2) enum HasXAudio2 = true;
else enum HasXAudio2 = false;

version(OpenAL) enum HasOpenAL = true;
else enum HasOpenAL = false;

version(WebAssembly) enum HasWebAudio = true;
else enum HasWebAudio = false;

version(iOS) enum HasAVAudioEngine = true;
else enum HasAVAudioEngine = false;