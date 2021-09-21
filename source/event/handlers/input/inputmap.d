module event.handlers.input.inputmap;
import error.handler;

//Public API

interface IHipInputMap
{
    void registerInputAction(string actionName);

}

class HipInputMap
{

    //registerInputAction("menu", MOUSE_BTN_R, TOUCH_0 | TOUCH_1, KEY_WINDOWS)
    void registerInputAction(string actionName)
    {
        mixin(ErrorHandler.assertReturn!q{actionName != ""}("Register Input Action should contain a name"));
        
    }
}