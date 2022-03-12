/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module event.dispatcher;
private:
    import event.handlers.keyboard;
    import event.handlers.mouse;
    import systems.gamepad;
    import windowing.window;
    import bindbc.sdl.bind.sdlevents;
    import bindbc.sdl.bind.sdlkeyboard;
    import bindbc.sdl.bind.sdlkeycode;
    import bindbc.sdl.bind.sdlmouse;
    import bindbc.sdl.bind.sdlvideo;

public:
    import systems.input;
    import util.time;
    import hipengine.api.math.vector;
    import hipengine.api.input.keyboard;
    import hipengine.api.input.button;
    import hipengine.api.input.mouse;
    import hipengine.api.input.gamepad;



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
        import windowing.events;

        onKeyDown = (wchar key)
        {
            try
            {
                HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(cast(ushort)key));
                debug { import std.stdio : writeln; try { writeln(key); } catch (Exception) {} }
            }
            catch(Exception e){assert(false);}
        };
        onKeyUp = (wchar key)
        {
            try{HipEventQueue.post(0, HipEventQueue.EventType.keyUp, HipEventQueue.Key(cast(ushort)key));}
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
        ///Use SDL to populate our Input Queue
        // SDL_Event e;
        window.pollWindowEvents();
        // version(Desktop)
        // {
        //     while(SDL_PollEvent(&e) != 0)
        //     {
        //         switch(e.type) with (SDL_EventType)
        //         {
        //             case SDL_KEYDOWN:
        //                 HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(cast(ushort)e.key.keysym.sym));
        //                 break;
        //             case SDL_KEYUP:
        //                 HipEventQueue.post(0, HipEventQueue.EventType.keyUp, HipEventQueue.Key(cast(ushort)e.key.keysym.sym));
        //                 break;
        //             case SDL_MOUSEMOTION:
        //                 int x, y;
        //                 SDL_GetMouseState(&x,&y);
        //                 HipEventQueue.post(0, HipEventQueue.EventType.touchMove, HipEventQueue.Touch(0, x, y));
        //                 break;
        //             case SDL_MOUSEBUTTONUP:
        //                 int x, y;
        //                 SDL_GetMouseState(&x,&y);
        //                 HipEventQueue.post(0, HipEventQueue.EventType.touchUp, HipEventQueue.Touch(0, x, y));
        //                 break;
        //             case SDL_MOUSEBUTTONDOWN:
        //                 int x, y;
        //                 SDL_GetMouseState(&x,&y);
        //                 HipEventQueue.post(0, HipEventQueue.EventType.touchDown, HipEventQueue.Touch(0, x, y));
        //                 break;
        //             case SDL_MOUSEWHEEL:
        //                 HipEventQueue.post(0, HipEventQueue.EventType.touchScroll, HipEventQueue.Scroll(e.wheel.x, e.wheel.y, 0));
        //                 break;
        //             case SDL_WINDOWEVENT:
        //                 SDL_WindowEvent wnd = e.window;
        //                 switch(wnd.event) with(SDL_WindowEventID)
        //                 {
        //                     case SDL_WINDOWEVENT_RESIZED:
        //                         // HipEventQueue.post(0, HipEventQueue.EventType.windowResize, HipEventQueue.Key(e.key.keysym.sym));
        //                         foreach(r; resizeListeners)
        //                             r(wnd.data1, wnd.data2);
        //                         break;
        //                     default:break;
        //                 }
        //                 break;
        //             case SDL_QUIT:
        //                 HipEventQueue.post(0, HipEventQueue.EventType.exit, true);
        //                 break;
        //             default:break;
        //         }
        //     }
        // }
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
                    keyboard.handleKeyDown(cast(SDL_Keycode)(cast(char)k.id).toUppercase);
                    break;
                case HipEventQueue.EventType.keyUp:
                    auto k = ev.get!(HipEventQueue.Key);
                    keyboard.handleKeyUp(cast(SDL_Keycode)(cast(char)k.id).toUppercase);
                    break;
                case HipEventQueue.EventType.gamepadConnected:
                    import console.log;rawlog("Gamepad connected");
                    auto g = ev.get!(HipEventQueue.Gamepad);
                    if(g.id+1 > gamepads.length)
                        gamepads~= new HipGamePad();
                    gamepads[g.id].setConnected(true);
                    break;
                case HipEventQueue.EventType.gamepadDisconnected:
                    import console.log;rawlog("Gamepad disconnected");
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

