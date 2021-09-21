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
    import bindbc.sdl;

public:
import systems.input;

/** 
 * Class used to dispatch the events for the each specific handler
 */
class EventDispatcher
{
    SDL_Event e;
    ulong frameCount;
    KeyboardHandler* keyboard = null;
    HipMouse mouse = null;
    protected void delegate(uint width, uint height)[] resizeListeners;

    this(KeyboardHandler *kb)
    {
        keyboard = kb;
        mouse = new HipMouse();
        HipEventQueue.newController(); //Creates controller 0
    }
    
    bool hasQuit = false;

    void handleEvent()
    {
        ///Use SDL to populate our Input Queue
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
                    keyboard.handleKeyDown(cast(SDL_Keycode)k.id);
                    break;
                case HipEventQueue.EventType.keyUp:
                    auto k = ev.get!(HipEventQueue.Key);
                    keyboard.handleKeyUp(cast(SDL_Keycode)k.id);
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

    void postUpdate()
    {
        keyboard.postUpdate();
    }
}

