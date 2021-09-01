module systems.input;
import jni.helper.androidlog;
import jni.jni;
import jni.helper.jnicall;
///Setups an Android Package for HipremeEngine
alias HipAndroidInput = javaGetPackage!("com.hipremeengine.app.HipInput");

__gshared HipInput inp;

version(Android)
{
    @JavaFunc!(HipAndroidInput) void onMotionEventActionMove(int pointerId, float x, float y)
	{
        import console.log;
        inp.postInput(HipInput.InputType.TOUCH_MOVE, HipInput.Touch(cast(ushort)pointerId, x,y));
        rawlog("Move: ", pointerId, " ", x, " ", y);
	}

    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerDown(int pointerId, float x, float y)
	{
        import console.log;
        inp.postInput(HipInput.InputType.TOUCH_DOWN, HipInput.Touch(cast(ushort)pointerId, x,y));
        rawlog("PointerDown: ", pointerId, " ", x, " ", y);
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerUp(int pointerId, float x, float y)
	{
        import console.log;
        inp.postInput(HipInput.InputType.TOUCH_UP, HipInput.Touch(cast(ushort)pointerId, x,y));
        rawlog("PointerUp: ", pointerId, " ", x, " ", y);
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionScroll(float x, float y)
	{
        import console.log;
        inp.postInput(HipInput.InputType.TOUCH_SCROLL, HipInput.Touch(ushort.max, x,y));
        rawlog("Scroll: ", x, " ", y);
	}

    mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, systems.input, false);
}
else
{

} 

class HipInput
{
    import util.memory;
    enum InputType : ubyte
    {
        TOUCH_DOWN,
        TOUCH_MOVE,
        TOUCH_UP,
        TOUCH_SCROLL,
        KEY_DOWN,
        KEY_UP
    }

    struct InputEvent
    {
        InputType type;
        ubyte evSize;
        void[0] evData;
    }

    struct Key
    {
        ushort id;
    }

    struct Touch
    {
        ///Ubyte unnecessary, as I doubt any arch would receive a struct non divisible by 2
        ushort id;
        float  xPos;
        float  yPos;
    }

    void* eventQueue;
    uint bytesCapacity;
    uint bytesOffset;

    protected uint pollCursor;

    this(uint touchStructsCapacity = 126)
    {
        ///Uses capacity*greatest structure size
        bytesCapacity = cast(uint)Touch.sizeof*touchStructsCapacity;
        bytesOffset = 0;
        eventQueue = malloc(bytesCapacity);
    }


    void postInput(T)(InputType type, T ev)
    {
        assert(bytesOffset+T.sizeof+InputEvent.sizeof < bytesCapacity, "InputQueue Out of bounds");
        if(pollCursor == bytesOffset) //It will restart if everything was polled
        {
            pollCursor = 0;
            bytesOffset = 0;
        }
        else if(pollCursor != 0) //It will copy everything from the right to the start
        {
            memcpy(eventQueue, eventQueue+pollCursor, bytesOffset-pollCursor);
            //Compensates the offset into the cursor.
            bytesOffset-= pollCursor;
            //Restarts the poll cursor, as everything from the right moved to left
            pollCursor = 0;
        }
        InputEvent ie;
        ie.type = type;
        ie.evSize = T.sizeof;
        memcpy(eventQueue+bytesOffset, &ie, InputEvent.sizeof);
        memcpy(eventQueue+bytesOffset+InputEvent.sizeof, &ev, T.sizeof);
        bytesOffset+= T.sizeof+InputEvent.sizeof;
    }

    void clear()
    {
        //By setting it equal, no one will be able to poll it
        pollCursor = bytesOffset;
    }

    InputEvent* poll()
    {
        if(bytesOffset - pollCursor <= 0)
            return null;
        InputEvent* ev = cast(InputEvent*)(eventQueue+pollCursor);
        pollCursor+= ev.evSize+InputEvent.sizeof;
        return ev;
    }

    ~this()
    {
        free(eventQueue);
        eventQueue = null;
        pollCursor = 0;
        bytesCapacity = 0;
        bytesOffset = 0;
    }
}
