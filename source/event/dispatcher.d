/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module event.dispatcher;
private:
    import event.handlers.keyboard;
    import event.handlers.mouse;
    import systems.gamepad;
    import bindbc.sdl;

public:
    import systems.input;
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
    protected void delegate(uint width, uint height)[] resizeListeners;

    this(KeyboardHandler *kb)
    {
        keyboard = kb;
        mouse = new HipMouse();
        HipEventQueue.newController(); //Creates controller 0
        initXboxGamepadInput();
    }
    
    bool hasQuit = false;

    void handleEvent()
    {
        ///Use SDL to populate our Input Queue
        SDL_Event e;
        version(Desktop)
        {
            while(SDL_PollEvent(&e) != 0)
            {
                switch(e.type) with (SDL_EventType)
                {
                    case SDL_KEYDOWN:
                        HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(cast(ushort)e.key.keysym.sym));
                        break;
                    case SDL_KEYUP:
                        HipEventQueue.post(0, HipEventQueue.EventType.keyUp, HipEventQueue.Key(cast(ushort)e.key.keysym.sym));
                        break;
                    case SDL_MOUSEMOTION:
                        int x, y;
                        SDL_GetMouseState(&x,&y);
                        HipEventQueue.post(0, HipEventQueue.EventType.touchMove, HipEventQueue.Touch(0, x, y));
                        break;
                    case SDL_MOUSEBUTTONUP:
                        int x, y;
                        SDL_GetMouseState(&x,&y);
                        HipEventQueue.post(0, HipEventQueue.EventType.touchUp, HipEventQueue.Touch(0, x, y));
                        break;
                    case SDL_MOUSEBUTTONDOWN:
                        int x, y;
                        SDL_GetMouseState(&x,&y);
                        HipEventQueue.post(0, HipEventQueue.EventType.touchDown, HipEventQueue.Touch(0, x, y));
                        break;
                    case SDL_MOUSEWHEEL:
                        HipEventQueue.post(0, HipEventQueue.EventType.touchScroll, HipEventQueue.Scroll(e.wheel.x, e.wheel.y, 0));
                        break;
                    case SDL_WINDOWEVENT:
                        SDL_WindowEvent wnd = e.window;
                        switch(wnd.event) with(SDL_WindowEventID)
                        {
                            case SDL_WINDOWEVENT_RESIZED:
                                // HipEventQueue.post(0, HipEventQueue.EventType.windowResize, HipEventQueue.Key(e.key.keysym.sym));
                                foreach(r; resizeListeners)
                                    r(wnd.data1, wnd.data2);
                                break;
                            default:break;
                        }
                        break;
                    case SDL_QUIT:
                        HipEventQueue.post(0, HipEventQueue.EventType.exit, true);
                        break;
                    default:break;
                }
            }
        }

        //Now poll the cross platform input queue
        HipEventQueue.InputEvent* ev;
        while((ev = HipEventQueue.poll(0)) != null)
        {
            switch(ev.type)
            {
                case HipEventQueue.EventType.touchDown:
                    auto t = ev.get!(HipEventQueue.Touch);
                    mouse.setPressed(HipMouseButton.LEFT, true);
                    foreach (g; gamepads)
                        g.poll();
                    break;
                case HipEventQueue.EventType.touchUp:
                    auto t = ev.get!(HipEventQueue.Touch);
                    mouse.setPressed(HipMouseButton.LEFT, false);
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
        frameCount++;
    }

    void addOnResizeListener(void delegate(uint width, uint height) onResize)
    in{assert(onResize !is null, "onResize event must not be null.");}
    do
    {
        resizeListeners~= onResize;    
    }

    ///Public API
    immutable(Vector2*) getTouchPosition(uint id = 0){return mouse.getPosition(id);}
    Vector2 getTouchDeltaPosition(uint id = 0){return mouse.getDeltaPosition(id);}
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0){return mouse.isPressed(btn);}
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0){return mouse.isJustPressed(btn);}
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.LEFT, uint id = 0){return mouse.isJustReleased(btn);}
    Vector3 getScroll(){return mouse.getScroll();}
    bool isKeyPressed(char key, uint id = 0){return keyboard.isKeyPressed(key.toUppercase);}
    bool isKeyJustPressed(char key, uint id = 0){return keyboard.isKeyJustPressed(key.toUppercase);}
    bool isKeyJustReleased(char key, uint id = 0){return keyboard.isKeyJustReleased(key.toUppercase);}
    float getKeyDownTime(char key, uint id = 0){return keyboard.getKeyDownTime(key.toUppercase);}
    float getKeyUpTime(char key, uint id = 0){return keyboard.getKeyUpTime(key.toUppercase);}
    ubyte getGamepadCount(){return cast(ubyte)gamepads.length;}

    void postUpdate()
    {
        keyboard.postUpdate();
    }
}

