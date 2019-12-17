module systems.game;
private import sdl.event.dispatcher;
private import sdl.event.handlers.keyboard;
private import sdl.loader;

class GameSystem
{
    /** 
     * Holds the member that generates the events as inputs
     */
    EventDispatcher dispatcher;
    KeyboardHandler keyboard;

    float update()
    {
        dispatcher.handleEvent();
        keyboard.update();
        return 0;
    }
}