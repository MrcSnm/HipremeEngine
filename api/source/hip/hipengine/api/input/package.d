/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.hipengine.api.input;
public import hip.hipengine.api.math.vector;
public import hip.hipengine.api.input.mouse;
public import hip.hipengine.api.input.gamepad;
public import hip.hipengine.api.input.inputmap;


void initInput()
{
    version(Script)
    {
        import hipengine.internal;

        loadSymbols!(
            isKeyPressed,
            isKeyJustPressed,
            isKeyJustReleased,
            getKeyDownTime,
            getKeyUpTime,
            isMouseButtonPressed,
            isMouseButtonJustPressed,
            isMouseButtonJustReleased,
            getTouchPosition,
            getTouchDeltaPosition,
            getScroll,

            //Gamepad
            getGamepadCount,
            getGamepad,
            getAnalog,
            isGamepadButtonPressed,
            isGamepadButtonJustPressed,
            isGamepadButtonJustReleased,
            setGamepadVibrating,
            getGamepadBatteryStatus,
            isGamepadWireless
        );
        enum InputMapClass = "HipInputMap";
        mixin(loadSymbolsFromExportD!(InputMapClass,
            parseInputMap_File,
            parseInputMap_Mem
        ));

    }
}

version(Have_hipreme_engine)
{
    public import hip.event.api;
}
else
{
    extern(System)
    {
        //Keyboard functions
        bool function(char key, uint id = 0) isKeyPressed;
        bool function(char key, uint id = 0) isKeyJustPressed;
        bool function(char key, uint id = 0) isKeyJustReleased;
        float function(char key, uint id = 0) getKeyDownTime;
        float function(char key, uint id = 0) getKeyUpTime;

        //Mouse/Touch functions
        bool function(HipMouseButton btn = HipMouseButton.left, uint id = 0) isMouseButtonPressed;
        bool function(HipMouseButton btn = HipMouseButton.left, uint id = 0) isMouseButtonJustPressed;
        bool function(HipMouseButton btn = HipMouseButton.left, uint id = 0) isMouseButtonJustReleased;
        immutable(Vector2*) function(uint id = 0) getTouchPosition;
        Vector2 function(uint id=0) getTouchDeltaPosition;
        Vector3 function(uint id=0) getScroll;
        //Gamepad Functions
        ubyte function() getGamepadCount;
        AHipGamepad function(ubyte id = 0) getGamepad;
        Vector3 function(HipGamepadAnalogs analog, ubyte id = 0) getAnalog;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonPressed;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonJustPressed;
        bool function(HipGamepadButton btn, ubyte id = 0) isGamepadButtonJustReleased;
        bool function(float vibrationPower, float time, ubyte id = 0) setGamepadVibrating;
        float function(ubyte id = 0) getGamepadBatteryStatus;
        bool function(ubyte id = 0) isGamepadWireless;
    }
}
alias getMousePosition = getTouchPosition;
alias getMouseDeltaPosition = getTouchDeltaPosition;