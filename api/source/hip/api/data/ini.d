module hip.api.data.ini;


struct IniVar
{
    string name;
    string value;

    pragma(inline, true) string get() => value;
    pragma(inline, true) string opAssign(string v) () => value = v;

    version(Have_util)
    {
        import hip.util.variant;
        private Variant data;
        IniVar opAssign(IniVar var){this.name = var.name; this.value = var.value; this.data = var.data; return this;}

        T get(T)()
        {
            static if(is(T == string))
                return get;
            else
            {
                if(data.type == Type.undefined)
                    data = Variant.make!T(value);
                return data.get!T;
            }
        }
        pragma(inline, true) auto opAssign(T)(T v) => data.set!T(v);
    }
    string toString() const @safe pure nothrow{return name~" = "~ value;}
}

struct IniBlock
{
    string name;
    string comment;
    IniVar[string] vars;

    string toString() const @safe pure
    {
        string ret = "["~name~"]\n";
        foreach (v; vars)
            ret~= v.toString();
        return ret;
    }
    pragma(inline, true) auto opDispatch(string member)() => vars[member];
    alias vars this;
}

/**
*   Usage:
```d
//If not found, use 2 as default
ini.tryGet!ubyte("buffering.count", 2);
//Alternative usage
ini.buffering.count.get!ubyte
```
*/
interface IHipIniFile
{
    ref IniBlock[string] blocks();
    const(string[]) getErrors() const;
    bool noError() const;
    version(Have_util)
    {
        IniVar* getIniVar(string varPath);
        T tryGet(T)(string varPath, T defaultVal = T.init)
        {
            IniVar* v = getIniVar(varPath);
            if(v is null)
                return defaultVal;
            return v.get!T;
        }
    }
    auto opDispatch(string member)() => blocks[member];
}