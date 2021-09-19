
module util.file;
import std.stdio:File;

string getFileContent(string path, bool noCarriageReturn = true);
string replaceFileName(string path, string newFileName);
string getFileNameFromPath(string path);
string stripLineBreaks(string content);
string getFileContentFromBasePath(string path, string basePath, bool noCarriageReturn = true);
string joinPath(string[] paths...);
string joinPath(string[] paths);
void fileTruncate(File file, long offset);


interface IFileProgression
{
	void setOnFinish(void delegate(ref ubyte[] data) onFinish);
	void setOnUpdate(void delegate(float progress) onUpdate);
	bool update();
	float getProgress();
	ulong readSize();
	ulong size();
}
