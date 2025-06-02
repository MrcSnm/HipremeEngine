module hip.api.input.inputmap;
public import hip.api.input.gamepad;
public import hip.math.vector;

/**
 * Example of an inputmap data format:

```json
{
    "actions": {
        "left": {
            "keyboard": ["a"],
            "gamepad": ["dPadLeft"]
        },
        "right": {
            "keyboard": ["d"],
            "gamepad": ["dPadRight"]
        },
        "up": {
            "keyboard": ["w"],
            "gamepad": ["dPadUp"]
        },
        "down": {
            "keyboard": ["s"],
            "gamepad": ["dPadDown"]
        }
    },
    "directionals": {
        "move": {
            "x": [
                {"keyboard": "a", "gamepad": "dPadLeft", "value": -1},
                {"keyboard": "d", "gamepad": "dPadRight","value": 1},
                {"analog": "left", "axis": "x"}
            ],
            "y": [
                {"keyboard": "w", "gamepad": "dPadUp", "value": -1},
                {"keyboard": "s", "gamepad": "dPadDown", "value": 1},
                {"analog": "left", "axis": "y"}
            ]
        }
    }
}
```
 */
interface IHipInputMap
{
    struct Context
    {
        ///Got from the object that contains input information
        string name;
        ///Got from the "keyboard" properties from input json
        char[] keys;
        ///Got from "gamepad" properties from input json
        HipGamepadButton[] btns;
    }
    struct AxisContext
    {
        /**
         * Holds whether this controls the X, Y or Z axis.
         * May also hold which analog stick, either the left or right on it, if that happens, it can't hold
         * a key, value nor button.
         * Then, also hold which axis from the analog is being mapped
         */
        ubyte axis;
        /**
         * Holds which gamepad button holds the value specified
         */
        HipGamepadButton btn;
        /**
         * A keyboard key
         */
        char key;
        /**
        * Value ranging from byte.min - byte.max
        * A float value is usually specified on input mapping, between 1.0 and -1.0
        * This value is then scaled by 127
        */
        byte value;
    }
    void registerInputAction(string actionName, Context ctx);
    float isActionPressed(string actionName);
    float isActionJustPressed(string actionName);
    float isActionJustReleased(string actionName);
    /**
     * Gets a Vector3 from a mapped directional.
     * Params:
     *   directionalName = A directional which was registered through "directionals" on input map json
     * Returns:
     */
    Vector3 getAxis(string directionalName);
}