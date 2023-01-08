module hip.bind.interpreters;


struct HipInterpreterEntry
{
    HipInterpreter intepreter = HipInterpreter.none;
    string sourceEntry;
}

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

enum HipInterpreter
{
    none,
    lua
}

alias InterpreterCFunction = extern(C) nothrow void function();
interface IHipInterpreter
{
    bool loadFile(string fileName);
    void reload();
    bool hasFunction(string funcName);
    void expose(string funcName, InterpreterCFunction func);
}


version(HipremeEngineLua)
{
    package __gshared LuaInterpreter _lua;
    public import hip.bind.interpreters.lua;
}

void startInterpreter(HipInterpreter interpreter)
{
    final switch(interpreter)
    {
        case HipInterpreter.lua:
            version(HipremeEngineLua)
                _lua = new LuaInterpreter();
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
            version(HipremeEngineLua)
            {
                assert(_lua.loadFile(entryPoint) && 
                _lua.hasFunction("HipInitialize") &&
                _lua.hasFunction("HipUpdate") &&
                _lua.hasFunction("HipRender"),
            "Lua entrypoint "~entryPoint~" must implement the functions HipInitialize, HipUpdate and HipRender");

                _lua.call!LuaVoid("HipInitialize");//, "Invalid HipInitialize";
            }
            break;
        case HipInterpreter.none:break;

    }
    
}
void sendInterpreterFunc(alias func)(HipInterpreter interpreter)
{
    final switch(interpreter)
    {
        case HipInterpreter.lua:
            version(HipremeEngineLua)
            {
                _lua.expose(__traits(identifier, func), &externLua!func);
            }
            break;
        case HipInterpreter.none:
            break;
    }
}


void reloadInterpreter()
{
    version(HipremeEngineLua)
    {
        if(_lua !is null)
            _lua.reload();
    }
}

void renderInterpreter()
{
    version(HipremeEngineLua)
    {
        if(_lua !is null)
            _lua.call!(LuaVoid)("HipRender");
    }
}

void updateInterpreter()
{
    version(HipremeEngineLua)
    {
        if(_lua !is null)
            _lua.call!(LuaVoid)("HipUpdate");
    }
}
