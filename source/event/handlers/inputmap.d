module event.handlers.inputmap;
import data.hipfs;
import hipengine.api.input;
import error.handler;
import std.json;

//Public API

interface IHipInputMap
{
    void registerInputAction(string actionName);
}


class HipInputMap
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
        foreach(k; c.keys)
        {
            if(isKeyJustReleased(k, id))
                greatest = 1.0f;

            import std.stdio;writeln(isKeyPressed(k, id));
        }
        return greatest;
    }

    void registerInputAction(string actionName, Context ctx)
    {
        mixin(ErrorHandler.assertReturn!q{actionName != ""}("Register Input Action should contain a name"));
        inputMapping[actionName] = ctx;

    }

    static HipInputMap parseInputMap(string file)
    {
        void[] output;
        if(HipFS.read(file, output))
            return parseInputMap(cast(ubyte[])output, file);
        return null;
    }
    static HipInputMap parseInputMap(ubyte[] file, string fileName, ubyte id = 0)
    {
        HipInputMap ret = new HipInputMap();
        JSONValue inputJson = parseJSON(cast(string)file);

        JSONValue* temp = ("actions" in inputJson.object);
        ErrorHandler.assertErrorMessage(temp != null, "HipInputMap wrong formatting", 
        "\"actions\" not found in "~fileName);

        foreach(k, v; temp.object)
        {
            string actionName = k;
            float delegate()[] validations;
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