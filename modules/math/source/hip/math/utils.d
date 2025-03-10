module hip.math.utils;
import hip.math.vector;

///There are some errors occurring when compiling with LDC
public import core.math: sqrt, cos, sin;

pure @safe nothrow @nogc:

enum PI = 3.14159;
enum PI_2 = PI/2;
enum PI_4 = PI/4;

enum RAD_TO_DEG = 180/PI;
enum DEG_TO_RAD = PI/180;

float radToDeg(float radians)
{
    assert(radians == radians); //float.nan check
    return radians*RAD_TO_DEG;
}
float degToRad(float degrees)
{
    assert(degrees == degrees); //float.nan check
    return DEG_TO_RAD * degrees;
}

int getClosestMultiple(int from, int to)
{
    float temp = to/cast(float)from;
    int tempI = to/from;

    if(temp == tempI)
        return from * tempI;
    else
    {
        temp-= tempI;
        if(temp <= 0.5)
            return from*tempI;
        else
            return from*(tempI+1);
    }
}

bool approximatelyEqual(in float from, in float to, in float error = 0.01)
{
    float diff = from - to;
    return diff >= -error && diff <= error;
}

pragma(inline, true) int round(float f) pure @nogc @safe nothrow {return f > 0 ? cast(int)(f+0.5) : cast(int)(f-0.5);}

///Bit twiddling hacks
uint roundPow2(uint n)
{
    if(n == 0) return 1;
    n--;
    n |= n >> 1;
    n |= n >> 2;
    n |= n >> 4;
    n |= n >> 8;
    n |= n >> 16;
    return n + 1;
}

/** 
 * 
 * Params:
 *   from = From which value to interpolate
 *   to = To which value
 *   t = The T of interpolation
 * Returns: 
 */
float lerp(float from, float to, float t)
{
    return (1.0f-t)*from + t*to;
}

bool isPowerOf2(size_t num)
{
    return (num & (num - 1)) == 0;
}

enum dipsPerInch = 96.0f;
int convertDipsToPixels(float dips, float dpi = 96.0f) //96 is Windows convention
{
    return cast(int)(dips * dpi / dipsPerInch + 0.5f); //Round to nearest integer
}

float physicalPixelToDIPs(int pixels, float dpi = 96.0f)
{
    return pixels/(dpi/dipsPerInch);
}

enum AxisNavigation{xy, yz, xz, zx, zy, yx}

Vector3 toCircleBounds(Vector3 v, float angle, AxisNavigation axis=AxisNavigation.xy)
{
    float mag = v.mag;
    final switch(axis) with(AxisNavigation)
    {
        case xy:
            v.x = cos(angle)*mag;
            v.y = sin(angle)*mag;
            break;
        case yz:
            v.y = cos(angle)*mag;
            v.z = sin(angle)*mag;
            break;
        case xz:
            v.x = cos(angle)*mag;
            v.z = sin(angle)*mag;
            break;
        case zx:
            v.z = cos(angle)*mag;
            v.x = sin(angle)*mag;
            break;
        case zy:
            v.z = cos(angle)*mag;
            v.y = sin(angle)*mag;
            break;
        case yx:
            v.y = cos(angle)*mag;
            v.x = sin(angle)*mag;
            break;
    }
    return v;
}

pragma(inline, true)
T abs(T)(T val) pure nothrow @safe @nogc
{
    return val < 0 ? -val : val;
}

T min(T)(in T[] values ...) pure nothrow @safe @nogc
{
    T v = values[0];
    for(int i = 1; i < values.length; i++)
        if(values[i] < v)
            v = values[i];
    return v;
}

T max(T)(in T[] values ...) pure nothrow @safe @nogc
{
    T v = values[0];
    for(int i = 1; i < values.length; i++)
        if(values[i] > v)
            v = values[i];
    return v;
}

T sum(T)(in T[] values ...) pure nothrow @safe @nogc
{
    T sum = 0;
    foreach(v; values) sum+= v;
    return sum;
}


float floor(in float val) pure nothrow @safe @nogc{return floor!float(val);}
T floor(T)(in float val) pure nothrow @safe @nogc
{
    return cast(T)(cast(int)val);
}
float ceil(in float val) pure nothrow @safe @nogc {return ceil!float(val);}
T ceil(T)(in float val) pure nothrow @safe @nogc
{
    return cast(T)(cast(int)(val + 0.9999999));
}

/**
 *
 * Reduce the precision of a floating point. Useful for displaying on screen
 * Params:
 *   value = Some floating input value, e.g: 5.59367
 *   precision = The precision which must be seen, for example 2
 * Returns: An approximated floating value, for those inputs, return 5.93
 */
T floorDecimal(T)(T value, ubyte precision = 2) @nogc nothrow pure @safe
if(__traits(isFloating, T))
{
    import std.math;
    size_t multiplier = 10^^precision;
    return floor(value*multiplier) / multiplier;
}

T clamp(T)(T value, T min, T max) pure nothrow @safe @nogc
{
    return value < min ? min : value > max ? max : value;
}

pragma(inline, true)T abs(T)(in T value){return value < 0 ? -value : value;}
pragma(inline, true)int sign(T)(in T value){return value == 0 ? 0 : value < 0 ? -1 : 1; }


int greatestCommonDivisor(int a, int b)
{
    int res;
    int lastRes;
    do
    {
        res = a % b;
        lastRes = b;
        a = b;
        b = res;
    } while(res != 0);

    return lastRes;
}

Vector2 quadraticBezier(float x0, float y0, float x1, float y1, float x2, float y2, float t)
{
    float dtT = (1.0f-t);
    float dtTSquare = dtT*dtT;
    float tSq = t*t;
    return Vector2(
        dtTSquare*x0 + 2*t*dtT*x1 + tSq*x2, 
        dtTSquare*y0 + 2*t*dtT*y1 + tSq*y2
    );
}

pragma(inline) Vector2 quadraticBezier(Vector2 p0, Vector2 p1, Vector2 p2, float t)
{
    return quadraticBezier(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, t);
}

Vector2 cubicBezier(float x0, float y0, float x1, float y1, float x2, float y2, float x3, float y3, float t)
{
    float dtT = 1.0f-t;
    float dtTSq = dtT*dtT;
    float dtTCub = dtTSq*dtT;
    float tSq = t*t;
    float tCub = tSq*t;

    return Vector2(
        dtTCub*x0 + 3*t*dtTSq*x1 + 3*tSq*dtT*x2 + tCub*x3,
        dtTCub*y0 + 3*t*dtTSq*y1 + 3*tSq*dtT*y2 + tCub*y3,
    );
}

pragma(inline) Vector2 cubicBezier(Vector2 p0, Vector2 p1, Vector2 p2, Vector2 p3, float t)
{
    return cubicBezier(p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, t);
}