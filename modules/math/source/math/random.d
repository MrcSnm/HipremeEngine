/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module modules.math.temp.random;
import std.random;

class Random
{
    private static std.random.Random randomGenerator;
    static this()
    {
        randomGenerator = std.random.Random(std.random.unpredictableSeed());
    }
    static float rangef(float min, float max)
    {
        return std.random.uniform(cast(int)min, cast(int)max, randomGenerator);
    }
    static int range(int min, int max)
    {
        return cast(int)rangef(min, max);
    }
    static uint rangeu(uint min, uint max)
    {
        return cast(uint)rangef(min, max);
    }
    static ubyte rangeub(ubyte min, ubyte max)
    {
        return cast(ubyte)rangef(min, max);
    }
    
}