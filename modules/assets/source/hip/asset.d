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

import hip.api.data.commons;

/** Controls the asset ids for every game asset
*   0 is reserved for errors.
*/
private __gshared uint currentAssetID = 0;

abstract class HipAsset : ILoadable, IHipAsset
{
    /** Use it to insert into an asset pool, alias*/
    protected string _name;
    /**Currently not in use */
    protected uint _assetID;
    /** Usage inside asset manager */
    protected uint _typeID;

    ///When it started loading
    float startLoadingTimestamp;
    ///How much time it took to load, in millis
    float loadTime;

    this(string assetName)
    {
        this.name = assetName;
        _assetID = ++currentAssetID;
    }

    string name() const{return _name;}
    string name(string newName) {return _name = newName;}
    uint assetID() const {return _assetID;}
    uint typeID() const { return _typeID;}

    /**
    * Action for when the asset finishes loading
    * Proabably be executed on the main thread
    */
    abstract void onFinishLoading();


    void startLoading()
    {
        import hip.util.time;
        startLoadingTimestamp = HipTime.getCurrentTimeAsMs();
    }

    void finishLoading()
    {
        import hip.util.time;
        if(isReady())
        {
            onFinishLoading();
            loadTime = HipTime.getCurrentTimeAsMs() - startLoadingTimestamp;
        }
    }

    /**
    *   Currently, no AssetID recycle is in mind. It will only invalidate
    *   the asset for disposing it on an appropriate time
    */
    final void dispose()
    {
        _assetID = 0;
        onDispose();
    }
    ///Use it to clear the engine. 
    abstract void onDispose();
}


class HipFileAsset : HipAsset
{
    string path;
    ubyte[] data;
    this(in string path)
    {
        super("File_"~path);
        this.path = path;
        _typeID = assetTypeID!HipFileAsset;
    } 
    void load(in ubyte[] data){this.data = cast(ubyte[])data;}
    string getText(){return cast(string)data;}
    override void onFinishLoading(){}
    override void onDispose(){}
    bool isReady(){return data.length != 0;}
}

private __gshared int assetIds = 0;
int assetTypeID(T : IHipAsset)()
{
    __gshared int id = -1;
    if(id == -1){id = ++assetIds;}
    return id;
}