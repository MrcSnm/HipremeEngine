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

/** 
 * Handler for any kind of button
 */
class HipButton
{
    AHipButtonMetadata meta;
    abstract void onDown();
    abstract void onUp();
}

abstract class AHipButtonMetadata
{
    int id;
    this(int id){this.id = id;}
    public abstract float getDownTimeDuration();
    public abstract float getLastDownTimeDuration();
    public abstract float getUpTimeDuration();
    public abstract float getLastUpTimeDuration();
    public abstract bool isPressed();
    ///Useful for looking justPressed and justRelease
    public abstract bool isNewState();
    ///User API is not expected to call that function. It is used for controlling the input flow
    public abstract void setPressed(bool press);
    public final bool isJustReleased(){return !isPressed && isNewState;}
    public final bool isJustPressed(){return isPressed && isNewState;}
}