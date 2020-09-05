module sdl.event.handlers.keyboard;
import std.stdio;
private import sdl.loader;
private import std.algorithm, std.conv, std.datetime.stopwatch;
private import error.handler;
private import util.time, util.array;

/** 
 * Key handler
 */
abstract class _Key
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
            ErrorHandler.assertErrorMessage(keyboard.rebind(this, newKeycode), "Key Rebind error", "Error rebinding key'" ~ newKeycode.to!char);
    }
}

final private class KeyMetadata
{
    float lastDownTime, downTimeStamp;
    float lastUpTime, upTimeStamp;
    ubyte keyCode;
    bool isPressed = false;
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
    private _Key[][int] listeners;
    private int[int] listenersCount;
    private static int[256] pressedKeys;
    private static KeyMetadata[256] metadatas;

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
    bool rebind(_Key k, SDL_Keycode kCode)
    {
        _Key[] currentListener = listeners[k.keyCode];
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
    void addKeyListener(SDL_Keycode key, _Key k)
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
        ubyte _key = cast(ubyte)key;
        metadatas[_key].setPressed(press);
        if(press)
        {
            if(pressedKeys.indexOf(_key) == -1)
            {
                pressedKeys[pressedKeys.indexOf(0)] = _key; //Assign to null index a key
            }
        }
        else
        {
            const int index = pressedKeys.indexOf(0); //Get last index
            const int upIndex = pressedKeys.indexOf(_key);
            if(index > 1)
            {
                swapAt(pressedKeys, index - 1, upIndex);//Swaps the current key with the last valid key
                pressedKeys[index - 1] = 0;
            }
            else pressedKeys[0] = 0;

        }

    }

    void handleKeyUp(SDL_Keycode key)
    {
        setPressed(key, false);
        if((key in listeners) != null)
        {
            _Key[] keyListeners = listeners[key];
            immutable int len = listenersCount[key];
            for(int i = 0; i < len; i++)
                keyListeners[i].onUp();
        }
    }
    
    /**
    *   Updates the metadata
    */
    void handleKeyDown(SDL_Keycode key)
    {
        import std.stdio : writeln;
        setPressed(key, true);
    
    }

    void update()
    {
        int i = 0;
        while(pressedKeys[i] != 0)
        {
            if((pressedKeys[i] in listeners) != null)
                foreach(key; listeners[pressedKeys[i]])
                    key.onDown();
            i++;
        }
    }

}