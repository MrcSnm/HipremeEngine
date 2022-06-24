module hip.util.path;
import hip.util.string;
import hip.util.system;

version(Windows) 
    enum defaultCaseSensitivity = false;
else version(Darwin) 
    enum defaultCaseSensitivity = false;
else// version(Posix) 
    enum defaultCaseSensitivity = true;

version(Windows)
    enum pathSeparator = '\\';
else
    enum pathSeparator = '/';

string[] pathSplitter(string path)
{
    string[] ret;
    string current;
    for(uint i = 0; i < path.length; i++)
    {
        if(path[i] == '/' || path[i] == '\\')
        {
            ret~= current;
            current = null;
            continue;
        }
        current~= path[i];
    }
    if(current.length != 0)
        ret~= current;
    return ret;
}


string baseName(string path)
{
    int lastSepIndex = -1;
    int preLastSepIndex = -1;

    foreach(i, v; path)
    {
        if(path[i] == pathSeparator)
        {
            if(preLastSepIndex == -1)
                preLastSepIndex = lastSepIndex;
            lastSepIndex = cast(int)i;
        }
    }
    
    if(lastSepIndex == path.length)
        return path[preLastSepIndex..$-1];
    else if(lastSepIndex == -1)
        return path;
    return path[lastSepIndex..$];
}

string dirName(string path)
{
    return joinPath(pathSplitter(path)[0..$-1]);
}

string extension(string pathOrFilename)
{
    auto ind = pathOrFilename.lastIndexOf(".");
    if(ind == -1)
        return "";
    return pathOrFilename[cast(uint)ind+1..$];
}



string relativePath(string path, string base, bool caseSensitive = defaultCaseSensitivity) pure nothrow
{
    string ret;
    int commonIndex = 0;
    bool isEqual = true;
    if(caseSensitive)
    {
        foreach(i, v; base)
        {
            if(base[i] != path[i])
            {
                isEqual = false;
                break;
            }
           	else if(base[i] == pathSeparator)
            	commonIndex = cast(int)i;
        }
    }
    else
    {
        foreach(i, v; base)
        {
            if(base[i].toLowerCase != path[i].toLowerCase)
            {
                isEqual = false;
                break;
            }
           	else if(base[i] == pathSeparator)
            	commonIndex = cast(int)i;
        }
    }
    if(isEqual && path.length == base.length)
        return ".";
    else if(isEqual)
    {
        ret = path[base.length..$];
        if(ret[0] == pathSeparator)
            return ret[1..$];
       	return ret;
    }
    else if(commonIndex == base.length)
        return path[commonIndex..$];
    else if(commonIndex == 0)
        return path;

    uint pathCount = 0;
        
    for(uint i = commonIndex; i < base.length; i++)
    {
        if(base[i] == pathSeparator)
        {
            pathCount++;
            ret~= ".."~pathSeparator;
        }
    }
    ret~= path[0] == pathSeparator ? path[commonIndex+1..$] : path[commonIndex..$];	
    return ret;
}


string replaceFileName(string path, string newFileName)
{
    string[] p = pathSplitter(path);
    p[$-1] = newFileName;
    return joinPath(p);
}
string getFileNameFromPath(string path){return pathSplitter(path)[$-1];}
string joinPath(string[] paths ...){return joinPath(paths);}
string joinPath(string[] paths)
{
    if(paths.length == 1)
        return paths[0];
    string output;
    char charType = isPathUnixStyle(paths[0]) ? '/' : '\\';
    for(int i = 0; i < paths.length; i++)
    {
        if(paths[i] == "")
            continue;
        output~=paths[i];
        if(i+1 != paths.length &&
        paths[i+1].length != 0 &&
        paths[i+1][0] != charType &&
        paths[i][$-1] != charType)
            output~=charType;
    }
    return output;
}


///Copied from dmd.
@safe unittest
{
    assert(relativePath("foo") == "foo");

    version (Posix)
    {
        assert(relativePath("foo", "/bar") == "foo");
        assert(relativePath("/foo/bar", "/foo/bar") == ".");
        assert(relativePath("/foo/bar", "/foo/baz") == "../bar");
        assert(relativePath("/foo/bar/baz", "/foo/woo/wee") == "../../bar/baz");
        assert(relativePath("/foo/bar/baz", "/foo/bar") == "baz");
    }
    version (Windows)
    {
        assert(relativePath("foo", `c:\bar`) == "foo");
        assert(relativePath(`c:\foo\bar`, `c:\foo\bar`) == ".");
        assert(relativePath(`c:\foo\bar`, `c:\foo\baz`) == `..\bar`);
        assert(relativePath(`c:\foo\bar\baz`, `c:\foo\woo\wee`) == `..\..\bar\baz`);
        assert(relativePath(`c:\foo\bar\baz`, `c:\foo\bar`) == "baz");
        assert(relativePath(`c:\foo\bar`, `d:\foo`) == `c:\foo\bar`);
    }
}