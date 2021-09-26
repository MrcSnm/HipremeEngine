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
        loadSymbol!setGamepadVibrating;
        loadSymbol!getGamepadBatteryStatus;
        loadSymbol!isGamepadWireless;
    }
}

version(Have_hipreme_engine)
{
    public import event.api;
}
else
{
    extern(System)
    {
        //Keyboard functions
        bool function(char key, uint id = 0) isKeyPressed;
        bool function(char key, uint id = 0) isKeyJustPressed;
        bool function(char key, uint id = 0) isKeyJustReleased;
        float function(char key, uint id = 0) getKeyDownTime;
        float function(char key, uint id = 0) getKeyUpTime;

        //Mouse/Touch functions
        bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonPressed;
        bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonJustPressed;
        bool function(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0) isMouseButtonJustReleased;
        immutable(Vector2*) function(uint id = 0) getTouchPosition;
        Vector2 function(uint id=0) getTouchDeltaPosition;
        Vector3 function(uint id=0) getScroll;
        //Gamepad Functions
        ubyte function() getGamepadCount;
        AHipGamepad function(ubyte id = 0) getGamepad;
        Vector3 function(HipGamepadAnalogs analog, ubyte id = 0) getAnalog;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonPressed;
        bool function(float vibrationPower, float time, ubyte id = 0) setGamepadVibrating;
        float function(ubyte id = 0) getGamepadBatteryStatus;
        bool function(ubyte id = 0) isGamepadWireless;
    }
    
}