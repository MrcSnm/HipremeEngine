module hip.event.handlers.inputmap;
public import hip.api.input.inputmap;

extern class HipInputMap : IHipInputMap
{
    static IHipInputMap parseInputMap(ubyte[] file, string fileName, ubyte id = 0);
    
    void registerInputAction(string actionName, IHipInputMap.Context ctx);
    float isActionPressed(string actionName);
    float isActionJustPressed(string actionName);
    float isActionJustReleased(string actionName);
    
}

alias parseInputMap_Mem = HipInputMap.parseInputMap;