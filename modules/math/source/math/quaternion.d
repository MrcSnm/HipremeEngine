module math.quaternion;
import std.math;
import math.vector;
import math.matrix;

struct Quaternion
{
    union {
        struct {float x, y, z, w;}
        float[4] values;
    }

    ///https://en.wikipedia.org/wiki/Quaternions_and_spatial_rotation
    static rotation(float angle, in Vector3 axis)
    {
        float c = cos(angle/2);
        float s = sin(angle/2);
        Vector3 a = axis.unit;

        return Quaternion(s*a.x, s*a.y, s*a.z, c);
    }

    Quaternion opUnary(string op)() if(op == "-")
    {
        return Quaternion(-x, -y, -z, w);
    }

    Quaternion unit()
    {
        float magnitude = mag();
        if(magnitude == 0)
            return Quaternion(0,0,0,0);
        return Quaternion(x/magnitude, y/magnitude, z/magnitude, w/magnitude);
    }
    void normalize()
    {
        float magnitude = mag();
        if(magnitude == 0)
            values[] = 0;
        else
            values[]/= magnitude;
    }
    


    Quaternion opBinary(string op)(in Quaternion rhs) const
    {
        static if(op == "*")
        {
            Quaternion ret;
            ret.w = w * rhs.w - x * rhs.x - y * rhs.y - z * rhs.z;
            ret.x = w*rhs.x + x*rhs.w + y*rhs.z - z*rhs.y;
	        ret.y = w * rhs.y + y * rhs.w + z * rhs.x - x * rhs.z;
	        ret.z = w * rhs.z + z * rhs.w + x * rhs.y - y * rhs.x;
            return ret.unit;
        }
    }

    Matrix3 toMatrix3()
    {
        float rcos = cos(w);
        float rsin = sin(w);
        float dcos = 1 - rcos;
        Matrix3 matrix;
        matrix[0,0] =      rcos + x*x*dcos;
        matrix[1,0] =  z * rsin + y*x*dcos;
        matrix[2,0] = -y * rsin + z*x*dcos;
        matrix[0,1] = -z * rsin + x*y*dcos;
        matrix[1,1] =      rcos + y*y*dcos;
        matrix[2,1] =  x * rsin + z*y*dcos;
        matrix[0,2] =  y * rsin + x*z*dcos;
        matrix[1,2] = -x * rsin + y*z*dcos;
        matrix[2,2] =      rcos + z*z*dcos;
        return matrix;
    }

    Matrix4 toMatrix4()
    {
        float rcos = cos(w);
        float rsin = sin(w);
        float dcos = 1 - rcos;
        Matrix4 matrix;
        matrix[0,0] =      rcos + x*x*dcos;
        matrix[1,0] =  z * rsin + y*x*dcos;
        matrix[2,0] = -y * rsin + z*x*dcos;
        matrix[0,1] = -z * rsin + x*y*dcos;
        matrix[1,1] =      rcos + y*y*dcos;
        matrix[2,1] =  x * rsin + z*y*dcos;
        matrix[0,2] =  y * rsin + x*z*dcos;
        matrix[1,2] = -x * rsin + y*z*dcos;
        matrix[2,2] =      rcos + z*z*dcos;
        matrix[3,0] = 0;
        matrix[3,1] = 0;
        matrix[3,2] = 0;
        matrix[3,3] = 1;

        return matrix;
    }

    float mag(){return sqrt(x*x+y*y+z*z+w*w);}
    alias values this;
}