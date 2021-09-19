
module math.random;
static import std.random;
public static class Random
{
	private static std.random.Random randomGenerator;
	static this();
	static int range(int min, int max);
	static uint rangeu(uint min, uint max);
	static ubyte rangeub(ubyte min, ubyte max);
	static float rangef(float min, float max);
}
