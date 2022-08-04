module hip.api.data.commons;

interface ILoadable
{
    /** Should return if the asset is ready for use*/
    bool isReady();
}

interface IHipAsset
{
    string name() const;
    string name(string newName);

    uint assetID() const;
    uint typeID() const;
}


enum HipAssetResult
{
    cantLoad,
    loading,
    loaded
}

interface IHipAssetLoadTask
{
    HipAssetResult result() const;
    HipAssetResult result(HipAssetResult result);
    IHipAsset asset();
    IHipAsset asset(IHipAsset asset);
    bool hasFinishedLoading() const;
    void await();
}

interface IHipDeferrableTexture
{
    void setTexture(IHipAssetLoadTask task);
}
interface IHipDeferrableText
{
    void setFont(IHipAssetLoadTask task);
}