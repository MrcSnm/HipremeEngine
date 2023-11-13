module hip.event.api;
public import hip.global.gamedef;
public import hip.event.handlers.inputmap;
public import hip.api.input.button:HipButton;
public import hip.api.renderer.viewport:Viewport;
public import hip.api.input.keyboard;
public import hip.api.input.mouse;

extern(System)
{
    bool isKeyPressed(char key, uint id = 0);
    bool isKeyJustPressed(char key, uint id = 0);
    bool isKeyJustReleased(char key, uint id = 0);
    float getKeyDownTime(char key, uint id = 0);
    float getKeyUpTime(char key, uint id = 0);
    ubyte getMulticlickCount(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isDoubleClicked(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.any, uint id = 0);
    float[2] getTouchPosition(uint id=0);
    float[2] getNormallizedTouchPosition(uint id=0);
    float[2] getWorldTouchPosition(uint id=0, Viewport vp = null);
    float[2] getTouchDeltaPosition(uint id=0);
    float[3] getScroll() ;
    ubyte getGamepadCount();
    AHipGamepad getGamepad(ubyte id);
    bool setGamepadVibrating(float vibrationPower, float time, ubyte id = 0);
    float[3] getAnalog(HipGamepadAnalogs analog, ubyte id = 0);
    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0);
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0);
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0);
    bool areGamepadButtonsPressed(scope HipGamepadButton[] btns, ubyte id = 0);
    bool areGamepadButtonsJustPressed(scope HipGamepadButton[] btns, ubyte id = 0);
    bool areGamepadButtonsJustReleased(scope HipGamepadButton[] btns, ubyte id = 0);
    float getGamepadBatteryStatus(ubyte id = 0);
    bool isGamepadWireless(ubyte id = 0);
    const(HipButton)* addKeyboardListener(HipKey key, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no);
    const(HipButton)* addTouchListener(HipMouseButton btn, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no);

    const(ScrollListener)* addScrollListener(HipScrollAction onScroll,
        AutoRemove remove = AutoRemove.no);

    const(TouchMoveListener)* addTouchMoveListener(HipTouchMoveAction onMove,
        AutoRemove remove = AutoRemove.no);
    bool removeKeyboardListener(const(HipButton)* btn);
    bool removeTouchListener(const(HipButton)* btn);
    bool removeScrollListener(const(ScrollListener)* l);
    bool removeTouchMoveListener(const(TouchMoveListener)* l);
}