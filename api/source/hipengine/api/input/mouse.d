/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hipengine.api.input.mouse;
public import hipengine.api.math.vector;

enum HipMouseButton : ubyte
{
    LEFT,
    MIDDLE,
    RIGHT
}

interface IHipMouse
{
    immutable(Vector2*) getPosition(uint id = 0);
    Vector2 getDeltaPosition(uint id = 0);
    bool isPressed(HipMouseButton btn = HipMouseButton.LEFT);
    bool isJustPressed(HipMouseButton btn = HipMouseButton.LEFT);
    bool isJustReleased(HipMouseButton btn = HipMouseButton.LEFT);
    Vector3 getScroll();
}