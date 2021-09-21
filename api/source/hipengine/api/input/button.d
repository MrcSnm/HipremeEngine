module hipengine.api.input.button;

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
    public abstract float getDowntimeDuration();
    public abstract float getLastDownTimeDuration();
    public abstract float getUpTimeDuration();
    public abstract float getLastUpTimeDuration();
    public abstract bool isPressed();
    ///Useful for looking justPressed and justRelease
    public abstract bool isNewState();
    public final bool isJustReleased(){return !isPressed && isNewState;}
    public final bool isJustPressed(){return isPressed && isNewState;}
}