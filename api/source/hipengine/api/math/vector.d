/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/
module hipengine.api.math.vector;

version(HipremeEngineDef)
{
    public import math.vector;
}
else: //version(Script):

// import internal;
struct VectorImpl
{
    extern(C):
    //Vector2
    static float function(const ref Vector2 first, Vector2 other) dot;
    static float function (const ref Vector2 first) mag;
    static void function (ref Vector2 first) normalize;
    static Vector2 function(const ref Vector2 first) unit;
    static Vector2 function (const ref Vector2 first, Vector2 reference) project;
    static Vector2 function(const ref Vector2 first, float radians) rotate;


    //Vector3
    static float function(const ref Vector3 first, Vector3 other) dot_3;
    static float function (const ref Vector3 first) mag_3;
    static void function (ref Vector3 first) normalize_3;
    static float function(ref Vector3 first, Vector3 other) distance_3;
    static Vector3 function(const ref Vector3 first) unit_3;
    static Vector3 function(const ref Vector3 first, float radians) rotateZ_3;
    static Vector3 function (const ref Vector3 first, Vector3 reference) project_3;
    static Vector3 function(const ref Vector3 first, Vector3 axis, float angle) axisAngle;
    static Vector3 function (const ref Vector3 first, Vector3 other) cross;

    //Vector4
    static float function(const ref Vector4 first, Vector4 other) dot_4;
    static float function (const ref Vector4 first) mag_4;
    static void function (ref Vector4 first) normalize_4;
    static Vector4 function(const ref Vector4 first) unit_4;
    static Vector4 function(const ref Vector4 first, Vector4 other) project_4;
}
private alias impl = VectorImpl;


package void initVector()
{
    import hipengine.internal;
    impl.dot = getSymbol!(VectorImpl.dot);
    impl.mag = getSymbol!(VectorImpl.mag);
    impl.normalize = getSymbol!(VectorImpl.normalize);
    impl.unit = getSymbol!(VectorImpl.unit);
    impl.project = getSymbol!(VectorImpl.project);
    impl.rotate = getSymbol!(VectorImpl.rotate);


    //Vector3
    impl.dot_3 = getSymbol!(VectorImpl.dot_3);
    impl.mag_3 = getSymbol!(VectorImpl.mag_3);
    impl.normalize_3 = getSymbol!(VectorImpl.normalize_3);
    impl.distance_3 = getSymbol!(VectorImpl.distance_3);
    impl.unit_3 = getSymbol!(VectorImpl.unit_3);
    impl.rotateZ_3 = getSymbol!(VectorImpl.rotateZ_3);
    impl.project_3 = getSymbol!(VectorImpl.project_3);
    impl.axisAngle = getSymbol!(VectorImpl.axisAngle);
    impl.cross = getSymbol!(VectorImpl.cross);

    //Vector4
    impl.dot_4 = getSymbol!(VectorImpl.dot_4);
    impl.mag_4 = getSymbol!(VectorImpl.mag_4);
    impl.normalize_4 = getSymbol!(VectorImpl.normalize_4);
    impl.unit_4 = getSymbol!(VectorImpl.unit_4);
    impl.project_4 = getSymbol!(VectorImpl.project_4);
}

public struct Vector2
{
    this(float x, float y){values = [x,y];}
    this(float[2] v){values = [v[0], v[1]];}
    Vector2 opIndexUnary(string op)(size_t index)
    {
        static if(op == "-")
            return Vector(-values[0], -values[1]);
        return this;
    }
    float dot()(auto ref Vector2 other) const{return impl.dot(this, other);}
    const float mag(){return impl.mag(this);}
    void normalize(){impl.normalize(this);}
    Vector2 unit() const {return impl.unit(this);}
    Vector2 project(Vector2 reference) const{return impl.project(this, reference);}
    static float dot(ref Vector2 first, Vector2 second){return first.dot(second);}

    Vector2 rotate(float radians){return impl.rotate(this, radians);}

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

    float opIndexAssign(float value, size_t index)
    {
        values[index] = value;
        return value;
    }
    
    ref Vector2 opAssign(Vector2 other) return
    {
        values[0] = other[0];
        values[1] = other[1];
        return this;
    }
    static Vector2 zero(){return Vector2(0,0);}
    private float[2] values;
    auto ref float x() return {return values[0];}
    auto ref float y() return {return values[1];}

    auto ref opIndex(size_t index){return values[index];}
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
    float dot(Vector3 other) const{return impl.dot_3(this, other);}

    const float mag(){return impl.mag_3(this);}
    void normalize(){impl.normalize_3(this);}
    float distance(Vector3 other){return impl.distance_3(this, other);}
    Vector3 unit() const {return impl.unit_3(this);}
    Vector3 project(ref Vector3 reference) const{return impl.project_3(this, reference);}
    auto axisAngle(const ref Vector3 axis, float angle){return impl.axisAngle(this, axis, angle);}
    Vector3 cross(ref Vector3 other) const{return impl.cross(this, other);}
    static float Dot(ref Vector3 first, ref Vector3 second){return first.dot(second);}
    Vector3 rotateZ(float radians){return impl.rotateZ_3(this, radians);}

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

    auto ref float x() return {return values[0];}
    auto ref float y() return {return values[1];}
    auto ref float z() return {return values[2];}
    auto ref opIndex(size_t index){return values[index];}
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
    float dot(Vector4 other) const{return impl.dot_4(this, other);}

    const float mag(){return impl.mag_4(this);}
    void normalize(){impl.normalize_4(this);}
    Vector4 unit() const {return impl.unit_4(this);}
    Vector4 project(Vector4 reference) const{return impl.project_4(this, reference);}
    static float Dot(Vector4 first, Vector4 second){return first.dot(second);}
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

    auto ref float x() return {return values[0];}
    auto ref float y() return {return values[1];}
    auto ref float z() return {return values[2];}
    auto ref float w() return {return values[3];}
    auto ref opIndex(size_t index){return values[index];}
}