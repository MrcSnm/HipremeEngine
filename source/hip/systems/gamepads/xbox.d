module hip.systems.gamepads.xbox;
import hip.util.system;
import hip.systems.gamepad;

///Refer to https://docs.microsoft.com/en-us/uwp/api/windows.gaming.input.gamepadbuttons?view=winrt-20348
enum HipXboxGamepadButton : int
{
    none            = 0,     ///No button.
    menu            = 1,     ///Menu button.
    view            = 1<<1,  ///View button.
    a               = 1<<2,  ///A button.
    b               = 1<<3,  ///B button.
    x               = 1<<4,  ///X button.
    y               = 1<<5,  ///Y button.
    dPadUp          = 1<<6,  ///D-pad up.
    dPadDown        = 1<<7,  ///D-pad down.
    dPadLeft        = 1<<8,  ///D-pad left.
    dPadRight       = 1<<9,  ///D-pad right.
    leftShoulder    = 1<<10, ///Left bumper.
    rightShoulder   = 1<<11, ///Right bumper.
    leftThumbstick  = 1<<12, ///Left stick.
    rightThumbstick = 1<<13, ///Right stick.
    paddle1         = 1<<14, ///The first paddle.
    paddle2         = 1<<15, ///The second paddle.
    paddle3         = 1<<16, ///The third paddle.
    paddle4         = 1<<17, ///The fourth paddle.
}


pragma(inline, true) 
bool isXboxGamepadButtonPressed(int gamepadState, HipXboxGamepadButton btn){return (gamepadState & btn) == btn;}

struct HipInputXboxGamepadState
{
    int buttons;
    double leftAnalogX;
    double leftAnalogY;
    double rightAnalogX;
    double rightAnalogY;
    double leftTrigger;
    double rightTrigger;
}


//////// External API ////////
extern(System) __gshared
{
    ubyte* function() HipGamepadCheckConnectedGamepads;
    HipGamepadBatteryStatus function(ubyte id) HipGamepadGetBatteryStatus;
    HipInputXboxGamepadState function(ubyte id) HipGamepadGetXboxGamepadState;
    bool function(ubyte id) HipGamepadIsWireless;
    ubyte function() HipGamepadQueryConnectedGamepadsCount;

    void function(
        ubyte id,
        double leftMotor,
        double rightMotor,
        double leftTrigger,
        double rightTrigger
    ) HipGamepadSetXboxGamepadVibration;
}



extern(D):
void initXboxGamepadInput()
{
    __gshared bool hasInit = false;
    if(hasInit)
        return;
    version(Windows)
    {
        string[] errors = dllImportVariables!(
            HipGamepadCheckConnectedGamepads,
            HipGamepadGetBatteryStatus,
            HipGamepadGetXboxGamepadState,
            HipGamepadIsWireless,
            HipGamepadQueryConnectedGamepadsCount,
            HipGamepadSetXboxGamepadVibration
        );
        foreach(err; errors)
        {
            import hip.console.log;
            logln("HIPREME_ENGINE: Could not load ", err);
        }
    }

    hasInit = true;
}

//////// End External API ////////

/** Engine task:
* Send gamepad connect and disconnect events
* Poll every connected gamepad every frame
* Should always return a neutral state for every disconnected gamepad
*
* Game task:
* Check gamepad count
* Decide what will do with connected gamepads
*/
class HipXBOXGamepad : IHipGamepadImpl
{
    void poll(HipGamepad pad)
    {
        HipInputXboxGamepadState state = HipGamepadGetXboxGamepadState(pad.getId);
        int b = state.buttons;
        with(pad)
        {
            setAnalog(HipGamepadAnalogs.leftStick, [state.leftAnalogX, state.leftAnalogY, 1]);
            setAnalog(HipGamepadAnalogs.rightStick, [state.rightAnalogX, state.rightAnalogY, 1]);

            leftTrigger = state.leftTrigger;
            rightTrigger = state.rightTrigger;
            setButtonPressed(HipGamepadButton.xboxY, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.y));
            setButtonPressed(HipGamepadButton.xboxX, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.x));
            setButtonPressed(HipGamepadButton.xboxA, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.a));
            setButtonPressed(HipGamepadButton.xboxB, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.b));

            setButtonPressed(HipGamepadButton.dPadUp, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.dPadUp));
            setButtonPressed(HipGamepadButton.dPadLeft, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.dPadLeft));
            setButtonPressed(HipGamepadButton.dPadDown, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.dPadDown));
            setButtonPressed(HipGamepadButton.dPadRight, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.dPadRight));

            setButtonPressed(HipGamepadButton.left1, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.leftShoulder));
            setButtonPressed(HipGamepadButton.right1, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.rightShoulder));
            // setButtonPressed(HipGamepadButton.left2, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.pa));
            // setButtonPressed(HipGamepadButton.right2, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.dPadRight));

            setButtonPressed(HipGamepadButton.left3, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.leftThumbstick));
            setButtonPressed(HipGamepadButton.right3, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.rightThumbstick));

            setButtonPressed(HipGamepadButton.start, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.menu));
            setButtonPressed(HipGamepadButton.select, isXboxGamepadButtonPressed(b, HipXboxGamepadButton.view));
        }
    }

    void setVibrating(ubyte id, double leftMotor, double rightMotor, double leftTrigger, double rightTrigger)
    {
        HipGamepadSetXboxGamepadVibration(id, 
            leftMotor,
            rightMotor,
            leftTrigger,
            rightTrigger
        );
    }
    bool isWireless(ubyte id){return HipGamepadIsWireless(id);}
    HipGamepadBatteryStatus getBatteryStatus(ubyte id){return HipGamepadGetBatteryStatus(id);}
}