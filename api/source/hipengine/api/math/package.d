/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

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