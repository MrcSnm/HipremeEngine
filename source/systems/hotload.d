/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module systems.hotload;
import std.file : copy;
import data.hipfs;
import util.system;
import util.path;

class HotloadableDLL
{
    void* lib;

    immutable string trueLibPath;
    void delegate (void* libPointer) onDllLoad;
    string tempPath;
    this(string path, void delegate (void* libPointer) onDllLoad)
    {
        assert(path, "DLL path should not be null");
        if(!dynamicLibraryIsLibNameValid(path))
            path = dynamicLibraryGetLibName(path);
        trueLibPath = path;
        this.onDllLoad = onDllLoad;
        load(path);
    }
    protected bool load(string path)
    {
        if(!HipFS.exists(path))
            return false;
        tempPath = getTempName(path);
        copy(path, tempPath);
        lib = dynamicLibraryLoad(tempPath);
        if(onDllLoad && lib != null)
            onDllLoad(lib);
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
            dynamicLibraryRelease(lib);
        if(tempPath)
            HipFS.remove(tempPath);
    }
}