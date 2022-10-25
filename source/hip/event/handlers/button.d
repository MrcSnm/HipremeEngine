module hip.event.handlers.button;

public import hip.api.input.button;
import hip.util.time;

final class HipButtonMetadata : AHipButtonMetadata
{
    float lastDownTime, downTimeStamp;
    float lastUpTime, upTimeStamp;
    bool _isPressed = false;
    bool _isNewState = false;
    override bool isNewState() const {return _isNewState;}
    override bool isPressed() const {return _isPressed;}
    override float getLastDownTimeDuration() const {return lastDownTime;}
    override float getLastUpTimeDuration() const {return lastUpTime;}

    this(int key){super(key);}

    override float getDownTimeDuration() const
    {
        if(_isPressed)
            return (HipTime.getCurrentTimeAsMilliseconds() - downTimeStamp) / 1000;
        return 0;
    }
    override float getUpTimeDuration() const
    {
        if(!_isPressed)
            return (HipTime.getCurrentTimeAsMilliseconds() - upTimeStamp) / 1000;
        return 0;
    }
    override void setPressed(bool press)
    {
        _isNewState = false;
        if(press != _isPressed)
        {
            _isNewState = true;
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