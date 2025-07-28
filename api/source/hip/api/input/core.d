module hip.api.input.core;
public import hip.api.input.mouse;
public import hip.api.input.keyboard;
public import hip.api.input.gamepad;
public import hip.api.renderer.viewport;

interface IHipInput
{
    bool isKeyPressed(char key, uint id = 0);
    bool isKeyJustPressed(char key, uint id = 0);
    bool isKeyJustReleased(char key, uint id = 0);
    float getKeyDownTime(char key, uint id = 0);
    float getKeyUpTime(char key, uint id = 0);

    //Mouse/Touch functions
    ubyte getMulticlickCount(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isDoubleClicked(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.any, uint id = 0);

    ///Gets Raw touch/mouse position
    float[2] getTouchPosition(uint id = 0);
    ///Gets normallized to the window touch/mouse position
    float[2] getNormallizedTouchPosition(uint id = 0);
    alias getNormallizedMousePosition = getNormallizedTouchPosition;
    ///Gets touch position in world transform. The world transform can both be based in Viewport argument, if none is passed, it is based on the currently active viewport
    float[2] getWorldTouchPosition(uint id = 0, Viewport vp = null);
    alias getWorldMousePosition = getWorldTouchPosition;
    float[2] getTouchDeltaPosition(uint id=0);
    float[3] getScroll(uint id=0);
    //Gamepad Functions
    ubyte getGamepadCount();
    AHipGamepad getGamepad(ubyte id = 0);
    float[3] getAnalog(HipGamepadAnalogs analog, ubyte id = 0);
    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0);
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0);
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0);


    bool areGamepadButtonsPressed(scope HipGamepadButton[] btn, ubyte id = 0);
    bool areGamepadButtonsJustPressed(scope HipGamepadButton[] btn, ubyte id = 0);
    bool areGamepadButtonsJustReleased(scope HipGamepadButton[] btn, ubyte id = 0);
    
    bool setGamepadVibrating(float vibrationPower, float time, ubyte id = 0);
    float getGamepadBatteryStatus(ubyte id = 0);
    bool isGamepadWireless(ubyte id = 0);

    alias isTouchPressed = isMouseButtonPressed;
    alias isTouchJustPressed = isMouseButtonJustPressed;
    alias isTouchJustReleased = isMouseButtonJustReleased;
}

interface IHipInputListener
{
    const(HipButton)* addKeyboardListener(HipKey key, HipInputAction action,
    HipButtonType type = HipButtonType.down,
    AutoRemove remove = AutoRemove.no);

    const(HipButton)* addTouchListener(HipMouseButton btn, HipInputAction action,
    HipButtonType type = HipButtonType.down,
    AutoRemove remove = AutoRemove.no);

    const(ScrollListener)*  addScrollListener(HipScrollAction onScoll,
    AutoRemove remove = AutoRemove.no);

    const(TouchMoveListener)* addTouchMoveListener(HipTouchMoveAction onMove,
    AutoRemove remove = AutoRemove.no);

    bool removeKeyboardListener(const(HipButton)* button);
    bool removeTouchListener(const(HipButton)* btn);
    bool removeScrollListener(const(ScrollListener)*);
    bool removeTouchMoveListener(const(TouchMoveListener)*);
}

private __gshared
{
    IHipInput _input;
    IHipInputListener _inputListener;
}
void setHipInput(IHipInput input){_input = input;}
void setHipInputListener(IHipInputListener inputListener){_inputListener = inputListener;}
pragma(inline, true)
{
    IHipInput HipInput(){return _input;}
    IHipInputListener HipInputListener(){return _inputListener;}
}