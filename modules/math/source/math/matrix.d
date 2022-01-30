/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module math.matrix;
import core.math;
import util.conv;

enum MatrixType
{
    COLUMN_MAJOR,
    ROW_MAJOR
}

struct Matrix3
{
    float[9] values;
    pragma(inline) inout ref auto opIndex(size_t i) return
    {
        return values[i];
    }
    pragma(inline) inout ref auto opIndex(size_t i, size_t j) return
    {
        return values[i*3+j];
    }
    pragma(inline, true)
    static Matrix3 translation(float x, float y)
    {
        return Matrix3([
            1, 0, 0,
            0, 1, 0,
            x, y, 1
        ]);
    }
    static Matrix3 identity()
    {
        return Matrix3([
            1,0,0,
            0,1,0,
            0,0,1
        ]);
    }
    Matrix3 translate(float x, float y)
    {
        return this * translation(x,y);
    }

    Matrix3 scale(float x, float y)
    {
        return this * Matrix3([
            x, 0, 0,
            0, y, 0,
            0, 0, 1
        ]);
    }
    Matrix3 transpose()
    {
        return Matrix3([
            this[0], this[3], this[6],
            this[1], this[4], this[7],
            this[2], this[5], this[8]
        ]);
    }

    static Matrix3 rotation(float radians)
    {
        float c = cos(radians);
        float s = sin(radians);

        return Matrix3([
            c, s, 0,
           -s, c, 0,
            0, 0, 1
        ]);
    }

    Matrix3 rotate(float radians)
    {
        return this * rotation(radians);
    }


    Matrix3 opBinary(string op, R)(const R rhs) const
    {
        Matrix3 ret;
        ret.values = this.values;
        static if(op == "*")
        {
            static if(is(R == float))
            {
                ret[]*= rhs;
            }
            else //Matrix case
            {
                for(uint i = 0; i < 9; i+=3)
                {
                    ret[i] = values[i]*rhs[0] +values[i+1]*rhs[3] + values[i+2]*rhs[6];
                    ret[i+1] = values[i]*rhs[1] +values[i+1]*rhs[4] + values[i+2]*rhs[7];
                    ret[i+2] = values[i]*rhs[2] +values[i+1]*rhs[5] + values[i+2]*rhs[8];
                }
            }
        }
        else static if(op == "+")
        {
            foreach(i, v; values)
                ret[i]+=rhs[i];
        }
        else static if(op == "-")
        {
            foreach(i, v; values)
                ret[i]-=rhs[i];
        }
        else static if(op == "/")
        {
            static if(is(R == float))
            {
                ret[]/=rhs;
            }
        }
        return ret;
    }

    string toString()
    {
        string ret = "[";
        for(uint i = 0; i < 9; i++)
        {
            if(i != 0)
            {
                if(i%3 == 0)
                    ret~= "]\n[";
                else
                    ret~=", ";
            }            
            ret~= to!string(this[i]);
        }
        return ret~"]";
    }

    T opCast(T)() const
    {
        static assert(is(T == float[9]), "Matrix3 can only be cast to float[9]");
        return values;
    }

    alias values this;
}

struct Matrix4
{
    float[16] values;

    static Matrix4 identity()
    {
        return Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]);
    }
    pragma(inline) inout ref auto opIndex(size_t i) return
    {
        return values[i];
    }
    pragma(inline) inout ref auto opIndex(size_t i, size_t j) return
    {
        return values[i*4+j];
    }
    pragma(inline, true)
    static Matrix4 translation(float x, float y, float z)
    {
        return Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            x, y, z, 1
        ]);
    }
    Matrix4 translate(float x, float y, float z)
    {
        return this * translation(x,y,z);
    }

    static Matrix4 createScale(float x, float y, float z)
    {
        return Matrix4([
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        ]);
    }

    Matrix4 scale(float x, float y, float z)
    {
        return this * Matrix4([
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        ]);
    }
    Matrix4 transpose()
    {
        return Matrix4([
            this[0], this[4], this[8],  this[12],
            this[1], this[5], this[9],  this[13],
            this[2], this[6], this[10], this[14],
            this[3], this[7], this[11], this[15]
        ]);
    }

    static Matrix4 rotationX(float radians)
    {
        float c = cos(radians);
        float s = sin(radians);

        return Matrix4([
            1, 0, 0, 0,
            0, c, s, 0,
            0,-s, c, 0,
            0, 0, 0, 1
        ]);
    }

    static Matrix4 rotationY(float radians)
    {
        float c = cos(radians);
        float s = sin(radians);

        return Matrix4([
            c, 0, s, 0,
            0, 1, 0, 0,
           -s, 0, c, 0,
            0, 0, 0, 1
        ]);
    }
    static Matrix4 rotationZ(float radians)
    {
        float c = cos(radians);
        float s = sin(radians);

        return Matrix4([
            c, s, 0, 0,
           -s, c, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]);
    }

    Matrix4 rotate(float x_angle, float y_angle, float z_angle)
    {
        return this * rotationX(x_angle) * rotationY(y_angle) * rotationZ(z_angle);
    }


    Matrix4 opBinary(string op, R)(const R rhs) const
    {
        Matrix4 ret;
        ret.values = this.values;
        static if(op == "*")
        {
            static if(is(R == float))
            {
                ret[]*= rhs;
            }
            else //Matrix case
            {
                for(uint i = 0; i < 16; i+=4)
                {
                    ret[i]   = values[i]*rhs[0] +values[i+1]*rhs[4] + values[i+2]*rhs[8] + values[i+3]*rhs[12];
                    ret[i+1] = values[i]*rhs[1] +values[i+1]*rhs[5] + values[i+2]*rhs[9] + values[i+3]*rhs[13];
                    ret[i+2] = values[i]*rhs[2] +values[i+1]*rhs[6] + values[i+2]*rhs[10] + values[i+3]*rhs[14];
                    ret[i+3] = values[i]*rhs[3] +values[i+1]*rhs[7] + values[i+2]*rhs[11] + values[i+3]*rhs[15];
                }
            }
        }
        else static if(op == "+")
        {
            foreach(i, v; values)
                ret[i]+=rhs[i];
        }
        else static if(op == "-")
        {
            foreach(i, v; values)
                ret[i]-=rhs[i];
        }
        else static if(op == "/")
        {
            static assert(is(R == float), "Only float is valid for matrix division");
            ret[]/=rhs;
        }
        return ret;
    }

    /**
    * Based on the document on MSDN:
    * https://docs.microsoft.com/en-us/windows/win32/direct3d9/d3dxmatrixorthooffcenterlh?redirectedfrom=MSDN
    */
    static Matrix4 orthoLH(float left, float right, float bottom, float top, float znear, float zfar)
    {
        return Matrix4([
            2/(right-left), 0, 0, 0,
            0, 2/(top-bottom), 0, 0,
            0, 0, 1/(zfar-znear), 0,
            (left+right)/(left-right), (top+bottom)/(bottom-top), -znear/(znear-zfar), 1
        ]);
    }

    static Matrix4 alternateHandedness(Matrix4 mat)
    {
        return Matrix4([
            1, 0, 0, 0,
            0, 1, 0, 1,
            0, 0,-1, 0,
            0, 0, 0, 1
        ]) * mat;
    }

    string toString()
    {
        string ret = "[";
        for(uint i = 0; i < 16; i++)
        {
            if(i != 0)
            {
                if(i%4 == 0)
                    ret~= "]\n[";
                else
                    ret~=", ";
            }            
            ret~= to!string(this[i]);
        }
        return ret~"]";
    }

    alias values this;
}