module core.stdc.math;

import core.stdc.stddef;

enum PI = 3.1415;

extern(C) extern
{
    double fabs(double x);
    double atan2(double y, double x);
    double cos(double x);
    double acos(double x);
    double sin(double x);
    double pow(double x, double y);
    double sqrt(double x);
    double floor(double x);
    double ceil(double x);
    double tan(double x);
    double fmod(double x, double denom);


    float fabsf(float x);
    float atan2f(float y, float x);
    float cosf(float x);
    float acosf(float x);
    float sinf(float x);
    float powf(float x, float y);
    float sqrtf(float x);
    float floorf(float x);
    float ceilf(float x);
    float tanf(float x);
    float fmodf(float x, float denom);


}
