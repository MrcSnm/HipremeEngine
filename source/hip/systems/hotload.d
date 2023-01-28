/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.systems.hotload;

version(Load_DScript):
import std.file : copy;
import hip.filesystem.hipfs;
import hip.util.system;
import hip.util.path;
import hip.console.log;
import hip.error.handler;

class HotloadableDLL
{
    void* lib;

    immutable string trueLibPath;
    void delegate (void* libPointer) onDllLoad;
    string tempPath;
    this(string path, void delegate (void* libPointer) onDllLoad)
    {
        ErrorHandler.assertExit(path != null, "DLL path should not be null:
Call `dub -c script -- path/to/project` dub -c script requires that argument.");

        if(HipFS.absoluteIsDir(path))
            path = joinPath(path, path.filenameNoExt);

        
        if(!dynamicLibraryIsLibNameValid(path))
            path = dynamicLibraryGetLibName(path);
        trueLibPath = path;
        this.onDllLoad = onDllLoad;
        load(path);
    }
    protected bool load(string path)
    {
        import std.file;
        if(!HipFS.absoluteExists(path))
        {
            import hip.console.log;
            logln("Does not exists ", path);
            return false;
        }
        tempPath = getTempName(path);
        copy(path, tempPath);

        loglnInfo("Loading dll ", path);
        lib = dynamicLibraryLoad(tempPath);
        if(onDllLoad && lib != null)
            onDllLoad(lib);
        else if(lib == null)
            loglnError("Could not load dll ", path);
        return lib != null;
    }

    string getTempName(string path)
    {
        string d = dirName(path);
        string n = baseName(path);
        string ext = extension(path);
        return joinPath(d, n~"_hiptemp"~ext);
    }
    void reload()
    {
        if(lib != null)
            dynamicLibraryRelease(lib);
        load(trueLibPath);
        if(onDllLoad)
            onDllLoad(lib);
    }

    void dispose()
    {
        if(lib != null)
        {
            if(!dynamicLibraryRelease(lib))
            {
                import hip.error.handler;
                ErrorHandler.showErrorMessage("Could not unload the dll ", tempPath);
                return;
            }
            if(tempPath)
            {
                if(!HipFS.absoluteRemove(tempPath))
                {
                    import hip.error.handler;
                    ErrorHandler.showErrorMessage("Could not remove ", tempPath);
                }
            }
        }
    }
}