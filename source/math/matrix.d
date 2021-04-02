module math.matrix;
import core.math;

struct Matrix3
{

    float[9] values;
    pragma(inline, true)
    static Matrix3 translation(float x, float y)
    {
        return Matrix3([
            1, 0, 0,
            0, 1, 0,
            x, y, 1
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
        import std.conv:to;
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

    alias values this;
}

struct Matrix4
{
    float[16] values;
}