/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.systems.gamepad;

import hip.event.handlers.button;
public import hip.api.input.gamepad;
public import hip.math.vector;
import hip.systems.gamepads.xbox;
import hip.systems.gamepads.psv;


enum HipGamepadTypes : ubyte
{
    xbox,
    psvita
}

HipGamepad getNewGamepad(ubyte type)
{
    final switch(type)
    {
        case HipGamepadTypes.xbox: return new HipGamepad(new HipXBOXGamepad());
        case HipGamepadTypes.psvita: return new HipGamepad(new HipPSVGamepad());
    }
}

interface IHipGamepadImpl
{
    void poll(HipGamepad pad);
    void setVibrating(ubyte id, 
        double leftMotor, 
        double rightMotor,
        double leftTrigger,
        double rightTrigger
    );
    bool isWireless(ubyte id);
    HipGamepadBatteryStatus getBatteryStatus(ubyte id);
}
final class HipNullGamepad : IHipGamepadImpl
{
    void poll(HipGamepad pad){}
    void setVibrating(ubyte id, double leftMotor, double rightMotor, double leftTrigger, double rightTrigger){}
    bool isWireless(ubyte id){return false;}
    HipGamepadBatteryStatus getBatteryStatus(ubyte id){return HipGamepadBatteryStatus.init;}
}


private pragma(inline, true) float applyDeadzone(float input, float deadzone)
{
    if(input < 0) return input > -deadzone ? 0 : input;
    return input < deadzone ? 0 : input;
}

private pragma(inline, true) float applyZones(float input, float deadzone, float alivezone)
{
    input = applyDeadzone(input, deadzone);
    if(input < 0) return input < -alivezone ? -1 : input;
    return input > alivezone ? 1 : input;
}


/** Engine task:
* Send gamepad connect and disconnect events
* Poll every connected gamepad every frame
* Should always return a neutral state for every disconnected gamepad
*
* Game task:
* Check gamepad count
* Decide what will do with connected gamepads
*/
class HipGamepad : AHipGamepad
{
    HipGamepadBatteryStatus status;
    Vector3 leftAnalog;
    Vector3 rightAnalog;
    float leftTrigger;
    float rightTrigger;
    ubyte id;
    __gshared ubyte instanceCount = 0;
    protected float vibrationAccumulator = 0;
    protected HipButtonMetadata[HipGamepadButton.count] buttons;
    private IHipGamepadImpl impl;



    ubyte getId(){return id;}
    package this(IHipGamepadImpl impl)
    {
        id = instanceCount++;
        for(int i = 0; i < buttons.length; i++)
            buttons[i] = new HipButtonMetadata(i);
        this.impl = impl;
    }

    void setButtonPressed(HipGamepadButton btn, bool pressed){buttons[btn].setPressed(pressed);}

    void setAnalog(HipGamepadAnalogs analog, float[3] value)
    {
        value[0] = applyZones(value[0], deadZone, aliveZone);
        value[1] = applyZones(value[1], deadZone, aliveZone);
        value[2] = applyZones(value[2], deadZone, aliveZone);

        final switch(analog)
        {
            case HipGamepadAnalogs.leftStick:
                leftAnalog = value;
                break;
            case HipGamepadAnalogs.rightStick:
                rightAnalog = value;
                break;
            case HipGamepadAnalogs.rightTrigger:
                rightTrigger = value[0];
                break;
            case HipGamepadAnalogs.leftTrigger:
                leftTrigger = value[0];
                break;
        }
    }
    bool isButtonPressed(HipGamepadButton btn){return buttons[btn].isPressed;}
    bool isButtonJustPressed(HipGamepadButton btn){return buttons[btn].isJustPressed;}
    bool isButtonJustReleased(HipGamepadButton btn){return buttons[btn].isJustReleased;}

    bool areButtonsPressed(scope HipGamepadButton[] btns)
    {
        foreach(btn; btns)
            if(!buttons[btn].isPressed) return false;
        return true;
    }
    bool areButtonsJustPressed(scope HipGamepadButton[] btns)
    {
        foreach(btn; btns)
            if(!buttons[btn].isJustPressed) return false;
        return true;
    }
    bool areButtonsJustReleased(scope HipGamepadButton[] btns)
    {
        foreach(btn; btns)
            if(!buttons[btn].isJustReleased) return false;
        return true;
    }

    void poll(float deltaTime)
    {
        if(vibrationTime != 0)
        {
            vibrationAccumulator+= deltaTime;
            if(vibrationAccumulator >= vibrationTime)
                setVibrating(0,0);
        }

        if(_isConnected) 
            impl.poll(this);
    }

    void postUpdate()
    {
        for(int i =0; i < buttons.length; i++)
            buttons[i]._isNewState = false;
    }

    final bool setVibrating(float time, double vibrationPower)
    {
        return setVibrating(time, vibrationPower,vibrationPower,vibrationPower,vibrationPower);
    }

    bool setVibrating(float time,  double leftMotor,
        double rightMotor,
        double leftTrigger,
        double rightTrigger
    )
    {
        impl.setVibrating(getId, 
            leftMotor,
            rightMotor,
            leftTrigger,
            rightTrigger
        );
        vibrationAccumulator = 0;
        vibrationTime = time;
        return true;
    }
    
    bool isWireless(){return impl.isWireless(getId);}
    Vector3 getAnalogState(HipGamepadAnalogs analog)
    {
        final switch(analog)
        {
            case HipGamepadAnalogs.leftStick: return leftAnalog;
            case HipGamepadAnalogs.rightStick: return rightAnalog;
            case HipGamepadAnalogs.rightTrigger: return Vector3(rightTrigger, 0, 0);
            case HipGamepadAnalogs.leftTrigger: return Vector3(leftTrigger, 0, 0);
        }
    }
    float getBatteryStatus()
    {
        status = impl.getBatteryStatus(getId());
        return cast(float)status.remainingCapacityInMilliwattHours
            / status.fullChargeCapacityInMilliwattHours;
    }
}

void initGamepads()
{
    import hip.systems.gamepads.xbox;
    initXboxGamepadInput();
}