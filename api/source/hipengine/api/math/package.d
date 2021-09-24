module hipengine.api.math;
public import Random = hipengine.api.math.random;
public import hipengine.api.math.vector;


version(HipremeEngineDef)
{
    
}
else:
void initMath()
{
    version(Script)
    {
        Random.initRandom();
        initVector();
    }
}