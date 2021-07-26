module data.asset;
import util.time;

/** Controls the asset ids for every game asset
*   0 is reserved for errors.
*/
private __gshared uint currentAssetID = 0;

abstract class HipAsset
{
    /** Use it to insert into an asset pool, alias*/
    string name;
    /**Currently not in use */
    uint assetID;
    ///When it started loading
    float startLoadingTimestamp;
    ///How much time it took to load, in millis
    float loadTime;

    this(string assetName)
    {
        this.name = assetName;
        assetID = ++currentAssetID;
    }

    /** Should return if the load was successful */
    abstract bool load();
    /** Should return if the asset is ready for use*/
    abstract bool isReady();
    /** Action for when the asset finishes loading*/
    abstract void onFinishLoading();

    void startLoading()
    {
        startLoadingTimestamp = Time.getCurrentTime();
        load();
    }
    void finishLoading()
    {
        if(isReady())
        {
            onFinishLoading();
            loadTime = Time.getCurrentTime() - startLoadingTimestamp;
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