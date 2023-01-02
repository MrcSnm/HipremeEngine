module hip.api.data.commons;

struct Asset
{
    string path;
}

mixin template PreloadAssets()
{
    void preload()
    {
        import std.traits:isFunction;
        alias T = typeof(this);
        template GetUDA(UDAType, Attributes...)
        {
            enum impl()
            {
                UDAType ret;
                foreach(i; Attributes)
                {
                    if(is(typeof(i) == UDAType))
                    {
                        ret = i;
                        break;
                    }
                }
                return ret;
            }
            enum GetUDA = impl();
        }
        static foreach(member; __traits(derivedMembers, T))
        {{
            alias theMember = __traits(getMember, T, member);
            static if(!isFunction!theMember)
            {
                alias type = typeof(theMember);
                alias assetUDA = GetUDA!(Asset, __traits(getAttributes, theMember));
                if(assetUDA.path != null)
                {
                    enum assetPath = assetUDA.path;

                    static if(is(type == IHipCSV))
                        HipAssetManager.loadCSV(assetPath).into(&theMember);
                    else static if(is(type == IHipFont))
                        HipAssetManager.loadFont(assetPath).into(&theMember);
                    else static if(is(type == IImage))
                        HipAssetManager.loadImage(assetPath).into(&theMember);
                    else static if(is(type == IHipIniFile))
                        HipAssetManager.loadINI(assetPath).into(&theMember);
                    else static if(is(type == IHipJSONC))
                        HipAssetManager.loadJSONC(assetPath).into(&theMember);
                    else static if(is(type == IHipTexture))
                        HipAssetManager.loadTexture(assetPath).into(&theMember);
                    else static if(is(type == IHipTextureAtlas))
                        HipAssetManager.loadTextureAtlas(assetPath).into(&theMember);
                    else static if(is(type == IHipTilemap))
                        HipAssetManager.loadTilemap(assetPath).into(&theMember);
                    else static if(is(type == IHipTileset))
                        HipAssetManager.loadTileset(assetPath).into(&theMember);
                }
            }
        }}
    }
}

interface ILoadable
{
    /** Should return if the asset is ready for use*/
    bool isReady();
}

/**
*   OpenGL Renderer must implement IReloadable for when changing device orientation.
*/
interface IReloadable
{
    bool reload();
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
    ///Awaits the asset load process
    void await();
    ///When the variables finish loading, it will also assign the asset to the variables 
    void into(void* function(IHipAsset asset) castFunc, IHipAsset*[] variables...);
    final void into(T)(T*[] variables...){into((asset) => (cast(void*)cast(T)asset), cast(IHipAsset*[])variables);}


    ///Awaits the asset to be loaded and if the load was possible, cast it to the type, else returns null.
    T awaitAs(T)()
    {
        await();
        //Ignore dynamic cast (future only) return cast(T)(cast(void*)asset);
        if(hasFinishedLoading() && result == HipAssetResult.loaded)
            return cast(T)asset;
        return null;
    }
}

interface IHipDeferrableTexture
{
    void setTexture(IHipAssetLoadTask task);
}
interface IHipDeferrableText
{
    void setFont(IHipAssetLoadTask task);
}

interface IHipDeserializable
{
    IHipDeserializable deserialize(string data);
    IHipDeserializable deserialize(void* data);
}