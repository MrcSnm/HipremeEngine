module hip.math.collision;
import hip.math.utils:sqrt;
import std.traits:isNumeric;
public import hip.math.rect;
public import hip.math.vector;


pure nothrow @nogc @safe:

bool isPointInsideCircle(T)(in T px, in T py, in T circleX, in T circleY, in T circleRadius) 
if(isNumeric!T)
{
    float dx = px-circleX;
    float dy = py-circleY;
    return sqrt(dx*dx+dy*dy) <= circleRadius;
}

bool isPointInsideCircle(in Vector2 point, in Vector2 circle, in float radius)
{
    return (circle - point).mag <= radius;
}

bool isPointInsideRect(T)(in T px, in T py, in T rx, in T ry, in T rw, in T rh)
if(isNumeric!T)
{
    return !(px <= rx || px >= rx+rw || py <= ry || py >= ry+rh);
}

bool isPointInsideRect(in Vector2 p, in Rect r)
{
    return !(p.x <= r.x || p.x >= r.x+r.w || p.y <= r.y || p.y >= r.x+r.h);
}

bool isRayIntersectingRect(in Vector2 rayPos, in Vector2 rayEnd, in Rect rect, out Vector2 intersection, out Vector2 intersectionNormal, out float intersectionTime)
{
    import hip.math.utils;

    Vector2 rayDir = rayEnd - rayPos;
    if(rayDir.magSquare == 0)
        return false;
    //T when hitting the near point to rayPos in X axis

    Vector2 recStart = Vector2(rect.x, rect.y);
    Vector2 recSize = Vector2(rect.w, rect.h);

    Vector2 nearT = (recStart - rayPos);
    if((nearT.x == 0 && rayDir.x == 0) || (nearT.y == 0 && rayDir.y == 0)) //Prevents NaN
        return false;
    nearT/= rayDir;

    Vector2 farT = (recStart + recSize - rayPos);
    if((farT.x == 0 && rayDir.x == 0) || (farT.y == 0 && rayDir.y == 0)) //Prevents NaN
        return false;
    farT/= rayDir;

    auto swap = (ref float a, ref float b)
    {
        float temp = b;
        b = a;
        a = temp;
    };

    if(nearT.x > farT.x) swap(nearT.x, farT.x);
    if(nearT.y > farT.y) swap(nearT.y, farT.y);
    //No collision
    if(nearT.x > farT.y || nearT.y > farT.x) return false;


    float tHitNear = max(nearT.x, nearT.y);
    float tHitFar = min(farT.x, farT.y);

    //Collision in opposite direction
    intersectionTime = tHitNear;
    if(tHitFar < 0 || tHitNear < 0) return false;

    intersection = rayPos + tHitNear * rayDir;

    //Hit on top of the rect
    if(nearT.x > nearT.y)
    {
        if(rayDir.x > 0)
            intersectionNormal = Vector2(-1, 0);
        else
            intersectionNormal = Vector2(1, 0);
    }
    //Hit on bottom of the rect
    else
    {
        if(rayDir.y > 0)
            intersectionNormal = Vector2(0, -1);
        else
            intersectionNormal = Vector2(0, 1);
    }
    return true;
}

/**
*   Automatically updates Rect velocity if collision happened. If you wish a non changing velocity, send a velocity copy.
*/
bool isDynamicRectOverlappingRect(in Rect source, in Vector2 vel, in Rect target, in float deltaTime, out Vector2 intersectionNormal, out float intersectionTime)
{
    if(vel.x == 0 && vel.y == 0)
        return false;

    float w = cast(float)source.w;
    float h = cast(float)source.h;
    Rect expandedTarget = Rect(target.x-w, target.y-h, target.w+w, target.h+h);

    Vector2 intersection = void;
    if(isRayIntersectingRect(source.position, source.position + vel*deltaTime, expandedTarget, intersection, intersectionNormal, intersectionTime) 
        && intersectionTime <= 1.0)
        return true;
    return false;
}

void resolveDynamicRectOverlappingRect(in Vector2 normal, ref Vector2 velocity, in float intersectionTime)
{
    import hip.math.utils:abs;
    velocity+= normal * Vector2(velocity.x.abs, velocity.y.abs) * (1-intersectionTime);
}


bool isRectOverlappingRect(in Rect r1, in Rect r2)
{
    const float r1x2 = r1.x+r1.w;
    const float r2x2 = r2.x+r2.w;
    const float r1y2 = r1.y+r1.h;
    const float r2y2 = r2.y+r2.h;
    return !(r1x2 < r2.x || r1.x > r2x2 || r1y2 < r2.y || r1.y > r2y2);
}

struct RectWorld
{
    private DynamicRect[] dynamicRects;
    private Rect[] staticRects;

    /**
    *   Returns a reference to the dynamic rect as they will need to be manipulated.
    */
    DynamicRect* addDynamic(in Rect rect, in Vector2 velocity)
    {
        dynamicRects~= DynamicRect(rect, velocity);
        return &dynamicRects[$-1];
    }


    /**
    *   Should never be manipulated, which is why their reference is not returned.
    */
    void addStatic(in Rect[] rect...)
    {
        foreach(r;rect)
            staticRects~= r;
    }

    void update(float dt)
    {
        struct DynamicRectCollision
        {
            Vector2 normal;
            float time;
        }
        foreach(ref DynamicRect dynamic; dynamicRects)
        {
            scope DynamicRectCollision[] collisionList;
            foreach(const ref rect; staticRects)
            {
                DynamicRectCollision col = void;
                if(isDynamicRectOverlappingRect(dynamic.rect, dynamic.velocity, rect, dt, col.normal, col.time))
                {
                    collisionList~= col;
                }
            }
            if(collisionList.length > 0)
            {
                import std.algorithm:sort;
                foreach(col; sort!((DynamicRectCollision a, DynamicRectCollision b) => a.time < b.time)(collisionList))
                {
                    resolveDynamicRectOverlappingRect(col.normal, dynamic.velocity, col.time);
                }
            }
            destroy(collisionList);
            dynamic.move(dynamic.velocity * dt);
        }
    }


    @system int opApply(scope int delegate(ref DynamicRect) dg)
    {
        int result = 0;
        foreach (ref DynamicRect item; dynamicRects)
        {
            result = dg(item);
            if (result)
                break;
        }
        return result;
    }

    @system int opApply(scope int delegate (const ref Rect) dg)
    {
        int result = 0;
        foreach (const ref Rect item; staticRects)
        {
            result = dg(item);
            if (result)
                break;
        }
        return result;
    }
}