module hip.api.data.commons;
public import hip.api.data.asset;
import hip.util.reflection;


///Use @Asset instead of HipAsset.
pragma(LDC_no_typeinfo)
struct HipAssetUDA(T, Extra)
{
    string path;
    static if(!(is(T == void)))
        T function(string data) conversionFunction;
    static if(!(is(Extra == void)))
        Extra extra;
    int start, end;
}

/** 
 * Params:
 *   path = Path where the asset is located. 
        It may receive an $ for path formatting with numbers(only valid when array is used.)
 *   conversionFunc = A function with input the data located at "path", and return any data.
 *   start = For Arrays. Inclusive. May be greater than end for reverse counting.
 *   end = For Arrays. Inclusive.
 * Returns: 
 */
HipAssetUDA!(T, void) Asset(T)(string path, T function(string) conversionFunc, int start = 0, int end = 0){return HipAssetUDA!(T, void)(path, conversionFunc, start, end);}

/** 
 * Params:
 *   path = Path where the asset is located. 
        It may receive an $ for path formatting with numbers(only valid when array is used.)
 *   conversionFunc = A function with input the data located at "path", and return any data.
 *   extra = Extra data for instantiating the asset. Usually associated with the constructor
 *   start = For Arrays. Inclusive. May be greater than end for reverse counting.
 *   end = For Arrays. Inclusive.
 * Returns: 
 */
HipAssetUDA!(T, Extra) Asset(T, Extra)(string path, T function(string) conversionFunc, Extra extra, int start = 0, int end = 0){return HipAssetUDA!(T, Extra)(path, conversionFunc, extra, start, end);}

/**
 * Params:
 *   path = Path where the asset is located.
        It may receive an $ for path formatting with numbers(only valid when array is used.)
 * Returns:
 */
HipAssetUDA!(void, void) Asset(string path){return HipAssetUDA!(void, void)(path, 0, 0);}
/**
 * Params:
 *   path = Path where the asset is located.
        It may receive an $ for path formatting with numbers(only valid when array is used.)
 *   start = For Arrays. Inclusive. May be greater than end for reverse counting.
 *   end = For Arrays. Inclusive.
 * Returns:
 */
HipAssetUDA!(void, void) Asset(string path, int start, int end){return HipAssetUDA!(void, void)(path, start, end);}

/**
 * Params:
 *   path = Path where the asset is located.
        It may receive an $ for path formatting with numbers(only valid when array is used.)
 *   extra = Extra data for instantiating with the asset. Usually used with its constructor
 *   start = For Arrays. Inclusive. May be greater than end for reverse counting.
 *   end = For Arrays. Inclusive.
 * Returns:
 */
HipAssetUDA!(void, T) Asset(T)(string path, T extra, int start = 0, int end = 0) if(!isFunction!T) {return HipAssetUDA!(void, T)(path, extra, start, end);}


template FilterAsset(Attributes...)
{
    import std.traits:isInstanceOf;
    import std.meta:AliasSeq;
    static foreach(attr; Attributes)
        static if(isInstanceOf!(HipAssetUDA, typeof(attr)))
        	alias FilterAsset = attr;
}

template GetAssetUDA(Attributes...)
{
    alias asset = FilterAsset!(Attributes);
    static if(!is(typeof(asset) == void)) //Means it is a real struct.
        enum GetAssetUDA = asset;
    else
        enum GetAssetUDA = HipAssetUDA!(void, void)();
}


public string[] splitLines(string input)
{
    string[] ret;
    size_t lastCut = 0;
    foreach(i, ch; input)
    {
        if(ch == '\n')
        {
            ret~= input[lastCut..i];
            lastCut = i+1;
        }
    }
    if(lastCut < input.length) ret~= input[lastCut..$];
    return ret;
}


string[] getModulesFromRoot(string modules, string root)
{
    string[] ret = splitLines(modules);

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

IHipAssetLoadTask[] loadAssets()(TypeInfo type, string assetPath, const(ubyte)[] extraData, int start, int end)
{
    import hip.api;
    int sign = end - start >= 0 ? 1 : -1;
    ///Include 1 for the upper bounds 
    int count = ((end - start) * sign) + 1;
    if(count == 1) return [HipAssetManager.loadAsset(type, assetPath, extraData)];
    IHipAssetLoadTask[] ret = new IHipAssetLoadTask[count];

    static string formatStr(string str, int number)
    {
        import hip.util.to_string_range;
        char[32] numSink = 0xff;
        toStringRange(numSink[], number);
        int charCount = 0;
        while(numSink[charCount++] != 0xff){} charCount--;
        //-1 for the $
        char[] formattedStr = new char[(cast(int)str.length)-1+charCount];
        int i = 0;
        foreach(ch; str)
        {
            if(ch == '$')
                formattedStr[i..i+=charCount] = numSink[0..charCount];
            else
                formattedStr[i++] = ch;
        }
        return formattedStr;
    }

    foreach(i; 0..count) 
        ret[i] = HipAssetManager.loadAsset(type, formatStr(assetPath, start+i*sign), extraData);
    return ret;
}

mixin template LoadAllAssets(string modules)
{
    import hip.api.data.commons;
    mixin LoadReferencedAssets!(splitLines(modules));
}
mixin template LoadReferencedAssets(string[] modules)
{
    //TODO: Improve that loadReferenced to a better
    void loadReferenced()
    {
        import std.stdio;
        static foreach(modStr; modules)
        {{
            mixin("import ",modStr,";");
            alias theModule = mixin(modStr);
            static foreach(moduleMemberStr; __traits(allMembers, theModule))
            {{
                alias moduleMember = __traits(getMember, theModule, moduleMemberStr);
                static if(is(moduleMember type) && (is(type == class) || is(type == struct)))
                {
                    static foreach(classMemberStr; __traits(derivedMembers, type))
                    {{
                        alias classMember = __traits(getMember, type, classMemberStr);
                        alias assetUDA = GetAssetUDA!(__traits(getAttributes, classMember));
                        // pragma(msg, assetUDA);
                        static if(assetUDA.path !is null)
                        {{
                            import hip.util.reflection: isArray;

                            static if(!is(typeof(classMember) == string) && isArray!(typeof(classMember))) alias memberType = typeof(classMember.init[0]);
                            else alias memberType = typeof(classMember);


                            const(ubyte)[] extra;
                            static if(__traits(hasMember, assetUDA, "extra"))
                            {
                                auto v = assetUDA.extra;
                                extra = (cast(ubyte*)&v)[0..typeof(v).sizeof];

                            }
                            IHipAssetLoadTask[] tasks = loadAssets(typeid(memberType), assetUDA.path, extra, assetUDA.start, assetUDA.end);
                            memberType* members;

                            static if(!__traits(compiles, classMember.offsetof)) //Static
                            {
                                static if(!is(memberType == string) && isArray!(memberType))
                                {
                                    size_t start = classMember.length;
                                    classMember.length+= tasks.length;
                                    members = &classMember[start];
                                }
                                else
                                    members = &classMember;

                                foreach(i, task; tasks)
                                {
                                    static if(__traits(hasMember, assetUDA, "conversionFunction"))
                                        task.into(assetUDA.conversionFunction, &members[i]);
                                    else static if(is(memberType == string))
                                        task.into(&members[i]);
                                    else
                                        task.into!(memberType)(&members[i]);
                                }
                            }
                        }}
                    }}
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
                {
                    const(ubyte)[] extra;
                    const v = assetUDA.extra;
                    static if(__traits(hasMember, assetUDA, "extra"))
                        extra = (cast(const(ubyte*))&v)[0..typeof(v).sizeof];
                    static if(__traits(isTemplate, foreachAsset))
                        foreachAsset!(type, theMember)(assetUDA.path, extra);
                    else
                        foreachAsset(assetUDA.path, extra);
                }
            }
        }}
    }
}

mixin template PreloadAssets()
{
    private void _load(alias theMember)(TypeInfo t, string assetPath, const(ubyte)[] extraData)
    {
        import hip.api;
        HipAssetManager.loadAsset(t, assetPath, extraData).into(&theMember);
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
        mixin template finalImpl()
        {
            private __gshared string[] _assetsForPreload;
            private __gshared void getAsset(string asset, const(ubyte)[] extraData){_assetsForPreload~= asset;}
            private final void loadAsset(T, alias member)(string asset, const(ubyte)[] extraData)
            {
                alias mem = member;
                ///Take members that aren't static and populate them after loading.
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
        }
        mixin template impl()
        {
            string[] getAssetsForPreload()
            {
                if(_assetsForPreload.length == 0)
                {
                    mixin ForeachAssetInClass!(typeof(this), __traits(child, this, getAsset)) f;
                    f.ForeachAssetInClass;
                }
                return _assetsForPreload;
            }
            void preload()
            {
                mixin ForeachAssetInClass!(typeof(this), loadAsset) f;
                f.ForeachAssetInClass;
            }
        }
        

        ///Deal with override/no override
        mixin finalImpl;
        static if(__traits(compiles, typeof(super).preload)){override: mixin impl;}
        else{mixin impl;}
    }
}

/**
*   OpenGL Renderer must implement IReloadable for when changing device orientation.
*/
interface IReloadable
{
    bool reload();
}



enum HipAssetResult : ubyte
{
    waiting,
    cantLoad,
    loading,
    mainThreadLoading,
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

    HipAsset asset();
    ///Sets the asset. Should not exist in user code.
    HipAsset asset(HipAsset asset);

    bool hasFinishedLoading() const;
    ///Awaits the asset load process. Can't be used on WebAssembly export
    void await();
    ///When the variables finish loading, it will also assign the asset to the variables 
    void into(void* function(HipAsset asset) castFunc, HipAsset*[] variables...);
    final void into(T)(T*[] variables...)
    {
        into((HipAsset asset) => (cast(void*)cast(T)asset), cast(HipAsset*[])variables);
    }
    void into(string*[] variables...);

    ///May be executed instantly if the asset is already loaded.
    void addOnCompleteHandler(void delegate(HipAsset) onComplete);
    void addOnCompleteHandler(void delegate(string) onComplete);
    ///Executs a step on the loading task. Call `asset` when state is loaded
    void update();
    final void into(T)(T function(string) convertFunction, T*[] variables...)
    {
        T*[] vars = variables.dup;
        addOnCompleteHandler((string data)
        {
            foreach(v; vars)
                *v = convertFunction(data);
        });
    }
}

interface IHipDeserializable
{
    IHipDeserializable deserialize(string data);
    IHipDeserializable deserialize(void* data);
}