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
    left,
    middle,
    right,
    button1,
    button2,
    invalid
}
interface IHipMouse
{
    Vector2 getPosition(uint id = 0);
    Vector2 getDeltaPosition(uint id = 0);
    bool isPressed(HipMouseButton btn = HipMouseButton.left);
    bool isJustPressed(HipMouseButton btn = HipMouseButton.left);
    bool isJustReleased(HipMouseButton btn = HipMouseButton.left);
    Vector3 getScroll();
}