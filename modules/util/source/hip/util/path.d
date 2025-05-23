module hip.util.path;
import hip.util.string;
import hip.util.system;
//Node required for buildFolderTree
public import hip.util.data_structures: Node;

version(Windows) 
    enum defaultCaseSensitivity = false;
else version(Darwin) 
    enum defaultCaseSensitivity = false;
else// version(Posix) 
    enum defaultCaseSensitivity = true;

version(Windows)
{
    enum pathSeparator = '\\';
    enum otherSeparator = '/';
}
else
{
    enum pathSeparator = '/';
    enum otherSeparator = '\\';
}

string[] pathSplitter(string path) @safe pure nothrow
{
    string[] ret;
    foreach(p; pathSplitterRange(path))
        ret~= p;
    return ret;
}

auto pathSplitterRange(string path) pure @safe nothrow @nogc
{
    struct PathRange
    {
        string path;
        size_t indexRight = 0;

        bool empty() @safe pure nothrow @nogc {return indexRight >= path.length;}
        string front() @safe pure nothrow @nogc
        {
            size_t i = indexRight;
            while(i < path.length && path[i] != '\\' && path[i] != '/')
                i++;
            indexRight = i;
            return path[0..indexRight];
        }
        void popFront() @safe pure nothrow @nogc
        {
            if(indexRight+1 < path.length)
            {
                path = path[indexRight+1..$];
                indexRight = 0;
            }
            else
                indexRight+= 1; //Guarantees empty
        }
    }

    return PathRange(path);
}

bool isRootOf(string theRoot, string ofWhat) pure nothrow @nogc
{
    auto pathA = pathSplitterRange(theRoot);
    auto pathB = pathSplitterRange(ofWhat);

    for(; !pathA.empty && !pathB.empty; pathA.popFront, pathB.popFront)
    {
        string compA = pathA.front;
        string compB = pathB.front;
        if(compA != compB)
            return false;
    }
    return true;
}



string relativePath(bool caseSensitive = defaultCaseSensitivity)(string filePath, string base) pure nothrow @safe
{
    int commonIndex = 0;
    bool isEqual = true;
    for(int i = 0; i < base.length; i++)
    {
        if(i == filePath.length || (caseSensitive ? base[i] != filePath[i] : base[i].toLowerCase != filePath[i].toLowerCase))
        {
            isEqual = false;
            break;
        }
        else if(base[i] == pathSeparator)
            commonIndex = cast(int)i;
    }
    if(isEqual)
    {
        if(filePath.length == base.length)
            return ".";
        else //If the base string is a subset, return part after base.
            return filePath[base.length + (filePath[base.length] == pathSeparator ? 1 : 0)..$];
    } 
    else if(commonIndex == 0)
        return filePath;

    string ret;
    for(uint i = commonIndex; i < base.length; i++)
    {
        if(base[i] == pathSeparator)
            ret~= ".."~pathSeparator;
    }
    ret~= filePath[commonIndex] == pathSeparator ? filePath[commonIndex+1..$] : filePath[commonIndex..$];
    return ret;
}

bool isAbsolutePath(string fPath) pure nothrow @nogc @safe
{
    if(fPath == null)
        return false;
    version(Posix)
        if(fPath[0] != '/')
            return false;
    version(Windows)
    {
        if(fPath.length < 3)
            return false;
        if(!(fPath[0].isUpperCase && fPath[1] == ':' && fPath[2] == '\\'))
            return false;
    }
    for(size_t i = 0; i < fPath.length; i++)
        if(i + 2 < fPath.length && fPath[i] == '.' && fPath[i+1] == '.' && fPath[i+2] == pathSeparator)
            return false;
    return true;
}

string absolutePath(string thePath, string currPath)
{
    if(isAbsolutePath(thePath)) return thePath;
    return joinPath(currPath, thePath);
}



char determineSeparator(const string filePath) pure nothrow @nogc @safe
{
    size_t i = 0;
    while(i < filePath.length && filePath[i] != '/' && filePath[i] != '\\')
        i++;
    return i < filePath.length ? filePath[i] : '\0';
}

///Will get the directory name until a trailing separator or return 
string dirName(string filePath) pure nothrow @nogc @safe
{
    char sep = determineSeparator(filePath);
    if(sep == '\0')
        return filePath;
    int last = filePath.lastIndexOf(sep);
    if(last == -1)
        return filePath;
    return filePath[0..last];
}


string filename(string filePath) @safe pure nothrow @nogc
{
    char sep = determineSeparator(filePath);
    if(sep == '\0')
        return filePath;
    int last = filePath.lastIndexOf(sep);
    if(last == -1)
        return filePath;
    return filePath[last+1..$];
}

alias baseName = filename;

ref string filename(return ref string filePath, string newFileName) @safe pure nothrow
{
    return filePath = replaceFileName(filePath, newFileName);
}

string filenameNoExt(string filePath) @safe pure nothrow @nogc
{
    string f = filePath.filename;
    if(f == "")
        return "";
    int last = f.lastIndexOf(".");
    if(last == -1)
        return f;
    return f[0..last];
}

string replaceFileName(string filePath, string newFileName) @safe pure nothrow
{
    char sep = determineSeparator(filePath);
    string[] p = pathSplitter(filePath);
    p[$-1] = newFileName;
    return ((p[0] == "" && sep == '/') ? "/" : "") ~ joinPath(sep, p);
}

string normalizePath(string path)
{
    string[16] normalized;
    size_t pathsLength;
    foreach(p; pathSplitterRange(path))
    {
        if(p == ".")
            continue;
        else if(p == "..")
        {
            if(pathsLength > 0)
                pathsLength--;
            else
                normalized[pathsLength++]= p;
        }
        else
            normalized[pathsLength++]= p;

    }
    return normalized[0..pathsLength].joinPath;
}



/**
*   Extension getter
```d
string myFile = "test.png";
writeln(myFile.extension); //png
```
*/
string extension(string pathOrFilename) pure nothrow @nogc @safe
{
    auto ind = pathOrFilename.lastIndexOf(".");
    if(ind == -1)
        return "";
    return pathOrFilename[cast(uint)ind+1..$];
}

/**
*   Extension setter.
*   Usage:
```d
   string test = "test.png"
   test.extension = "txt";
   writeln(test); //test.txt
```
*/
ref string extension(return ref string pathOrFilename, string newExt)
{
    auto ind = pathOrFilename.lastIndexOf(".");    
    if(ind != -1 && ind != pathOrFilename.length)
    {
        if(newExt.length == 0)
            pathOrFilename = pathOrFilename[0..ind];
        else if(newExt[0] != '.')
            pathOrFilename = pathOrFilename[0..ind+1]~newExt;
        else
            pathOrFilename = pathOrFilename[0..ind+1]~newExt[1..$];
    }
    return pathOrFilename;
}

string extension(string pathOrFilename, string newExt)
{
    pathOrFilename = pathOrFilename.extension(newExt);
    return pathOrFilename;
}

string joinPath(char separator, scope const string[] paths ...) @safe pure nothrow
{
    if(paths.length == 1)
        return paths[0];

    PathString output;
    for(int i = 0; i < paths.length; i++)
    {
        string next = i+1 < paths.length ? paths[i+1] : "";
        if(paths[i] != "")
        {
            output~=paths[i];
            if(next != "" && next[0] != separator  &&
            paths[i][$-1] != separator)
                output~=separator;
        }
        else
        {
            if(next != "" && next[0] != separator)
                output~= separator;
        }
    }
    return output.toString.dup;
}

string joinPath(scope const string[] paths ...) @safe pure nothrow
{
    char sep;
    foreach(p; paths)
    {
        sep = determineSeparator(p);
        if(sep != '\0')
            break;
    }
    if(sep == '\0')
        sep = pathSeparator;
    return joinPath(sep, paths);
}


public Node!string buildFolderTree(string[] filesList)
{
    alias DirNode = Node!string;
    DirNode root = new DirNode(filesList[0]);

    scope DirNode[] dirStack = [root];
    
    for(size_t i = 1; i < filesList.length; i++)
    {
        int currStack = 0;
        foreach(pathPart; pathSplitterRange(filesList[i]))
        {
            if(pathPart.extension != "") //It is a leaf if it has an extension
            {
                dirStack[$-1].addChild(pathPart);
            }
            else if(currStack >= dirStack.length) //If we have more parts than the stack has children, add to the stack
            {
                //Add child to the last
                dirStack~= dirStack[$-1].addChild(pathPart);
                currStack++;
            }
            else if(dirStack[currStack].data != pathPart) //If both they are the same, check for the next part
            {
                dirStack = dirStack[0..$-1];
                currStack--;
            }
            else if(dirStack[currStack].data == pathPart) //If both they are the same, check for the next part
                currStack++;
        }
    }
    return root;
}
string buildPath(Node!string node)
{
    string ret = node.data;
    while(node.parent !is null)
    {
        node = node.parent;
        if(node)
        {
            ret = node.data~"/"~ret;
        }
    }
    return ret;
}


///Copied from dmd.
unittest
{
    assert(baseName("a/b/test.txt") == "test.txt");
    assert(relativePath("foo", "") == "foo");
    assert(filenameNoExt("helloWorld.zip") == "helloWorld");
    assert("/hello/test/again".isRootOf("/hello/test/again/something/is/here.txt"));

    version (Posix)
    {
        assert(filename("/something/here/yet.txt"), "yet.txt");
        assert(filenameNoExt("/something/here/yet.txt"), "yet");

        assert(relativePath("foo", "/bar") == "foo");
        assert(relativePath("/foo/bar", "/foo/bar") == ".");
        assert(relativePath("/foo/bar", "/foo/baz") == "../bar");
        assert(relativePath("/foo/bar/baz", "/foo/woo/wee") == "../../bar/baz");
        assert(relativePath("/foo/bar/baz", "/foo/bar") == "baz");
    }
    version (Windows)
    {
        assert(filename(`c:\something\here\yet.txt`), "yet.txt");
        assert(filenameNoExt(`c:\something\here\yet.txt`) == "yet");

        assert(relativePath("foo", `c:\bar`) == "foo");
        assert(relativePath(`c:\foo\bar`, `c:\foo\bar`) == ".");
        assert(relativePath(`c:\foo\bar`, `c:\foo\baz`) == `..\bar`);
        assert(relativePath(`c:\foo\bar\baz`, `c:\foo\woo\wee`) == `..\..\bar\baz`);
        assert(relativePath(`c:\foo\bar\baz`, `c:\foo\bar`) == "baz");
        assert(relativePath(`c:\foo\bar`, `d:\foo`) == `c:\foo\bar`);
    }
}
