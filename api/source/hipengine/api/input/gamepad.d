module hipengine.api.input.gamepad;
public import hipengine.api.math.vector;

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

    ///Internal usage only
    count
}

interface IHipGamepad
{
    /** Returns wether it is vibrating. Receives a time to stop vibrating */
    bool setVibrating(float vibrationPower, float time = 0.5);
    bool isVibrating();
    /** Returns the Id for this controller, usually the order in which it was connected*/
    ubyte getId();

    /** Completely implementation dependent*/
    void poll();

    /** Returns a Vector3 containing the current state of the analog */
    Vector3 getAnalogState(HipGamepadAnalogs analog = HipGamepadAnalogs.leftStick);
    /** This will set a deadzone for making gamepad doesn't issue any kind of event until the threshold*/
    void setDeadzone(float threshold = 0.2);

    /** Returns the battery status in range 0 - 1, only makes sense when wireless*/
    float getBatteryStatus()out(r; (r > 0.0f && r <= 1.0f), "Battery should be 0 > battery <= 1");
    /** Knowing wether it is wireless may be essential for showing battery alert */
    bool isWireless();


    /** Receives a gamepad button*/
    bool isButtonPressed(HipGamepadButton btn);
    /** After first created, gamepads are never destroyed, use this property for using it or not*/
    bool isConnected();

    /** May include an implementation for turning gamepad off*/
    void setConnected(bool connected);


}

abstract class AHipGamePad : IHipGamepad
{
    protected float vibrationPower;
    protected float vibrationTime;
    protected bool _isConnected;
    protected float deadZone;
    protected bool[HipGamepadButton.count] buttons;

    void setDeadzone(float threshold = 0.2){deadZone = threshold;}
    bool isVibrating(){return vibrationPower==0;}
    void setButtonPressed(HipGamepadButton btn, bool pressed){buttons[btn] = pressed;}
    bool isButtonPressed(HipGamepadButton btn){return buttons[btn];}
    bool isConnected(){return _isConnected;}
    void setConnected(bool connected){_isConnected = connected;}

}