module hip.api.data.commons;


///Use @Asset instead of HipAsset.
struct HipAssetUDA(T)
{
    string path;
    static if(!(is(T == void)))
        T function(string data) conversionFunction;
}

HipAssetUDA!T Asset(T)(string path, T function(string) conversionFunc){return HipAssetUDA!T(path, conversionFunc);}
HipAssetUDA!void Asset(string path){return HipAssetUDA!void(path);}

template FilterAsset(Attributes...)
{
    import std.traits:isInstanceOf;
    import std.meta:AliasSeq;
    alias FilterAsset = AliasSeq!();
    static foreach(attr; Attributes)
        static if(isInstanceOf!(HipAssetUDA, typeof(attr)))
        	FilterAsset = attr;
}

template GetAssetUDA(Attributes...)
{
    alias asset = FilterAsset!(Attributes);
    static if(is(typeof(asset)))
        enum GetAssetUDA = asset;
    else
        enum GetAssetUDA = HipAssetUDA!void();
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

IHipAssetLoadTask loadAsset(type)(string assetPath)
{
    import hip.api;
    static if(is(type == IHipCSV))
        return HipAssetManager.loadCSV(assetPath);
    else static if(is(type == IHipFont))
        return HipAssetManager.loadFont(assetPath);
    else static if(is(type == IImage))
        return HipAssetManager.loadImage(assetPath);
    else static if(is(type == IHipIniFile))
        return HipAssetManager.loadINI(assetPath);
    else static if(is(type == IHipJSONC))
        return HipAssetManager.loadJSONC(assetPath);
    else static if(is(type == IHipTexture))
        return HipAssetManager.loadTexture(assetPath);
    else static if(is(type == IHipTextureAtlas))
        return HipAssetManager.loadTextureAtlas(assetPath);
    else static if(is(type == IHipTilemap))
        return HipAssetManager.loadTilemap(assetPath);
    else static if(is(type == IHipTileset))
        return HipAssetManager.loadTileset(assetPath);
    else static if(is(type == IHipAudioClip))
        return HipAssetManager.loadAudio(assetPath);
    else
        return HipAssetManager.loadFile(assetPath);
}

mixin template LoadAllAssets(string modules)
{
    import hip.util.string:split;
    mixin LoadReferencedAssets!(modules.split("\n"));
}
mixin template LoadReferencedAssets(string[] modules)
{
    void loadReferenced()
    {
        static foreach(modStr; modules)
        {{
            mixin("import ",modStr,";");
            alias theModule = mixin(modStr);
            static foreach(moduleMemberStr; __traits(allMembers, theModule))
            {{
                alias moduleMember = __traits(getMember, theModule, moduleMemberStr);
                static if(!is(moduleMember == module) && is(moduleMember type))
                {
                    static if(is(type == class) || is(type == struct))
                    {
                        static foreach(classMemberStr; __traits(derivedMembers, type))
                        {{
                            alias classMember = __traits(getMember, type, classMemberStr);
                            alias assetUDA = GetAssetUDA!(__traits(getAttributes, classMember));
                            static if(assetUDA.path !is null)
                            {{
                                IHipAssetLoadTask task = loadAsset!(typeof(classMember))(assetUDA.path);
                                static if(!__traits(compiles, classMember.offsetof)) //Static 
                                {
                                    static if(__traits(hasMember, assetUDA, "conversionFunction"))
                                        task.into(assetUDA.conversionFunction, &classMember);
                                    else
                                        task.into(&classMember);
                                }
                            }}
                        }}
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
        static foreach(member; __traits(derivedMembers, T))
        {{
            alias theMember = __traits(getMember, T, member);
            static if(!isFunction!theMember)
            {
                alias type = typeof(theMember);
                enum assetUDA = GetAssetUDA!(__traits(getAttributes, theMember));
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
        loadAsset!type(assetPath).into(&theMember);
    }
    alias preload = ForeachAssetInClass!(typeof(this), _load);
}

/**
*   Usage:
```d
class SomeScene : IHipPreloadable
{
    mixin Preload; ///IHipPreloadable lets you use Preload symbol. 

    ///Will load "someTexture.png" inside the member 'texture'
    @Asset("someTexture.png")
    IHipTexture texture;

    ///Loads game levels inside this variable
    @Asset("gameLevels.txt", &parseGameLevels)
    GameLevel[] gameLevels

    ///Doesn't need to call 'preload()' to populate. As it is variable, it will be populated right after its load.
    @Asset("helpText.txt")
    static string helpText;

    void initialize()
    {
        preload(); ///Needed to call for populating your assets after the class creation
    }

    GameLevel[] parseGameLevels(string data){return [];}
}
```
*/
interface IHipPreloadable
{
    void preload();
    string[] getAssetsForPreload();

    mixin template Preload()
    {
        mixin template impl()
        {
            private __gshared string[] _assetsForPreload;
            private __gshared void getAsset(T, alias member)(string asset){_assetsForPreload~= asset;}

            final string[] getAssetsForPreload()
            {
                if(_assetsForPreload.length != 0)
                {
                    mixin ForeachAssetInClass!(typeof(this), __traits(child, this, getAsset)) f;
                    f.ForeachAssetInClass;
                }
                return _assetsForPreload;
            }
            final void preload()
            {
                mixin ForeachAssetInClass!(typeof(this), loadAsset) f;
                f.ForeachAssetInClass;
            }
        }
        private final void loadAsset(T, alias member)(string asset)
        {
            ///Don't take static members.
            alias mem = __traits(child, this, member);
            static if(__traits(compiles, mem.offsetof))
            {
                ///Try converting the member with conversion function
                static if(!__traits(compiles, HipAssetManager.get!T))
                {
                    alias assetUDA = GetAssetUDA!(__traits(getAttributes, mem));
                    static assert(__traits(hasMember, assetUDA, "conversionFunction"), 
                    "Type has no conversion function and HipAssetManager can't infer its type.");
                    mem = assetUDA.conversionFunction(HipAssetManager.get!string(asset));
                }
                else //Just get from asset manager
                    mem = HipAssetManager.get!T(asset);
            }
        }

        ///Deal with override/no override
        static if(__traits(compiles, typeof(super).preload)){override: mixin impl;}
        else{mixin impl;}
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

/** 
 *  IHipAssetLoadTask is the base return type from any asset you want to `HipAssetManager.load{X}`.
 *  The loading, unless otherwise stated, is asynchronous. For simple games, most of the time you won't need
 *  to directly used LoadTask as currently the engine loads all the assets at startup to make it easier
 *  to prototype a game without needing to think about those tasks.
 *
 *  `await` is not supported on WebAssembly export, so, don't use it if you plan to export to web.
 */
interface IHipAssetLoadTask
{
    HipAssetResult result() const;
    ///Sets the result. Should not exist in user code.
    HipAssetResult result(HipAssetResult result);

    IHipAsset asset();
    ///Sets the asset. Should not exist in user code.
    IHipAsset asset(IHipAsset asset);

    bool hasFinishedLoading() const;
    ///Awaits the asset load process. Can't be used on WebAssembly export
    void await();
    ///When the variables finish loading, it will also assign the asset to the variables 
    void into(void* function(IHipAsset asset) castFunc, IHipAsset*[] variables...);
    final void into(T)(T*[] variables...){into((asset) => (cast(void*)cast(T)asset), cast(IHipAsset*[])variables);}
    void into(string*[] variables...);

    ///May be executed instantly if the asset is already loaded.
    void addOnCompleteHandler(void delegate(IHipAsset) onComplete);
    void addOnCompleteHandler(void delegate(string) onComplete);
    final void into(T)(T function(string) convertFunction, T*[] variables...)
    {
        T*[] vars = variables.dup;
        addOnCompleteHandler((string data)
        {
            foreach(v; vars)
                *v = convertFunction(data);
        });
    }


    /**
    *   Awaits the asset to be loaded and if the load was possible, cast it to the type, else returns null.
    *   Unsupported at WebAssembly.
    */
    T awaitAs(T)()
    {
        await();
        //Ignore dynamic cast (future only) return cast(T)(cast(void*)asset);
        if(hasFinishedLoading() && result == HipAssetResult.loaded)
            return cast(T)asset;
        return null;
    }
}


///Maybe will be deprecated in future. This is common in web, but it is a pain to work with.
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