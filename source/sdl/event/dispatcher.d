/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module sdl.event.dispatcher;
private:
    import sdl.loader;
    import sdl.event.handlers.keyboard;

public:
/** 
 * Class used to dispatch the events for the each specific handler
 */
class EventDispatcher
{
    SDL_Event e;
    ulong frameCount;
    KeyboardHandler* keyboard = null;
    protected void delegate(uint width, uint height)[] resizeListeners;

    this(KeyboardHandler *kb)
    {
        keyboard = kb;
    }
    
    bool hasQuit = false;

    void handleEvent()
    {
        while(SDL_PollEvent(&e) != 0)
        {
            switch(e.type) with (SDL_EventType)
            {
                case SDL_KEYDOWN:
                    keyboard.handleKeyDown(e.key.keysym.sym);
                    break;
                case SDL_KEYUP:
                    keyboard.handleKeyUp(e.key.keysym.sym);
                    break;
                case SDL_WINDOWEVENT:
                    SDL_WindowEvent wnd = e.window;
                    switch(wnd.event) with(SDL_WindowEventID)
                    {
                        case SDL_WINDOWEVENT_RESIZED:
                            foreach(r; resizeListeners)
                                r(wnd.data1, wnd.data2);
                            break;
                        default:
                            break;
                    }
                    break;
                case SDL_QUIT:
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

