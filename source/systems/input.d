module systems.input;
import util.data_structures;
import error.handler;
import jni.helper.androidlog;
import jni.jni;
import jni.helper.jnicall;

version(Android)
{
    ///Setups an Android Package for HipremeEngine
    alias HipAndroidInput = javaGetPackage!("com.hipremeengine.app.HipInput");
    @JavaFunc!(HipAndroidInput) void onMotionEventActionMove(int pointerId, float x, float y)
	{
        HipInput.post(0, HipInput.InputType.touchMove, HipInput.Touch(cast(ushort)pointerId, x,y));
	}

    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerDown(int pointerId, float x, float y)
	{
        HipInput.post(0, HipInput.InputType.touchDown, HipInput.Touch(cast(ushort)pointerId, x,y));
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerUp(int pointerId, float x, float y)
	{
        HipInput.post(0, HipInput.InputType.touchUp, HipInput.Touch(cast(ushort)pointerId, x,y));
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionScroll(float x, float y)
	{
        HipInput.post(0, HipInput.InputType.touchScroll, HipInput.Touch(ushort.max, x,y));
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
*   The input queue is populated by external APIs, like UWP's CoreWindow, Android's app and SDL2 Event. 
*   This way, it is possible to create a centralized input resource. This class does not creates the entire
*   input system. It creates its base for being handled.
*/
class HipEventQueue : EventQueue
{
    enum EventType : ubyte
    {
        ///Mouse was basically ignored for the sake of making it only touch ( it should be easier )
        touchDown,
        touchMove,
        touchUp,
        touchScroll,
        keyDown,
        keyUp,
        ///When user returns to application
        focusReceived,
        ///When user exists the application
        focusLost,
        windowResize,
        exit
    }

    struct InputEvent
    {
        EventType type;
        ubyte evSize;
        void[0] evData;
        pragma(inline, true)
        T get(T)(){return *(cast(T*)evData);}
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
    struct Scroll
    {
        float x, y,z;
    }

    ///This class should probably not contain more than one instance(unless 2 people are playing)
    protected __gshared HipEventQueue[] controllers;

    protected this(uint touchStructsCapacity = 126)
    {
        ///Uses capacity*greatest structure size
        super(cast(uint)Touch.sizeof*touchStructsCapacity);
    }
    InputEvent* poll(){return cast(InputEvent*)super.poll();}

    static HipEventQueue newController(uint touchStructsCapacity = 126)
    {
        HipEventQueue ip = new HipEventQueue(touchStructsCapacity);
        controllers~= ip;
        return ip;
    }

    /** External API used for getting the input events inside an internal queue. This way the API can remains the same*/
    static void post(T)(uint id, EventType type, T ev)
    {
        ErrorHandler.assertExit(id < controllers.length, "Input controller out of range!");
        controllers[id].post(cast(ubyte)type, ev);
    }
    /** Polls an input event for a specified controller */
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
