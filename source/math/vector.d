module math.vector;
import std.stdio;
import core.math : sqrt, sin, cos;

public struct Vector(T)
{
    this(T t1, T t2, T t3)
    {
        values = [t1, t2, t3];
    }
    this(T[3] ts){values = [ts[0], ts[1], ts[2]];}
    Vector!T opIndexUnary(string op)(size_t index)
    {
        static if(op == "-")
            return Vector(-values[0], -values[1], -values[2]);
        return this;
    }
    T dot()(auto ref Vector!T other) const
    {
        return (values[0]*other[0] + values[1]*other[1] + values[2] * other[2]);
    }

    const T mag(){return sqrt(values[0]*values[0] + values[1]*values[1] + values[2]*values[2]);}
    void normalize()
    {
        const float m = mag();
        values[]/=m;
    }

    Vector!T unit() const 
    {
        const T m = mag();
        return Vector!T(values[0]/m, values[1]/m, values[2]/m);
    }
    
    Vector!T project(ref Vector!T reference) const
    {
        auto n = reference.unit;
        return n * dot(reference);
    }

    pragma(inline, true)
    auto axisAngle(const ref Vector!T axis, float angle)
    {
        auto n = axis.unit;
        auto proj = n* axis.dot(n);
        auto perpendicular = this - proj;
        auto rot = perpendicular*cos(angle) + n.cross(perpendicular)*sin(angle);
        return proj + rot;
    }


    Vector!T cross(ref Vector!T other) const
    {
        return Vector(values[1]*other[2] - values[2]-other[1],
                     -(values[0]*other[2]- values[2]*other[0]),
                     values[0]*other[1] - values[1]*other[0]);
    }

    static T Dot(ref Vector!T first, ref Vector!T second){return first.dot(second);}

    Vector!T rotateZ(float radians)
    {
        const float c = cos(radians);
        const float s = sin(radians);

        return Vector!T(x*c - y*s, y*c + s*x, z);
    }

    auto opBinary(string op)(auto ref Vector!T rhs) const
    {
        static if(op == "+")return Vector(values[0]+ rhs[0], values[1]+ rhs[1], values[2]+ rhs[2]);
        else static if(op == "-")return Vector(values[0]- rhs[0], values[1]- rhs[1], values[2]- rhs[2]);
        else static if(op == "*")return dot(rhs);
    }

    auto opBinary(string op)(auto ref T rhs) const
    {
        mixin("return Vector(values[0] "~ op ~ "rhs , values[1] "~ op ~ "rhs, values[2] "~ op~"rhs);");
    }

    T opIndexAssign(T value, size_t index)
    {
        values[index] = value;
        return value;
    }
    
    ref Vector!T opAssign(Vector!T other)
    {
        values[0] = other[0];
        values[1] = other[1];
        values[2] = other[2];
        return this;
    }
    ref Vector!T opAssign(T[3] other)
    {
        values[0] = other[0];
        values[1] = other[1];
        values[2] = other[2];
        return this;
    }
    ref T opIndex(size_t index){return values[index];}

    static Vector!T Zero(){return Vector(0,0,0);}
    private T[3] values;

    scope ref T x(){return values[0];}
    scope ref T y(){return values[1];}
    scope ref T z(){return values[2];}

}

alias Vectorf = Vector!float;
// alias Vectord = Vector!double;
