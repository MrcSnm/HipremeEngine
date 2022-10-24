// D import file generated from 'source\hip\util\file.d'
module hip.util.file;
import hip.util.conv : to;
import hip.util.array : join, array;
import hip.util.system;
import hip.util.path;
import hip.util.string;
string getFileContent(string path, bool noCarriageReturn = true);
string stripLineBreaks(string content);
version (HipDStdFile)
{
	import std.stdio : File;
	import std.file;
	void fileTruncate(File file, long offset);
}
version (HipDStdFile)
{
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
}
