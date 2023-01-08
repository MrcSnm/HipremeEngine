module hip.event.handlers.inputmap;
import hip.util.reflection;
import std.json;
import hip.filesystem.hipfs;
import hip.error.handler;
import hip.api.input;

class HipInputMap : IHipInputMap
{
    alias Context = IHipInputMap.Context;
    Context[string] inputMapping;
    ubyte id;
    //registerInputAction("menu", MOUSE_BTN_R, TOUCH_0 | TOUCH_1, KEY_WINDOWS)
    private pragma(inline) Context* getAction(string actionName)
    {
        Context* ctx = actionName in inputMapping;
        if(ctx == null)
        {
            ErrorHandler.showErrorMessage("HipInputMap action getter error",
            '"'~actionName~"' does not exists on input mapping");
        }
        return ctx;
    }
    float isActionPressed(string actionName)
    {
        Context* c = getAction(actionName);
        if(!c) return 0.0f;
        float greatest = 0;
        foreach(g; c.btns) if(isGamepadButtonPressed(g, id))
            greatest = 1.0f;
        foreach(k; c.keys) if(isKeyPressed(k, id))
            greatest = 1.0f;
        return greatest;
    }
    float isActionJustPressed(string actionName)
    {
        Context* c = getAction(actionName);
        if(!c) return 0.0f;
        float greatest = 0;
        foreach(g; c.btns) if(isGamepadButtonJustPressed(g, id))
            greatest = 1.0f;
        foreach(k; c.keys) if(isKeyJustPressed(k, id))
            greatest = 1.0f;
        return greatest;
    }
    float isActionJustReleased(string actionName)
    {
        Context* c = getAction(actionName);
        if(!c) return 0.0f;
        float greatest = 0;
        foreach(g; c.btns) if(isGamepadButtonJustReleased(g, id))
            greatest = 1.0f;
        foreach(k; c.keys) if(isKeyJustReleased(k, id))
            greatest = 1.0f;
        return greatest;
    }

    void registerInputAction(string actionName, Context ctx)
    {
        mixin(ErrorHandler.assertReturn!q{actionName != ""}("Register Input Action should contain a name"));
        inputMapping[actionName] = ctx;

    }

    @ExportD("File") static IHipInputMap parseInputMap(string file, ubyte id = 0)
    {
        void[] output;
        if(HipFS.read(file, output))
            return parseInputMap(cast(ubyte[])output, file, id);
        import hip.error.handler;
        ErrorHandler.showWarningMessage("Could not parse input map ",file);
        return null;
    }
    @ExportD("Mem") static IHipInputMap parseInputMap(ubyte[] file, string fileName, ubyte id = 0)
    {
        version(WebAssembly)
        {
            return null;
        }
        else
        {
            HipInputMap ret = new HipInputMap();
            JSONValue inputJson = parseJSON(cast(string)file);

            JSONValue* temp = ("actions" in inputJson.object);
            ErrorHandler.assertLazyErrorMessage(temp != null, "HipInputMap wrong formatting", 
            "\"actions\" not found in "~fileName);

            foreach(k, v; temp.object)
            {
                string actionName = k;
                JSONValue* kb = ("keyboard" in v.object);
                JSONValue* gp = ("gamepad" in v.object);

                Context ctx;
                if(kb != null)
                {
                    JSONValue[] keys = kb.array;
                    foreach(key; keys)
                        ctx.keys~= key.str[0];
                }
                if(gp != null)
                {
                    JSONValue[] btns = gp.array;
                    foreach(btn; btns)
                        ctx.btns ~=  gamepadButtonFromString(btn.str);
                }
                ret.inputMapping[actionName] = ctx;
                ctx.name = actionName;
            }
            return ret;
        }
    }
}


mixin ExportDFunctions!(hip.event.handlers.inputmap);