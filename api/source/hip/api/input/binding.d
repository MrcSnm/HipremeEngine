module hip.api.input.binding;


private alias thisModule = __traits(parent, {});
void initInput()
{
    version(Script)
    {
        import hip.api.internal;
        loadModuleFunctionPointers!thisModule;
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
    public import hip.api.input.inputmap;
    public import hip.api.input.keyboard;
    public import hip.api.renderer.viewport:Viewport;
    
    extern(System)
    {
        //Keyboard functions
        bool function(char key, uint id = 0) isKeyPressed;
        bool function(char key, uint id = 0) isKeyJustPressed;
        bool function(char key, uint id = 0) isKeyJustReleased;
        float function(char key, uint id = 0) getKeyDownTime;
        float function(char key, uint id = 0) getKeyUpTime;

        //Mouse/Touch functions
        bool function(HipMouseButton btn = HipMouseButton.any, uint id = 0) isMouseButtonPressed;
        bool function(HipMouseButton btn = HipMouseButton.any, uint id = 0) isMouseButtonJustPressed;
        bool function(HipMouseButton btn = HipMouseButton.any, uint id = 0) isMouseButtonJustReleased;

        ///Gets Raw touch/mouse position
        float[2] function(uint id = 0) getTouchPosition;
        ///Gets normallized to the window touch/mouse position
        float[2] function(uint id = 0) getNormallizedTouchPosition;
        ///Gets touch position in world transform. The world transform can both be based in Viewport argument, if none is passed, it is based on the currently active viewport
        float[2] function(uint id = 0, Viewport vp = null) getWorldTouchPosition;
        float[2] function(uint id=0) getTouchDeltaPosition;
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

        const(HipButton)* function(HipKey key, HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no) addKeyboardListener;

        const(HipButton)* function (HipMouseButton btn, HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no) addTouchListener;



        bool function(const(HipButton)* button) removeKeyboardListener;
        bool function(const(HipButton)* btn) removeTouchListener;
    }
}


alias addMouseListener = addTouchListener;
alias isTouchPressed = isMouseButtonPressed;
alias isTouchJustPressed = isMouseButtonJustPressed;
alias isTouchJustReleased = isMouseButtonJustReleased;