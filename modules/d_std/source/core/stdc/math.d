module core.stdc.math;
import core.stdc.stddef;


enum PI = 3.1415;

version(WebAssembly)
{
    extern(C) @nogc nothrow @safe pure
    {
        //Double
        double sqrt(double x){return cast(double)sqrtf(cast(float)x);}
        double atan2(double y, double x){return cast(double)atan2f(cast(float)y, cast(float)x);}
        double cos(double x){return cast(double)cosf(cast(float)x);}
        double acos(double x){return cast(double)acosf(cast(float)x);}
        double sin(double x){return cast(double)sinf(cast(float)x);}
        double tan(double x){return cast(double)tanf(cast(float)x);}
        double cbrt(double x);



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
        double fmod(double f, double w) 
        {
            auto i = cast(int) f;
            return i % cast(int) w;
        }


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
    extern(C) extern @nogc @safe nothrow pure
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
        double cbrt(double x);


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

extern(C) @nogc nothrow @trusted pure:

enum int FP_ILOGB0        = int.min;
///
enum int FP_ILOGBNAN      = int.min;
extern(D) real fmodl()(real x, real y) { return fmod(cast(double) x, cast(double) y); }

float remainderf( float x, float y ){assert(0);}
double remainder( double x, double y ){assert(0);}
real remainderl( real x, real y ){assert(0);}
double  remquo(double x, double y, int* quo){assert(0);}
float   remquof(float x, float y, int* quo){assert(0);}
extern(D) real remquol()(real x, real y, int* quo) { return remquo(cast(double) x, cast(double) y, quo); }
extern(D) pure real cbrtl()(real x)   { return cbrt(cast(double) x); }
extern(D) pure real modfl()(real value, real* iptr)
{
    double i;
    double r = modf(cast(double) value, &i);
    *iptr = i;
    return r;
}

pure double  modf(double value, double* iptr){assert(0);}
pure float   modff(float value, float* iptr){assert(0);}
pure double  nearbyint(double x){assert(0);}
pure float   nearbyintf(float x){assert(0);}
extern(D) pure real nearbyintl()(real x) { return nearbyint(cast(double) x); }

pure float   roundf(float x)
{ 
    return ((x - cast(int)x) >= 0.5) ? cast(int)x+1 : cast(int)x;
}
pure double  round(double x){ return cast(double)roundf(x);}
extern(D) pure real roundl()(real x)  { return round(cast(double) x); }

long llround(double x)
{
    return ((x - cast(long)x) >= 0.5) ? cast(long)x+1 : cast(long)x;
}
    ///
long llroundf(float x){return llroundf(cast(double)x);}
///
extern(C) long llroundl(double x) { return llround(cast(double) x); }
extern(D) long llroundl()(real x) { return llround(cast(double) x); }


pure double  trunc(double x) {return cast(double)(cast(long)x);}
///
pure float   truncf(float x) {return cast(float)(cast(int)x);}
///
extern(D) pure real truncl()(real x)  { return trunc(cast(double) x); }