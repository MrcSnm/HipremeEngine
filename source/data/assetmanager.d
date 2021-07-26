module data.assetmanager;
import std.stdio;
import util.time;
import core.time:Duration, dur;
import graphics.image;
import std.concurrency;


private void loadImageAsyncImpl(Tid tid, string imagePath)
{
    shared Image img = cast(shared)new Image(imagePath);
    img.loadFromFile();
    send(tid, img);
}

class HipAssetManager
{
    protected static Tid[] workerPool;
    static float currentTime;
    static immutable Duration timeout = dur!"nsecs"(-1);

    static void loadImage(string imagePath, bool async = true)
    {
        currentTime = Time.getCurrentTime();
        if(async)
        {
            workerPool~= spawn(&loadImageAsyncImpl, thisTid, imagePath);
        }
        else
        {
            shared Image img = cast(shared)new Image(imagePath);
            img.loadFromFile();
            writeln(Time.getCurrentTime()-HipAssetManager.currentTime, "ms");

        }

    }

    static void checkLoad()
    {
        // writeln(img);
        if(workerPool.length > 0)
        {
            receiveTimeout(HipAssetManager.timeout,
                (shared Image img)
                {
                    writeln(img.imagePath ~" decoded in ");
                    writeln(Time.getCurrentTime()-HipAssetManager.currentTime, " ms.");
                }
            );
        }
    }
}