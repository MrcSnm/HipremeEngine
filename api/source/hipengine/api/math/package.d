module hipengine.api.math;

version(Have_hipreme_engine)
    public import hipengine.api.math.random;
else
    public import Random = hipengine.api.math.random;
public import hipengine.api.math.vector;


void initMath()
{
    version(Script)
    {
        Random.initRandom();
        initVector();
    }
}