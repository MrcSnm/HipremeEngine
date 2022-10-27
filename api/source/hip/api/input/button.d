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

version(HipInputAPI)
    version = HasHipInput;
else version(Have_hipreme_engine)
    version = HasHipInput;

version(HasHipInput):

enum HipButtonType : ushort
{
    down,
    up
}

import std.typecons:Flag;

alias AutoRemove = Flag!"AutoRemove";
alias HipInputAction = void delegate(const(AHipButtonMetadata) meta);

/** 
 * Handler for any kind of button
 */
struct HipButton
{
    ushort id;
    HipButtonType type;
    HipInputAction action;
    AutoRemove isAutoRemove;

    alias id this;
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