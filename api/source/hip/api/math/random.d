/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.math.random;

private alias thisModule = __traits(parent, {});

package void initRandom()
{
	version(Script)
	{
		import hip.api.internal;
		loadModuleFunctionPointers!thisModule;
	}
}


version(HipMathAPI):
version(Have_hipreme_engine)
{
	public import hip.math.random;
}
else:

version(Script)
{
	private extern(System)
	{
		int function(int min, int max) Random_range;
		uint function(uint min, uint max) Random_rangeu;
		ubyte function(ubyte min, ubyte max) Random_rangeub;
		float function(float min, float max) Random_rangef;
	}
	extern(D)
	{
		struct Random
		{
			@disable this();
			static int range(int min, int max){return Random_range(min,max);}
			static uint rangeu(uint min, uint max){return Random_rangeu(min, max);}
			static ubyte rangeub(ubyte min, ubyte max){return Random_rangeub(min, max);}
			static float rangef(float min, float max){return Random_rangef(min, max);}
		}
	}
}