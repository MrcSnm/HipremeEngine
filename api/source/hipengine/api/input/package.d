module hipengine.api.input;
public import hipengine.api.math.vector;
public import hipengine.api.input.mouse;
public import hipengine.api.input.gamepad;


void initInput()
{
    version(Script)
    {
        import hipengine.internal;
        loadSymbol!isKeyPressed;
        loadSymbol!isKeyJustPressed;
        loadSymbol!isKeyJustReleased;
        loadSymbol!getKeyDownTime;
        loadSymbol!getKeyUpTime;
        loadSymbol!isMouseButtonPressed;
        loadSymbol!isMouseButtonJustPressed;
        loadSymbol!isMouseButtonJustReleased;
        loadSymbol!getTouchPosition;
        loadSymbol!getTouchDeltaPosition;
        loadSymbol!getScroll;

        //Gamepad
        loadSymbol!getGamepadCount;
        loadSymbol!getGamepad;
        loadSymbol!getAnalog;
        loadSymbol!isGamepadButtonPressed;
    }
}

version(Have_hipreme_engine)
{
    public import event.api;
}
else
{
    extern(C) bool function(char key, uint id = 0) isKeyPressed;
    extern(C) bool function(char key, uint id = 0) isKeyJustPressed;
    extern(C) bool function(char key, uint id = 0) isKeyJustReleased;
    extern(C) float function(char key, uint id = 0) getKeyDownTime;
    extern(C) float function(char key, uint id = 0) getKeyUpTime;
    extern(C) bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonPressed;
    extern(C) bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonJustPressed;
    extern(C) bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonJustReleased;
    extern(C) immutable(Vector2*) function(uint id = 0) getTouchPosition;
    extern(C) Vector2 function(uint id=0) getTouchDeltaPosition;
    extern(C) Vector3 function(uint id=0) getScroll;
    extern(C) ubyte function() getGamepadCount;
    extern(C) AHipGamepad function(ubyte id = 0) getGamepad;
    extern(C) Vector3 function(HipGamepadAnalogs analog, ubyte id = 0) getAnalog;
    extern(C) bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonPressed;
}