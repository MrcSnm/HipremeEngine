// D import file generated from 'source\data\hipfs.d'
module data.hipfs;
public import std.stdio : File;
enum 
{
	SEEK_SET,
	SEEK_CUR,
	SEEK_END,
}
private pure bool validatePath(string initial, string toAppend);
enum FileMode
{
	READ,
	WRITE,
	APPEND,
	READ_WRITE,
	READ_APPEND,
}
interface IHipFileItf
{
	bool open(string path, FileMode mode);
	int read(void* buffer, ulong count);
	int seek(long count, int whence);
	ulong getSize();
	void close();
}
interface IHipFileSystemInteraction
{
	bool read(string path, out void[] output);
	bool write(string path, void[] data);
	bool exists(string path);
	bool remove(string path);
}
abstract class HipFile : IHipFileItf
{
	immutable FileMode mode;
	immutable string path;
	ulong size;
	ulong cursor;
	@disable this();
	this(string path, FileMode mode)
	{
		this.mode = mode;
		this.path = path;
		open(path, mode);
		this.size = getSize();
	}
	long seek(long count, int whence = SEEK_CUR);
	T[] rawRead(T)(T[] buffer)
	{
		read(cast(void*)buffer.ptr, buffer.length);
		return buffer;
	}
}
version (Android)
{
	public import jni.android.asset_manager;
	public import jni.android.asset_manager_jni;
	AAssetManager* aaMgr;
	class HipAndroidFile : HipFile
	{
		import core.stdc.stdio;
		AAsset* asset;
		@disable this();
		this(string path, FileMode mode)
		{
			super(path, mode);
		}
		override ulong getSize();
		override bool open(string path, FileMode mode);
		override int read(void* buffer, ulong count);
		override long seek(long count, int whence = SEEK_CUR);
		bool write(string path, void[] data);
		void close();
	}
	class HipAndroidFileSystemInteraction : IHipFileSystemInteraction
	{
		bool read(string path, out void[] output);
		bool write(string path, void[] data);
		bool exists(string path);
		bool remove(string path);
	}
}
class HipStdFileSystemInteraction : IHipFileSystemInteraction
{
	bool read(string path, out void[] output);
	bool write(string path, void[] data);
	bool exists(string path);
	bool remove(string path);
}
version (UWP)
{
	import core.sys.windows.windef;
	import bind.external : UWPCreateFileFromAppW, UWPDeleteFileFromAppW, UWPGetFileAttributesExFromAppW;
	class HipUWPFile : HipFile
	{
		HANDLE fp;
		import std.utf : toUTF16z;
		@disable this();
		this(string path, FileMode mode)
		{
			super(path, mode);
		}
		bool open(string path, FileMode mode);
		int read(void* buffer, ulong count);
		override long seek(long count, int whence);
		ulong getSize();
		void close();
	}
	class HipUWPileSystemInteraction : IHipFileSystemInteraction
	{
		bool read(string path, out void[] output);
		bool write(string path, void[] data);
		bool exists(string path);
		bool remove(string path);
	}
}
class HipFileSystem
{
	protected static string defPath;
	protected static string initialPath = "";
	protected static string combinedPath;
	protected static bool hasSetInitial;
	protected static IHipFileSystemInteraction fs;
	protected static bool function(string path, out string errMessage)[] extraValidations;
	public static void install(string path, bool function(string path, out string errMessage)[] validations...);
	public static string getPath(string path);
	public static bool isPathValid(string path);
	public static bool isPathValidExtra(string path);
	public static bool setPath(string path);
	public static bool read(string path, out void[] output);
	public static bool read(string path, out ubyte[] output);
	public static bool readText(string path, out string output);
	public static bool getFile(string path, string opts, out File file);
	public static bool write(string path, void[] data);
	public static bool exists(string path);
	public static bool remove(string path);
	public static string getcwd();
	public static string writeCache(string cacheName, void[] data);
}
alias HipFS = HipFileSystem;
