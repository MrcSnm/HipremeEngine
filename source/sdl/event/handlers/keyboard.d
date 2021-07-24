module sdl.event.handlers.keyboard;
import sdl.event.handlers.input.keyboard_layout;
import util.data_structures;
import std.stdio;
private import sdl.loader;
private import std.algorithm, std.conv, std.datetime.stopwatch;
private import error.handler;
private import util.time, util.array;

enum KeyCodes
{
    BACKSPACE = 8, TAB, ENTER = 13, SHIFT = 16, CTRL, ALT, PAUSE_BREAK, CAPSLOCK,
    ESCAPE = 27, SPACE = 32, PAGE_UP, PAGE_DOWN, END, HOME, ARROW_LEFT, ARROW_UP, ARROW_RIGHT, ARROW_DOWN,
    INSERT = 45, DELETE, _0 = 48, _1, _2, _3, _4, _5, _6, _7, _8, _9,
    A = 65, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,

    META_LEFT = 91, META_RIGHT,

    F1 = 112, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12, 
    SEMICOLON = 186, EQUAL, COMMA, MINUS, PERIOD = 190, SLASH, BACKQUOTE, BRACKET_LEFT = 219, BACKSLASH, BRACKET_RIGHT, QUOTE
}

private char toUppercase(char a)
{
    ubyte charV = ubyte(a);
    if(charV >= KeyCodes.A+32 && charV <= KeyCodes.Z+32)
        return cast(char)(charV-32);
    return a;
}

/** 
 * Key handler
 */
abstract class Key
{
    /** 
     * Reference for the handler
     */
    KeyboardHandler* keyboard;
    KeyMetadata meta;

    /** 
     * Only assigned by the KeyboardHandler
     * invoke rebind() for changing current key
     */
    int keyCode;
    abstract void onDown();
    abstract void onUp();

    /** 
     * Params:
     *   newKeycode = New button to be assigned
     */
    final void rebind(SDL_Keycode newKeycode)
    {
        if(newKeycode != keyCode)
            ErrorHandler.assertErrorMessage(!keyboard.rebind(this, newKeycode), "Key Rebind error", "Error rebinding key'" ~ newKeycode.to!char);
    }
}

final private class KeyMetadata
{
    float lastDownTime, downTimeStamp;
    float lastUpTime, upTimeStamp;
    ubyte keyCode;
    bool isPressed = false;
    bool justPressed = false;
    this(int key)
    {
        this.keyCode = cast(ubyte)key;
    }

    this(SDL_Keycode key)
    {
        this.keyCode = cast(ubyte)key;
    }

    private void stampDownTime()
    {
        downTimeStamp = Time.getCurrentTime();
    }

    private void stampUpTime()
    {
        upTimeStamp = Time.getCurrentTime();
    }


    public float getDowntimeDuration()
    {
        if(isPressed)
            return (Time.getCurrentTime() - downTimeStamp) / 1000;
        return 0;
    }
    public float getUpTimeDuration()
    {
        if(!isPressed)
            return (Time.getCurrentTime() - upTimeStamp) / 1000;
        return 0;
    }
    private void setPressed(bool press)
    {
        if(press && !isPressed)
            justPressed = true;
        if(press != isPressed)
        {
            if(isPressed)
            {
                lastDownTime = getDowntimeDuration();
                stampUpTime();
            }
            else
            {
                lastUpTime = getUpTimeDuration();
                stampDownTime();
            }
            isPressed = press;
        }
    }
}

/** 
 * Keyboard wrapper
 */
class KeyboardHandler
{
    private Key[][int] listeners;
    private int[int] listenersCount;
    private static int[256] pressedKeys;
    private static KeyMetadata[256] metadatas;
    private static string frameText;

    private static bool altPressed;
    private static bool shiftPressed;
    private static bool ctrlPressed;
    private static float keyRepeatDelay = 0.5;

    static this()
    {
        for(int i = 0; i < 256; i++)
            metadatas[i] = new KeyMetadata(i);
        pressedKeys[] = 0;
    }
    
    
    /** 
     * Will take care of not let memory fragmentation happen by switching places with current index and last
     *   k = Key object reference
     * Params:
     *   kCode = New key code
     * Returns: Rebinded was succesful
     */
    bool rebind(Key k, SDL_Keycode kCode)
    {
        Key[] currentListener = listeners[k.keyCode];
        int currentCount = listenersCount[k.keyCode];
        int index = cast(int)countUntil(currentListener, k);
        if(index != -1)
        {
            swapAt(currentListener, index, currentCount - 1);
            currentListener[currentCount-1] = null;
            listenersCount[k.keyCode]--;
            addKeyListener(kCode, k);
        }
        return index != -1;
    }
    /** 
     * Will make the key being enqueued in the keyboard event distribution
     * Params:
     *   key = Keycode for being assigned with the Key object
     *   k = Key object reference
     */
    void addKeyListener(SDL_Keycode key, Key k)
    {
        if((key in listeners) == null) //Initialization for new key
        {
            listeners[key] = []; //Creates a new place for the new key
            listeners[key].reserve(4); //Reserves a bit of memory
            listenersCount[key] = 0; //Initialization
        }
        if(listeners[key].length != listenersCount[key]) //Check if there is null space
            listeners[key][$ - 1] = k;
        else
            listeners[key]~= k; //Append if not
        k.keyCode = key; //Initializes key
        k.meta = metadatas[cast(ubyte)key];
        listenersCount[key]++;
    }
    /**
      * Takes care of the pressed keys array
      */
    private void setPressed(SDL_Keycode key, bool press)
    {
        ubyte Key = cast(ubyte)key;
        metadatas[Key].setPressed(press);
        if(press)
        {
            if(pressedKeys.indexOf(Key) == -1)
            {
                pressedKeys[pressedKeys.indexOf(0)] = Key; //Assign to null index a key
            }
        }
        else
        {
            const int index = pressedKeys.indexOf(0); //Get last index
            const int upIndex = pressedKeys.indexOf(Key);
            if(index > 1)
            {
                swapAt(pressedKeys, index - 1, upIndex);//Swaps the current key with the last valid key
                pressedKeys[index - 1] = 0;
            }
            else pressedKeys[0] = 0;
        }
        switch(key)
        {
            case SDL_Keycode.SDLK_LALT:
            case SDL_Keycode.SDLK_RALT:
                altPressed = press;
                break;
            case SDL_Keycode.SDLK_LCTRL:
            case SDL_Keycode.SDLK_RCTRL:
                ctrlPressed = press;
                break;
            case SDL_Keycode.SDLK_LSHIFT:
            case SDL_Keycode.SDLK_RSHIFT:
                shiftPressed = press;
                break;
            default:
                break;
        }

    }

    void handleKeyUp(SDL_Keycode key)
    {
        setPressed(key, false);
        if((key in listeners) != null)
        {
            Key[] keyListeners = listeners[key];
            immutable int len = listenersCount[key];
            for(int i = 0; i < len; i++)
                keyListeners[i].onUp();
        }
    }

    pragma(inline, true)
    bool isKeyPressed(char key)
    {
        return metadatas[key].isPressed;
    }
    
    /**
    *   Updates the metadata
    */
    void handleKeyDown(SDL_Keycode key)
    {
        import std.stdio;
        setPressed(key, true);
    }

    static string getInputText(KeyboardLayout layout)
    {
        KeyboardLayout.KeyState state = KeyboardLayout.KeyState.NONE;
        if(altPressed)
            state|= KeyboardLayout.KeyState.ALT;
        if(shiftPressed)
            state|= KeyboardLayout.KeyState.SHIFT;
        if(ctrlPressed)
            state|= KeyboardLayout.KeyState.CTRL;
        string ret = "";
        int i = 0;
        while(pressedKeys[i] != 0)
        {
            const float pressTime = metadatas[pressedKeys[i]].getDowntimeDuration();
            if(pressTime >= keyRepeatDelay || metadatas[pressedKeys[i]].justPressed)
                ret~= layout.getKey(toUppercase(cast(char)pressedKeys[i]), state);
            i++;
        }
        return ret;
    }

    void update()
    {
        int i = 0;
        while(pressedKeys[i] != 0)
        {
            //Check listeners for that ey
            if((pressedKeys[i] in listeners) != null)
                foreach(key; listeners[pressedKeys[i]])
                    key.onDown();
            //Add it to the current input
            i++;
        }
    }

    void postUpdate()
    {
        int i = 0;
        while(pressedKeys[i] != 0)
            metadatas[pressedKeys[i++]].justPressed = false;
        frameText = "";
    }

}
