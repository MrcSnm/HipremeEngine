module core.stdc.math;

import core.stdc.stddef;

enum PI = 3.1415;

version(WebAssembly)
{
    extern(C)
    {
        //Double
        double sqrt(double x){return cast(double)sqrtf(cast(float)x);}
        double atan2(double y, double x){return cast(double)atan2f(cast(float)y, cast(float)x);}
        double cos(double x){return cast(double)cosf(cast(float)x);}
        double acos(double x){return cast(double)acosf(cast(float)x);}
        double sin(double x){return cast(double)sinf(cast(float)x);}
        double tan(double x){return cast(double)tanf(cast(float)x);}



        double fabs(double x){ return x > 0 ? x : -x;}
        double pow(double x, double y)
        {
            if(y == 0) return 1;
            double ret = x;
            if(y > 0) foreach(i; 1..y)
                ret*=x;
            else if(x == 0)
                return double.infinity;
            else foreach(i; y..1)
                ret/= x;
            return ret;
        }
        double floor(double x){return cast(double)(cast(long)x);}
        double ceil(double x){return cast(double)(cast(long)(x+0.999999999));}

        //Float
        float sqrtf(float x);
        float atan2f(float y, float x);
        float cosf(float x);
        float acosf(float x);
        float sinf(float x);
        float tanf(float x);

        float fabsf(float x){return x > 0 ? x : -x;}
        float powf(float x, float y)
        {
            if(y == 0) return 1;
            float ret = x;
            foreach(i; 1..y)
                ret*=x;
            return ret;
        }
        float floorf(float x){return cast(float)(cast(int)x);}
        float ceilf(float x){return cast(float)(cast(int)(x+0.999999999));}
        float fmodf(float x, float denom)
        { 
            float div = x / denom;
            div = div - cast(int)div;
            return cast(float)(cast(int)div*denom);
        }
    }
}
else
{
    extern(C) extern
    {
        double sqrt(double x);
        double atan2(double y, double x);
        double cos(double x);
        double acos(double x);
        double sin(double x);
        double tan(double x);
        double fabs(double x);
        double pow(double x, double y);
        double floor(double x);
        double ceil(double x);
        double fmod(double x, double denom);


        float sqrtf(float x);
        float atan2f(float y, float x);
        float cosf(float x);
        float acosf(float x);
        float sinf(float x);
        float tanf(float x);
        float fabsf(float x);
        float powf(float x, float y);
        float floorf(float x);
        float ceilf(float x);
        float fmodf(float x, float denom);
    }
}

