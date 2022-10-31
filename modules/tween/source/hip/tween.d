module hip.tween;

version(HipTweenAPI):
import std.math:cos, sin, PI, pow, sqrt;
public import hip.timer;

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
    easeOutBounce   = function float(float x)
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


class HipTween : HipTimer, IHipFiniteTask
{
    HipEasing easing = null;
    protected void[] savedData = null;

    protected void delegate() onPlay;
    protected void delegate()[] onFinish;

    this(float durationSeconds, bool loops)
    {
        super("Tween", durationSeconds, HipTimerType.progressive, loops);
        this.easing = null;
    }
    HipTween setEasing(HipEasing easing){this.easing = easing; return this;}
    void setProperties(string name, float durationSeconds, bool loops = false)
    {
        super.setProperties(name, durationSeconds, HipTimerType.progressive, loops);
    }
    override HipTween play()
    {
        super.play();
        if(onPlay != null)
            onPlay();
        return this;
    }
    override void stop()
    {
        super.stop();
        foreach(finish; onFinish)
            finish();
    }

    protected void allocSaveData(size_t size)
    {
        if(savedData !is null)
            destroy(savedData);
        savedData = new void[](size);
    }

    /**
    *   This version is more lightweight compiler wise as it is not templated 
    */
    static HipTween to(float durationSeconds, float*[] valuesRef, float[] targetValues)
    {
        HipTween t = new HipTween(durationSeconds, false);
        float[] v2 = targetValues.dup;
        t.allocSaveData(valuesRef.length * float.sizeof);

        t.onPlay = ()
        {
            float[] savedDataConv = cast(float[])t.savedData;
            foreach(i, v; valuesRef)
                savedDataConv[i] = *v;
            
            t.addHandler((float prog, uint loops) 
            {
                float multiplier = prog;
                if(t.easing != null)
                    multiplier = t.easing(multiplier);
                float initialValue;
                float newValue;

                foreach(i, value; valuesRef)
                {
                    initialValue = savedDataConv[i];
                    newValue = ((1-multiplier)*initialValue + (v2[i] * multiplier));
                    *value = newValue;
                }
            });
        };
        return t;
    }

    static HipTween to(string[] Props, T, V)(float durationSeconds, T target, V[]  values...)
    {
        HipTween t = new HipTween(durationSeconds, false);
        t.allocSaveData(Props.length * V.sizeof);

        V[] v2 = values.dup;
        t.onPlay = ()
        {
            V[] savedDataConv = cast(V[])t.savedData;
            static foreach(i, p; Props)
            {
                savedDataConv[i] = cast(V)__traits(getMember, target, p);
            }
                        
            
            t.addHandler((float prog, uint loops) 
            {
                float multiplier = prog;
                if(t.easing != null)
                    multiplier = t.easing(multiplier);
                V initialValue;
                V newValue;
                static foreach(i, p; Props)
                {
                    initialValue = savedDataConv[i];
                    newValue = cast(V)((1-multiplier)*initialValue + (v2[i] * multiplier));
                    __traits(getMember, target, p) = newValue;
                }
            });
        };
        return t;
    }

    static HipTween by(string[] Props, T, V)(float durationSeconds, float*[] valuesRef, float[] targetValues)
    {
        HipTween t = new HipTween(durationSeconds, false);
        t.allocSaveData(float.sizeof * valuesRef.length);
        float[] v2 = targetValues.dup;

        t.onPlay = ()
        {
            t.addHandler((float prog, uint loops) 
            {
                float[] savedDataConv = cast(float[])t.savedData;
                float multiplier = prog;
                if(t.easing != null)
                    multiplier = t.easing(multiplier);
                float temp;
                float temp2;
                foreach(i, valueRef; valuesRef)
                {
                    temp = savedDataConv[i];
                    temp2 = (v2[i] * multiplier);
                    *valueRef+= -temp + temp2;
                    //Copy the new values for being subtracted next frame
                    savedDataConv[i] = temp2;

                }
            });
        };

        return t;
    }

    static HipTween by(string[] Props, T, V)(float durationSeconds, T target, V[]  values...)
    {
        HipTween t = new HipTween(durationSeconds, false);
        t.allocSaveData(Props.length * V.sizeof);
        V[] v2 = values.dup;

        t.onPlay = ()
        {
            t.addHandler((float prog, uint loops) 
            {
                V[] savedDataConv = cast(V[])t.savedData;
                float multiplier = prog;
                if(t.easing != null)
                    multiplier = t.easing(multiplier);
                V temp;
                V temp2;
                static foreach(i, p; Props)
                {
                    temp = savedDataConv[i];
                    temp2 = cast(V)(v2[i] * multiplier);

                    __traits(getMember, target, p)+= -temp + temp2;
                    //Copy the new values for being subtracted next frame
                    savedDataConv[i] = temp2;
                }
            });
        };

        return t;
    }

    HipTween addOnFinish(void delegate() onFinish)
    {
        this.onFinish~= onFinish;
        return this;
    }
    ~this(){destroy(savedData);}

}