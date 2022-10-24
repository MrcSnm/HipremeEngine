// D import file generated from 'source\hip\util\path.d'
module hip.util.path;
import hip.util.string;
import hip.util.system;
public import hip.util.data_structures : Node;
version (Windows)
{
	enum defaultCaseSensitivity = false;
}
else
{
	version (Darwin)
	{
		enum defaultCaseSensitivity = false;
	}
	else
	{
		enum defaultCaseSensitivity = true;
	}
}
version (Windows)
{
	enum pathSeparator = '\\';
	enum otherSeparator = '/';
}
else
{
	enum pathSeparator = '/';
	enum otherSeparator = '\\';
}
pure nothrow @safe string[] pathSplitter(string path);
auto pure nothrow @nogc pathSplitterRange(string path)
{
	struct PathRange
	{
		string path;
		size_t indexRight = 0;
		pure nothrow @nogc bool empty();
		pure nothrow @nogc string front();
		pure nothrow @nogc void popFront();
	}
	return PathRange(path);
}
pure nothrow @nogc bool isRootOf(string theRoot, string ofWhat);
pure nothrow @nogc @safe string baseName(string path);
pure nothrow @safe string relativePath(string filePath, string base, bool caseSensitive = defaultCaseSensitivity);
pure nothrow @nogc @safe bool isAbsolutePath(string fPath);
pure nothrow @nogc @safe char determineSeparator(string filePath);
pure nothrow @nogc @safe string dirName(string filePath);
pure nothrow @nogc @safe string filename(string filePath);
pure nothrow ref @safe string filename(return ref string filePath, string newFileName);
pure nothrow @nogc @safe string filenameNoExt(string filePath);
pure nothrow @safe string replaceFileName(string filePath, string newFileName);
pure nothrow @nogc @safe string extension(string pathOrFilename);
ref string extension(return ref string pathOrFilename, string newExt);
pure nothrow @safe string joinPath(string[] paths...);
pure nothrow @safe string joinPath(string[] paths);
public Node!string buildFolderTree(string[] filesList);
string buildPath(Node!string node);
