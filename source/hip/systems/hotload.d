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
    string tempDll;
    string tempPdb;
    this(string path, void delegate (void* libPointer) onDllLoad)
    {
        ErrorHandler.assertExit(path != null, "DLL path should not be null:
Call `dub -c script -- path/to/project` dub -c script requires that argument.");

        import hip.util.path;
        import hip.util.file;

        path = absolutePath(path, getcwd).normalizePath;
        if(HipFS.absoluteExists(path) && HipFS.absoluteIsDir(path))
            path = joinPath(path, path.filenameNoExt);
        if(!dynamicLibraryIsLibNameValid(path))
            path = dynamicLibraryGetLibName(path);
        trueLibPath = path;
        this.onDllLoad = onDllLoad;
        load(path);
    }
    protected bool load(string path)
    {
        if(!HipFS.absoluteExists(path))
        {
            import hip.console.log;
            logln("Path '", path, "' does not exists while trying to find for a HotloadableDLL");
            return false;
        }
        //Create dll_hiptempdll
        tempDll = getTempName(path);
        copy(path, tempDll);

        // version(Windows)
        // {{
        //     import std.process:executeShell;
        //     import hip.util.path;
        //     string tempDirectory = joinPath(path.dirName, "temp");
        //     mkdirRecurse(tempDirectory);
            
        //     string thePdb = path.extension("pdb");
        //     tempPdb = getTempName(thePdb);
        //     if(exists(thePdb))
        //     {
        //         copy(thePdb, joinPath(tempDirectory, thePdb.baseName));
        //         rename(thePdb, tempPdb);
        //     }

        // }}


        loglnInfo("Loading dll ", path);
        lib = dynamicLibraryLoad(tempDll);
        if(onDllLoad && lib != null)
            onDllLoad(lib);
        else if(lib == null)
            loglnError("Could not load dll ", path);
        return lib != null;
    }
    /** 
     * 
     * Params:
     *   path = File path
     * Returns: filePath.(ext)_hiptempdll
     */
    static string getTempName(string path)
    {
        import hip.util.string;
        string d = dirName(path);
        string n = baseName(path);
        string ext = extension(n);
        
        int ind = lastIndexOf(n, "_hiptemp");
        if(ind != -1)
            return path;
        return joinPath(d, n[0..$-(ext.length+1)]~"_hiptemp."~ext);
    }

    void reload()
    {
        if(lib != null)
        {
            dynamicLibraryRelease(lib);
            lib = null;
        }
        load(trueLibPath);
    }

    void dispose()
    {
        import hip.error.handler;
        if(lib != null)
        {
            if(!dynamicLibraryRelease(lib))
                return ErrorHandler.showErrorMessage("Could not unload the dll ", tempDll);
            
            foreach(remFile; [tempDll, tempPdb]) 
            if(remFile && !HipFS.absoluteRemove(remFile))
            {
                ErrorHandler.showErrorMessage("Could not remove ", remFile);
            }
        }
    }
}

private void copy(string input, string output)
{
    import hip.filesystem.hipfs;
    void[] data;
    if(!HipFS.absoluteRead(input, data))
        throw new Error("Could not read input file "~input);
    if(!HipFS.absoluteWrite(output, data))
        throw new Error("Could not copy from "~input~" to "~output);

}