
module data.assetmanager;
import console.log;
import util.system;
import util.data_structures;
import util.time;
import core.time : Duration, dur;
import data.image;
import std.concurrency;
private void loadImageAsyncImpl(Tid tid, string imagePath);
private template Callback(T)
{
	alias Callback = void delegate(T obj);
}
private template AssetPair(T)
{
	alias AssetPair = Pair!(T, Callback!T);
}
class HipAssetManager
{
	protected static Tid[] workerPool;
	static float currentTime;
	static immutable Duration timeout = dur!"nsecs"(-1);
	protected static AssetPair!Image[string] images;
	static Image getImage(string imagePath);
	static void loadImage(string imagePath, Callback!Image cb, bool async = true);
	static void checkLoad();
}
