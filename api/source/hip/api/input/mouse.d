/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.input.mouse;

version(HipInputAPI)
    version = HasHipInput;
else version(Have_hipreme_engine)
    version = HasHipInput;

version(HasHipInput):

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
    int[2] getPosition(uint id = 0);
    int[2] getDeltaPosition(uint id = 0);
    bool isPressed(HipMouseButton btn = HipMouseButton.left);
    bool isJustPressed(HipMouseButton btn = HipMouseButton.left);
    bool isJustReleased(HipMouseButton btn = HipMouseButton.left);
    float[3] getScroll();
}