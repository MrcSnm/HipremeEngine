module event.handlers.button;

public import hipengine.api.input.button;
import bindbc.sdl;
import util.time;

final class HipButtonMetadata : AHipButtonMetadata
{
    float lastDownTime, downTimeStamp;
    float lastUpTime, upTimeStamp;
    bool _isPressed = false;
    bool _isNewState = false;
    override bool isNewState(){return _isNewState;}
    override bool isPressed(){return _isPressed;}
    override float getLastDownTimeDuration(){return lastDownTime;}
    override float getLastUpTimeDuration(){return lastUpTime;}

    this(int key){super(key);}
    this(SDL_Keycode key){super(cast(int)key);}

    override float getDownTimeDuration()
    {
        if(_isPressed)
            return (HipTime.getCurrentTimeAsMilliseconds() - downTimeStamp) / 1000;
        return 0;
    }
    override float getUpTimeDuration()
    {
        if(!_isPressed)
            return (HipTime.getCurrentTimeAsMilliseconds() - upTimeStamp) / 1000;
        return 0;
    }
    void setPressed(bool press)
    {
        if(press && !_isPressed)
            _isNewState = true;
        if(press != _isPressed)
        {
            if(_isPressed)
            {
                lastDownTime = getDownTimeDuration();
                upTimeStamp = HipTime.getCurrentTimeAsMilliseconds();
            }
            else
            {
                lastUpTime = getUpTimeDuration();
                downTimeStamp = HipTime.getCurrentTimeAsMilliseconds();
            }
            _isPressed = press;
        }
    }
}