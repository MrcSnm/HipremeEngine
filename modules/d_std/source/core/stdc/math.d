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



        double fabs(double x){ return (x != x) ? x :  (x > 0 ? x : -x);}
        double pow(double x, double y)
        {
            long n = cast(long)y;
            if(n == 0) return 1;
            double ret = x;

            if(n > 0) foreach(i; 1..n)
                ret*=x;
            else if(x == 0)
                return double.infinity;
            else foreach(i; y..1)
                ret/= x;
            return ret;
        }
        float powf(float x, float y){return cast(float)core.stdc.math.pow(cast(double)x, cast(double)y);}

        double floor(double x){return cast(long)(x-0.99999999);}
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

        float fabsf(float x){return (x != x) ? x :  (x > 0 ? x : -x);}
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
        float cbrtf(float x);


        float sqrtf(float x);
        float atan2f(float y, float x);
        float cosf(float x);
        float acosf(float x);
        float sinf(float x);
        float tanf(float x);
        float fabsf(float x);
        float powf(float x, float y);
        real powl(real x, real y);
        float floorf(float x);
        float ceilf(float x);
        float fmodf(float x, float denom);


        double exp(double x);
        float expf(float x);

        double log(double x);
        float logf(float x);
        pure double  round(double x);
        pure float   roundf(float x);

        float ldexpf(float n, int exp);   /* intrinsic */
        double ldexp(double n, int exp); /* intrinsic */ /// ditto
        real ldexpl(real n, int exp);     /* intrinsic */ /// ditto
    }
}

extern(C) @nogc nothrow @trusted pure:

enum int FP_ILOGB0        = int.min;
///
enum int FP_ILOGBNAN      = int.min;
// extern(D) real fmodl()(real x, real y) { return fmod(cast(double) x, cast(double) y); }

// float remainderf( float x, float y ){assert(0);}
// double remainder( double x, double y ){assert(0);}
// real remainderl( real x, real y ){assert(0);}
// double  remquo(double x, double y, int* quo){assert(0);}
// float   remquof(float x, float y, int* quo){assert(0);}
// extern(D) real remquol()(real x, real y, int* quo) { return remquo(cast(double) x, cast(double) y, quo); }
// extern(D) pure real cbrtl()(real x)   { return cbrt(cast(double) x); }
// extern(D) pure real modfl()(real value, real* iptr)
// {
//     double i;
//     double r = modf(cast(double) value, &i);
//     *iptr = i;
//     return r;
// }

// pure double  modf(double value, double* iptr){assert(0);}
// pure float   modff(float value, float* iptr){assert(0);}
// extern(C) pure double  nearbyint(double x){assert(0);}
// // pure float   nearbyintf(float x){assert(0);}
// // extern(D) pure real nearbyintl()(real x) { return nearbyint(cast(double) x); }

// pure float   roundf(float x)
// {
//     return ((x - cast(int)x) >= 0.5) ? cast(int)x+1 : cast(int)x;
// }
// pure double  round(double x){ return cast(double)roundf(x);}
// extern(D) pure real roundl()(real x)  { return round(cast(double) x); }

// long llround(double x)
// {
//     return ((x - cast(long)x) >= 0.5) ? cast(long)x+1 : cast(long)x;
// }
//     ///
// long llroundf(float x){return llroundf(cast(double)x);}
// ///
// extern(C) long llroundl(double x) { return llround(cast(double) x); }
// extern(D) long llroundl()(real x) { return llround(cast(double) x); }


// pure double  trunc(double x) {return cast(double)(cast(long)x);}
// ///
// pure float   truncf(float x) {return cast(float)(cast(int)x);}
// ///
// extern(D) pure real truncl()(real x)  { return trunc(cast(double) x); }




// ///////////////////////////////////////Comparisons///////////////////////////////////////

// ///real1 > real2
// extern(C) bool __gttf2(real a  , real b){assert(false);}
// ///real1 < real2
// extern(C) bool __lttf2(real a, real b){assert(false);}
// ///real <= real2
// extern(C) bool __letf2(real a, real b){assert(false);}
// ///real != real
// extern(C) real __netf2(real a, real b){assert(false);}
// /// real == real
// extern(C) real __eqtf2(real a, real b){assert(false);}
// ///isNaN(real)
// extern(C) bool __unordtf2(real a){assert(false);}
// ///comp float a and b
// extern(C) bool __getf2(float a, float b){assert(false);}


// ///////////////////////////////////////Basic Operations///////////////////////////////////////

// ///real + real
// extern(C) real __addtf3(real a, real b){assert(false);}
// ///real - real
// extern(C) real __subtf3(real a, real b){assert(false);}
// ///real / real
// extern(C) real __divtf3(real a, real b){assert(false);}
// ///real * real
// extern(C) real __multf3(real a, real b){assert(false);}




// ///////////////////////////////////////Special Operations///////////////////////////////////////

// /// round(real)
// extern(C) real rintl(real a){assert(false);}
// ///cos(real)
// extern(C) real cosl(real a){assert(false);}
// ///sqrt(real)
// extern(C) real sqrtl(real a){assert(false);}
// ///sin(real)
// extern(C) real sinl(real a){assert(false);}

// ///////////////////////////////////////Castings///////////////////////////////////////

// // ///cast(double)realValue
// extern(C) double __trunctfdf2(real x){assert(false);}
// ///cast(float)real
// extern(C) float __trunctfsf2(real a){assert(false);}
// ///cast(real)uint
// extern(C) real __floatunsitf (uint a){assert(false);}
// ///cast(real)long
// extern(C) real __floatditf(long a){assert(false);}
// ///cast(real)ulong
// extern(C) real __floatunditf(long a){assert(false);}
// ///cast(real) double
// extern(C) real __extenddftf2(double a){assert(false);}
// ///cast(real) float
// extern(C) real __extendsftf2(float a){assert(false);}
// ///cast(real)long
// extern(C) real __fixtfdi(long a){assert(false);}
// ///cast(real)int
// extern(C) real __floatsitf(int a){assert(false);}
// ///Don't know
// extern(C) int __fixtfsi(float a){assert(false);}