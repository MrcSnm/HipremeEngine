/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hipengine.api.math.random;

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
		loadSymbols!
		(
			range,
			rangeu,
			rangeub,
			rangef
		);
	}
}
