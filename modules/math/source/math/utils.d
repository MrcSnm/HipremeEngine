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