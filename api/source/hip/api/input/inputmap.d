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
}