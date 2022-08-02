module hip.api.input.binding;

void initInput()
{
    version(Script)
    {
        import hip.api.internal;

        loadSymbols!(
            isKeyPressed,
            isKeyJustPressed,
            isKeyJustReleased,
            getKeyDownTime,
            getKeyUpTime,
            isMouseButtonPressed,
            isMouseButtonJustPressed,
            isMouseButtonJustReleased,
            getTouchPosition,
            getTouchDeltaPosition,
            getScroll,

            //Gamepad
            getGamepadCount,
            getGamepad,
            getAnalog,
            isGamepadButtonPressed,
            isGamepadButtonJustPressed,
            isGamepadButtonJustReleased,
            setGamepadVibrating,
            getGamepadBatteryStatus,
            isGamepadWireless
        );
        enum InputMapClass = "HipInputMap";
        mixin(loadSymbolsFromExportD!(InputMapClass,
            parseInputMap_File,
            parseInputMap_Mem
        ));

    }
}


version(Have_hipreme_engine)
{
    public import hip.event.api;
}
else
{
    public import hip.api.input.button;
    public import hip.api.input.gamepad;
    public import hip.api.input.mouse;
    extern(System)
    {
        //Keyboard functions
        bool function(char key, uint id = 0) isKeyPressed;
        bool function(char key, uint id = 0) isKeyJustPressed;
        bool function(char key, uint id = 0) isKeyJustReleased;
        float function(char key, uint id = 0) getKeyDownTime;
        float function(char key, uint id = 0) getKeyUpTime;

        //Mouse/Touch functions
        bool function(HipMouseButton btn = HipMouseButton.left, uint id = 0) isMouseButtonPressed;
        bool function(HipMouseButton btn = HipMouseButton.left, uint id = 0) isMouseButtonJustPressed;
        bool function(HipMouseButton btn = HipMouseButton.left, uint id = 0) isMouseButtonJustReleased;
        immutable(int[2]*) function(uint id = 0) getTouchPosition;
        int[2] function(uint id=0) getTouchDeltaPosition;
        float[3] function(uint id=0) getScroll;
        //Gamepad Functions
        ubyte function() getGamepadCount;
        AHipGamepad function(ubyte id = 0) getGamepad;
        float[3] function(HipGamepadAnalogs analog, ubyte id = 0) getAnalog;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonPressed;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonJustPressed;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonJustReleased;
        bool function(float vibrationPower, float time, ubyte id = 0) setGamepadVibrating;
        float function(ubyte id = 0) getGamepadBatteryStatus;
        bool function(ubyte id = 0) isGamepadWireless;
    }
}