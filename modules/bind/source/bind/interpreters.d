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
import bindbc.lua;

enum checkLuaState = "if(L == null) assert(false, \"No Lua State is loaded\");";
alias LuaVoid = InterpreterVoid;


struct Point
{
    int x, y;
}
class LuaInterpreter
{
    public lua_State* L;

    private enum TOP = -1;

    public this()
    {
        L = luaL_newstate();
        //Open standard libs
        luaL_openlibs(L);
    }

    public bool loadFile(string fileName)
    {
        if(luaL_dofile(L, (fileName~"\0").ptr) != LUA_OK)
        {
            luaL_error(L, "HipremeEngine Lua interpreter error: %s:\n", lua_tostring(L, -1));
            return false;
        }
        return true;
    }

    void push(T)(T arg)
    {
        mixin(checkLuaState);
        static if(isUnsigned!T)
        {
            lua_pushunsigned(L, arg);
        }
        else static if(isSigned!T)
        {
            lua_pushinteger(L, arg);
        }
        else static if(isFloating!T)
        {
            lua_pushnumber(L, arg);
        }
        else static if(is(T == bool))
        {
            lua_pushboolean(L, cast(int)arg);
        }
        else static if(is(T == typeof(null)))
        {
            lua_pushnil(L);
        }
        else static if(is(T == string))
        {
            lua_pushlstring(L, arg.ptr, arg.length);
        }
        else static if(is(T == struct))
        {
            import core.stdc.string;
            void* data = lua_newuserdata(L, arg.sizeof);
            memcpy(data, &arg, arg.sizeof);
        }

    }

    public int getInt(string varName)
    {
        mixin(checkLuaState);
        lua_getglobal(L, (varName~'\0').ptr);
        lua_Number n = lua_tonumber(L, TOP);
        return cast(int)n;
    }

    private T getFromIndex(T)(int ind)
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
            auto luaStr = lua_tostring(L, i);
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
        else static if(is(T == void*))
        {
            assert(lua_islightuserdata(L, ind), "Tried to get a "~T.stringof~" from a not light user data");
            return lua_topointer(L, ind);
        }
    }

    public InterpreterResult!T call(T, Args...)(string funcName, Args args)
    {
        mixin(checkLuaState);
        lua_getglobal(L, (funcName~'\0').ptr);
        assert(lua_isfunction(L, TOP), "Variable "~funcName~" is not a function");
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
                return LuaVoid(invalid);
            else
                return InterpreterResult!T(invalid, T.init);
        }


        static if(is(T == LuaVoid))
            return LuaVoid(valid);
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
            return InterpreterResult!T(valid, getFromIndex!T(TOP));

    }


    public void expose(string func)()
    {
        mixin(checkLuaState);
        // {
            lua_pushcfunction(L, &mixin(func));
            lua_setglobal(L, (func~"\0").ptr);
        // }
    }

    public bool hasFunction(string funcName)
    {
        mixin(checkLuaState);
        lua_getglobal(L, (funcName~'\0').ptr);
        return lua_isfunction(L, TOP);
    }

    /**
    *   Use void to get a table
    */
    public T get(T)(string varName)
    {
        mixin(checkLuaState);
        lua_getglobal(L, (varName~'\0').ptr);
        static if(!is(T == void))
            return getFromIndex!T(TOP);
    }
    public void getTable(string tableName){return get!void(tableName);}
    public T getTableField(T)(string field, int ind)
    {
        assert(lua_istable(L, ind), "Index on lua stack is not a table");
        assert(lua_getfield(L, ind, (field~'\0').ptr) == LUA_OK, "Could not get field named '"~field~"' from table");
        return getFromIndex!T(field, TOP);
    }


    ~this()
    {
        if(L != null)
            lua_close(L);
        L = null;
    }


    alias L this;
}

nothrow int hello(lua_State* state)
{
    lua_pushnumber(state, 230);
    return 1;
}

LuaInterpreter startLuaInterpreter(string entryPoint)
{
    static import std.stdio;
    LuaInterpreter interp = new LuaInterpreter();
    interp.expose!"hello";

    interp.loadFile(entryPoint);
    assert(interp.hasFunction("HipInitialize") &&
           interp.hasFunction("HipUpdate") &&
           interp.hasFunction("HipRender"),
    "Lua entrypoint "~entryPoint~" must implement the functions HipInitialize, HipUpdate and HipRender");

    interp.call!void("initialize");

    return interp;
}


version(all):