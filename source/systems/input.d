module systems.input;
import util.data_structures;
import error.handler;
import jni.helper.androidlog;
import jni.jni;
import jni.helper.jnicall;
///Setups an Android Package for HipremeEngine


version(Android)
{
    alias HipAndroidInput = javaGetPackage!("com.hipremeengine.app.HipInput");
    @JavaFunc!(HipAndroidInput) void onMotionEventActionMove(int pointerId, float x, float y)
	{
        HipInput.post(0, HipInput.InputType.TOUCH_MOVE, HipInput.Touch(cast(ushort)pointerId, x,y));
	}

    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerDown(int pointerId, float x, float y)
	{
        HipInput.post(0, HipInput.InputType.TOUCH_DOWN, HipInput.Touch(cast(ushort)pointerId, x,y));
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerUp(int pointerId, float x, float y)
	{
        HipInput.post(0, HipInput.InputType.TOUCH_UP, HipInput.Touch(cast(ushort)pointerId, x,y));
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionScroll(float x, float y)
	{
        HipInput.post(0, HipInput.InputType.TOUCH_SCROLL, HipInput.Touch(ushort.max, x,y));
	}

    mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, systems.input, false);
}
else
{

} 

/**
*   High efficient(at least memory-wise), tightly packed Input queue that supports any kind of data in
*   a single allocated memory pool(no fragmentation).
*
*   This class could probably be extendeded to be every event handler
*/
class HipInput : EventQueue
{
    enum InputType : ubyte
    {
        TOUCH, //Check if type >= TOUCH ?
        TOUCH_DOWN,
        TOUCH_MOVE,
        TOUCH_UP,
        TOUCH_SCROLL,
        KEY,
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

    ///This class should probably not contain more than one instance(unless 2 people are playing)
    protected __gshared HipInput[] controllers;

    protected this(uint touchStructsCapacity = 126)
    {
        ///Uses capacity*greatest structure size
        super(cast(uint)Touch.sizeof*touchStructsCapacity);
    }
    InputEvent* poll(){return cast(InputEvent*)super.poll();}

    static HipInput newController(uint touchStructsCapacity = 126)
    {
        HipInput ip = new HipInput(touchStructsCapacity);
        controllers~= ip;
        return ip;
    }
    static void post(T)(uint id, InputType type, T ev)
    {
        ErrorHandler.assertExit(id < controllers.length, "Input controller out of range!");
        controllers[id].post(cast(ubyte)type, ev);
    }
    static InputEvent* poll(uint id)
    {
        ErrorHandler.assertExit(id < controllers.length, "Input controller out of range!");
        return controllers[id].poll();
    }
    static void clear(uint id)
    {
        ErrorHandler.assertExit(id < controllers.length, "Input controller out of range!");
        controllers[id].clear();
    }
    alias poll = EventQueue.poll;
    alias post = EventQueue.post;
    alias clear = EventQueue.clear;
}
