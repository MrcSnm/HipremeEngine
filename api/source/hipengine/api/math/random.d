module hipengine.api.math.random;

/*
Copyright: Marcelo S. N. Mancini, 2018 - 2021
License:   [https://opensource.org/licenses/MIT|MIT License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the MIT Software License.
   (See accompanying file LICENSE.txt or copy at
	https://opensource.org/licenses/MIT)
*/


version(Have_hipreme_engine)
{
	public import math.random;
}
else:

version(Script)
{
	extern(C) int function(int min, int max) range;
	extern(C) uint function(uint min, uint max) rangeu;
	extern(C) ubyte function(ubyte min, ubyte max) rangeub;
	extern(C) float function(float min, float max) rangef;
}

package void initRandom()
{
	version(Script)
	{
		import hipengine.internal;
		loadSymbol!range;
		loadSymbol!rangeu;
		loadSymbol!rangeub;
		loadSymbol!rangef;
	}
}
