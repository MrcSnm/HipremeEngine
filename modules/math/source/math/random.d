/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
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