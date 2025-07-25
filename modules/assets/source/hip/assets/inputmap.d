module hip.assets.inputmap;
import hip.util.reflection;
import hip.data.jsonc;
import hip.error.handler;
import hip.api.input.inputmap;
import hip.api.data.asset;

//Defined at hip.event.api
private extern(System)
{
    bool isKeyPressed(char key, uint id = 0);
    bool isKeyJustPressed(char key, uint id = 0);
    bool isKeyJustReleased(char key, uint id = 0);

    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0);
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0);
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0);
    float[3] getAnalog(HipGamepadAnalogs analog, ubyte id = 0);
}

private enum Axes : ubyte
{
    x = 0b1,
    y = 0b10,
    z = 0b11,
    leftStick  = 1 << 2,
    rightStick = 1 << 3,

    stickX = 0b01 << 4,
    stickY = 0b10 << 4,
    stickZ = 0b11 << 4
}

Axes getStickFromString(Axes baseAxis, string whichStick, string stickAxis)
{
    Axes stick = whichStick == "left" ? Axes.leftStick : Axes.rightStick;
    switch(stickAxis)
    {
        case "x": return cast(Axes)(Axes.stickX | baseAxis | stick);
        case "y": return cast(Axes)(Axes.stickY | baseAxis | stick);
        case "z": return cast(Axes)(Axes.stickZ | baseAxis | stick);
        default:
            assert(false, "Can only accept 'x', 'y', 'z' from getStick");
    }
}





class HipInputMap : HipAsset, IHipInputMap
{
    alias Context = IHipInputMap.Context;
    alias AxisContext = IHipInputMap.AxisContext;

    Context[string] inputMapping;

    AxisContext[][string] directionalsMapping;
    ubyte id;
    this()
    {
        super("HipInputMap");
    }
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
    private pragma(inline) AxisContext[] getDirectional(string directionalName)
    {
        AxisContext[]* ctx = directionalName in directionalsMapping;
        if(ctx == null)
        {
            ErrorHandler.showErrorMessage("HipInputMap directionals getter error",
            '"'~directionalName~"' does not exists on direction mapping");
        }
        return *ctx;
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


    Vector3 getAxis(string directionalName)
    {
        AxisContext[] axisArray = getDirectional(directionalName);
        Vector3 ret;
        foreach(AxisContext ax; axisArray)
        {
            int i = 0;
            switch(ax.axis & Axes.z)
            {
                case Axes.x: break;
                case Axes.y: i = 1; break;
                case Axes.z: i = 2; break;
                default:
                    throw new Exception("Invalid Axis context found.");
            }
            if(ax.axis & Axes.leftStick || ax.axis & Axes.rightStick)
            {
                ret[i]+= getAnalog((ax.axis & Axes.leftStick) != 0 ? HipGamepadAnalogs.leftStick : HipGamepadAnalogs.rightStick, id)[i];
                continue;
            }
            if(isGamepadButtonPressed(ax.btn, id) || isKeyPressed(ax.key, id))
                ret[i]+= (cast(float)ax.value / 127.0);
        }
        return ret;
    }

    void registerInputAction(string actionName, Context ctx)
    {
        mixin(ErrorHandler.assertReturn!q{actionName != ""}("Register Input Action should contain a name"));
        inputMapping[actionName] = ctx;
    }
    override void onFinishLoading() {}
    override bool isReady() const { return inputMapping !is null; }
    override void onDispose() {}

    @ExportD("Mem") static IHipInputMap parseInputMap(const ubyte[] file, string fileName, ubyte id = 0)
    {
        import hip.util.exception;
        HipInputMap ret = new HipInputMap();
        JSONValue inputJson = parseJSON(cast(string)file);
        enforce(inputJson.type == JSONType.object, "Input map at path "~fileName~" must be an object");

        //Parse "actions"
        JSONValue* actions = ("actions" in inputJson);
        if(actions)
        {
            foreach(k, v; actions.object)
            {
                string actionName = k;
                JSONValue* kb = ("keyboard" in v.object);
                JSONValue* gp = ("gamepad" in v.object);

                Context ctx;
                if(kb != null)
                {
                    foreach(key; kb.array) //Keyboard
                        ctx.keys~= key.str[0];
                }
                if(gp != null)
                {
                    foreach(btn; gp.array) //Gamepad
                        ctx.btns ~=  gamepadButtonFromString(btn.str);
                }
                ret.inputMapping[actionName] = ctx;
                ctx.name = actionName;
            }
        }
        JSONValue* directionals = "directionals" in inputJson;
        if(directionals)
        {
            enforce(directionals.type == JSONType.object, "Directionals must be an object.");
            foreach(string directionalName, JSONValue dV; directionals.object)
            {
                enforce(dV.type == JSONType.object, "Directionals must hold an object.");
                foreach(string axis, JSONValue content; dV)
                {
                    AxisContext axisCtx;
                    switch(axis)
                    {
                        case "x":
                            axisCtx.axis = Axes.x;
                            break;
                        case "y":
                            axisCtx.axis = Axes.y;
                            break;
                        case "z":
                            axisCtx.axis = Axes.z;
                            break;
                        default:
                            enforce(false, "Directional named "~directionalName~" must hold an object named 'x', 'y' or 'z'");
                    }
                    enforce(content.type == JSONType.array, "Axis '"~axis~"' of directional '"~directionalName~"' must hold an array.");
                    foreach(JSONValue value; content.array)
                    {
                        AxisContext newAxis = axisCtx;
                        enforce(value.type == JSONType.object, "Axis '"~axis~"' of directional '"~directionalName~"' can only contain an array of objects.");

                        JSONValue* an = "analog" in value;
                        JSONValue* kb = "keyboard" in value;
                        JSONValue* gp = "gamepad" in value;
                        JSONValue* v = "value" in value;

                        if(kb || gp)
                        {
                            enforce(!an, "If your input has either a keyboard or gamepad, it can't have an analog.");
                            if(kb)
                            {
                                enforce(!an, "Keyboard can only receive a string.");
                                enforce(kb.type == JSONType.string, "Keyboard can only receive a string.");
                                newAxis.key = kb.str[0];
                            }
                            if(gp)
                            {
                                enforce(gp.type == JSONType.string, "Gamepad can only receive a string.");
                                newAxis.btn = gamepadButtonFromString(gp.str);
                            }
                            enforce(v && (v.type == JSONType.integer || v.type == JSONType.float_) && (v.floating >= -1.0 && v.floating <= 1.0), "directionals input must have a value and it must be a float between -1 and 1");
                            newAxis.value = cast(byte)((cast(int)v.floating) * 127);
                        }
                        else if(an)
                        {
                            enforce(!kb && !gp, "If your input has an analog, it can't contain a gamepad or keyboard");
                            enforce(an.type == JSONType.string && (an.str == "left" || an.str == "right"), "Your analog must map to either 'left' or 'right'");
                            JSONValue* stickAxis = "axis" in value;
                            enforce(stickAxis && stickAxis.type == JSONType.string, "An analog must have an axis, and its type must be a string");
                            newAxis.axis = getStickFromString(cast(Axes)axisCtx.axis, an.str, stickAxis.str);
                        }

                        ret.directionalsMapping[directionalName]~= newAxis;
                    }

                }
            }
        }

        return ret;
    }
}
