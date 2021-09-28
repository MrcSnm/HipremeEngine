module event.handlers.inputmap;
import hipengine.api.input;
import error.handler;

//Public API

interface IHipInputMap
{
    void registerInputAction(string actionName);

}

class HipInputMap
{

    //registerInputAction("menu", MOUSE_BTN_R, TOUCH_0 | TOUCH_1, KEY_WINDOWS)

    float function()[string] inputMapping;
    void registerInputAction(string actionName, float function() actionHappenned)
    {
        mixin(ErrorHandler.assertReturn!q{actionName != ""}("Register Input Action should contain a name"));
        inputMapping[actionName] = actionHappenned;

        registerInputAction("left", ()
        {
            if(isGamepadButtonPressed(HipGamepadButton.dPadLeft) || isKeyPressed('a'))
                return 1.0f;
            return getAnalog(HipGamepadAnalogs.leftStick).x;
        });

        registerInputAction("right", ()
        {
            return isGamepadButtonPressed(HipGamepadButton.dPadRight) || isKeyPressed('d');
        });
        registerInputAction("up", ()
        {
            return isGamepadButtonPressed(HipGamepadButton.dPadUp) || isKeyPressed('w');
        });
        registerInputAction("down", ()
        {
            return isGamepadButtonPressed(HipGamepadButton.dPadDown) || isKeyPressed('s');
        });
    }



}