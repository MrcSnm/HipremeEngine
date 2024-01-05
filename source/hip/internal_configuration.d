module hip.internal_configuration;
import hip.console.console;


version(Android) enum ActivePlatform = Platforms.ANDROID;
else version(WebAssembly) enum ActivePlatform = Platforms.WASM;
else version(PSVita) enum ActivePlatform = Platforms.PSVITA;
else version(UWP) enum ActivePlatform = Platforms.UWP;
else version(AppleOS) enum ActivePlatform = Platforms.APPLEOS;
else enum ActivePlatform = Platforms.DEFAULT;


version(dll)
{
	version(WebAssembly){}
	else version(PSVita){}
	else enum ManagesMainDRuntime = true;
}
else version(AppleOS) {}
else enum HandleArguments = true;


string getFSInstallPath(string projectToLoad)
{
    version(WebAssembly) return "assets";
	else version(PSVita) return "app0:assets";
    else version(Android) { return null;}
    else version(AppleOS)
    {
        import hip.filesystem.hipfs;
        return HipFS.getResourcesPath ~ "/assets";
    }
    else version(UWP)
    {
        import std.file:getcwd;
        return getcwd()~"\\UWPResources\\";
    }
    else version(GameBuildTest)
	{
		import std.file:getcwd;
		return getcwd()~"/build/release_game/assets";
	}
    else
    {
        import std.file:getcwd;
		if(projectToLoad)
			return projectToLoad~"/assets";
        return getcwd()~"/assets";
    }
}
void function(string) getPlatformPrintFunction()
{
    version(UWP)
    {
        import hip.bind.external;
        return &uwpPrint;
    }
    else return null;
}

bool function(string path, out string msg)[] getFilesystemValidations()
{
    version(UWP)
    {
        import hip.filesystem.hipfs;
        return [(string path, out string msg)
		{
			//As the path is installed already, it should check only for absolute paths.
			if(!HipFS.absoluteExists(path))
			{
				msg = "File at path "~path~" does not exists. Did you forget to add it to the AppX Resources?";
				return false;
			}
			return true;
		}];
    }
    else return [];
}
