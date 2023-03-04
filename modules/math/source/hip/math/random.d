/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.math.random;
import core.stdc.stdlib;

version(WebAssembly) extern(C) float JS_Math_random() @nogc nothrow;
version(PSVita) extern(C) int psv_rand() @nogc nothrow;

class Random
{
    @disable this();
    
    // version(Android)
    // {
    //     import std.random;
    //     private __gshared std.random.Random randomGenerator;
    // }
    static void initialize()
    {
        version(WebAssembly){} else
        {
            import core.stdc.time;
            srand(cast(uint)time(null));
        }
        // version(Android)
        // {
        //     import std.random;
        //     randomGenerator = std.random.Random(std.random.unpredictableSeed());
        // }
    }

    @nogc nothrow
    {
        static float rangef(float min, float max)
        {
            version(WebAssembly){return JS_Math_random() * max + min;}
            else version(PSVita){return (cast(float)psv_rand() / RAND_MAX) * max + min;}
            //else version(Android){return std.random.uniform(cast(int)min, cast(int)max, randomGenerator);}
            else
                return (cast(float)rand() / RAND_MAX) * max + min;
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

    /**
    *   This function gets a container and returns a random value from it.
    *   It may not receive any weight, so, it will be normally distributed (I expect)
    *   If it receives less weights than it has values, the last value will contain a weight equals
    *   to 1 - sum(weights)
    *   The weights must sum up to 1.0
    */
    static T randomSelect(T)(in T[] container, float[] weights = []) @nogc nothrow
    {
        if(weights.length == 0)
        {
            int min = 0;
            int max = cast(int)(container.length) - 1;
            int index = range(min, max);

            return container[index];
        }

        float currentSum = 0;
        float selectedValue = rangef(0.0, 1.0);
        
        for(int i = 0; i < weights.length; i++)
        {
            if(selectedValue >= currentSum && selectedValue <= currentSum+weights[i])
                return container[i];
            currentSum+= weights[i];
        }
        return container[$-1];
    }
    
}
