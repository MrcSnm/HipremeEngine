module hip.systems.gamepads.nswitch;
import hip.systems.gamepad;

version(NintendoSwitch){}
else
{
    alias HipNSwitchGamepad = HipNullGamepad;
}
version(NintendoSwitch):
import hip.windowing.platforms.nxlib.pad;
import hip.windowing.platforms.nintendo_switch;

pragma(inline, true) bool isNSwitchButtonPressed(u64 btns, HidNpadButton btn){return (btns & btn) == btn;}


class HipNSwitchGamepad : IHipGamepadImpl
{

    void poll(HipGamepad pad)
    {
        padUpdate(&nxpad);
        HidAnalogStickState analogStickL = padGetStickPos(&nxpad, 0);
        HidAnalogStickState analogStickR = padGetStickPos(&nxpad, 1);
        u64 b = padGetButtonsDown(&nxpad);

        with(pad)
        {
            enum center = 0;
            enum div = short.max - 1; //

            float lx = cast(float)analogStickL.x;
            float ly = cast(float)analogStickL.y;

            float rx = cast(float)analogStickR.x;
            float ry = cast(float)analogStickR.y;

            
            setAnalog(HipGamepadAnalogs.leftStick, [
                (lx - center) / div,
                -(ly - center) / div, 
                0
            ]);

            setAnalog(HipGamepadAnalogs.rightStick, [
                (rx - center) / div,
                -(ry - center) / div, 
                0
            ]);


            setButtonPressed(HipGamepadButton.nintendoA, isNSwitchButtonPressed(b, HidNpadButton.A));
            setButtonPressed(HipGamepadButton.nintendoB, isNSwitchButtonPressed(b, HidNpadButton.B));
            setButtonPressed(HipGamepadButton.nintendoX, isNSwitchButtonPressed(b, HidNpadButton.X));
            setButtonPressed(HipGamepadButton.nintendoY, isNSwitchButtonPressed(b, HidNpadButton.Y));


            setButtonPressed(HipGamepadButton.dPadDown, isNSwitchButtonPressed(b, HidNpadButton.Up));
            setButtonPressed(HipGamepadButton.dPadLeft, isNSwitchButtonPressed(b, HidNpadButton.Left));
            setButtonPressed(HipGamepadButton.dPadDown, isNSwitchButtonPressed(b, HidNpadButton.Down));
            setButtonPressed(HipGamepadButton.dPadRight, isNSwitchButtonPressed(b, HidNpadButton.Right));

            setButtonPressed(HipGamepadButton.select, isNSwitchButtonPressed(b, HidNpadButton.Minus));
            setButtonPressed(HipGamepadButton.start, isNSwitchButtonPressed(b, HidNpadButton.Plus));

            setButtonPressed(HipGamepadButton.left1, isNSwitchButtonPressed(b, HidNpadButton.L));
            setButtonPressed(HipGamepadButton.right1, isNSwitchButtonPressed(b, HidNpadButton.R));

            setButtonPressed(HipGamepadButton.left3, isNSwitchButtonPressed(b, HidNpadButton.StickL));
            setButtonPressed(HipGamepadButton.right3, isNSwitchButtonPressed(b, HidNpadButton.StickR));

            leftTrigger = (b & HidNpadButton.ZL) != 0 ? 1 : 0; 
            rightTrigger = (b & HidNpadButton.ZR) != 0 ? 1 : 0;


        }

    }

    void setVibrating(ubyte id, double leftMotor, double rightMotor, double leftTrigger, double rightTrigger)
    {
        import hip.windowing.platforms.nxlib.hid;
        HidVibrationValue vibValue;
        HidVibrationValue vibStop;
        HidVibrationValue[2] vibValues;

        vibValue.amp_low = 0.2f;
        vibValue.freq_low = 10.0f;
        vibValue.amp_high = 0.2f;
        vibValue.freq_high = 10.0f;

        vibStop.freq_high = 160.0f;
        vibStop.freq_high = 320.0f;
    }
    bool isWireless(ubyte id){return false;}
    HipGamepadBatteryStatus getBatteryStatus(ubyte id)
    {
        return HipGamepadBatteryStatus.init; // TODO: implement
    }
}