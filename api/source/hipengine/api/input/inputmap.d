module hipengine.api.input.inputmap;
public import hipengine.api.input.gamepad;

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
}
version(Script)
{
    extern(C) IHipInputMap function(string file, ubyte id = 0) parseInputMap_File;
    extern(C) IHipInputMap function(ubyte[] file, string fileName, ubyte id = 0) parseInputMap_Mem;

    alias HipInputMap = IHipInputMap;
}