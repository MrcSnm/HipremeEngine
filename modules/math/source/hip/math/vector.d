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
import core.simd;

public struct Vector(uint N, T)
{
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
        T opIndexUnary(string op)(size_t index) if(op == "-")
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
            VectorN axisAngle(in ref VectorN axis, float angle) inout
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

        auto opBinary(string op)(in VectorN rhs) inout
        {
            static if(op == "*") return dot(rhs);
            else static if(op != "/")
            {
                VectorN ret;
                for(size_t i = 0; i < N; i++)   
                    mixin("ret[i] = data[i] "~op~"rhs[i];");
                return ret;
            }
        }
        VectorN opBinary(string op)(float rhs) inout
        {
            VectorN ret;
            for(size_t i = 0; i < N; i++)
                mixin("ret[i] = data[i] "~op~"rhs;");
            return ret;
        }

        alias opBinaryRight = opBinary;
        // auto opBinaryRight(string op)(in VectorN lhs) inout
        // {
        //     static if(op == "*") return dot(lhs);
        //     else static if(op != "/")
        //     {
        //         VectorN ret;
        //         for(size_t i = 0; i < N; i++)   
        //             mixin("ret[i] = lhs[i] "~op~"data[i];");
        //         return ret;
        //     }
        // }
        // VectorN opBinaryRight(string op)(float lhs) inout
        // {
        //     VectorN ret;
        //     for(size_t i = 0; i < N; i++)
        //         mixin("ret[i] = lhs "~op~"data[i];");
        //     return ret;
        // }

        auto opOpAssign(string op)(VectorN other) return
        {
            for(size_t i = 0; i < N; i++)
                mixin("data[i]"~op~"= other[i];");
            return this;
        }

        auto opOpAssign(string op)(float value) return
        {
            for(size_t i = 0; i < N; i++)
                mixin("data[i]"~op~"= value;");
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

        enum isSIMD = false;
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
            assert(index >= 0 && index <= N, "Out of bounds");
            return data[index];
        }
    }
}

// public struct Vector2
// {
//     @nogc @safe nothrow
//     {

//         this(float x, float y)
//         {
//             data = [x,y];
//         }
//         this(float[2] v){data = [v[0], v[1]];}
//         float opIndexUnary(string op)(size_t index)
//         {
//             return mixin(op ~ "data[",index~"];");
//         }
//         auto opUnary(string op)() inout
//         {
//             static if(op == "-")
//                 return Vector2(-data[0], -data[1]);
//             else static if(op == "+")
//                 return Vector2(data[0], data[1]);
//             else
//                 static assert(0, op~" is not supported on vectors");
//         }
//         float dot()(auto ref Vector2 other) inout
//         {
//             return (data[0]*other[0] + data[1]*other[1]);
//         }

//         const float mag(){return sqrt(data[0]*data[0] + data[1]*data[1]);}
//         const float magSquare(){return data[0]*data[0] + data[1] * data[1];}

        
//         void normalize()
//         {
//             const float m = mag();
//             data[]/=m;
//         }

//         Vector2 unit() inout
//         {
//             const float m = mag();
//             return Vector2(data[0]/m, data[1]/m);
//         }
        
//         Vector2 project(ref Vector2 reference) inout
//         {
//             auto n = reference.unit;
//             return n * dot(reference);
//         }

//         static float dot(ref Vector2 first, ref Vector2 second){return first.dot(second);}

//         Vector2 rotate(float radians)
//         {
//             const float c = cos(radians);
//             const float s = sin(radians);

//             return Vector2(x*c - y*s, y*c + s*x);
//         }

//         auto opBinary(string op)(auto ref in Vector2 rhs) inout
//         {
//             static if(op == "+")return Vector2(data[0]+ rhs[0], data[1]+ rhs[1]);
//             else static if(op == "-")return Vector2(data[0]- rhs[0], data[1]- rhs[1]);
//             else static if(op == "*")return dot(rhs);
//         }
//         auto opBinary(string op)(auto ref float rhs) inout
//         {
//             mixin("return Vector2(data[0] "~ op ~ "rhs , data[1] "~ op ~ "rhs);");
//         }
//         auto opBinaryRight(string op, T)(auto ref T lhs) inout {return opBinary!op(lhs);}

//         ref Vector2 opAssign(Vector2 other) return
//         {
//             data[0] = other[0];
//             data[1] = other[1];
//             return this;
//         }

//         static Vector2 zero(){return Vector2(0,0);}
//         private float[2] data;

//         inout auto ref float x() return {return data[0];}
//         inout auto ref float y() return {return data[1];}
//         inout auto ref opIndex(size_t index){return data[index];}
//     }
// }


// public struct Vector3
// {
//     @nogc @safe nothrow
//     {

//         this(float x, float y, float z)
//         {
//             data = [x,y,z];
//         }
//         this(float[3] v){data = [v[0], v[1], v[2]];}
//         float opIndexUnary(string op)(size_t index)
//         {
//             return mixin(op ~ "data[",index~"];");
//         }
//         auto opUnary(string op)() inout
//         {
//             static if(op == "-")
//                 return Vector3(-data[0], -data[1], -data[2]);
//             else static if(op == "+")
//                 return Vector3(data[0], data[1], data[2]);
//             else
//                 static assert(0, op~" is not supported on vectors");
//         }
//         float dot()(auto ref Vector3 other) inout
//         {
//             return (data[0]*other[0] + data[1]*other[1] + data[2] * other[2]);
//         }

//         inout float mag(){return sqrt(data[0]*data[0] + data[1]*data[1] + data[2]*data[2]);}
//         inout float magSquare(){return data[0]*data[0] + data[1] * data[1] + data[2]*data[2];}
//         void normalize()
//         {
//             const float m = mag();
//             data[]/=m;
//         }

//         float distance(Vector3 other)
//         {
//             float dx = (other.x-x);
//             dx*=dx;
//             float dy = other.y-y;
//             dy*=dy;
//             float dz = other.z-z;
//             dz*=dz;
//             return sqrt(dx+dy+dz);
//         }

//         Vector3 unit() const 
//         {
//             const float m = mag();
//             return Vector3(data[0]/m, data[1]/m, data[2]/m);
//         }
        
//         Vector3 project(ref Vector3 reference) const
//         {
//             auto n = reference.unit;
//             return n * dot(reference);
//         }

//         pragma(inline, true)
//         auto axisAngle(in ref Vector3 axis, float angle) inout
//         {
//             auto n = axis.unit;
//             auto proj = n* axis.dot(n);
//             auto perpendicular = this - proj;
//             auto rot = perpendicular*cos(angle) + n.cross(perpendicular)*sin(angle);
//             return proj + rot;
//         }


//         Vector3 cross(ref Vector3 other) inout
//         {
//             return Vector3(data[1]*other[2] - data[2]-other[1],
//                         -(data[0]*other[2]- data[2]*other[0]),
//                         data[0]*other[1] - data[1]*other[0]);
//         }

//         static float Dot(ref Vector3 first, ref Vector3 second){return first.dot(second);}

//         Vector3 rotateZ(float radians)
//         {
//             const float c = cos(radians);
//             const float s = sin(radians);

//             return Vector3(x*c - y*s, y*c + s*x, z);
//         }

//         auto opBinary(string op)(auto ref in Vector3 rhs) inout
//         {
//             static if(op == "+")return Vector3(data[0]+ rhs[0], data[1]+ rhs[1], data[2]+ rhs[2]);
//             else static if(op == "-")return Vector3(data[0]- rhs[0], data[1]- rhs[1], data[2]- rhs[2]);
//             else static if(op == "*")return dot(rhs);
//         }

//         Vector3 opBinary(string op)(float rhs) inout
//         {
//             mixin("return Vector3(data[0] "~ op ~ "rhs , data[1] "~ op ~ "rhs, data[2] "~ op~"rhs);");
//         }
//         auto opBinaryRight(string op, T)(T lhs) inout{return opBinary!op(lhs);}

//         auto opOpAssign(string op, T)(T value)
//         {
//             mixin("this.x"~op~"= value;");
//             mixin("this.y"~op~"= value;");
//             mixin("this.z"~op~"= value;");
//             return this;
//         }
//         ref Vector3 opAssign(Vector3 other) return
//         {
//             data[0] = other[0];
//             data[1] = other[1];
//             data[2] = other[2];
//             return this;
//         }
//         ref Vector3 opAssign(float[3] other) return
//         {
//             data[0] = other[0];
//             data[1] = other[1];
//             data[2] = other[2];
//             return this;
//         }

//         static Vector3 Zero(){return Vector3(0,0,0);}
//         private float[3] data;

//         inout auto ref float x() return {return data[0];}
//         inout auto ref float y() return {return data[1];}
//         inout auto ref float z() return {return data[2];}
//         inout auto ref opIndex(size_t index){return data[index];}
//     }
// }

// public struct Vector4
// {
//     @nogc @safe nothrow
//     {

//         this(float x, float y, float z, float w)
//         {
//             data = [x,y,z, w];
//         }
//         this(float[4] v){data = [v[0], v[1], v[2], v[3]];}
//         float opIndexUnary(string op)(size_t index)
//         {
//             return mixin(op ~ "data[",index~"];");
//         }
//         auto opUnary(string op)() inout
//         {
//             static if(op == "-")
//                 return Vector4(-data[0], -data[1], -data[2], -data[3]);
//             else static if(op == "+")
//                 return Vector4(data[0], data[1], data[2], data[3]);
//             else
//                 static assert(0, op~" is not supported on vectors");
//         }
//         float dot()(auto ref Vector4 other) inout
//         {
//             return (data[0]*other[0] + data[1]*other[1] + data[2] * other[2] + data[3]*other[3]);
//         }

//         inout float mag(){return sqrt(data[0]*data[0] + data[1]*data[1] + data[2]*data[2] + data[3]*data[3]);}
//         inout float magSquare(){return data[0]*data[0] + data[1] * data[1] + data[2]*data[2] + data[3] * data[3];}
//         void normalize()
//         {
//             const float m = mag();
//             data[]/=m;
//         }

//         Vector4 unit() inout 
//         {
//             const float m = mag();
//             return Vector4(data[0]/m, data[1]/m, data[2]/m, data[3]/m);
//         }
        
//         Vector4 project(ref Vector4 reference) inout
//         {
//             auto n = reference.unit;
//             return n * dot(reference);
//         }

//         static float Dot(ref Vector3 first, ref Vector3 second){return first.dot(second);}

//         auto opBinary(string op)(auto ref Vector3 rhs) inout
//         {
//             static if(op == "+")return Vector4(data[0]+ rhs[0], data[1]+ rhs[1], data[2]+ rhs[2], data[3]+rhs[3]);
//             else static if(op == "-")return Vector4(data[0]- rhs[0], data[1]- rhs[1], data[2]- rhs[2], data[3]-rhs[3]);
//             else static if(op == "*")return dot(rhs);
//         }

//         auto opBinary(string op)(auto ref float rhs) inout
//         {
//             mixin("return Vector4(data[0] "~ op ~ "rhs,
//             data[1] "~ op ~ "rhs,
//             data[2] "~ op~"rhs,
//             data[3] "~ op~"rhs);");
//         }

//         ref Vector4 opAssign(Vector4 other) return
//         {
//             data[0] = other[0];
//             data[1] = other[1];
//             data[2] = other[2];
//             data[3] = other[3];
//             return this;
//         }
//         ref Vector4 opAssign(float[4] other) return
//         {
//             data[0] = other[0];
//             data[1] = other[1];
//             data[2] = other[2];
//             data[3] = other[3];
//             return this;
//         }

//         static Vector4 Zero(){return Vector4(0,0,0,0);}
//         private float[4] data;

//         inout auto ref float x() return {return data[0];}
//         inout auto ref float y() return {return data[1];}
//         inout auto ref float z() return {return data[2];}
//         inout auto ref float w() return {return data[3];}
//         inout auto ref opIndex(size_t index){return data[index];}
//     }
// }



alias Vector2 = Vector!(2, float);
alias Vector3 = Vector!(3, float);
alias Vector4 = Vector!(4, float);

// alias Vector2i = Vector!(2, int);
// alias Vector3i = Vector!(3, int);
// alias Vector4i = Vector!(4, int);