module hip.event.handlers.button;

public import hip.api.input.button;
import hip.util.time;


final class HipButtonMetadata : AHipButtonMetadata
{
    import hip.config.opts;

    float lastDownTime, downTimeStamp;
    float lastUpTime, upTimeStamp;
    float timeStartedCheckingRestart = 0;
    float timeUntilRestartMulticlick = HIP_DEFAULT_TIME_UNTIL_CLICK_COUNT_RESTART;
    bool _isPressed = false;
    bool _isNewState = false;
    ubyte clickCount = 0;

    override bool isNewState() const {return _isNewState;}
    override bool isPressed() const {return _isPressed;}
    override float getLastDownTimeDuration() const {return lastDownTime;}
    override float getLastUpTimeDuration() const {return lastUpTime;}

    this(int key){super(key);}

    override float getDownTimeDuration() const
    {
        if(_isPressed)
            return (HipTime.getCurrentTimeAsMs() - downTimeStamp) / 1000;
        return 0;
    }
    override float getUpTimeDuration() const
    {
        if(!_isPressed)
            return (HipTime.getCurrentTimeAsMs() - upTimeStamp) / 1000;
        return 0;
    }
    override void setPressed(bool press)
    {
        _isNewState = false;
        float currTime = HipTime.getCurrentTimeAsMs();
        if(currTime - timeStartedCheckingRestart > timeUntilRestartMulticlick)
        {
            clickCount = 0;
            timeStartedCheckingRestart = currTime;
        }
        if(press != _isPressed)
        {
            _isNewState = true;
            if(_isPressed)
            {
                lastDownTime = getDownTimeDuration();
                upTimeStamp = currTime;
                clickCount++;
            }
            else
            {
                lastUpTime = getUpTimeDuration();
                downTimeStamp = currTime;
            }
            _isPressed = press;
        }
    }
}