module math.vector;
import std.stdio;
import core.math : sqrt;

public struct Vector(T)
{
    this(T t1, T t2, T t3)
    {
        values = [t1, t2, t3];
    }
    Vector!T opIndexUnary(string op)(size_t index)
    {
        static if(op == "-")
            return Vector(-values[0], -values[1], -values[2]);
        return this;
    }
    T dot(ref Vector!T other) const
    {
        return (values[0]*other[0] + values[1]*other[1] + values[2] * other[2]);
    }

    float mag(){return sqrt(values[0]*values[0] + values[1]*values[1] + values[2]*values[2]);}
    void normallize()
    {
        const float m = mag();
        values[0]/=m;
        values[1]/=m;
        values[2]/=m;
    }


    Vector!T cross(ref Vector!T other) const
    {
        return Vector(values[1]*other[2] - values[2]-other[1],
                     -(values[0]*other[2]- values[2]*other[0]),
                     values[0]*other[1] - values[1]*other[0]);
    }

    static T Dot(ref Vector!T first, ref Vector!T second){return first.dot(second);}

    auto opBinary(string op)(ref Vector!T rhs) const
    {
        static if(op == "+")return Vector(values[0]+ rhs[0], values[1]+ rhs[1], values[2]+ rhs[2]);
        else static if(op == "-")return Vector(values[0]- rhs[0], values[1]- rhs[1], values[2]- rhs[2]);
        return this;
    }

    auto opBinary(string op)(const ref T rhs) const
    {
        static if(op == "+")return Vector(values[0]+ rhs, values[1]+ rhs, values[2]+ rhs);
        else static if(op == "-")return Vector(values[0]- rhs, values[1]- rhs, values[2]- rhs);
        else static if(op == "*")return Vector(values[0]* rhs, values[1]* rhs, values[2]* rhs);
        else static if(op == "/")return Vector(values[0]/ rhs, values[1]/ rhs, values[2]/ rhs);
        return this;
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
    ref T opIndex(size_t index){return values[index];}

    static Vector!T Zero(){return Vector(0,0,0);}
    private T[3] values;

    scope ref T x(){return values[0];}
    scope ref T y(){return values[1];}
    scope ref T z(){return values[2];}
}