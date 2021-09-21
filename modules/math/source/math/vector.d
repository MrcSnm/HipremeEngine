/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/

module math.vector;
import core.math : sqrt, sin, cos;

public struct Vector2
{
    this(float x, float y)
    {
        values = [x,y];
    }
    this(float[2] v){values = [v[0], v[1]];}
    Vector2 opIndexUnary(string op)(size_t index)
    {
        static if(op == "-")
            return Vector(-values[0], -values[1]);
        return this;
    }
    float dot()(auto ref Vector2 other) const
    {
        return (values[0]*other[0] + values[1]*other[1]);
    }

    const float mag(){return sqrt(values[0]*values[0] + values[1]*values[1]);}
    void normalize()
    {
        const float m = mag();
        values[]/=m;
    }

    Vector2 unit() const 
    {
        const float m = mag();
        return Vector2(values[0]/m, values[1]/m);
    }
    
    Vector2 project(ref Vector2 reference) const
    {
        auto n = reference.unit;
        return n * dot(reference);
    }

    static float dot(ref Vector2 first, ref Vector2 second){return first.dot(second);}

    Vector2 rotate(float radians)
    {
        const float c = cos(radians);
        const float s = sin(radians);

        return Vector2(x*c - y*s, y*c + s*x);
    }

    auto opBinary(string op)(auto ref Vector2 rhs) const
    {
        static if(op == "+")return Vector2(values[0]+ rhs[0], values[1]+ rhs[1]);
        else static if(op == "-")return Vector2(values[0]- rhs[0], values[1]- rhs[1]);
        else static if(op == "*")return dot(rhs);
    }

    auto opBinary(string op)(auto ref float rhs) const
    {
        mixin("return Vector2(values[0] "~ op ~ "rhs , values[1] "~ op ~ "rhs);");
    }
    ref Vector2 opAssign(Vector2 other) return
    {
        values[0] = other[0];
        values[1] = other[1];
        return this;
    }

    static Vector2 zero(){return Vector2(0,0);}
    private float[2] values;

    scope ref float x() return {return values[0];}
    scope ref float y() return {return values[1];}
    alias values this;

}


public struct Vector3
{
    this(float x, float y, float z)
    {
        values = [x,y,z];
    }
    this(float[3] v){values = [v[0], v[1], v[2]];}
    Vector3 opIndexUnary(string op)(size_t index)
    {
        static if(op == "-")
            return Vector(-values[0], -values[1], -values[2]);
        return this;
    }
    float dot()(auto ref Vector3 other) const
    {
        return (values[0]*other[0] + values[1]*other[1] + values[2] * other[2]);
    }

    const float mag(){return sqrt(values[0]*values[0] + values[1]*values[1] + values[2]*values[2]);}
    void normalize()
    {
        const float m = mag();
        values[]/=m;
    }

    float distance(Vector3 other)
    {
        float dx = (other.x-x);
        dx*=dx;
        float dy = other.y-y;
        dy*=dy;
        float dz = other.z-z;
        dz*=dz;
        return sqrt(dx+dy+dz);
    }

    Vector3 unit() const 
    {
        const float m = mag();
        return Vector3(values[0]/m, values[1]/m, values[2]/m);
    }
    
    Vector3 project(ref Vector3 reference) const
    {
        auto n = reference.unit;
        return n * dot(reference);
    }

    pragma(inline, true)
    auto axisAngle(const ref Vector3 axis, float angle) const
    {
        auto n = axis.unit;
        auto proj = n* axis.dot(n);
        auto perpendicular = this - proj;
        auto rot = perpendicular*cos(angle) + n.cross(perpendicular)*sin(angle);
        return proj + rot;
    }


    Vector3 cross(ref Vector3 other) const
    {
        return Vector3(values[1]*other[2] - values[2]-other[1],
                     -(values[0]*other[2]- values[2]*other[0]),
                     values[0]*other[1] - values[1]*other[0]);
    }

    static float Dot(ref Vector3 first, ref Vector3 second){return first.dot(second);}

    Vector3 rotateZ(float radians)
    {
        const float c = cos(radians);
        const float s = sin(radians);

        return Vector3(x*c - y*s, y*c + s*x, z);
    }

    auto opBinary(string op)(auto ref Vector3 rhs) const
    {
        static if(op == "+")return Vector3(values[0]+ rhs[0], values[1]+ rhs[1], values[2]+ rhs[2]);
        else static if(op == "-")return Vector3(values[0]- rhs[0], values[1]- rhs[1], values[2]- rhs[2]);
        else static if(op == "*")return dot(rhs);
    }

    Vector3 opBinary(string op, T)(auto ref T rhs) const
    {
        mixin("return Vector3(values[0] "~ op ~ "rhs , values[1] "~ op ~ "rhs, values[2] "~ op~"rhs);");
    }
    Vector3 opBinaryRight(string op, T)(auto ref T lhs) const
    {
        mixin("return Vector3(values[0] "~ op ~ "rhs , values[1] "~ op ~ "rhs, values[2] "~ op~"rhs);");
    }
    auto opOpAssign(string op, T)(T value)
    {
        mixin("this.x"~op~"= value;");
        mixin("this.y"~op~"= value;");
        mixin("this.z"~op~"= value;");
        return this;
    }
    ref Vector3 opAssign(Vector3 other) return
    {
        values[0] = other[0];
        values[1] = other[1];
        values[2] = other[2];
        return this;
    }
    ref Vector3 opAssign(float[3] other) return
    {
        values[0] = other[0];
        values[1] = other[1];
        values[2] = other[2];
        return this;
    }

    static Vector3 Zero(){return Vector3(0,0,0);}
    private float[3] values;

    scope ref float x() return {return values[0];}
    scope ref float y() return {return values[1];}
    scope ref float z() return {return values[2];}
    alias values this;

}

public struct Vector4
{
    this(float x, float y, float z, float w)
    {
        values = [x,y,z, w];
    }
    this(float[4] v){values = [v[0], v[1], v[2], v[3]];}
    Vector3 opIndexUnary(string op)(size_t index)
    {
        static if(op == "-")
            return Vector(-values[0], -values[1], -values[2], -values[3]);
        return this;
    }
    float dot()(auto ref Vector4 other) const
    {
        return (values[0]*other[0] + values[1]*other[1] + values[2] * other[2] + values[3]*other[3]);
    }

    const float mag(){return sqrt(values[0]*values[0] + values[1]*values[1] + values[2]*values[2] + values[3]*values[3]);}
    void normalize()
    {
        const float m = mag();
        values[]/=m;
    }

    Vector4 unit() const 
    {
        const float m = mag();
        return Vector4(values[0]/m, values[1]/m, values[2]/m, values[3]/m);
    }
    
    Vector4 project(ref Vector4 reference) const
    {
        auto n = reference.unit;
        return n * dot(reference);
    }

    static float Dot(ref Vector3 first, ref Vector3 second){return first.dot(second);}

    auto opBinary(string op)(auto ref Vector3 rhs) const
    {
        static if(op == "+")return Vector4(values[0]+ rhs[0], values[1]+ rhs[1], values[2]+ rhs[2], values[3]+rhs[3]);
        else static if(op == "-")return Vector4(values[0]- rhs[0], values[1]- rhs[1], values[2]- rhs[2], values[3]-rhs[3]);
        else static if(op == "*")return dot(rhs);
    }

    auto opBinary(string op)(auto ref float rhs) const
    {
        mixin("return Vector4(values[0] "~ op ~ "rhs,
        values[1] "~ op ~ "rhs,
        values[2] "~ op~"rhs,
        values[3] "~ op~"rhs);");
    }
    
    ref Vector4 opAssign(Vector4 other) return
    {
        values[0] = other[0];
        values[1] = other[1];
        values[2] = other[2];
        values[3] = other[3];
        return this;
    }
    ref Vector4 opAssign(float[4] other) return
    {
        values[0] = other[0];
        values[1] = other[1];
        values[2] = other[2];
        values[3] = other[3];
        return this;
    }

    static Vector4 Zero(){return Vector4(0,0,0,0);}
    private float[4] values;

    scope ref float x() return {return values[0];}
    scope ref float y() return {return values[1];}
    scope ref float z() return {return values[2];}
    scope ref float w() return {return values[3];}
    alias values this;

}