module core.stdc.math;
import core.stdc.stddef;
static import std.math.constants;
enum float PI = std.math.constants.PI;
enum float PI_2 = std.math.constants.PI_2;
enum float PI_4 = std.math.constants.PI_4;

version(WebAssembly)
{
    @nogc nothrow @safe pure
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
            float atan2f(float y, float x) { return fastAtan2(y, x);}
            float cosf(float x){ return fastCos(x); }
            float acosf(float x) { return fastAcos(x); }
            float sinf(float x) { return fastSin(x); }
            float tanf(float x) { return fastTan(x); }

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


        immutable float[256] sineTable = [
            0f, 0.00615995f, 0.0123197f, 0.0184789f, 0.0246374f, 0.0307951f, 0.0369515f, 0.0431065f, 0.0492599f, 0.0554115f,
            0.0615609f, 0.067708f, 0.0738525f, 0.0799943f, 0.0861329f, 0.0922684f, 0.0984003f, 0.104528f, 0.110653f, 0.116773f,
            0.122888f, 0.128999f, 0.135105f, 0.141206f, 0.147302f, 0.153392f, 0.159476f, 0.165554f, 0.171626f, 0.177691f,
            0.18375f, 0.189801f, 0.195846f, 0.201882f, 0.207912f, 0.213933f, 0.219946f, 0.225951f, 0.231948f, 0.237935f,
            0.243914f, 0.249883f, 0.255843f, 0.261793f, 0.267733f, 0.273663f, 0.279583f, 0.285492f, 0.29139f, 0.297277f,
            0.303153f, 0.309017f, 0.31487f, 0.32071f, 0.326539f, 0.332355f, 0.338158f, 0.343949f, 0.349727f, 0.355491f,
            0.361242f, 0.366979f, 0.372702f, 0.378411f, 0.384106f, 0.389786f, 0.395451f, 0.401102f, 0.406737f, 0.412357f,
            0.417961f, 0.423549f, 0.429121f, 0.434677f, 0.440216f, 0.445739f, 0.451244f, 0.456733f, 0.462204f, 0.467658f,
            0.473094f, 0.478512f, 0.483912f, 0.489293f, 0.494656f, 0.5f, 0.505325f, 0.510631f, 0.515918f, 0.521185f,
            0.526432f, 0.53166f, 0.536867f, 0.542053f, 0.54722f, 0.552365f, 0.557489f, 0.562593f, 0.567675f, 0.572735f,
            0.577774f, 0.58279f, 0.587785f, 0.592757f, 0.597707f, 0.602634f, 0.607539f, 0.61242f, 0.617278f, 0.622113f,
            0.626924f, 0.631711f, 0.636474f, 0.641213f, 0.645928f, 0.650618f, 0.655283f, 0.659924f, 0.66454f, 0.66913f,
            0.673695f, 0.678235f, 0.682748f, 0.687236f, 0.691698f, 0.696133f, 0.700543f, 0.704925f, 0.709281f, 0.71361f,
            0.717911f, 0.722186f, 0.726433f, 0.730653f, 0.734844f, 0.739008f, 0.743144f, 0.747252f, 0.751331f, 0.755382f,
            0.759404f, 0.763398f, 0.767362f, 0.771297f, 0.775203f, 0.77908f, 0.782927f, 0.786744f, 0.790532f, 0.794289f,
            0.798016f, 0.801713f, 0.80538f, 0.809016f, 0.812622f, 0.816196f, 0.81974f, 0.823252f, 0.826733f, 0.830183f,
            0.833602f, 0.836988f, 0.840343f, 0.843666f, 0.846957f, 0.850216f, 0.853443f, 0.856637f, 0.859799f, 0.862928f,
            0.866025f, 0.869088f, 0.872119f, 0.875116f, 0.878081f, 0.881012f, 0.883909f, 0.886773f, 0.889603f, 0.8924f,
            0.895163f, 0.897892f, 0.900586f, 0.903247f, 0.905873f, 0.908465f, 0.911022f, 0.913545f, 0.916033f, 0.918487f,
            0.920905f, 0.923289f, 0.925637f, 0.927951f, 0.930229f, 0.932472f, 0.93468f, 0.936852f, 0.938988f, 0.941089f,
            0.943154f, 0.945184f, 0.947177f, 0.949135f, 0.951056f, 0.952942f, 0.954791f, 0.956604f, 0.958381f, 0.960122f,
            0.961826f, 0.963493f, 0.965124f, 0.966718f, 0.968276f, 0.969797f, 0.971281f, 0.972728f, 0.974139f, 0.975512f,
            0.976848f, 0.978148f, 0.97941f, 0.980635f, 0.981823f, 0.982973f, 0.984086f, 0.985162f, 0.986201f, 0.987202f,
            0.988166f, 0.989092f, 0.98998f, 0.990831f, 0.991645f, 0.992421f, 0.993159f, 0.993859f, 0.994522f, 0.995147f,
            0.995734f, 0.996284f, 0.996795f, 0.997269f, 0.997705f, 0.998103f, 0.998464f, 0.998786f, 0.999071f, 0.999317f,
            0.999526f, 0.999696f, 0.999829f, 0.999924f, 0.999981f, 1.0f
        ];

        float fastSin(float radians)
        {
            import std.math.constants;

            enum PI_3 = PI_2+PI;
            radians = radians - cast(int)(radians / (2 * PI)) * (2 * PI);

            float factor = sineTable.length / (PI / 2);
            int index = cast(int)(radians * factor) % sineTable.length;
            if (radians < PI_2) return sineTable[index];
            if (radians < PI) return sineTable[sineTable.length - index - 1];
            if (radians < PI_3) return -sineTable[index];
            return -sineTable[sineTable.length - index - 1];
        }
        float fastCos(float radians)
        {
            import std.math.constants;
            return fastSin(radians + PI_2);
        }
        float fastTan(float radians){return fastSin(radians) / fastCos(radians);}
        double fastAtan(float x)
        {
            // Efficient aproximation for arctan
            enum double B = 0.28125; // ~9/32

            bool neg = false;
            if (x < 0) {
                x = -x;
                neg = true;
            }

            double result;
            if (x < 1.0) {
                result = x / (1 + B * x * x);
            } else {
                result = PI / 2 - (1 / x) / (1 + B / (x * x));
            }

            return neg ? -result : result;
        }

        float fastAsin(float x)
        {
            enum tolerance=1e-6;
            ///Compute arcsin(x) using Taylor series expansion.
            if(x < -1 || x > 1)
                return float.nan;

            float result = x;
            float term = x;
            int n = 1;
            while(fabsf(term) > tolerance)
            {
                term *= (x * x) * (2 * n - 1) ^^ 2 / ((2 * n) * (2 * n + 1));
                result += term;
                n += 1;
            }

            return result;
        }
        float fastAcos(float x)
        {
            return PI_2 - fastAcos(x);
        }


        float fastAtan2(float y, float x) {
            if (x == 0)
                return (y > 0) ? PI / 2 : 3 * PI / 2; // 90|270

            float atanVal = fastAtan(y / x);

            if (x < 0)
                atanVal += (y >= 0) ? PI : -PI;

            if (atanVal < 0)
                atanVal += 2 * PI;

            return atanVal;
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
// extern(C) bool __unordtf2(real a, real b){assert(false);}
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