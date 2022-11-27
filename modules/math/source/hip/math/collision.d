module hip.math.collision;
import hip.math.rect;
import hip.math.vector;
import hip.math.utils:sqrt;
import std.traits:isNumeric;

public import hip.math.rect:overlaps;


pure nothrow @nogc @safe
bool isPointInsideCircle(T)( T px, T py, T circleX, T circleY, T circleRadius) 
if(isNumeric!T)
{
    float dx = px-circleX;
    float dy = py-circleY;
    return sqrt(dx*dx+dy*dy) <= circleRadius;
}

pure nothrow @nogc @safe
bool isPointInsideCircle(Vector2 point, Vector2 circle, float radius)
{
    return (circle - point).mag <= radius;
}

pure nothrow @nogc @safe
bool isPointInsideRect(T)(T px, T py, T rx, T ry, T rw, T rh)
if(isNumeric!T)
{
    return !(px <= rx || px >= rx+rw || py <= ry || py >= ry+rh);
}

pure nothrow @nogc @safe
bool isPointInsideRect(Vector2 p, Rect r)
{
    return !(p.x <= r.x || p.x >= r.x+r.w || p.y <= r.y || p.y >= r.x+r.h);
}