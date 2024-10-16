module hip.math.collision;
import hip.math.utils:sqrt;
import std.traits:isNumeric;
public import hip.math.rect;
public import hip.math.vector;


pure nothrow @nogc @safe:

bool isPointInCircle(T)(in T px, in T py, in T circleX, in T circleY, in T circleRadius) 
if(isNumeric!T)
{
    float dx = px-circleX;
    float dy = py-circleY;
    return sqrt(dx*dx+dy*dy) <= circleRadius;
}

bool isPointInCircle(in Vector2 point, in Vector2 circle, in float radius)
{
    return (circle - point).mag <= radius;
}


bool isPointInRect(T)(in T px, in T py, in T rx, in T ry, in T rw, in T rh)
if(isNumeric!T)
{
    return !(px <= rx || px >= rx+rw || py <= ry || py >= ry+rh);
}
bool isPointInRect(in Vector2 p, in Rect r)
{
    return !(p.x <= r.x || p.x >= r.x+r.w || p.y <= r.y || p.y >= r.x+r.h);
}



///Error AKA approximation
bool isPointInLine(T)(in T px, in T py, in T lx1, in T ly1, in T lx2, in T ly2, in float error = 0.01)
if(isNumeric!T)
{
    import hip.math.utils;
    float lineLength = (lx2 - lx1)^^2 +(ly2 - ly1)^^2;
    float distLeft = (lx1 - px)^^2 + (ly1 - py)^^2;
    float distRight = (lx2 - px)^^2 + (ly2 - py)^^2;

    return sqrt(lineLength).approximatelyEqual(sqrt(distLeft)+sqrt(distRight), error);
}
bool isPointInLine2(T)(in T px, in T py, in T lx1, in T ly1, in T lx2, in T ly2, in float error = 0.01)
if(isNumeric!T)
{
    import hip.math.utils;

    if(px < lx1 || px > lx2) return false;

    float dx = lx2 - lx1;
    float dy = ly2 - ly1;

    float slope = dy/dx;
    float yIntercept = ly1 - (slope*lx1);

    return py.approximatelyEqual(slope*px + yIntercept, error);
}

pragma(inline, true)
bool isPointInLine(T)(in T[2] point, in T[2] lineStart, in T[2] lineEnd, in float error = 0.01)
{
    return isPointInLine(point[0], point[1], lineStart[0], lineStart[1], lineEnd[0], lineEnd[1], error);
}
pragma(inline, true)
bool isPointInLine(in Vector2 point, in Vector2 lineStart, in Vector2 lineEnd, in float error = 0.01)
{
    return isPointInLine(point[0], point[1], lineStart[0], lineStart[1], lineEnd[0], lineEnd[1], error);
}

bool isCircleInLine(float circleX, float circleY, float radius, float lx1, float ly1, float lx2, float ly2)
{
    if(isPointInCircle(lx1, ly1, circleX, circleY, radius) || isPointInCircle(lx2, ly2, circleX, circleY, radius))
        return true;
    import hip.math.utils;
    float lineDistX = lx2 - lx1;
    float lineDistY = ly2 - ly1;
    float lineLengthSquared = lineDistX*lineDistX + lineDistY*lineDistY;

    //Dot product between circle pos distance to line start to line vector.
    //Remember dot is the same as length squared vector, so need to divide by squared length to normalize.
    float dot = ((circleX - lx1) * lineDistX + (circleY - ly1) * lineDistY) / lineLengthSquared;

    ///Closest point from the circleX and Y to the line
    float closestX = lx1 + dot*lineDistX, closestY = ly1 + dot*lineDistY;
    if(!isPointInLine(closestX, closestY, lx1, ly1, lx2, ly2))
        return false;

    //Returns if distance <= radius from the closest point in line to the circle point
    return sqrt((closestX - circleX)^^ 2 + (closestY - circleY)^^ 2) <= radius;
}

bool isRayIntersectingLine(in Vector2 l1Start, in Vector2 l1End, in Vector2 l2Start, in Vector2 l2End, out Vector2 intersection)
{
    Vector2 line1 = l1End - l1Start;
    Vector2 line2 = l2End - l2Start;
    return false;
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
                import hip.util.algorithm:quicksort;
                foreach(col; quicksort(collisionList, ((DynamicRectCollision a, DynamicRectCollision b) => a.time < b.time)))
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