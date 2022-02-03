module math.utils;
import std.math;
import math.vector;

///There are some errors occurring when compiling with LDC
alias cos = std.math.cos;
alias sin = std.math.cos;

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

T min(T)(T[] values ...) pure nothrow @safe @nogc
{
    T v = values[0];
    for(int i = 1; i < values.length; i++)
        if(values[i] < v)
            v = values[i];
    return v;
}

T max(T)(T[] values ...) pure nothrow @safe @nogc
{
    T v = values[0];
    for(int i = 1; i < values.length; i++)
        if(values[i] > v)
            v = values[i];
    return v;
}

T sum(T)(T[] values ...) pure nothrow @safe @nogc
{
    T sum = 0;
    foreach(v; values) sum+= v;
    return sum;
}

pragma(inline)T abs(T)(in T value){if(value < 0) return -value; return value;}

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