/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.input.gamepad;

public import hip.api.input.button;

enum HipGamepadAnalogs : ubyte
{
    leftStick,
    rightStick,
    leftTrigger,
    rightTrigger
}

/** Define order is starting from up and it goes counter clockwise*/
enum HipGamepadButton : ubyte
{
    dPadUp = 0,
    dPadLeft,
    dPadDown,
    dPadRight,

    psTriangle,
    psSquare,
    psCross,
    psCircle,

    xboxY = psTriangle,
    xboxX = psSquare,
    xboxA = psCross,
    xboxB = psCircle,

    left1,
    right1,

    left2,
    right2,

    left3,
    right3,

    start,
    select,
    home,
    printScreen,
    volumeUp,
    volumeDown,

    ///Internal usage only
    count
}


HipGamepadButton gamepadButtonFromString(string str)
{
    switch(str)
    {
        static foreach(btn; __traits(allMembers, HipGamepadButton))
        {
            case btn:
                return __traits(getMember, HipGamepadButton, btn);
        }
        default:
            return HipGamepadButton.count;
    }
}

///Based on https://docs.microsoft.com/en-us/uwp/api/windows.system.power.batterystatus?view=winrt-20348
enum HipGamepadBatteryState : ubyte
{
    notPresent = 0,
    discharging,
    idle,
    charging,
}
///Struct based on winrt::Windows::Devices::Power::BatteryReport
pragma(LDC_no_typeinfo)
struct HipGamepadBatteryStatus
{
    int chargeRateInMilliwatts;
    int remainingCapacityInMilliwattHours;
    int fullChargeCapacityInMilliwattHours;
    HipGamepadBatteryState state;
}

interface IHipGamepad
{
    /** Returns wether it is vibrating. Receives a time to stop vibrating */
    bool setVibrating(float vibrationPower, float time = 0.5);
    bool isVibrating();
    /** Returns the Id for this controller, usually the order in which it was connected*/
    ubyte getId();

    /** Completely implementation dependent, 
    *   deltaTime is used for it auto stop vibrating
    */
    void poll(float deltaTime);

    /** Returns a Vector3 containing the current state of the analog */
    float[3] getAnalogState(HipGamepadAnalogs analog = HipGamepadAnalogs.leftStick);
    /** This will set a deadzone for making gamepad doesn't issue any kind of event until the threshold*/
    void setDeadzone(float threshold = 0.1);

    /** Returns the battery status in range 0 - 1, only makes sense when wireless*/
    float getBatteryStatus()out(r; (r > 0.0f && r <= 1.0f), "Battery should be 0 > battery <= 1");
    /** Knowing wether it is wireless may be essential for showing battery alert */
    bool isWireless();


    /** Receives a gamepad button*/
    bool isButtonPressed(HipGamepadButton btn);
    bool isButtonJustPressed(HipGamepadButton btn);
    bool isButtonJustReleased(HipGamepadButton btn);

    final bool isButtonPressed(string btn){return isButtonPressed(gamepadButtonFromString(btn));}
    /** After first created, gamepads are never destroyed, use this property for using it or not*/
    bool isConnected();

    /** May include an implementation for turning gamepad off*/
    void setConnected(bool connected);


}

abstract class AHipGamepad : IHipGamepad
{
    protected float vibrationPower = 0;
    protected float vibrationTime = 0;
    protected bool _isConnected = false;
    protected float deadZone = 0.1;
    protected float aliveZone = 0.95;

    void setDeadzone(float threshold = 0.1){deadZone = threshold;}
    void setAlivezone(float threshold = 0.95){aliveZone = threshold;}
    bool isVibrating(){return vibrationPower==0;}
    bool isConnected(){return _isConnected;}
    void setConnected(bool connected){_isConnected = connected;}

}