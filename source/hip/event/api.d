module hip.event.api;
public import hip.global.gamedef;
public import hip.event.handlers.inputmap;
import hip.event.dispatcher;
import hip.systems.game;
import hip.math.vector;


export extern(System)
{
    bool isKeyPressed(char key, uint id = 0) 
    {
        return sys.dispatcher.isKeyPressed(key, id);
    }
    bool isKeyJustPressed(char key, uint id = 0) 
    {
        return sys.dispatcher.isKeyJustPressed(key, id);
    }
    bool isKeyJustReleased(char key, uint id = 0) 
    {
        return sys.dispatcher.isKeyJustReleased(key, id);
    }
    float getKeyDownTime(char key, uint id = 0) 
    {
        return sys.dispatcher.getKeyDownTime(key, id);
    }
    float getKeyUpTime(char key, uint id = 0) 
    {
        return sys.dispatcher.getKeyUpTime(key, id);
    }
    bool isMouseButtonPressed(HipMouseButton btn = HipMouseButton.left, uint id = 0) 
    {
        return sys.dispatcher.isMouseButtonPressed(btn, id);
    }
    bool isMouseButtonJustPressed(HipMouseButton btn = HipMouseButton.left, uint id = 0) 
    {
        return sys.dispatcher.isMouseButtonJustPressed(btn, id);
    }
    bool isMouseButtonJustReleased(HipMouseButton btn = HipMouseButton.left, uint id = 0) 
    {
        return sys.dispatcher.isMouseButtonJustReleased(btn, id);
    }
    Vector2 getTouchPosition(uint id=0) 
    {
        return sys.dispatcher.getTouchPosition(id);
    }
    Vector2 getTouchDeltaPosition(uint id=0) 
    {
        return sys.dispatcher.getTouchDeltaPosition(id);
    }
    Vector3 getScroll() 
    {
        return sys.dispatcher.getScroll();
    }
    ubyte getGamepadCount()
    {
        return sys.dispatcher.getGamepadCount();
    }
    AHipGamepad getGamepad(ubyte id)
    {
        return sys.dispatcher.getGamepad(id);
    }
    bool setGamepadVibrating(float vibrationPower, float time, ubyte id = 0)
    {
        return sys.dispatcher.setGamepadVibrating(vibrationPower, time, id);
    }
    Vector3 getAnalog(HipGamepadAnalogs analog, ubyte id = 0)
    {
        return sys.dispatcher.getAnalog(analog);
    }
    bool isGamepadButtonPressed(HipGamepadButton btn, ubyte id = 0)
    {
        return sys.dispatcher.isGamepadButtonPressed(btn, id);
    }
    bool isGamepadButtonJustPressed(HipGamepadButton btn, ubyte id = 0)
    {
        return sys.dispatcher.isGamepadButtonJustPressed(btn, id);
    }
    bool isGamepadButtonJustReleased(HipGamepadButton btn, ubyte id = 0)
    {
        return sys.dispatcher.isGamepadButtonJustReleased(btn, id);
    }
    float getGamepadBatteryStatus(ubyte id = 0)
    {
        return sys.dispatcher.getGamepadBatteryStatus(id);
    }
    bool isGamepadWireless(ubyte id = 0)
    {
        return sys.dispatcher.isGamepadWireless(id);
    }
}