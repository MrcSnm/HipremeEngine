module hip.api.config;
public import hip.api.input.keyboard;
public import hip.api.input.gamepad;

version(Android)
    enum IsMobile = true;
else version(iOS)
    enum IsMobile = true;
else 
    enum IsMobile = false;

version(Android) enum isLinuxPC = false;
else version(PSVita) enum isLinuxPC = false;
else version(linux) enum isLinuxPC = true;
else enum isLinuxPC = false;

enum HipAssetLoadStrategy
{
	loadAll
}

/** 
 * Used to convert analog input to the keys listed here.
 * See Also: hip.config.input
 * 
 * Params:
 *   key = The HipKey received.
 * Returns: If it is a directional key by default.
 */
bool keyIsDirectional(HipKey key)
{
    switch(key)
    {
        case HipKey.LEFT:
        case HipKey.A:
        case HipKey.UP:
        case HipKey.W:
        case HipKey.RIGHT:
        case HipKey.D:
        case HipKey.DOWN:
        case HipKey.S:
            return true;
        default: return false;
    }
}

bool analogMapsToKey(float[3] n, HipKey k)
{
    switch(k)
    {
        case HipKey.LEFT:
        case HipKey.A:
            return n[0] < -0.5;
        case HipKey.UP:
        case HipKey.W:
            return n[1] < -0.5;
        case HipKey.RIGHT:
        case HipKey.D:
            return n[0] > 0.5;
        case HipKey.DOWN:
        case HipKey.S:
            return n[1] > 0.5;
        default: return false;
    }
}

/** 
 * Used to make it easier to port PC-first games and provide at least
 * basic functionality without rewriting. Used for InputConvertKeyboardToGamepad
 * See Also: hip.config.input
 *
 * Params:
 *   key = The received key
 * Returns: The mapped gamepad button by default
 */
HipGamepadButton mapToGamepad(HipKey key)
{
    switch(key)
    {
        case HipKey.LEFT, HipKey.A:
            return HipGamepadButton.dPadLeft;
        case HipKey.UP, HipKey.W:
            return HipGamepadButton.dPadUp;
        case HipKey.RIGHT, HipKey.D:
            return HipGamepadButton.dPadRight;
        case HipKey.DOWN, HipKey.S:
            return HipGamepadButton.dPadDown;

        case HipKey.Q:
            return HipGamepadButton.left1;
        case HipKey.E:
            return HipGamepadButton.right1;
        case HipKey.Z:
            return HipGamepadButton.psSquare;
        case HipKey.X:
            return HipGamepadButton.psTriangle;
        case HipKey.SPACE:
            return HipGamepadButton.psCross;
        case HipKey.ENTER, HipKey.R:
            return HipGamepadButton.start;
        default:
            return HipGamepadButton.count;
    }
}