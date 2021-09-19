// D import file generated from 'source\data\assetpacker.d'
module data.assetpacker;
import console.log;
import util.string;
import util.file;
import std.algorithm : countUntil, map, min, sort;
import core.stdc.stdio;
import std.array : split, array;
import std.conv : to;
import core.stdc.string;
import std.stdio : File;
import std.path;
import std.file;
enum HapHeaderStart = "1HZ00ZH9";
enum HapHeaderEnd = "9HZ00ZH1";
enum HapHeaderSize = HapHeaderEnd.length + HapHeaderStart.length;
enum HapHeaderStatus 
{
	SUCCESS = 0,
	DOES_NOT_EXIST,
	NOT_HAP,
}
struct HapChunk
{
	string fileName;
	ulong startPosition;
	ubyte[] bin;
	alias bin this;
}
class HapFile
{
	HapChunk[string] chunks;
	protected FileProgression fp;
	static HapFile get(string filePath);
	this(string filePath, uint fileSteps = 10)
	{
		fp = new FileProgression(filePath, fileSteps);
		fp.setOnFinish((ref ubyte[] data)
		{
			HapChunk[] ch = getHapChunks(data, getHeaderStart(data));
			foreach (c; ch)
			{
				chunks[c.fileName] = c;
			}
		}
		);
	}
	string getText(string chunkName, bool removeCarriageReturn = true);
	string[] getChunksList();
	bool update();
	float getProgress();
	alias chunks this;
}
private string reverse(string s);
bool writeAssetPack(string outputFileName, string[] assetPaths, string basePath = "");
HapHeaderStatus appendAssetInPack(string hapFile, string[] assetPaths, string basePath = "");
HapHeaderStatus updateAssetInPack(string hapFile, string[] assetPaths, string basePath = "");
ulong getHeaderStart(string hapFile);
ulong getHeaderStart(ref ubyte[] fileData);
HapChunk[] getHapChunks(ref ubyte[] hapFile, ulong headerStart);
HapChunk[] getHapChunks(string hapFilePath);
