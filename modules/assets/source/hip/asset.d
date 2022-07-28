/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.asset;

import hip.hipengine.api.data.commons;

/** Controls the asset ids for every game asset
*   0 is reserved for errors.
*/
private __gshared uint currentAssetID = 0;

abstract class HipAsset : ILoadable
{
    /** Use it to insert into an asset pool, alias*/
    string name;
    /**Currently not in use */
    uint assetID;
    /** Usage inside asset manager */
    uint typeID;

    ///When it started loading
    float startLoadingTimestamp;
    ///How much time it took to load, in millis
    float loadTime;

    this(string assetName)
    {
        this.name = assetName;
        assetID = ++currentAssetID;
    }

    /**
    * Action for when the asset finishes loading
    * Proabably be executed on the main thread
    */
    abstract void onFinishLoading();


    void startLoading()
    {
        import hip.util.time;
        startLoadingTimestamp = HipTime.getCurrentTimeAsMilliseconds();
        load();
    }

    void finishLoading()
    {
        import hip.util.time;
        if(isReady())
        {
            onFinishLoading();
            loadTime = HipTime.getCurrentTimeAsMilliseconds() - startLoadingTimestamp;
        }
    }

    /**
    *   Currently, no AssetID recycle is in mind. It will only invalidate
    *   the asset for disposing it on an appropriate time
    */
    final void dispose()
    {
        this.assetID = 0;
        onDispose();
    }
    ///Use it to clear the engine. 
    abstract void onDispose();
}


private __gshared int assetIds = 0;
int assetTypeID(T : HipAsset)()
{
    static int id = -1;
    if(id == -1)
    {
        id = ++assetIds;
    }
    return id;
}