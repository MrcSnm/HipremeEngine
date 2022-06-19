/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.data.assetmanager;
import hip.util.system;
import core.time:Duration, dur;
import core.thread;

public import hip.data.assets.image;
public import hip.util.data_structures : Pair;

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

    void load(void* ctx)
    {
        context = ctx;
        start();
    }

    void run()
    {
        loadedData = loaderFunction(context);
        hasFinishedLoading = true;
    }
}


/**
void* loadImageAsyncImpl(void* context)
{
    string imagePath = *(cast(string*)context);
    Image img = new Image(imagePath);
    img.loadFromFile();
    return cast(void*)img;
}
**/

private alias Callback(T) = void delegate(T obj);
private alias AssetPair(T) = Pair!(T, Callback!T);

class HipAssetManager
{
    // protected static Tid[] workerPool;
    protected static AssetLoaderThread[] workerPool;
    static float currentTime;
    static immutable Duration timeout = dur!"nsecs"(-1);

    static void checkLoad(){}
    /**
    protected static AssetPair!Image[string] images;

    static Image getImage(string imagePath)
    {
        AssetPair!Image* img = (imagePath in images);
        if(img !is null)
        {
            if(img.first !is null)
                return img.first;
        }
        return null;
    }

    static void loadImage(string imagePath, Callback!Image cb, bool async = true)
    {
        import hip.console.log;
        import hip.util.time;
        currentTime = HipTime.getCurrentTimeAsMilliseconds();
        if(async)
        {
            AssetLoaderThread t = new AssetLoaderThread(&loadImageAsyncImpl);
            t.load(cast(void*)imagePath);
            // workerPool~= spawn(&loadImageAsyncImpl, thisTid, imagePath);
            workerPool~= t;
            images[sanitizePath(imagePath)] = AssetPair!(Image)(null, cb);
        }
        else
        {
            Image img = new Image(imagePath);
            img.loadFromFile();
            logln(HipTime.getCurrentTimeAsMilliseconds()-HipAssetManager.currentTime, "ms");
            images[imagePath] = AssetPair!(Image)(img, cb);
            cb(img);
        }

    }

    static void checkLoad()
    {
        import hip.console.log;
        if(workerPool.length > 0)
        {
            foreach(w; workerPool)
            {
                if(w.hasFinishedLoading)
                {
                    logln("Finished loading image " ~ (*cast(string*)w.context));
                }
            }
            // receiveTimeout(HipAssetManager.timeout,
            //     (shared Image img)
            //     {
            //         logln(img.imagePath ~" decoded in ");
            //         logln(HipTime.getCurrentTimeAsMilliseconds()-HipAssetManager.currentTime, " ms.");

            //         images[img.imagePath].first = cast(Image)img;
            //         AssetPair!Image p = images[img.imagePath];
            //         if(p.second !is null)
            //             p.second(cast(Image)img);
            //     }
            // );
        }
    }

    **/
}