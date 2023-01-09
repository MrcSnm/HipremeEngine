/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module hip.event.handlers.keyboard;

import hip.event.handlers.keyboard_layout;
public import hip.event.handlers.button;
public import hip.api.input.keyboard;

import hip.util.data_structures;
import hip.error.handler;
import hip.util.time, hip.util.array;

char toUppercase(char a)
{
    ubyte charV = ubyte(a);
    if(charV >= HipKey.A+32 && charV <= HipKey.Z+32)
        return cast(char)(charV-32);
    return a;
}




/** 
 *  This class controls callbacks related to keyboard buttons state, as its downtime, uptime,
 *  its current state, modifier key states and callbacks assigned to specific keys.
 *
 *  Controls what text has been typed in the current frame, useful for Label or Text objects.
 */
class KeyboardHandler : IHipKeyboard
{
    private __gshared int[256] pressedKeys;
    private __gshared HipButtonMetadata[256] metadatas;
    private __gshared string frameText;

    private __gshared bool altPressed;
    private __gshared bool shiftPressed;
    private __gshared bool ctrlPressed;
    private __gshared float keyRepeatDelay = 0.5;

    this()
    {
        if(metadatas[0] is null)
        {
            for(int i = 0; i < 256; i++)
                metadatas[i] = new HipButtonMetadata(i);
            pressedKeys[] = 0;
        }
    }
    

    /**
    * Takes care of the pressed keys array
    */
    private void setPressed(HipKey key, bool press)
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
            case HipKey.ALT:
                altPressed = press;
                break;
            case HipKey.CTRL:
                ctrlPressed = press;
                break;
            case HipKey.SHIFT:
                shiftPressed = press;
                break;
            default:
                break;
        }

    }

    void handleKeyUp(HipKey key)
    {
        setPressed(key, false);
    }
    AHipButtonMetadata getMetadata(char key) const {return metadatas[key];}

    bool isKeyPressed(char key){return metadatas[key]._isPressed;}
    bool isKeyJustPressed(char key){return metadatas[key].isJustPressed;}
    bool isKeyJustReleased(char key){return metadatas[key].isJustReleased;}
    float getKeyDownTime(char key){return metadatas[key].getDownTimeDuration();}
    float getKeyUpTime(char key){return metadatas[key].getUpTimeDuration();}

    
    /**
    *   Updates the metadata
    */
    void handleKeyDown(HipKey key)
    {
        setPressed(key, true);
        // import hip.console.log;
        // logln("Set pressed the key ", key);
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
            const float pressTime = metadatas[pressedKeys[i]].getDownTimeDuration();
            if(pressTime >= keyRepeatDelay || metadatas[pressedKeys[i]]._isNewState)
                ret~= layout.getKey(toUppercase(cast(char)pressedKeys[i]), state);
            i++;
        }
        return ret;
    }

    void update()
    {
    }

    void postUpdate()
    {
        for(int i = 0; i < metadatas.length; i++)
            metadatas[i]._isNewState = false;
        frameText = "";
    }

}


