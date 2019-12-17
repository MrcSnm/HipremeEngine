module sdl.loader;
public:
    import bindbc.sdl;
    import bindbc.sdl.image;
    import bindbc.sdl.mixer;
    import bindbc.sdl.ttf;
    import std.system;
private 
{
    import std.stdio;
    import data.image;
    import error.handler;
    import std.conv : to;
    import global.consts;
}

version(linux)
{
    immutable string CURRENT_SDL_VERSION = "SDL_2_0_8";
}
version(Windows)
{
    immutable string CURRENT_SDL_VERSION = "SDL_2_0_10";
}

/** 
 * This function will load SDL Dependencies
 * Returns: HAS_ANY_ERROR_HAPPENNED
 */
bool loadSDLLibs()
{
    SDLSupport ret = loadSDL();
    ErrorHandler.startListeningForErrors("Loading SDL Libraries");
    string errorHeader;
    string errorMessage; 
    string filetype;
    switch(os)
    {
        case os.win32:
        case os.win64:
            errorHeader = "Missing DLL";
            errorMessage = "Missing DLL 'SDL2.dll'\nVersion ";
            filetype = "DLL";
            break;
        default:
            errorHeader = "Missing Library";
            errorMessage = "Library 'libsdl2.so'\nVersion ";
            filetype = "Library";
    }
    if(ret != sdlSupport)
    {
        if(ret == SDLSupport.noLibrary)
            ErrorHandler.showErrorMessage(errorHeader, errorMessage ~ CURRENT_SDL_VERSION);
        else if(ret == SDLSupport.badLibrary)
            ErrorHandler.showErrorMessage("Lower " ~ filetype ~ " version ", "Your " ~ filetype ~ " version is lower than the version expected " ~ CURRENT_SDL_VERSION);
    }
    ErrorHandler.assertErrorMessage(loadSDLImage() != sdlImageSupport, "Could not load library", "SDL Image library hasn't been able to load");
    ErrorHandler.assertErrorMessage(loadSDLMixer() != sdlMixerSupport, "Could not load library", "SDL Mixer library hasn't been able to load");
    ErrorHandler.assertErrorMessage(loadSDLTTF() != sdlTTFSupport, "Could not load library", "SDL TTF library hasn't been able to load");
    return ErrorHandler.stopListeningForErrors();
}

/** 
 * 
 * Params:
 *   window = A window reference to start
 *   surface = A surface reference to start
 * Returns: HAS_ANY_ERROR_HAPPENNED
 */
bool initializeWindow(SDL_Window** window, SDL_Surface** surface)
{
    ErrorHandler.startListeningForErrors("SDL Initialization");
	if(!ErrorHandler.assertErrorMessage(SDL_Init(SDL_INIT_VIDEO) < 0, "SDL Initialization",  "SDL could not initialize\nSDL Error: " ~ to!string(SDL_GetError())))
	{
		int winPos = SDL_WINDOWPOS_UNDEFINED;
		*window = SDL_CreateWindow(cast(char*)ENGINE_NAME, winPos, winPos, SCREEN_WIDTH, SCREEN_HEIGHT, SDL_WindowFlags.SDL_WINDOW_SHOWN | SDL_WindowFlags.SDL_WINDOW_OPENGL);
		ErrorHandler.assertErrorMessage(window == null, "Window creation", "Window could not be opened\nSDL_Error: " ~ to!string(SDL_GetError()));
	}

	*surface = SDL_GetWindowSurface(*window);

    return ErrorHandler.stopListeningForErrors();
}

/** 
 * This function will destroy SDL and dispose every resource
 * Params:
 *   window = Window to destroy
 */
void exitEngine(SDL_Window** window)
{
    ResourceManager.disposeResources();
    SDL_DestroyWindow(*window);
    *window = null;
    SDL_Quit();
}