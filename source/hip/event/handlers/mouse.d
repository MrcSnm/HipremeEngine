module hip.event.handlers.mouse;
public import hip.api.input.mouse;
import hip.math.vector;
import hip.event.handlers.button;
import hip.error.handler;
import hip.util.data_structures;
import hip.util.reflection;

class HipMouse
{
    Vector2[] positions;
    Vector2[] lastPositions;
    Vector3 scroll;
    HipButtonMetadata[enumLength!HipMouseButton] metadatas;

    this()
    {
        positions = new Vector2[](1); //Start it with at least 1
        lastPositions = new Vector2[](1); //Start it with at least 1
        positions[0] = Vector2(0,0);
        lastPositions[0] = Vector2(0,0);
        foreach(i; 0..enumLength!HipMouseButton)
            metadatas[i] = new HipButtonMetadata(cast(int)i);
    }

    void setPressed(HipMouseButton btn, bool pressed)
    {
        metadatas[cast(int)btn].setPressed(pressed);
    }

    bool isPressed(HipMouseButton btn = HipMouseButton.any)
    {
        if(btn == HipMouseButton.any)
        {
            foreach(b; __traits(allMembers, HipMouseButton))
            {
                HipMouseButton mem = __traits(getMember, HipMouseButton, b);
                if(mem >= HipMouseButton.any)
                    return false;
                if(metadatas[mem].isPressed)
                    return true;
            }
            return false;
        }
        return metadatas[btn].isPressed;
    }

    bool isJustPressed(HipMouseButton btn)
    {
        if(btn == HipMouseButton.any)
        {
            foreach(b; __traits(allMembers, HipMouseButton))
            {
                HipMouseButton mem = __traits(getMember, HipMouseButton, b);
                if(mem >= HipMouseButton.any)
                    return false;
                if(metadatas[mem].isJustPressed)
                    return true;
            }
            return false;
        }
        return metadatas[btn].isJustPressed;
    }
    bool isJustReleased(HipMouseButton btn)
    {
        if(btn == HipMouseButton.any)
        {
            foreach(b; __traits(allMembers, HipMouseButton))
            {
                HipMouseButton mem = __traits(getMember, HipMouseButton, b);
                if(mem >= HipMouseButton.any)
                    return false;
                if(metadatas[mem].isJustReleased)
                    return true;
            }
            return false;
        }
        return metadatas[btn].isJustReleased;
    }
    void setPosition(float x, float y, uint id = 0)
    {
        if(id+1 > positions.length)
            positions.length = id+1;
        if(id+1 > lastPositions.length)
        {
            lastPositions.length = id+1;
        }
        lastPositions[id] = positions[id];
        ErrorHandler.assertExit(id < positions.length, "Touch ID out of range");
        positions[id].x=x;
        positions[id].y=y;
    }

    HipButtonMetadata getMetadata(HipMouseButton btn = HipMouseButton.any)
    {
        if(btn == HipMouseButton.any)
            btn = HipMouseButton.left;
        return metadatas[btn];
    }
    void setScroll(float x, float y, float z)
    {
        scroll.x=x;
        scroll.y=y;
        scroll.z=z;
    }
    

    ///Use the ID for getting the touch, may return null
    Vector2 getPosition(uint id = 0)
    {
        if(id > positions.length) return Vector2.zero;
        return positions[id];
    }
    Vector2 getDeltaPosition(uint id = 0)
    {
        if(id > positions.length) return Vector2.zero;

        return positions[id] - lastPositions[id];
    }
    Vector3 getScroll(){return scroll;}
    ubyte getMulticlickCount(HipMouseButton btn = HipMouseButton.left)
    {
        import hip.error.handler;
        if(btn == HipMouseButton.any)
            ErrorHandler.showWarningMessage("getMulticlickCount", "Can't get multiclick count for any button.");
        return metadatas[btn].clickCount;
    }

    bool isDoubleClicked(HipMouseButton btn = HipMouseButton.left)
    {
        if(btn == HipMouseButton.any)
        {
            foreach(b; __traits(allMembers, HipMouseButton))
            {
                HipMouseButton mem = __traits(getMember, HipMouseButton, b);
                if(mem >= HipMouseButton.any)
                    return false;
                if(metadatas[mem].clickCount == 2 && metadatas[mem]._isNewState)
                    return true;
            }
            return false;
        }
        return metadatas[btn].clickCount == 2 && metadatas[btn]._isNewState;
    }

    void postUpdate()
    {
        for(int i = 0; i < metadatas.length; i++)
            metadatas[i]._isNewState = false;
    }
}