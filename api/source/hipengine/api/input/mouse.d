module hipengine.api.input.mouse;
public import hipengine.api.math.vector;

enum HipMouseButton : ubyte
{
    LEFT,
    MIDDLE,
    RIGHT
}

interface IHipMouse
{
    immutable(Vector2*) getPosition(uint id = 0);
    Vector2 getDeltaPosition(uint id = 0);
    bool isPressed(HipMouseButton btn = HipMouseButton.LEFT);
    bool isJustPressed(HipMouseButton btn = HipMouseButton.LEFT);
    bool isJustReleased(HipMouseButton btn = HipMouseButton.LEFT);
    Vector3 getScroll();
}