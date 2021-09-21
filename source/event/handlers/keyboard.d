/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module event.handlers.keyboard;

import std.algorithm;
import bindbc.sdl;

import event.handlers.keyboard_layout;
public import event.handlers.button;

import util.data_structures;
import error.handler;
import util.time, util.array;

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
 *  This class controls callbacks related to keyboard buttons state, as its downtime, uptime,
 *  its current state, modifier key states and callbacks assigned to specific keys.
 *
 *  Controls what text has been typed in the current frame, useful for Label or Text objects.
 */
class KeyboardHandler
{
    private HipButton[][int] listeners;
    private int[int] listenersCount;
    private static int[256] pressedKeys;
    private static HipButtonMetadata[256] metadatas;
    private static string frameText;

    private static bool altPressed;
    private static bool shiftPressed;
    private static bool ctrlPressed;
    private static float keyRepeatDelay = 0.5;

    static this()
    {
        for(int i = 0; i < 256; i++)
            metadatas[i] = new HipButtonMetadata(i);
        pressedKeys[] = 0;
    }
    
    
    /** 
     * Will take care of not let memory fragmentation happen by switching places with current index and last
     *   k = Key object reference
     * Params:
     *   kCode = New key code
     * Returns: Rebinded was succesful
     */
    bool rebind(HipButton k, SDL_Keycode kCode)
    {
        HipButton[] currentListener = listeners[k.meta.id];
        int currentCount = listenersCount[k.meta.id];
        int index = cast(int)countUntil(currentListener, k);
        if(index != -1)
        {
            swapAt(currentListener, index, currentCount - 1);
            currentListener[currentCount-1] = null;
            listenersCount[k.meta.id]--;
            addKeyListener(kCode, k);
        }
        return index != -1;
    }
    /** 
     * Will make the key being enqueued in the keyboard event distribution
     * Params:
     *   key = id for being assigned with the Key object
     *   k = Key object reference
     */
    void addKeyListener(SDL_Keycode key, HipButton k)
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
            HipButton[] keyListeners = listeners[key];
            immutable int len = listenersCount[key];
            for(int i = 0; i < len; i++)
                keyListeners[i].onUp();
        }
    }

    pragma(inline, true) bool isKeyPressed(char key){return metadatas[key]._isPressed;}
    
    /**
    *   Updates the metadata
    */
    void handleKeyDown(SDL_Keycode key)
    {
        setPressed(key, true);
        if((key in listeners) != null)
        {
            HipButton[] keyListeners = listeners[key];
            immutable int len = listenersCount[key];
            for(int i = 0; i < len; i++)
                keyListeners[i].onDown();
        }
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
            if(pressTime >= keyRepeatDelay || metadatas[pressedKeys[i]]._isNewState)
                ret~= layout.getKey(toUppercase(cast(char)pressedKeys[i]), state);
            i++;
        }
        return ret;
    }

    void update()
    {
        //HipInput.isActionButtonPressed("jump")
        //HipInput.isActionButtonReleased("jump")
        //HipInput.isActionButtonReleased("menu")
        //HipInput.getTouchPosition(0) ==  HipInput.getMousePosition
        //HipInput.getTouchDeltaPosition(0)
        //HipInput.getScroll() -> Returns Vector3 for X, Y, Z
        //HipInput.getTouchCount
        //HipInput.
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
            metadatas[pressedKeys[i++]]._isNewState = false;
        frameText = "";
    }

}
