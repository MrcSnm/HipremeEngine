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
    private SDL_EventType types;
    ulong frameCount;
    KeyboardHandler* keyboard = null;

    this(KeyboardHandler *kb)
    {
        keyboard = kb;
    }
    
    bool hasQuit = false;

    void handleEvent()
    {
        while(SDL_PollEvent(&e) != 0)
        {
            switch(e.type)
            {
                case types.SDL_KEYDOWN:
                    keyboard.handleKeyDown(e.key.keysym.sym);
                    break;
                case types.SDL_KEYUP:
                    keyboard.handleKeyUp(e.key.keysym.sym);
                    break;
                case types.SDL_QUIT:
                    hasQuit = true;
                    break;
                default:break;
            }
        }
        keyboard.update();
        frameCount++;
    }

    void postUpdate()
    {
        keyboard.postUpdate();
    }
}

