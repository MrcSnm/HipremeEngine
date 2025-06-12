module hip.component.physics;
public import hip.component.base;
public import hip.math.collision;
import core.math;

class BodyRectComponent : IBaseComponent!BodyRectComponent
{
    Vector2 position;
    Size size;
    Vector2 velocity;

    mixin template ExpandFields()
    {
        pragma(inline, true)
        {
            final ref float x(){ return _BodyRectComponent.position.x; }
            final ref float y(){ return _BodyRectComponent.position.y; }
            final ref Vector2 velocity(){ return _BodyRectComponent.velocity; }
            final ref Vector2 position(){ return _BodyRectComponent.position; }
            final ref Size size(){ return _BodyRectComponent.size; }
        }
    }

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
