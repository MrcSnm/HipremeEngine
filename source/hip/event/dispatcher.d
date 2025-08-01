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
    import hip.api.config;

public:
    import hip.systems.input;
    import hip.util.time;
    import hip.api.input.keyboard;
    import hip.api.input.button;
    import hip.api.input.mouse;
    import hip.api.input.gamepad;
    import hip.api.renderer.viewport;
    import hip.api.input.core : IHipInput;



package __gshared HipGamepad[] gamepads;


/** 
 * Class used to dispatch the events for the each specific handler.
 *
 *  In the entire engine, there must be only one dispatcher. But it is possible
 *  to create more mouses and keyboards, but it is not being used yet.
 */
class EventDispatcher : IHipInput
{
    ulong frameCount;
    KeyboardHandler keyboard = null;
    HipMouse mouse = null;
    HipWindow window;
    bool* isInUpdate;
    protected void delegate(uint width, uint height)[] resizeListeners;

    this(HipWindow window, bool* isInUpdate)
    {
        this.window = window;
        this.isInUpdate = isInUpdate;
        keyboard = new KeyboardHandler();
        mouse = new HipMouse();
        HipEventQueue.newController(); //Creates controller 0
        initGamepads();
        import hip.windowing.events;

        onKeyDown = (uint key)
        {
            try
            {
                HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(getHipKeyFromSystem(key)));
            }
            catch(Exception e){assert(false);}
        };
        onKeyUp = (uint key)
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
        onMouseWheel = (int moveX, int moveY)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.touchScroll, HipEventQueue.Scroll(moveX, moveY, 0));}
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

    final void errUpdateOnly(string name)
    {
        // debug
        {
            import hip.console.log;
            bool inUpdate = *isInUpdate;
            if(!inUpdate)
                loglnError("API ", name, " can only be used inside update()");
        }
    }

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
                    mouse.setPosition(t.xPos, t.yPos, t.id);
                    mouse.setPressed(HipMouseButton.left, true);
                    break;
                case HipEventQueue.EventType.touchUp:
                    auto t = ev.get!(HipEventQueue.Touch);
                    mouse.setPosition(t.xPos, t.yPos, t.id);
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
                import hip.console.log;
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
                        gamepads~= getNewGamepad(g.type);
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
    float[2] getTouchPosition(uint id = 0){return cast(float[2])mouse.getPosition(id);}
    float[2] getTouchDeltaPosition(uint id = 0){return cast(float[2])mouse.getDeltaPosition(id);}

    float[2] getNormallizedTouchPosition(uint id=0) 
    {
        import hip.hiprenderer;
        float[2] ret = cast(float[2])getTouchPosition(id);
        ret[0]/= HipRenderer.width;
        ret[1]/= HipRenderer.height;
        return ret;
    }

    float[2] getWorldTouchPosition(uint id=0, Viewport vp = null) 
    {
        import hip.math.utils:clamp;
        import hip.api.renderer.core;
        float[2] ret = cast(float[2])getTouchPosition(id);
        if(vp is null)
            vp = HipRenderer.getCurrentViewport();

        ret[0] = clamp(((ret[0] - vp.x) / vp.width) * vp.worldWidth, 0, vp.worldWidth);
        ret[1] = clamp(((ret[1] - vp.y) / vp.height) * vp.worldHeight, 0, vp.worldHeight);
        

        return ret;
    }
    ubyte getMulticlickCount(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        errUpdateOnly("getMulticlickCount");
        return mouse.getMulticlickCount(btn);
    }
    bool isDoubleClicked(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        errUpdateOnly("isDoubleClicked");
        return mouse.isDoubleClicked(btn);
    }
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        errUpdateOnly("isMouseButtonPressed");
        return mouse.isPressed(btn);
    }
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        errUpdateOnly("isMouseButtonJustPressed");
        return mouse.isJustPressed(btn);
    }
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.any, uint id = 0)
    {
        errUpdateOnly("isMouseButtonJustReleased");
        return mouse.isJustReleased(btn);
    }
    float[3] getScroll(uint id = 0){return cast(float[3])mouse.getScroll();}
    bool isKeyPressed(char key, uint id = 0){return keyboard.isKeyPressed(key.toUppercase);}
    bool isKeyJustPressed(char key, uint id = 0)
    {
        errUpdateOnly("isKeyJustPressed");
        return keyboard.isKeyJustPressed(key.toUppercase);
    }
    bool isKeyJustReleased(char key, uint id = 0)
    {
        errUpdateOnly("isKeyJustReleased");
        return keyboard.isKeyJustReleased(key.toUppercase);
    }
    float getKeyDownTime(char key, uint id = 0)
    {
        errUpdateOnly("getKeyDownTime");
        return keyboard.getKeyDownTime(key.toUppercase);
    }
    float getKeyUpTime(char key, uint id = 0)
    {
        errUpdateOnly("getKeyUpTime");
        return keyboard.getKeyUpTime(key.toUppercase);
    }
    ubyte getGamepadCount(){return cast(ubyte)gamepads.length;}
    AHipGamepad getGamepad(ubyte id)
    {
        if(id >= gamepads.length)return null;
        return gamepads[id];
    }
    float[3] getAnalog(HipGamepadAnalogs analog, ubyte id = 0)
    {
        if(id >= gamepads.length) return cast(float[3])Vector3.zero;
        return cast(float[3])gamepads[id].getAnalogState(analog);
    }
    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        return gamepads[id].isButtonPressed(btn);
    }
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        errUpdateOnly("isGamepadButtonJustPressed");
        return gamepads[id].isButtonJustPressed(btn);
    }
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        errUpdateOnly("isGamepadButtonJustReleased");
        return gamepads[id].isButtonJustReleased(btn);
    }

    bool areGamepadButtonsPressed(scope HipGamepadButton[] btns, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        errUpdateOnly("areGamepadButtonsPressed");
        return gamepads[id].areButtonsPressed(btns);
    }
    bool areGamepadButtonsJustPressed(scope HipGamepadButton[] btns, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        errUpdateOnly("areGamepadButtonsJustPressed");
        return gamepads[id].areButtonsJustPressed(btns);
    }
    bool areGamepadButtonsJustReleased(scope HipGamepadButton[] btns, ubyte id = 0)
    {
        if(id >= gamepads.length) return false;
        errUpdateOnly("areGamepadButtonsJustReleased");
        return gamepads[id].areButtonsJustReleased(btns);
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
    public HipKey getHipKeyFromSystem(uint key)
    {
        import hip.windowing.platforms.winlib.keys;
        ushort k = cast(ushort)(key);
        assert(k > 0 && k <= ubyte.max, "Key out of range");
        switch(k)
        {
            case VK_BACK: return HipKey.BACKSPACE;
            case VK_TAB: return HipKey.TAB;
            case VK_ESCAPE: return HipKey.ESCAPE;


            case VK_SHIFT: return HipKey.SHIFT;
            case VK_CONTROL: return HipKey.CTRL;
            case VK_MENU: return HipKey.ALT;
            case VK_SNAPSHOT: return HipKey.PRINT;
            
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
            //0
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
            //A
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
            case  0xFF: return HipKey.NONE; //Invalid

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
else static if(isLinuxPC)
{
    public HipKey getHipKeyFromSystem(uint key)
    {
        import hip.windowing.platforms.x11lib.keysym;
        switch(key)
        {
            case XK_BackSpace: return HipKey.BACKSPACE;
            case XK_Tab: return HipKey.TAB;
            case XK_Return: return HipKey.ENTER;
            case XK_KP_Enter: return HipKey.ENTER;
            case XK_Shift_L: return HipKey.SHIFT;
            case XK_Shift_R: return HipKey.SHIFT;
            case XK_Control_L: return HipKey.CTRL;
            case XK_Control_R: return HipKey.CTRL;
            case XK_Alt_L: return HipKey.ALT;
            case XK_Alt_R: return HipKey.ALT;
            case XK_Pause: return HipKey.PAUSE_BREAK;
            case XK_Caps_Lock: return HipKey.CAPSLOCK;
            case XK_Escape: return HipKey.ESCAPE;
            case XK_space: return HipKey.SPACE;
            case XK_Page_Up: return HipKey.PAGE_UP;
            case XK_Page_Down: return HipKey.PAGE_DOWN;
            case XK_End: return HipKey.END;
            case XK_Home: return HipKey.HOME;
            case XK_Left: return HipKey.ARROW_LEFT;
            case XK_Up: return HipKey.ARROW_UP;
            case XK_Right: return HipKey.ARROW_RIGHT;
            case XK_Down: return HipKey.ARROW_DOWN;
            case XK_Insert: return HipKey.INSERT;
            case XK_Delete: return HipKey.DELETE;
            case XK_0: return HipKey._0;
            case XK_1: return HipKey._1;
            case XK_2: return HipKey._2;
            case XK_3: return HipKey._3;
            case XK_4: return HipKey._4;
            case XK_5: return HipKey._5;
            case XK_6: return HipKey._6;
            case XK_7: return HipKey._7;
            case XK_8: return HipKey._8;
            case XK_9: return HipKey._9;
            case XK_A: return HipKey.A;
            case XK_B: return HipKey.B;
            case XK_C: return HipKey.C;
            case XK_D: return HipKey.D;
            case XK_E: return HipKey.E;
            case XK_F: return HipKey.F;
            case XK_G: return HipKey.G;
            case XK_H: return HipKey.H;
            case XK_I: return HipKey.I;
            case XK_J: return HipKey.J;
            case XK_K: return HipKey.K;
            case XK_L: return HipKey.L;
            case XK_M: return HipKey.M;
            case XK_N: return HipKey.N;
            case XK_O: return HipKey.O;
            case XK_P: return HipKey.P;
            case XK_Q: return HipKey.Q;
            case XK_R: return HipKey.R;
            case XK_S: return HipKey.S;
            case XK_T: return HipKey.T;
            case XK_U: return HipKey.U;
            case XK_V: return HipKey.V;
            case XK_W: return HipKey.W;
            case XK_X: return HipKey.X;
            case XK_Y: return HipKey.Y;
            case XK_Z: return HipKey.Z;
            case XK_a: return HipKey.A;
            case XK_b: return HipKey.B;
            case XK_c: return HipKey.C;
            case XK_d: return HipKey.D;
            case XK_e: return HipKey.E;
            case XK_f: return HipKey.F;
            case XK_g: return HipKey.G;
            case XK_h: return HipKey.H;
            case XK_i: return HipKey.I;
            case XK_j: return HipKey.J;
            case XK_k: return HipKey.K;
            case XK_l: return HipKey.L;
            case XK_m: return HipKey.M;
            case XK_n: return HipKey.N;
            case XK_o: return HipKey.O;
            case XK_p: return HipKey.P;
            case XK_q: return HipKey.Q;
            case XK_r: return HipKey.R;
            case XK_s: return HipKey.S;
            case XK_t: return HipKey.T;
            case XK_u: return HipKey.U;
            case XK_v: return HipKey.V;
            case XK_w: return HipKey.W;
            case XK_x: return HipKey.X;
            case XK_y: return HipKey.Y;
            case XK_z: return HipKey.Z;
            case XK_Meta_L: return HipKey.META_LEFT;
            case XK_Meta_R: return HipKey.META_RIGHT;
            case XK_F1: return HipKey.F1;
            case XK_F2: return HipKey.F2;
            case XK_F3: return HipKey.F3;
            case XK_F4: return HipKey.F4;
            case XK_F5: return HipKey.F5;
            case XK_F6: return HipKey.F6;
            case XK_F7: return HipKey.F7;
            case XK_F8: return HipKey.F8;
            case XK_F9: return HipKey.F9;
            case XK_F10: return HipKey.F10;
            case XK_F11: return HipKey.F11;
            case XK_F12: return HipKey.F12;
            case XK_semicolon: return HipKey.SEMICOLON;
            case XK_equal: return HipKey.EQUAL;
            case XK_comma: return HipKey.COMMA;
            case XK_minus: return HipKey.MINUS;
            case XK_period: return HipKey.PERIOD;
            case XK_slash: return HipKey.SLASH;
            case XK_bracketleft: return HipKey.BRACKET_LEFT;
            case XK_bracketright: return HipKey.BRACKET_RIGHT;
            case XK_backslash: return HipKey.BACKSLASH;
            case XK_grave: return HipKey.QUOTE;
            default:
            {
                version(HipCheckUnknownKeycode)
                {
                    import hip.util.conv:to;
                    import hip.error.handler;
                    ErrorHandler.assertExit(false, "Unknown key received ("~to!string(key)~")");
                    return cast(HipKey)0;
                }
                else
                    return cast(HipKey)key;
            }
        }
    }
}
else version(WebAssembly)
{
    public HipKey getHipKeyFromSystem(uint key)
    {
        ushort k = cast(ushort)(key);
        assert(k > 0 && k <= ubyte.max, "Key out of range");
        switch(k)
        {
            case 8: return HipKey.BACKSPACE;
            case 9: return HipKey.TAB;
            case 27: return HipKey.ESCAPE;

            
            case 13: return HipKey.ENTER;
            case 20: return HipKey.CAPSLOCK;
            case 32: return HipKey.SPACE;
            case 33: return HipKey.PAGE_UP;
            case 35: return HipKey.END;
            case 36: return HipKey.HOME;
            case 37: return HipKey.ARROW_LEFT;
            case 38: return HipKey.ARROW_UP;
            case 39: return HipKey.ARROW_RIGHT;
            case 40: return HipKey.ARROW_DOWN;
            case 45: return HipKey.INSERT;
            case 46: return HipKey.DELETE;
            //0
            case 48: return HipKey._0;
            case 49: return HipKey._1;
            case 50: return HipKey._2;
            case 51: return HipKey._3;
            case 52: return HipKey._4;
            case 53: return HipKey._5;
            case 54: return HipKey._6;
            case 55: return HipKey._7;
            case 56: return HipKey._8;
            case 57: return HipKey._9;
            //A
            case 65: return HipKey.A;
            case 66: return HipKey.B;
            case 67: return HipKey.C;
            case 68: return HipKey.D;
            case 69: return HipKey.E;
            case 70: return HipKey.F;
            case 71: return HipKey.G;
            case 72: return HipKey.H;
            case 73: return HipKey.I;
            case 74: return HipKey.J;
            case 75: return HipKey.K;
            case 76: return HipKey.L;
            case 77: return HipKey.M;
            case 78: return HipKey.N;
            case 79: return HipKey.O;
            case 80: return HipKey.P;
            case 81: return HipKey.Q;
            case 82: return HipKey.R;
            case 83: return HipKey.S;
            case 84: return HipKey.T;
            case 85: return HipKey.U;
            case 86: return HipKey.V;
            case 87: return HipKey.W;
            case 88: return HipKey.X;
            case 89: return HipKey.Y;
            case 90: return HipKey.Z;
            case 91: return HipKey.META_LEFT;
            case 93: return HipKey.META_RIGHT;
            //Maybe there's a need to change?
            case 97: return HipKey._0;
            case 98: return HipKey._1;
            case 99: return HipKey._2;
            case 100: return HipKey._3;
            case 101: return HipKey._4;
            case 102: return HipKey._5;
            case 103: return HipKey._6;
            case 104: return HipKey._7;
            case 105: return HipKey._8;
            case 106: return HipKey._9;

            case 112: return HipKey.F1;
            case 113: return HipKey.F2;
            case 114: return HipKey.F3;
            case 115: return HipKey.F4;
            case 116: return HipKey.F5;
            case 117: return HipKey.F6;
            case 118: return HipKey.F7;
            case 119: return HipKey.F8;
            case 120: return HipKey.F9;
            case 121: return HipKey.F10;
            case 122: return HipKey.F11;
            case 123: return HipKey.F12;

            case 16: return HipKey.SHIFT;
            case 17: return HipKey.CTRL;
            case 18: return HipKey.ALT;

            case 191: return HipKey.SEMICOLON;

            case 188: return HipKey.COMMA;
            case 189: return HipKey.MINUS;
            case 190: return HipKey.PERIOD;

            case 193: return HipKey.SLASH;
            
            case 221: return HipKey.BRACKET_LEFT;
            case 220: return HipKey.BRACKET_RIGHT;
            case 226: return HipKey.BACKSLASH;
            case 192: return HipKey.QUOTE;
            case  0xFF: return HipKey.NONE; //Invalid

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
else version(AppleOS)
{
    public HipKey getHipKeyFromSystem(uint key)
    {
        switch(key)
        {

            //Special Chars
            case  0x31: return HipKey.SPACE; //space
            case  0x24: return HipKey.ENTER; //returnKey
            case  0x4C: return HipKey.ENTER; //enterKey
            case  0x35: return HipKey.ESCAPE; //escape
            case  0x38: return HipKey.SHIFT; //shift
            case  0x37: return HipKey.ALT; //command
            
            //DPad Keys
            case  0x7B: return HipKey.ARROW_LEFT; //leftArrow
            case  0x7C: return HipKey.ARROW_RIGHT; //rightArrow
            case  0x7D: return HipKey.ARROW_DOWN; //downArrow
            case  0x7E: return HipKey.ARROW_UP; //upArrow
            
            //Alphabet
            case  0x00: return HipKey.A; //a
            case  0x0B: return HipKey.B; //b
            case  0x08: return HipKey.C; //c
            case  0x02: return HipKey.D; //d
            case  0x0E: return HipKey.E; //e
            case  0x03: return HipKey.F; //f
            case  0x05: return HipKey.G; //g
            case  0x04: return HipKey.H; //h
            case  0x22: return HipKey.I; //i
            case  0x26: return HipKey.J; //j
            case  0x28: return HipKey.K; //k
            case  0x25: return HipKey.L; //l
            case  0x2E: return HipKey.M; //m
            case  0x2D: return HipKey.N; //n
            case  0x1F: return HipKey.O; //o
            case  0x23: return HipKey.P; //p
            case  0x0C: return HipKey.Q; //q
            case  0x0F: return HipKey.R; //r
            case  0x01: return HipKey.S; //s
            case  0x11: return HipKey.T; //t
            case  0x20: return HipKey.U; //u
            case  0x09: return HipKey.V; //v
            case  0x0D: return HipKey.W; //w
            case  0x07: return HipKey.X; //x
            case  0x10: return HipKey.Y; //y
            case  0x06: return HipKey.Z; //z
            
            //Top Numbers
            case  0x1D: return HipKey._0;//zero
            case  0x12: return HipKey._1; //one
            case  0x13: return HipKey._2;//two
            case  0x14: return HipKey._3;//three
            case  0x15: return HipKey._4;//four
            case  0x17: return HipKey._5;//five
            case  0x16: return HipKey._6;//six
            case  0x1A: return HipKey._7;//seven
            case  0x1C: return HipKey._8;//eight
            case  0x19: return HipKey._9;//nine
            
            //Keypad Numbers
            case  0x52: return HipKey._0; //keypad0
            case  0x53: return HipKey._1; //keypad1
            case  0x54: return HipKey._2; //keypad2
            case  0x55: return HipKey._3; //keypad3
            case  0x56: return HipKey._4; //keypad4
            case  0x57: return HipKey._5; //keypad5
            case  0x58: return HipKey._6; //keypad6
            case  0x59: return HipKey._7; //keypad7
            case  0x5B: return HipKey._8; //keypad8
            case  0x5C: return HipKey._9; //keypad9
            case  0xFF: return HipKey.NONE; //Invalid
            default:
                // version(HipCheckUnknownKeycode)
                // {
                //     import hip.console.log;
                //     loglnError("Unknown key received ("~to!string(k)~")");
                //     assert(false, "Unknown key received ("~to!string(k)~")");
                // }
                // else
                    return cast(HipKey)key;

        }
    }
}
else version(PSVita)
{
    public HipKey getHipKeyFromSystem(uint key){return HipKey._0;}
}
else public HipKey getHipKeyFromSystem(uint key){return HipKey._0;}

