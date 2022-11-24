/*
Copyright: Marcelo S. N. Mancini (Hipreme|MrcSnm), 2018 - 2021
License:   [https://creativecommons.org/licenses/by/4.0/|CC BY-4.0 License].
Authors: Marcelo S. N. Mancini

	Copyright Marcelo S. N. Mancini 2018 - 2021.
Distributed under the CC BY-4.0 License.
   (See accompanying file LICENSE.txt or copy at
	https://creativecommons.org/licenses/by/4.0/
*/
module hip.systems.input;
import hip.util.data_structures;
import hip.error.handler;

version(Android)
{
    import hip.jni.helper.androidlog;
    import hip.jni.jni;
    import hip.jni.helper.jnicall;

    ///Setups an Android Package for HipremeEngine
    alias HipAndroidInput = javaGetPackage!("com.hipremeengine.app.HipInput");
    alias HipAndroidRenderer = javaGetPackage!("com.hipremeengine.app.Hip_GLES30_Renderer");

    @JavaFunc!(HipAndroidInput) void onMotionEventActionMove(int pointerId, float x, float y)
	{
        HipEventQueue.post(0, HipEventQueue.EventType.touchMove, HipEventQueue.Touch(cast(ushort)pointerId, x,y));
	}

    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerDown(int pointerId, float x, float y)
	{
        HipEventQueue.post(0, HipEventQueue.EventType.touchDown, HipEventQueue.Touch(cast(ushort)pointerId, x,y));
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionPointerUp(int pointerId, float x, float y)
	{
        HipEventQueue.post(0, HipEventQueue.EventType.touchUp, HipEventQueue.Touch(cast(ushort)pointerId, x,y));
	}
    @JavaFunc!(HipAndroidInput) void onMotionEventActionScroll(float x, float y)
	{
        HipEventQueue.post(0, HipEventQueue.EventType.touchScroll, HipEventQueue.Touch(ushort.max, x,y));
	}

    @JavaFunc!(HipAndroidRenderer) void onRendererResize(int x, int y)
    {
        HipEventQueue.post(0, HipEventQueue.EventType.windowResize, HipEventQueue.Resize(cast(uint)x, cast(uint)y));
    }

    mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, hip.systems.input, true);
    mixin javaGenerateModuleMethodsForPackage!(HipAndroidRenderer, hip.systems.input, true);
}
else version(UWP)
{
    export extern(System)
    {
        void HipInputOnTouchPressed(uint id, float x, float y)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.touchDown, HipEventQueue.Touch(cast(ushort)id, x, y));
        }
        void HipInputOnTouchMoved(uint id, float x, float y)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.touchMove, HipEventQueue.Touch(cast(ushort)id, x, y));
        }
        void HipInputOnTouchReleased(uint id, float x, float y)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.touchUp, HipEventQueue.Touch(cast(ushort)id, x, y));
        }
        void HipInputOnTouchScroll(float x, float y, float z)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.touchScroll, HipEventQueue.Scroll(x,y,z));
        }
        void HipInputOnKeyDown(uint virtualKey)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(cast(ushort)virtualKey));
        }
        void HipInputOnKeyUp(uint virtualKey)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.keyUp, HipEventQueue.Key(cast(ushort)virtualKey));
        }
        void HipInputOnGamepadConnected(ubyte id)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.gamepadConnected, HipEventQueue.Gamepad(id));
        }
        void HipInputOnGamepadDisconnected(ubyte id)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.gamepadDisconnected, HipEventQueue.Gamepad(id));
        }
    }    
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

        gamepadConnected,
        gamepadDisconnected,

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
    struct Resize
    {
        uint width;
        uint height;
    }

    struct Gamepad{ubyte id;}

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
        import hip.util.format;
        ErrorHandler.assertExit(id < controllers.length, format!("Input controller out of range!(ID: %s, Type: %s)")(id, type));
        controllers[id].post(cast(ubyte)type, ev);
    }

    /** External API used for getting the input events inside an internal queue. This way the API can remains the same*/
    static void post(uint id, EventType type, Gamepad ev)
    {
        if(type == EventType.gamepadConnected)
        {
            while(controllers.length < id+1)
                newController();
        }
        import hip.util.format;
        ErrorHandler.assertExit(id < controllers.length, format!("Input controller out of range!(ID: %s, Type: %s)")(id, type));
        controllers[id].post(cast(ubyte)type, ev);
    }

    /** Polls an input event for a specified controller */
    static InputEvent* poll(uint id)
    {
        import hip.util.format;
        ErrorHandler.assertExit(id < controllers.length, format!("Input controller out of range!(ID: %s)")(id));
        return controllers[id].poll();
    }
    static void clear(uint id)
    {
        import hip.util.format;
        ErrorHandler.assertExit(id < controllers.length, format!("Input controller out of range!(ID: %s)")(id));
        controllers[id].clear();
    }
    alias poll = EventQueue.poll;
    alias post = EventQueue.post;
    alias clear = EventQueue.clear;
}
