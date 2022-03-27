// D import file generated from 'source\data\assetmanager.d'
module data.assetmanager;
public import data.image;
public import util.data_structures : Pair;
import util.system;
import core.time : Duration, dur;
import core.thread;
class AssetLoaderThread : Thread
{
	void* function(void* context) loaderFunction;
	void* loadedData;
	bool hasFinishedLoading = false;
	void* context;
	this(void* function(void* context) loaderFunction)
	{
		super(&run);
		this.loaderFunction = loaderFunction;
	}
	void load(void* ctx);
	void run();
}
void* loadImageAsyncImpl(void* context);
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
	protected static AssetLoaderThread[] workerPool;
	static float currentTime;
	static immutable Duration timeout = dur!"nsecs"(-1);
	protected static AssetPair!Image[string] images;
	static Image getImage(string imagePath);
	static void loadImage(string imagePath, Callback!Image cb, bool async = true);
	static void checkLoad();
}
