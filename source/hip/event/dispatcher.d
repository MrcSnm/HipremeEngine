/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.event.dispatcher;
private:
    import hip.event.handlers.keyboard;
    import hip.event.handlers.mouse;
    import hip.systems.gamepad;
    import hip.windowing.window;

public:
    import hip.systems.input;
    import hip.util.time;
    import hip.hipengine.api.math.vector;
    import hip.hipengine.api.input.keyboard;
    import hip.hipengine.api.input.button;
    import hip.hipengine.api.input.mouse;
    import hip.hipengine.api.input.gamepad;



package __gshared HipGamePad[] gamepads;


/** 
 * Class used to dispatch the events for the each specific handler.
 *
 *  In the entire engine, there must be only one dispatcher. But it is possible
 *  to create more mouses and keyboards, but it is not being used yet.
 */
class EventDispatcher
{
    ulong frameCount;
    KeyboardHandler* keyboard = null;
    HipMouse mouse = null;
    HipWindow window;
    protected void delegate(uint width, uint height)[] resizeListeners;

    this(HipWindow window, KeyboardHandler *kb)
    {
        this.window = window;
        keyboard = kb;
        mouse = new HipMouse();
        HipEventQueue.newController(); //Creates controller 0
        initXboxGamepadInput();
        import hip.windowing.events;

        onKeyDown = (wchar key)
        {
            try
            {
                HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(getHipKeyFromSystem(key)));
            }
            catch(Exception e){assert(false);}
        };
        onKeyUp = (wchar key)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.keyUp, HipEventQueue.Key(getHipKeyFromSystem(key)));}
            catch(Exception e){assert(false);}
        };
        onMouseMove = (int x, int y)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.touchMove, HipEventQueue.Touch(0, x, y));}
            catch(Exception e){assert(false);}
        };
        onMouseUp = (ubyte btn, int x, int y)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.touchUp, HipEventQueue.Touch(0, x, y));}
            catch(Exception e){assert(false);}
        };
        onMouseDown = (ubyte btn, int x, int y)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.touchDown, HipEventQueue.Touch(0, x, y));}
            catch(Exception e){assert(false);}
        };

        onWindowResize = (uint width, uint height)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.windowResize, HipEventQueue.Resize(width, height));}
            catch(Exception e){assert(false);}
        };
        onWindowClosed = ()
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.exit, true);}
            catch(Exception e){assert(false);}
        };

    }
    
    bool hasQuit = false;

    void handleEvent()
    {
        window.pollWindowEvents();
        handleHipEvent();
        frameCount++;
    }


    void handleHipEvent()
    {
        
        //Now poll the cross platform input queue
        HipEventQueue.InputEvent* ev;
        while((ev = HipEventQueue.poll(0)) != null)
        {
            switch(ev.type)
            {
                case HipEventQueue.EventType.windowResize:
                    auto w = ev.get!(HipEventQueue.Resize);
                    foreach(r; resizeListeners)
                        r(w.width, w.height);
                    break;
                case HipEventQueue.EventType.touchDown:
                    auto t = ev.get!(HipEventQueue.Touch);
                    mouse.setPressed(HipMouseButton.left, true);
                    break;
                case HipEventQueue.EventType.touchUp:
                    auto t = ev.get!(HipEventQueue.Touch);
                    mouse.setPressed(HipMouseButton.left, false);
                    break;
                case HipEventQueue.EventType.touchMove:
                    auto t = ev.get!(HipEventQueue.Touch);
                    mouse.setPosition(t.xPos, t.yPos, t.id);
                    break;
                case HipEventQueue.EventType.touchScroll:
                    auto t = ev.get!(HipEventQueue.Scroll);
                    mouse.setScroll(t.x, t.y, t.z);
                    break;
                case HipEventQueue.EventType.keyDown:
                    auto k = ev.get!(HipEventQueue.Key);
                    keyboard.handleKeyDown(cast(HipKey)(k.id));
                    break;
                case HipEventQueue.EventType.keyUp:
                    auto k = ev.get!(HipEventQueue.Key);
                    keyboard.handleKeyUp(cast(HipKey)(k.id));
                    break;
                case HipEventQueue.EventType.gamepadConnected:
                    import hip.console.log;rawlog("Gamepad connected");
                    auto g = ev.get!(HipEventQueue.Gamepad);
                    if(g.id+1 > gamepads.length)
                        gamepads~= new HipGamePad();
                    gamepads[g.id].setConnected(true);
                    break;
                case HipEventQueue.EventType.gamepadDisconnected:
                    import hip.console.log;rawlog("Gamepad disconnected");
                    auto g = ev.get!(HipEventQueue.Gamepad);
                    gamepads[g.id].setConnected(false);
                    break;
                case HipEventQueue.EventType.exit:
                    hasQuit = true;
                    break;
                default:break;
            }
        }
        
        keyboard.update();
    }
    void pollGamepads(float deltaTime)
    {
        foreach (g; gamepads)
            g.poll(deltaTime);
    }

    void addOnResizeListener(void delegate(uint width, uint height) onResize)
    in{assert(onResize !is null, "onResize event must not be null.");}
    do
    {
        resizeListeners~= onResize;    
    }

    ///Public API
    Vector2 getTouchPosition(uint id = 0){return mouse.getPosition(id);}
    Vector2 getTouchDeltaPosition(uint id = 0){return mouse.getDeltaPosition(id);}
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.left, uint id = 0){return mouse.isPressed(btn);}
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.left, uint id = 0){return mouse.isJustPressed(btn);}
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.left, uint id = 0){return mouse.isJustReleased(btn);}
    Vector3 getScroll(){return mouse.getScroll();}
    bool isKeyPressed(char key, uint id = 0){return keyboard.isKeyPressed(key.toUppercase);}
    bool isKeyJustPressed(char key, uint id = 0){return keyboard.isKeyJustPressed(key.toUppercase);}
    bool isKeyJustReleased(char key, uint id = 0){return keyboard.isKeyJustReleased(key.toUppercase);}
    float getKeyDownTime(char key, uint id = 0){return keyboard.getKeyDownTime(key.toUppercase);}
    float getKeyUpTime(char key, uint id = 0){return keyboard.getKeyUpTime(key.toUppercase);}
    ubyte getGamepadCount(){return cast(ubyte)gamepads.length;}
    AHipGamepad getGamepad(ubyte id)
    {
        if(id >= gamepads.length)return null;
        return gamepads[id];
    }
    Vector3 getAnalog(HipGamepadAnalogs analog, ubyte id = 0)
    {
        if(id >= gamepads.length) return Vector3.zero;
        return gamepads[id].getAnalogState(analog);
    }
    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        return gamepads[id].isButtonPressed(btn);
    }
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        return gamepads[id].isButtonJustPressed(btn);
    }
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        return gamepads[id].isButtonJustReleased(btn);
    }
    bool isGamepadWireless(ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        return gamepads[id].isWireless();
    }
    bool setGamepadVibrating(float vibrationPower, float time, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        return gamepads[id].setVibrating(vibrationPower, time);
    }
    float getGamepadBatteryStatus(ubyte id = 0)
    {
        if(id >= gamepads.length) return 0;
        return gamepads[id].getBatteryStatus();
    }

    void postUpdate()
    {
        keyboard.postUpdate();
        mouse.postUpdate();
        foreach(g; gamepads)
            g.postUpdate();
    }
}


version(Windows)
{
    private HipKey getHipKeyFromSystem(wchar key)
    {
        import core.sys.windows.winuser;
        ushort k = ushort(key);
        assert(k > 0 && k < ubyte.max, "Key out of range");
        switch(k)
        {
            case VK_BACK: return HipKey.BACKSPACE;
            case VK_TAB: return HipKey.TAB;
            case VK_ESCAPE: return HipKey.ESCAPE;

            case VK_SHIFT: return HipKey.SHIFT;
            case VK_CONTROL: return HipKey.CTRL;
            case VK_MENU: return HipKey.ALT;
            
            case VK_RETURN: return HipKey.ENTER;
            case VK_CAPITAL: return HipKey.CAPSLOCK;
            case VK_SPACE: return HipKey.SPACE;
            case VK_PRIOR: return HipKey.PAGE_UP;
            case VK_NEXT: return HipKey.PAGE_UP;
            case VK_END: return HipKey.END;
            case VK_HOME: return HipKey.HOME;
            case VK_LEFT: return HipKey.ARROW_LEFT;
            case VK_UP: return HipKey.ARROW_UP;
            case VK_RIGHT: return HipKey.ARROW_RIGHT;
            case VK_DOWN: return HipKey.ARROW_DOWN;
            case VK_INSERT: return HipKey.INSERT;
            case VK_DELETE: return HipKey.DELETE;
            //A
            case 0x30: return HipKey._0;
            case 0x31: return HipKey._1;
            case 0x32: return HipKey._2;
            case 0x33: return HipKey._3;
            case 0x34: return HipKey._4;
            case 0x35: return HipKey._5;
            case 0x36: return HipKey._6;
            case 0x37: return HipKey._7;
            case 0x38: return HipKey._8;
            case 0x39: return HipKey._9;

            case 0x41: return HipKey.A;
            case 0x42: return HipKey.B;
            case 0x43: return HipKey.C;
            case 0x44: return HipKey.D;
            case 0x45: return HipKey.E;
            case 0x46: return HipKey.F;
            case 0x47: return HipKey.G;
            case 0x48: return HipKey.H;
            case 0x49: return HipKey.I;
            case 0x4A: return HipKey.J;
            case 0x4B: return HipKey.K;
            case 0x4C: return HipKey.L;
            case 0x4D: return HipKey.M;
            case 0x4E: return HipKey.N;
            case 0x4F: return HipKey.O;
            case 0x50: return HipKey.P;
            case 0x51: return HipKey.Q;
            case 0x52: return HipKey.R;
            case 0x53: return HipKey.S;
            case 0x54: return HipKey.T;
            case 0x55: return HipKey.U;
            case 0x56: return HipKey.V;
            case 0x57: return HipKey.W;
            case 0x58: return HipKey.X;
            case 0x59: return HipKey.Y;
            case 0x5A: return HipKey.Z;
            case VK_LWIN: return HipKey.META_LEFT;
            case VK_RWIN: return HipKey.META_RIGHT;
            //Maybe there's a need to change?
            case VK_NUMPAD0: return HipKey._0;
            case VK_NUMPAD1: return HipKey._1;
            case VK_NUMPAD2: return HipKey._2;
            case VK_NUMPAD3: return HipKey._3;
            case VK_NUMPAD4: return HipKey._4;
            case VK_NUMPAD5: return HipKey._5;
            case VK_NUMPAD6: return HipKey._6;
            case VK_NUMPAD7: return HipKey._7;
            case VK_NUMPAD8: return HipKey._8;
            case VK_NUMPAD9: return HipKey._9;

            case VK_F1: return HipKey.F1;
            case VK_F2: return HipKey.F2;
            case VK_F3: return HipKey.F3;
            case VK_F4: return HipKey.F4;
            case VK_F5: return HipKey.F5;
            case VK_F6: return HipKey.F6;
            case VK_F7: return HipKey.F7;
            case VK_F8: return HipKey.F8;
            case VK_F9: return HipKey.F9;
            case VK_F10: return HipKey.F10;
            case VK_F11: return HipKey.F11;
            case VK_F12: return HipKey.F12;

            case VK_LSHIFT: return HipKey.SHIFT;
            case VK_RSHIFT: return HipKey.SHIFT;

            case VK_LCONTROL: return HipKey.CTRL;
            case VK_RCONTROL: return HipKey.CTRL;
            
            case VK_LMENU: return HipKey.ALT;
            case VK_RMENU: return HipKey.ALT;

            case VK_OEM_1: return HipKey.SEMICOLON;

            case VK_OEM_COMMA: return HipKey.COMMA;
            case VK_OEM_MINUS: return HipKey.MINUS;
            case VK_OEM_PERIOD: return HipKey.PERIOD;

            case VK_OEM_2: return HipKey.SLASH;
            
            case VK_OEM_4: return HipKey.BRACKET_LEFT;
            case VK_OEM_5: return HipKey.BACKSLASH;
            case VK_OEM_6: return HipKey.BRACKET_RIGHT;
            case VK_OEM_7: return HipKey.QUOTE;

            default:
                version(HipCheckUnknownKeycode)
                {
                    import hip.util.conv:to;
                    assert(false, "Unknown key received ("~to!string(k)~")");
                }
                else
                    return cast(HipKey)k;
        }
    }
}