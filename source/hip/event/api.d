module hip.event.api;
public import hip.global.gamedef;
public import hip.api.input.button:HipButton;
public import hip.api.renderer.viewport:Viewport;
import hip.hiprenderer;
import hip.event.dispatcher;
import hip.systems.game;
import hip.math.vector;

//TODO: Find a way to remove export from release
export extern(System)
{
    
    bool isKeyPressed(char key, uint id = 0) 
    {
        return sys.dispatcher.isKeyPressed(key, id);
    }
    bool isKeyJustPressed(char key, uint id = 0) 
    {
        return sys.dispatcher.isKeyJustPressed(key, id);
    }
    bool isKeyJustReleased(char key, uint id = 0) 
    {
        return sys.dispatcher.isKeyJustReleased(key, id);
    }
    float getKeyDownTime(char key, uint id = 0) 
    {
        return sys.dispatcher.getKeyDownTime(key, id);
    }
    float getKeyUpTime(char key, uint id = 0) 
    {
        return sys.dispatcher.getKeyUpTime(key, id);
    }
    ubyte getMulticlickCount(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        return sys.dispatcher.getMulticlickCount(btn, id);
    }
    bool isDoubleClicked(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        return sys.dispatcher.isDoubleClicked(btn, id);
    }
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0) 
    {
        return sys.dispatcher.isMouseButtonPressed(btn, id);
    }
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0) 
    {
        return sys.dispatcher.isMouseButtonJustPressed(btn, id);
    }
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.any, uint id = 0) 
    {
        return sys.dispatcher.isMouseButtonJustReleased(btn, id);
    }
    float[2] getTouchPosition(uint id=0) 
    {
        return cast(float[2])sys.dispatcher.getTouchPosition(id);
    }


    float[2] getNormallizedTouchPosition(uint id=0) 
    {
        import hip.hiprenderer;
        float[2] ret = cast(float[2])sys.dispatcher.getTouchPosition(id);
        ret[0]/= HipRenderer.width;
        ret[1]/= HipRenderer.height;
        return ret;
    }

    float[2] getWorldTouchPosition(uint id=0, Viewport vp = null) 
    {
        import hip.math.utils:clamp;
        float[2] ret = cast(float[2])sys.dispatcher.getTouchPosition(id);
        if(vp is null)
            vp = HipRenderer.getCurrentViewport();

        ret[0] = clamp(((ret[0] - vp.x) / vp.width) * vp.worldWidth, 0, vp.worldWidth);
        ret[1] = clamp(((ret[1] - vp.y) / vp.height) * vp.worldHeight, 0, vp.worldHeight);
        

        return ret;
    }
    float[2] getTouchDeltaPosition(uint id=0) 
    {
        return cast(float[2])sys.dispatcher.getTouchDeltaPosition(id);
    }
    float[3] getScroll() 
    {
        return cast(float[3])sys.dispatcher.getScroll();
    }
    ubyte getGamepadCount()
    {
        return sys.dispatcher.getGamepadCount();
    }
    AHipGamepad getGamepad(ubyte id)
    {
        return sys.dispatcher.getGamepad(id);
    }
    bool setGamepadVibrating(float vibrationPower, float time, ubyte id = 0)
    {
        return sys.dispatcher.setGamepadVibrating(vibrationPower, time, id);
    }
    float[3] getAnalog(HipGamepadAnalogs analog, ubyte id = 0)
    {
        return cast(float[3])sys.dispatcher.getAnalog(analog);
    }
    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0)
    {
        return sys.dispatcher.isGamepadButtonPressed(btn, id);
    }
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0)
    {
        return sys.dispatcher.isGamepadButtonJustPressed(btn, id);
    }
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0)
    {
        return sys.dispatcher.isGamepadButtonJustReleased(btn, id);
    }
    bool areGamepadButtonsPressed(scope HipGamepadButton[] btns, ubyte id = 0)
    {
        return sys.dispatcher.areGamepadButtonsPressed(btns, id);
    }
    bool areGamepadButtonsJustPressed(scope HipGamepadButton[] btns, ubyte id = 0)
    {
        return sys.dispatcher.areGamepadButtonsJustPressed(btns, id);
    }
    bool areGamepadButtonsJustReleased(scope HipGamepadButton[] btns, ubyte id = 0)
    {
        return sys.dispatcher.areGamepadButtonsJustReleased(btns, id);
    }

    float getGamepadBatteryStatus(ubyte id = 0)
    {
        return sys.dispatcher.getGamepadBatteryStatus(id);
    }
    bool isGamepadWireless(ubyte id = 0)
    {
        return sys.dispatcher.isGamepadWireless(id);
    }

    const(HipButton)* addKeyboardListener(HipKey key, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no)
    {
        return sys.scriptInputListener.addKeyboardListener(key,action,type,remove);
    }

    const(HipButton)* addTouchListener(HipMouseButton btn, 
        HipInputAction action,
        HipButtonType type = HipButtonType.down,
        AutoRemove remove = AutoRemove.no)
    {
        import hip.console.log;
        logln("Added touch");
        return sys.scriptInputListener.addTouchListener(btn,action,type,remove);
    }

    const(ScrollListener)* addScrollListener(HipScrollAction onScroll,
        AutoRemove remove = AutoRemove.no)
    {
        return sys.scriptInputListener.addScrollListener(onScroll, remove);
    }

    const(TouchMoveListener)* addTouchMoveListener(HipTouchMoveAction onMove,
        AutoRemove remove = AutoRemove.no)
    {
        return sys.scriptInputListener.addTouchMoveListener(onMove, remove);
    }

    bool removeKeyboardListener(const(HipButton)* btn)
    {
        return sys.scriptInputListener.removeKeyboardListener(btn);
    }
    bool removeTouchListener(const(HipButton)* btn)
    {
        return sys.scriptInputListener.removeTouchListener(btn);
    }
    bool removeScrollListener(const(ScrollListener)* l)
    {
        return sys.scriptInputListener.removeScrollListener(l);
    }
    bool removeTouchMoveListener(const(TouchMoveListener)* l)
    {
        return sys.scriptInputListener.removeTouchMoveListener(l);
    }


}