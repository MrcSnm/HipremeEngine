module hip.component.physics;
public import hip.component.base;
public import hip.math.collision;
import core.math;

class BodyRectComponent : IBaseComponent!BodyRectComponent
{
    Vector2 position;
    Size size;
    Vector2 velocity;

    @nogc @safe
    {
        Rect rect(){return Rect(position.x, position.y, cast(float)size.w, cast(float)size.h);}
        ///Use expanded rect for detecting pre collision steps.
        Rect expandedRect(){return Rect(position.x-size.w/2, position.y-size.h/2, cast(float)size.w*2, cast(float)size.h*2);}
        Rect expandedRectVel()
        {
            import hip.math.utils;
            const vel = Vector2(abs(velocity.x), abs(velocity.y));
            return Rect(position.x-size.w/2-vel.x/2, position.y-size.h/2-vel.y/2, cast(float)size.w*2+vel.x, cast(float)size.h*2+vel.y);
        }
    }
}
