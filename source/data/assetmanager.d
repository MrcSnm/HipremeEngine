/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module data.assetmanager;
import def.debugging.log;
import util.system;
import util.data_structures;
import util.time;
import core.time:Duration, dur;
import graphics.image;
import std.concurrency;


private void loadImageAsyncImpl(Tid tid, string imagePath)
{
    Image img = new Image(imagePath);
    img.loadFromFile();
    send(tid, cast(shared)img);
}

private alias Callback(T) = void delegate(T obj);
private alias AssetPair(T) = Pair!(T, Callback!T);

class HipAssetManager
{
    protected static Tid[] workerPool;
    static float currentTime;
    static immutable Duration timeout = dur!"nsecs"(-1);

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
        currentTime = Time.getCurrentTime();
        if(async)
        {
            workerPool~= spawn(&loadImageAsyncImpl, thisTid, imagePath);
            images[sanitizePath(imagePath)] = AssetPair!(Image)(null, cb);
        }
        else
        {
            Image img = new Image(imagePath);
            img.loadFromFile();
            logln(Time.getCurrentTime()-HipAssetManager.currentTime, "ms");
            images[imagePath] = AssetPair!(Image)(img, cb);
            cb(img);
        }

    }

    static void checkLoad()
    {
        if(workerPool.length > 0)
        {
            receiveTimeout(HipAssetManager.timeout,
                (shared Image img)
                {
                    logln(img.imagePath ~" decoded in ");
                    logln(Time.getCurrentTime()-HipAssetManager.currentTime, " ms.");

                    images[img.imagePath].first = cast(Image)img;
                    AssetPair!Image p = images[img.imagePath];
                    if(p.second !is null)
                        p.second(cast(Image)img);
                }
            );
        }
    }
}