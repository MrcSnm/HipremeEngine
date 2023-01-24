module hip.api.data.commons;

struct Asset
{
    string path;
}

string[] getModulesFromRoot(string modules, string root)
{
    import hip.util.string:split;
    string[] ret = modules.split("\n");

    ptrdiff_t rootStart = -1;
    foreach(i, mod; ret)
    {
        if(mod.length < root.length)
        {
            if(rootStart == -1)
                continue;
            else
                return ret[rootStart..i];

        }
        if(mod[0..root.length] == root)
        {
            if(rootStart == -1)
                rootStart = i;
        }
        else if(rootStart != -1)
            return ret[rootStart..i];
    }
    assert(rootStart != -1, "Unable to find root "~root~" in modules list.");
    return ret[rootStart..$];
}


mixin template LoadAllAssets()
{
    import hip.util.string:split;
    mixin LoadReferencedAssets!(modules.split("\n"));
}
mixin template LoadReferencedAssets(string[] modules, alias callback)
{
    void loadReferenced()
    {
        import std.traits:isFunction;
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
        static foreach(modStr; modules)
        {{
            mixin("import ",modStr,";");
            alias theModule = mixin(modStr);
            static foreach(moduleMemberStr; __traits(allMembers, theModule))
            {{
                alias moduleMember = __traits(getMember, theModule, moduleMemberStr);
                static if(!is(moduleMember == module) && is(moduleMember type))
                {
                    static if(!isFunction!type)
                    {
                        static if(is(type == class) || is(type == struct))
                        {
                            static foreach(classMemberStr; __traits(derivedMembers, type))
                            {{
                                alias classMember = __traits(getMember, type, classMemberStr);
                                alias assetUDA = GetUDA!(Asset, __traits(getAttributes, classMember));
                                static if(assetUDA.path !is null)
                                {
                                    callback(assetUDA.path);
                                }
                            }}
                        }
                    }
                }
            }}
        }}
    }
}


///foreachAsset: void foreachAsset(T)(string assetPath)
mixin template ForeachAssetInClass(T, alias foreachAsset)
{
    void ForeachAssetInClass()
    {
        import std.traits:isFunction;
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
                static if(assetUDA.path != null)
                    foreachAsset!(type, theMember)(assetUDA.path);
            }
        }}
    }
}

mixin template PreloadAssets()
{
    private void _load(type, alias theMember)(string assetPath)
    {
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
    ;
    alias preload = ForeachAssetInClass!(typeof(this), _load);
}

interface IHipPreloadable
{
    void preload();
    string[] getAssetsForPreload();

    mixin template Preload()
    {
        final string[] getAssetsForPreload()
        {
            static string[] ret;
            static void getAsset(T, alias member)(string asset){ret~= asset;}
            if(ret.length != 0)
            {
                mixin ForeachAssetInClass!(typeof(this), __traits(child, this, getAsset)) f;
                f.ForeachAssetInClass;
            }
            return ret;
        }

        private final void loadAsset(T, alias member)(string asset)
        {
            __traits(child, this, member) = HipAssetManager.get!T(asset);
        }

        final void preload()
        {
            mixin ForeachAssetInClass!(typeof(this), loadAsset) f;
            f.ForeachAssetInClass;
        }
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