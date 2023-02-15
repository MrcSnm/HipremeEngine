module hip.systems.gamepads.psv;
import hip.systems.gamepad;

version(PSVita){}
else
{
    alias HipPSVGamepad = HipNullGamepad;
}
version(PSVita):

/** Enumeration for the digital controller buttons.
 * @note - L1/R1/L3/R3 only can bind using ::sceCtrlPeekBufferPositiveExt2 and ::sceCtrlReadBufferPositiveExt2
 * @note - Vita's L Trigger and R Trigger are mapped to L1 and R1 when using ::sceCtrlPeekBufferPositiveExt2 and ::sceCtrlReadBufferPositiveExt2
 */
enum PsvButtons : uint
{
	SELECT      = 0x00000001,       //!< Select button.
	L3          = 0x00000002,       //!< L3 button.
	R3          = 0x00000004,       //!< R3 button.
	START       = 0x00000008,       //!< Start button.
	UP          = 0x00000010,       //!< Up D-Pad button.
	RIGHT       = 0x00000020,       //!< Right D-Pad button.
	DOWN        = 0x00000040,       //!< Down D-Pad button.
	LEFT        = 0x00000080,       //!< Left D-Pad button.
	LTRIGGER    = 0x00000100,       //!< Left trigger.
	L2          = LTRIGGER,     //!< L2 button.
	RTRIGGER    = 0x00000200,       //!< Right trigger.
	R2          = RTRIGGER,     //!< R2 button.
	L1          = 0x00000400,       //!< L1 button.
	R1          = 0x00000800,       //!< R1 button.
	TRIANGLE    = 0x00001000,       //!< Triangle button.
	CIRCLE      = 0x00002000,       //!< Circle button.
	CROSS       = 0x00004000,       //!< Cross button.
	SQUARE      = 0x00008000,       //!< Square button.
}

pragma(inline, true) enum isPSVButtonPressed(uint btns, PsvButtons btn){return (btns & btn) == btn;}
extern(C) void hipVitaPollGamepad(HipInputPSVGamepadState* state);

struct HipInputPSVGamepadState
{
    uint buttons;
    ubyte[2] leftAnalog; ///X, Y
    ubyte[2] rightAnalog; ///X, Y
}
class HipPSVGamepad : IHipGamepadImpl
{

    void poll(HipGamepad pad)
    {
        HipInputPSVGamepadState state;
        hipVitaPollGamepad(&state);

        uint b = state.buttons;
        with(pad)
        {
            enum center = 128;
            enum div = 128;

            float lx = cast(float)state.leftAnalog[0];
            float ly = cast(float)state.leftAnalog[1];

            float rx = cast(float)state.rightAnalog[0];
            float ry = cast(float)state.rightAnalog[1];

            
            setAnalog(HipGamepadAnalogs.leftStick, [
                (lx - center) / div,
                (ly - center) / div, 
                1
            ]);

            setAnalog(HipGamepadAnalogs.rightStick, [
                (rx - center) / div,
                (ry - center) / div, 
                1
            ]);

            leftTrigger = 0; rightTrigger = 0;


            setButtonPressed(HipGamepadButton.psTriangle, isPSVButtonPressed(b, PsvButtons.TRIANGLE));
            setButtonPressed(HipGamepadButton.psSquare, isPSVButtonPressed(b, PsvButtons.SQUARE));
            setButtonPressed(HipGamepadButton.psCross, isPSVButtonPressed(b, PsvButtons.CROSS));
            setButtonPressed(HipGamepadButton.psCircle, isPSVButtonPressed(b, PsvButtons.CIRCLE));


            setButtonPressed(HipGamepadButton.dPadUp, isPSVButtonPressed(b, PsvButtons.UP));
            setButtonPressed(HipGamepadButton.dPadLeft, isPSVButtonPressed(b, PsvButtons.LEFT));
            setButtonPressed(HipGamepadButton.dPadDown, isPSVButtonPressed(b, PsvButtons.DOWN));
            setButtonPressed(HipGamepadButton.dPadRight, isPSVButtonPressed(b, PsvButtons.RIGHT));

            setButtonPressed(HipGamepadButton.select, isPSVButtonPressed(b, PsvButtons.SELECT));
            setButtonPressed(HipGamepadButton.start, isPSVButtonPressed(b, PsvButtons.START));

            setButtonPressed(HipGamepadButton.left1, isPSVButtonPressed(b, PsvButtons.LTRIGGER));
            setButtonPressed(HipGamepadButton.right1, isPSVButtonPressed(b, PsvButtons.RTRIGGER));


        }

    }

    void setVibrating(ubyte id, double leftMotor, double rightMotor, double leftTrigger, double rightTrigger){}
    bool isWireless(ubyte id){return false;}
    HipGamepadBatteryStatus getBatteryStatus(ubyte id)
    {
        return HipGamepadBatteryStatus.init; // TODO: implement
    }
}