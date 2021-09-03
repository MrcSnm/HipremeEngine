module util.tween;
import std.math:cos, sin, PI, pow, sqrt;
import util.timer;

private enum c1 = 1.70158f;
private enum c2 = c1 * 1.525;
private enum c3 = c1+1;
private enum c4 = (2.0f * PI)/3.0f;
private enum c5 = (2 * PI) / 4.5f;
private enum n1 = 7.5625f;
private enum d1 = 2.75f;

/**
*   Credits to https://easings.net as I don't understand most of those functions
*/
enum HipEasing : float function(float x)
{
    identity        = (x) => x,
    easeInSine      = (x) => 1 - cos((x*PI)/2),
    easeOutSine     = (x) => sin((x*PI)/2),
    easeInOutSine   = (x) => -(cos(PI*x) - 1)/2,
    easeInQuad      = (x) => x*x,
    easeOutQuad     = (x) => 1 - (1-x) * (1-x),
    easeInOutQuad   = (x) => x < 0.5f ? 2 *x*x : 1 - pow(-2 * x + 2, 2)/2,
    easeInCubic     = (x) => x*x*x,
    easeOutCubic    = (x) => 1 - pow(1-x, 3),
    easeInOutCubic  = (x) => x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3)/2,
    easeInQuart     = (x) => x*x*x*x,
    easeOutQuart    = (x) => 1 - pow(1-x, 4),
    easeInOutQuart  = (x) => x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4)/2,
    easeInQuint     = (x) => x*x*x*x*x,
    easeOutQuint    = (x) => 1 - pow(1-x, 5),
    easeInOutQuint  = (x) => x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5)/2,
    easeInExpo      = (x) => x == 0 ? 0 : pow(2, 10 * x- 10),
    easeOutExpo     = (x) => x == 1 ? 1 : 1 - pow(2, -10 * x),
    easeInOutExpo   = (x) => x == 0 ? 0 
                             : x == 1 ? 1 
                             : x < 0.5 ? pow(2, 20 * x - 10)/2 
                             : (2 - pow(2, -20 * x + 10))/2,
    easeInCirc      = (x) => 1 - sqrt(1 - pow(x, 2)),
    easeOutCirc     = (x) => sqrt(1 - pow(x - 1, 2)),
    easeInOutCirc   = (x) => x < 0.5 ? (1 - sqrt(1 - pow(2 * x, 2)))/2
                             : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2,
    easeInBack      = (x) => c3 * x * x * x - c1 * x * x,
    easeOutBack     = (x) => 1 + c3 * pow(x - 1, 3) + c1 * pow(x-1, 2),
    easeInOutBack   = (x) => x < 0.5 ? (pow(2*x, 2) * ((c2+1) * 2 * x - c2))/2
                             : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2)/2,
    easeInElastic   = (x) => x == 0   ? 0
                             : x == 1 ? 1 
                             : -pow(2, 10 * x - 10) * sin((x * 10 - 10.75f) * c4),
    easeOutElastic  = (x) => x == 0   ? 0
                             : x == 1 ? 1
                             : pow(2, -10 * x) * sin((x * 10 - 0.75f) * c4) + 1,
    easeInOutElastic= (x) => x == 0 ? 0 : x == 1 ? 1 : x < 0.5 
                             ? -(pow(2, 20 * x - 10) * sin((20 * x - 11.125f) * c5))/2
                             : (pow(2, -20 * x + 10) * sin((20 * x - 11.125f) * c5))/2 + 1,
    easeInBounce    = (x) => 1 - HipEasing.easeOutBounce(1 - x),
    easeOutBounce   = (float x)
    {
        if(x < 1.0f / d1)
            return n1 * x * x;
        else if(x < 2.0f / d1)
            return n1 * (x-= 1.5f / d1) * x + 0.75;
        else if(x < 2.5f / d1)
            return n1 * (x-= 2.25f / d1) * x + 0.9375f;
        else
            return n1 * (x-= 2.625f / d1) * x + 0.984375f;
    },
    easeInOutBounce = (x) => x < 0.5 ? (1 - easeOutBounce(1 - 2 * x))/2
                             : (1+ easeOutBounce(2 * x - 1))/2
}


class HipTween : HipTimer
{
    import util.memory;
    HipEasing easing;
    void* savedData;
    uint savedDataSize;

    this(float durationSeconds, bool loops)
    {
        super("Tween", durationSeconds, HipTimer.TimerType.progressive, loops);
        this.easing = null;
    }
    void setEasing(HipEasing easing){this.easing = easing;}

    protected void allocSaveData(uint size)
    {
        if(savedData == null)
        {
            savedDataSize = size; 
            savedData = malloc(size);
        }
        else if(savedDataSize < size)
        {
            savedDataSize = size;
            savedData = realloc(savedData, size);
        }
    }

    static HipTween to(string[] Props, T, V)(float durationSeconds, T target, V[]  values...)
    {
        HipTween t = new HipTween(durationSeconds, false);
        t.allocSaveData(Props.length * V.sizeof);
        
        static foreach(i, p; Props)
            mixin("memcpy(t.savedData+",V.sizeof*i, ", &target.",p,", ", V.sizeof,");");
        V[] v2 = values.dup;


        t.addHandler((float prog, uint loops) 
        {
            float multiplier = prog;
            if(t.easing != null)
                multiplier = t.easing(multiplier);
            static foreach(i, p; Props)
                mixin("target.",p," = cast(V)((v2[",i,"] - *cast(V*)(t.savedData+",i*V.sizeof,"))*multiplier);");
            
        });
        return t;
    }
    static HipTween by(string[] Props, T, V)(float durationSeconds, T target, V[]  values...)
    {
        HipTween t = new HipTween(durationSeconds, false);
        t.allocSaveData(Props.length * V.sizeof);
        //Zero init for every variable
        memset(t.savedData, 0, t.savedDataSize);


        
        V[] v2 = values.dup;

        t.addHandler((float prog, uint loops) 
        {
            float multiplier = prog;
            if(t.easing != null)
                multiplier = t.easing(multiplier);
            V temp;
            V temp2;
            static foreach(i, p; Props)
            {
                temp = *((cast(V*)t.savedData)+i);
                temp2 = cast(V)(v2[i] * multiplier);

                mixin("target.",p,"+= -temp + temp2;");
                //Copy the new values for being subtracted next frame
                memcpy(t.savedData + i * V.sizeof, &temp2, V.sizeof);
            }
            
        });
        return t;
    }

    ~this()
    {
        safeFree(savedData);
    }

}