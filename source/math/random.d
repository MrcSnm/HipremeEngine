module math.random;
static import std.random;

public static class Random
{
    private static std.random.Random randomGenerator;
    static this()
    {
        randomGenerator = std.random.Random(std.random.unpredictableSeed());
    }
    static int range(int min, int max)
    {
        return std.random.uniform(min, max, randomGenerator);
    }
    static uint rangeu(uint min, uint max)
    {
        return std.random.uniform(min, max, randomGenerator);
    }
    static ubyte rangeub(ubyte min, ubyte max)
    {
        return std.random.uniform(min, max, randomGenerator);
    }
    static float rangef(float min, float max)
    {
        return std.random.uniform(min, max, randomGenerator);
    }
}