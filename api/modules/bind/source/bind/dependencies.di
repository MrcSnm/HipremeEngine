// D import file generated from 'source\bind\dependencies.d'
module bind.dependencies;
import error.handler;
import bindbc.sdl;
import bindbc.sdl.ttf;
import bindbc.sdl.image;
import bindbc.loader : SharedLib;
version (Android)
{
	immutable string CURRENT_SDL_VERSION = "SDL_2_0_12";
}
else
{
	version (Windows)
	{
		immutable string CURRENT_SDL_VERSION = "SDL_2_0_10";
	}
	else
	{
		version (linux)
		{
			immutable string CURRENT_SDL_VERSION = "SDL_2_0_8";
		}
	}
}
private void showDLLMissingError(string dllName);
private bool loadSDLDependencies();
bool loadEngineDependencies();
