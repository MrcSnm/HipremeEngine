module systems.gamepad;

public import hipengine.api.input.gamepad;

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


pragma(inline) enum isXboxGamepadButtonPressed(int gamepadState, HipXboxGamepadButton btn){return (gamepadState & btn) == btn;}

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

///Based on https://docs.microsoft.com/en-us/uwp/api/windows.system.power.batterystatus?view=winrt-20348
enum HipInputGamepadBatteryState : ubyte
{
    notPresent = 0,
    discharging,
    idle,
    charging,
}
///Struct based on winrt::Windows::Devices::Power::BatteryReport
struct HipInputGamepadBatteryStatus
{
    int chargeRateInMilliwatts;
    int remainingCapacityInMilliwattHours;
    int fullChargeCapacityInMilliwattHours;
    HipInputGamepadBatteryState state;
}


//////// External API ////////

import util.system;

mixin(external);
ubyte* function() HipInputGamepadCheckConnectedGamepads;
HipInputGamepadBatteryStatus function(ubyte id) HipInputGamepadGetBatteryStatus;
HipInputXboxGamepadState function(ubyte id) HipInputGamepadGetXboxGamepadState;
bool function(ubyte id) HipInputGamepadIsWireless;
ubyte function() HipInputGamepadQueryConnectedGamepadsCount;

void function(
    ubyte id,
    double leftMotor,
    double rightMotor,
    double leftTrigger,
    double rightTrigger
) HipInputGamepadSetXboxGamepadVibration;


extern(D):

void initXboxGamepadInput()
{
    static bool hasInit = false;
    if(hasInit)
        return;
    dll_import_varS!HipInputGamepadCheckConnectedGamepads;
    dll_import_varS!HipInputGamepadGetBatteryStatus;
    dll_import_varS!HipInputGamepadGetXboxGamepadState;
    dll_import_varS!HipInputGamepadIsWireless;
    dll_import_varS!HipInputGamepadQueryConnectedGamepadsCount;
    dll_import_varS!HipInputGamepadSetXboxGamepadVibration;

    hasInit = true;
}


//////// End External API ////////

private pragma(inline) void pollXbox(HipGamePad pad, HipInputXboxGamepadState state)
{
    with(pad)
    {
        leftAnalog.x = state.leftAnalogX;
        leftAnalog.y = state.leftAnalogY;

        rightAnalog.x = state.rightAnalogX;
        rightAnalog.y = state.rightAnalogY;

        leftTrigger = state.leftTrigger;
        rightTrigger = state.rightTrigger;
        setButtonPressed(HipGamepadButton.xboxY, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.y));
        setButtonPressed(HipGamepadButton.xboxX, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.x));
        setButtonPressed(HipGamepadButton.xboxA, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.a));
        setButtonPressed(HipGamepadButton.xboxB, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.b));

        setButtonPressed(HipGamepadButton.dPadUp, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.dPadUp));
        setButtonPressed(HipGamepadButton.dPadLeft, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.dPadLeft));
        setButtonPressed(HipGamepadButton.dPadDown, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.dPadDown));
        setButtonPressed(HipGamepadButton.dPadRight, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.dPadRight));

        setButtonPressed(HipGamepadButton.left1, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.leftShoulder));
        setButtonPressed(HipGamepadButton.right1, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.rightShoulder));
        // setButtonPressed(HipGamepadButton.left2, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.pa));
        // setButtonPressed(HipGamepadButton.right2, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.dPadRight));

        setButtonPressed(HipGamepadButton.left3, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.leftThumbstick));
        setButtonPressed(HipGamepadButton.right3, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.rightThumbstick));

        setButtonPressed(HipGamepadButton.start, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.menu));
        setButtonPressed(HipGamepadButton.select, isXboxGamepadButtonPressed(state.buttons, HipXboxGamepadButton.view));
    }

    //Engine task:
    //Check gamepad count
    //Poll every connected gamepad every frame
    //Should always return false for every function on disconnected gamepads
    
    //Game task:
    //Check gamepad count
    //Decide what will do with connected gamepads
    



}


class HipGamePad : AHipGamepad
{
    HipInputGamepadBatteryStatus status;
    Vector3 leftAnalog;
    Vector3 rightAnalog;
    float leftTrigger;
    float rightTrigger;
    ubyte id;
    static ubyte instanceCount = 0;

    this(){id = instanceCount++;}

    ubyte getId(){return id;}
    void poll()
    {
        if(_isConnected) 
            pollXbox(this, HipInputGamepadGetXboxGamepadState(getId));
    }
    bool setVibrating(float vibrationPower, float time)
    {
        HipInputGamepadSetXboxGamepadVibration(getId, vibrationPower,vibrationPower,vibrationPower,vibrationPower);
        return true;
    }
    bool isWireless(){return HipInputGamepadIsWireless(getId);}
    Vector3 getAnalogState(HipGamepadAnalogs analog)
    {
        final switch(analog)
        {
            case HipGamepadAnalogs.leftStick: return leftAnalog;
            case HipGamepadAnalogs.rightStick: return rightAnalog;
            case HipGamepadAnalogs.rightTrigger: return rightAnalog;
            case HipGamepadAnalogs.leftTrigger: return rightAnalog;
        }
    }
    float getBatteryStatus()
    {
        status = HipInputGamepadGetBatteryStatus(getId());
        return cast(float)status.remainingCapacityInMilliwattHours
            / status.fullChargeCapacityInMilliwattHours;
    }
}