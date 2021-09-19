// D import file generated from 'source\util\file.d'
module util.file;
import std.stdio;
import std.conv : to;
import std.path;
import std.array : array, join;
import std.file;
import util.system;
import util.string;
string getFileContent(string path, bool noCarriageReturn = true);
string replaceFileName(string path, string newFileName);
string getFileNameFromPath(string path);
string stripLineBreaks(string content);
string getFileContentFromBasePath(string path, string basePath, bool noCarriageReturn = true);
string joinPath(string[] paths...);
string joinPath(string[] paths);
void fileTruncate(File file, long offset);
class FileProgression
{
	protected ulong progress;
	protected uint stepSize;
	protected ulong fileSize;
	protected void delegate(ref ubyte[] data) onFinish;
	protected void delegate(float progress) onUpdate;
	ubyte[] fileData;
	ubyte[] buffer;
	File target;
	this(string filePath, uint readSteps = 100, uint bytes = 0)
	{
		assert(readSteps != 0 || bytes != 0, "Can't have readSteps and bytes both == 0");
		progress = 0;
		target = File(filePath, "r");
		ulong fSize = fileSize = target.size;
		assert(cast(uint)fSize < (uint).max, "Filesize is greater than uint.max, contact the FileProgression mantainer");
		fileData.reserve(cast(uint)fSize);
		if (readSteps > fSize)
			readSteps = cast(uint)fSize;
		if (bytes != 0)
			readSteps = cast(uint)fSize / bytes;
		real sz = cast(real)fSize / readSteps;
		if (sz != fSize / readSteps)
		{
			ulong remaining = cast(ulong)((sz - fSize / readSteps) * readSteps);
			buffer = new ubyte[remaining];
			target.rawRead(buffer);
			fileData ~= buffer[];
			progress += remaining;
			stepSize = cast(uint)(fSize - remaining) / readSteps;
		}
		else
			stepSize = cast(uint)fSize / readSteps;
		buffer.length = stepSize;
	}
	void setOnFinish(void delegate(ref ubyte[] data) onFinish);
	void setOnUpdate(void delegate(float progress) onUpdate);
	bool update();
	float getProgress();
	@property ulong readSize();
	@property ulong size();
	override string toString();
}
