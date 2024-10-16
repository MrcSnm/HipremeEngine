/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.math.vector;
import core.math : sqrt, sin, cos;
float abc(int a, int b) { return cast(float)a+b;}

struct Vector(uint N, T)
{
    @"format" string toString()
    {
        static if(N == 2) return "<$x, $y>";
        else static if(N == 3) return "<$x, $y, $z>";
        else static if(N == 4) return "<$x, $y, $z, $w>";
    }
    static assert(N >= 2 && N <= 4, "Vector is only implemented for 2, 3 and 4 dimensions");
    private alias VectorN = Vector!(N, T);
    @nogc @safe nothrow
    {
        static if(N == 2)
        {
            this(T x, T y)
            {
                static if(isSIMD)
                {
                    this.x = x;
                    this.y = y;
                }
                else
                    data = [x, y];
            }
            this(T[2] v)
            {
                static if(isSIMD)
                {
                    x = v[0];
                    y = v[1];
                }
                else
                    data = [v[0], v[1]];
            }
        }
        else static if (N == 3)
        {
            this(T x, T y, T z)
            {
                static if(isSIMD)
                {
                    this.x = x;
                    this.y = y;
                    this.z = z;
                }
                else
                    data = [x, y, z];
            }
            this(T[3] v)
            {
                static if(isSIMD)
                {
                    x = v[0];
                    y = v[1];
                    z = v[2];
                }
                else
                    data = [v[0], v[1], v[2]];
            }
        }
        else static if (N == 4)
        {
            this(T x, T y, T z, T w = 1)
            {
                static if(isSIMD)
                {
                    this.x = x;
                    this.y = y;
                    this.z = z;
                    this.w = w;
                }
                else
                    data = [x, y, z, w];
            }
            this(T[4] v)
            {
                static if(isSIMD)
                {
                    x = v[0];
                    y = v[1];
                    z = v[2];
                    w = v[3];
                }
                else
                    data = [v[0], v[1], v[2], v[3]];
            }
        }
        static if(N >= 3)
        {
            pragma(inline, true)
            {
                Vector2 xy(){return Vector2(x, y);}
                Vector2 xy(Vector2 v){x = v.x; y = v.y; return v;}
                Vector2 yx(){return Vector2(y, x);}
                Vector2 yx(Vector2 v){y = v.x; x = v.y; return yx;}
            }
        }
        static if(N == 4)
        {
            pragma(inline, true)
            {
                Vector3 xyz(){return Vector3(x, y, z);}
                Vector3 xyz(Vector3 v){x = v.x; y = v.y;z = v.z; return v;}
            }
        }
        pragma(inline, true) T opIndexUnary(string op)(size_t index) if(op == "-")
        {
            assert(index >= 0 && index <= N);
            return mixin(op ~ "data[",index,"];");
        }
        auto opUnary(string op)() inout if(op == "-")
        {
            static if(N == 2) return Vector!(2, T)(-data[0], -data[1]);
            static if(N == 3) return Vector!(3, T)(-data[0], -data[1], -data[2]);
            static if(N == 4) return Vector!(4, T)(-data[0], -data[1], -data[2], -data[3]);
        }
        float dot()(auto ref VectorN other) inout
        {
            float ret = 0;
            for(int i = 0; i < N; i++)
                ret+= data[i]*other[i];
            return ret;
        }
        inout float mag()
        {
            float ret = 0;
            for(int i = 0; i < N; i++)
                ret+= data[i]*data[i];
            return sqrt(ret);
        }
        inout float magSquare()
        {
            float ret = 0;
            for(int i = 0; i < N; i++)
                ret+= data[i]*data[i];
            return ret;
        }
        void normalize()
        {
            const float m = mag();
            if(m != 0)
                data[]/=m;
        }

        float distance(VectorN other)
        {
            float dx = (other.x-x);
            dx*=dx;
            float dy = other.y-y;
            dy*=dy;
            
            static if(N >= 3)
            {
                float dz = other.z-z;
                dz*=dz;
                static if(N == 4)
                {
                    float dw = other.w - w;
                    dw*=dw;
                    return sqrt(dx+dy+dz+dw);
                }
                else
                    return sqrt(dx+dy+dz);
            }
            static if(N == 2)
                return sqrt(dx+dy);
        }

        VectorN unit() inout
        {
            const float m = mag();
            if(m != 0)
                return this / m;
            return this;
        }
        
        VectorN project()(auto ref VectorN reference) inout
        {
            auto n = reference.unit;
            return n * dot(reference);
        }

        static if(N == 3)
        {
            VectorN axisAngle(in VectorN axis, float angle) inout
            {
                auto n = axis.unit;
                auto proj = n* axis.dot(n);
                auto perpendicular = this - proj;
                auto rot = perpendicular*cos(angle) + n.cross(perpendicular)*sin(angle);
                return proj + rot;
            }


            VectorN cross()(auto ref VectorN other) inout
            {
                return VectorN(data[1]*other[2] - data[2]-other[1],
                            -(data[0]*other[2]- data[2]*other[0]),
                            data[0]*other[1] - data[1]*other[0]);
            }
        }

        static float Dot()(auto ref Vector!N first, auto ref Vector!N second){return first.dot(second);}

        static if(N >= 3)
        {
            VectorN rotateZ(float radians)
            {
                const float c = cos(radians);
                const float s = sin(radians);

                static if(N == 3)
                    return VectorN(x*c - y*s, y*c + s*x, z);
                else
                    return Vector!(N, T)(x*c - y*s, y*c + s*x, z, w);
            }
        }

        pragma(inline, true)
        {
            VectorN opBinary(string op)(in VectorN rhs) inout if(op == "*" || op == "/" || op == "+" || op == "-")
            {
                VectorN ret;
                for(size_t i = 0; i < N; i++)   
                {
                    ret[i] = mixin("data[i] ", op,"rhs[i]");
                    version(HipMathSkipNanCheck){}
                    else static if(op == "/" || op == "-") assert(ret[i] == ret[i]); //Check for float.nan
                }
                return ret;
            }
            VectorN opBinary(string op)(float rhs) inout
            {
                VectorN ret;
                for(size_t i = 0; i < N; i++)
                {
                    ret[i] = mixin("data[i]", op, "rhs");
                    version(HipMathSkipNanCheck){}
                    else static if(op == "/" || op == "-") assert(ret[i] == ret[i]); //Check for float.nan
                }
                return ret;
            }

            alias opBinaryRight = opBinary;
            auto opOpAssign(string op)(VectorN other) return
            {
                version(HipMathSkipNanCheck)
                    mixin("data[]",op,"= other.data[];");
                else
                {
                    for(size_t i = 0; i < N; i++)
                    {
                        mixin("data[i]",op,"= other[i];");
                        static if(op == "/" || op == "-") 
                        assert(data[i] == data[i]); //Check for float.nan
                    }
                }
                return this;
            }

            auto opOpAssign(string op)(float value) return
            {
                version(HipMathSkipNanCheck)
                    mixin("data[]",op,"= value;");
                else
                {
                    for(size_t i = 0; i < N; i++)
                    {
                        mixin("data[i]",op,"= value;");
                        static if(op == "/" || op == "-") 
                        assert(data[i] == data[i]); //Check for float.nan
                    }
                }
                return this;
            }

            ref VectorN opAssign(in VectorN other) return
            {
                for(size_t i = 0; i < N; i++)
                    data[i] = other[i];
                return this;
            }

            ref VectorN opAssign(in T[N] other) return
            {
                for(size_t i = 0; i < N; i++)
                    data[i] = other[i];
                return this;
            }

            static VectorN zero()
            {
                return VectorN.init;
            }

        }

        private enum isSIMD = false;
        static if(isSIMD)
        {
            alias TSimd = mixin(T.stringof~"4");
            private TSimd data; //int2, float2 are not supported for some reason
        }
        else
        {
            ///Use 0 init for every type of number, float starts with nan which always involve into setting it to
            //a reasonable value
            private T[N] data = 0;
        }

        pragma(inline, true)
        {
            @trusted inout auto ref x() return 
            {
                static if(isSIMD)
                    return (cast(T*)&data)[0];
                else
                    return data[0];
            }
            @trusted inout auto ref y() return 
            {
                static if(isSIMD)
                    return (cast(T*)&data)[1];
                else
                    return data[1];
            }
            static if(N >= 3)
            {
                @trusted inout auto ref z() return 
                {
                    static if(isSIMD)
                        return (cast(T*)&data)[2];
                    else
                        return data[2];
                }
            }
            static if(N == 4)
            {
                @trusted inout auto ref w() return 
                {
                    static if(isSIMD)
                        return (cast(T*)&data)[3];
                    else
                        return data[3];
                }
            }

            inout auto ref opIndex(size_t index)
            {
                return data[index];
            }
        }

    }
}

alias Vector2 = Vector!(2, float);
alias Vector3 = Vector!(3, float);
alias Vector4 = Vector!(4, float);