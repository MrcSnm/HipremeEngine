/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/

module hip.api.input.button;

enum HipButtonType : ubyte
{
    down = 0,
    up = 1
}

enum AutoRemove : bool
{
    no = false,
    yes = true
}
alias HipInputAction = void delegate(const(AHipButtonMetadata) meta);
alias HipTouchMoveAction = void delegate(int x, int y);
alias HipScrollAction = void delegate(float[3]);

/** 
 * Handler for any kind of button
 */
struct HipButton
{
    ushort id;
    HipButtonType type;
    AutoRemove isAutoRemove = AutoRemove.no;
    HipInputAction action;

    alias id this;
}

struct TouchMoveListener
{
    HipTouchMoveAction action;
    AutoRemove isAutoRemove = AutoRemove.no;
}

struct ScrollListener
{
    HipScrollAction action;
    AutoRemove isAutoRemove = AutoRemove.no;
}

abstract class AHipButtonMetadata
{
    int id;
    this(int id){this.id = id;}
    public abstract float getDownTimeDuration() const;
    public abstract float getLastDownTimeDuration() const;
    public abstract float getUpTimeDuration() const;
    public abstract float getLastUpTimeDuration() const;
    public abstract bool isPressed() const;
    ///Useful for looking justPressed and justRelease
    public abstract bool isNewState() const;
    ///User API is not expected to call that function. It is used for controlling the input flow
    public abstract void setPressed(bool press);
    public final bool isJustReleased() const {return !isPressed && isNewState;}
    public final bool isJustPressed()const {return isPressed && isNewState;}
}