module hip.api.input.inputmap;

public import hip.api.input.gamepad;

interface IHipInputMap
{
    struct Context
    {
        ///Got from the object that contains input information
        string name;
        ///Got from the "keyboard" properties from input json
        char[] keys;
        ///Got from "gamepad" properties from input json
        HipGamepadButton[] btns;
    }
    void registerInputAction(string actionName, Context ctx);
    float isActionPressed(string actionName);
    float isActionJustPressed(string actionName);
    float isActionJustReleased(string actionName);

    version(Script)
    {
        static IHipInputMap parseInputMap(string file, ubyte id = 0){return parseInputMap_File(file,id);}
        static IHipInputMap parseInputMap(ubyte[] file, string fileName, ubyte id = 0){return parseInputMap_Mem(file, fileName,id);}
    }
    else version(Have_hipreme_engine)
    {
        static alias parseInputMap = HipInputMap.parseInputMap;
    }
}
version(Script)
{
    extern(System)
    {
        IHipInputMap function(string file, ubyte id = 0) parseInputMap_File;
        IHipInputMap function(ubyte[] file, string fileName, ubyte id = 0) parseInputMap_Mem;
    }
}

version(Have_hipreme_engine)
    public import hip.event.handlers.inputmap;
