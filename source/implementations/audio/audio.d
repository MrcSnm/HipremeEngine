module implementations.audio.audio;

import bindbc.openal;
import bindbc.sdl.mixer;
import implementations.audio.audiobase;
import error.handler;

struct AudioConfig
{
    size_t sampleRate;
    int sampleType;
    size_t channels;
    size_t bufferSize;
    /**
    *   Returns a default audio configuration for 2D
    */
    AudioConfig defaultConfig()
    {
        AudioConfig cfg;
        cfg.sampleRate = 44_100U;
        cfg.format = MIX_DEFAULT_FORMAT;
        cfg.channels = 2U;
        cfg.bufferSize = 2048;
    }
}


class Audio : AudioBase
{

    public static bool initialize(bool is3D = true)
    {
        Audio.is3D = is3D;
        if(is3D)
        {
            ErrorHandler.startListeningForErrors("HipremeAudio3D initialization");
            ALSupport sup = loadOpenAL();
            if(ErrorHandler.assertErrorMessage(sup != ALSupport.al11, "Error loading OpenAL", "No OpenAL support found"))
            {
                if(sup == ALSupport.badLibrary)
                    ErrorHandler.showErrorMessage("Bad OpenAL Support", "Unknown version of OpenAL");
                else
                    ErrorHandler.showErrorMessage("OpenAL not found", "Could not find OpenAL library");
            }
        }
        else
        {
            ErrorHandler.startListeningForErrors("HipremeAudio2D initialization");
            SDLMixerSupport sup = loadSDLMixer();
            if(sup == SDLMixerSupport.badLibrary)
                ErrorHandler.showErrorMessage("Bad SDL_Mixer support", "Unknown version of SDL_Mixer");
            else if(sup == SDLMixerSupport.noLibrary)
                ErrorHandler.showErrorMessage("No SDL_Mixer found", "Could not find any SDL_Mixer version");

            // ErrorHandler.assertErrorMessage(Mix_OpenAudio(44100));
        }

        return ErrorHandler.stopListeningForErrors();
    }

    public static void setDefaultMusicExtension(string ext)
    {
        defaultMusicExt = "."~ext;
    }
    public static void setDefaultSoundEffectExtension(string ext)
    {
        defaultSfxExt = "."~ext;
    }
    public static bool loadMusic(string musicName, string extension = "", bool forceReload = false)
    {
        return false;
    }

    

    protected static string defaultSfxExt;
    protected static string defaultMusicExt;

    private static bool is3D;
    
}
