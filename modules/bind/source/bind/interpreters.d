module bind.interpreters;

private enum valid = true;
private enum invalid = false;

private enum isUnsigned(T) = is(T == ubyte) || is(T == ushort) || is(T == uint) || (is(T == ulong));
private enum isSigned(T) = is(T == byte) || is(T == short) || is(T == int) || (is(T == long));
private enum isInteger(T) = isUnsigned!T || isSigned!T;
private enum isFloating(T) = is(T == float) || is(T == double);
private enum isNumber(T) = isInteger!T || isFloating!T;

private enum isStructPointer(T) = is(typeof(*T.init) == struct);

struct InterpreterResult(T)
{
    bool valid;
    T value;
    alias value this;
}

struct InterpreterVoid
{
    bool valid;
    alias valid this;
}

version(HipremeEngineLua):

private enum LUA_TOP = -1;
import bindbc.lua;

alias LuaVoid = InterpreterVoid;

alias LuaFunction = extern(C) nothrow int function(lua_State* L);

void luaPushVar(T)(lua_State* L, T arg)
{
    static if(isUnsigned!T)
        lua_pushunsigned(L, arg);
    else static if(isSigned!T)
        lua_pushinteger(L, arg);
    else static if(isFloating!T)
        lua_pushnumber(L, arg);
    else static if(is(T == bool))
        lua_pushboolean(L, cast(int)arg);
    else static if(is(T == typeof(null)))
        lua_pushnil(L);
    else static if(is(T == string))
        lua_pushlstring(L, arg.ptr, arg.length);
    else static if(is(T == struct))
    {
        import core.stdc.string;
        void* data = lua_newuserdata(L, arg.sizeof);
        memcpy(data, &arg, arg.sizeof);
    }
    else //Push classes, pointers and interfaces
        lua_pushlightuserdata(L, cast(void*)arg);
}


T luaGetFromIndex(T)(lua_State* L, int ind)
{
    static if(isInteger!T)
    {
        assert(lua_isinteger(L, ind), "Tried to get a "~T.stringof~" from a not integer");
        lua_Integer i = lua_tointeger(L, ind);
        return cast(T)i;
    }
    else static if(isFloating!T)
    {
        assert(lua_isnumber(L, ind), "Tried to get a "~T.stringof~" from a not number");
        lua_Number n = lua_tonumber(L, ind);
        return cast(T)n;
    }
    else static if(is(T == string))
    {
        import core.stdc.string;
        assert(lua_isstring(L, ind), "Tried to get a "~T.stringof~" from a not string");
        auto luaStr = lua_tostring(L, ind);
        char[] str = new char[](strlen(luaStr));
        return cast(T)str;
    }
    else static if(isStructPointer!T)
    {
        assert(lua_isuserdata(L, ind), "Tried to get a "~T.stringof~" from a not userdata");
        void* data = lua_touserdata(L, ind);
        return cast(T)data;
    }
    else static if(is(T == struct))
    {
        import core.stdc.string;
        assert(lua_isuserdata(L, ind), "Tried to get a "~T.stringof~" from a not userdata");
        void* data = lua_touserdata(L, ind);
        T ret;
        memcpy(&ret, data, T.sizeof);
        return ret;
    }
    else static if(is(T == class) || is(T == interface))
    {
        assert(lua_islightuserdata(L, ind), "Tried to get a "~T.stringof~" from a not light user data");
        return cast(T)lua_topointer(L, ind);
    }
}


InterpreterResult!T luaCallFunc(T, Args...)(lua_State* L, string funcName, Args args)
{
    lua_getglobal(L, (funcName~'\0').ptr);
    assert(lua_isfunction(L, LUA_TOP), "Variable "~funcName~" is not a function");
    static foreach(a; args)
        push(a);

    static if(is(T == class) || is(T == struct))
        enum returnCount = cast(int)__traits(allMembers, T).length;
    else static if(is(T == LuaVoid))
        enum returnCount = cast(int)0;
    else
        enum returnCount = cast(int)1;
    
    if(lua_pcall(L, args.length, returnCount, 0) != LUA_OK)
    {
        static if(is(T == LuaVoid))
            return InterpreterResult!T(invalid, LuaVoid(invalid));
        else
            return InterpreterResult!T(invalid, T.init);
    }


    static if(is(T == LuaVoid))
        return InterpreterResult!T(valid, LuaVoid(valid));
    else static if(is(T == struct))
    {
        T ret;
        static foreach(i, m; __traits(allMembers, T))
        {
            mixin("ret."~m ~ "= getFromIndex!("~
            typeof(mixin("T."~m)).stringof~")( -(returnCount - cast(int)i ) ); " );
        }

        return InterpreterResult!T(valid, ret);
    }
    else
        return InterpreterResult!T(valid, getFromIndex!T(LUA_TOP));
}

extern(C) int externLua(alias Func)(lua_State* L) nothrow
{
    import std.traits:Parameters, ReturnType;
    
    Parameters!Func params;
    int stackCounter = 0;
    
    foreach_reverse(ref param; params)
    {
        stackCounter--;
        param = luaGetFromIndex!(typeof(param))(L, stackCounter);
    }
    
    try
    {
        static if(is(ReturnType!Func == void))
        {
            Func(params);
            return 0;
        }
        else
        {
            luaPushVar(L, Func(params));
            return 1;
        }
    }
    catch(Exception e)
    {
        luaPushVar(L, null);
        try{luaL_error(L, ("A D function threw: "~e.toString~'\0').ptr);}
        catch(Exception e){luaL_error(L, "D threw when stringifying exception");}
        return 1;
    }
}


class LuaInterpreter
{
    public lua_State* L;
    private string currentFile;
    private LuaFunction[string] funcList;

    public this()
    {
        L = luaL_newstate();
        //Open standard libs
        luaL_openlibs(L);
    }

    public bool loadFile(string fileName)
    {
        currentFile = fileName;
        if(luaL_dofile(L, (fileName~"\0").ptr) != LUA_OK)
        {
            luaL_error(L, "HipremeEngine Lua interpreter error: %s:\n", lua_tostring(L, -1));
            return false;
        }
        return true;
    }
    pragma(inline) void checkLuaState()
    {
        assert(L != null,"No Lua State is loaded");
    }
    public void reload()
    {
        checkLuaState();
        loadFile(currentFile);
    }

    void push(T)(T arg)
    {
        checkLuaState();
        luaPushVar(L, arg);
    }

    private T getFromIndex(T)(int ind)
    {
        checkLuaState();
        return luaGetFromIndex!T(L, ind);
    }

    public InterpreterResult!T call(T, Args...)(string funcName, Args args)
    {
        checkLuaState();
        return luaCallFunc!T(L, funcName, args);
    }


    public void expose(string name, LuaFunction func)
    {
        immutable(char)* fName;
        fName = (name~'\0').ptr;
        funcList[name] = func;

        checkLuaState();
        lua_pushcfunction(L, func);
        lua_setglobal(L, fName);

    }
    public bool hasFunction(string funcName)
    {
        checkLuaState();
        lua_getglobal(L, (funcName~'\0').ptr);
        return lua_isfunction(L, LUA_TOP);
    }

    /**
    *   Use void to get a table
    */  
    public T get(T)(string varName)
    {
        checkLuaState();
        if(lua_getglobal(L, (varName~'\0').ptr) != LUA_OK)
        {
            luaL_error(L, "Variable not existent");
        }
        static if(!is(T == void))
            return getFromIndex!T(LUA_TOP);
    }
    public void getTable(string tableName){return get!void(tableName);}
    public T getTableField(T)(string field, int ind)
    {
        assert(lua_istable(L, ind), "Index on lua stack is not a table");
        assert(lua_getfield(L, ind, (field~'\0').ptr) == LUA_OK, "Could not get field named '"~field~"' from table");
        return getFromIndex!T(field, LUA_TOP);
    }


    ~this(){if(L != null)lua_close(L);L = null;}


    alias L this;
}

int hello()
{
    return 230;
}


package LuaInterpreter startLuaInterpreter(){return new LuaInterpreter();}


version(all):


enum HipInterpreter
{
    lua,
    none
}


package __gshared LuaInterpreter _lua;

void startInterpreter(HipInterpreter interpreter)
{
    final switch(interpreter)
    {
        case HipInterpreter.lua:
            _lua = startLuaInterpreter();
            break;
        case HipInterpreter.none:
            break;
    }
}

void loadInterpreterEntry(HipInterpreter interpreter, string entryPoint)
{
    final switch(interpreter)
    {
        case HipInterpreter.lua:
            assert(_lua.loadFile(entryPoint) && 
            _lua.hasFunction("HipInitialize") &&
            _lua.hasFunction("HipUpdate") &&
            _lua.hasFunction("HipRender"),
        "Lua entrypoint "~entryPoint~" must implement the functions HipInitialize, HipUpdate and HipRender");

            _lua.call!LuaVoid("HipInitialize");//, "Invalid HipInitialize";
            break;
        case HipInterpreter.none:break;

    }
    
}
void sendInterpreterFunc(alias func)(HipInterpreter interpreter)
{
    final switch(interpreter)
    {
        case HipInterpreter.lua:
            _lua.expose(__traits(identifier, func), &externLua!func);
            break;
        case HipInterpreter.none:
            break;
    }
}


void reloadInterpreter()
{
    if(_lua !is null)
        _lua.reload();
}

void renderInterpreter()
{
    if(_lua !is null)
        _lua.call!(LuaVoid)("HipRender");
}

void updateInterpreter()
{
    if(_lua !is null)
        _lua.call!(LuaVoid)("HipUpdate");
}

struct HipInterpreterEntry
{
    HipInterpreter intepreter;
    string sourceEntry;
}