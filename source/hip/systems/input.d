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

version(WebAssembly) version = QueuePopulatedExternally;
else version(UWP) version = QueuePopulatedExternally;
else version(PSVita) version = QueuePopulatedExternally;
else version(AppleOS) version = QueuePopulatedExternally;

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
        HipEventQueue.post(0, HipEventQueue.EventType.touchScroll, HipEventQueue.Scroll(x,x,0));
	}

    @JavaFunc!(HipAndroidRenderer) void onRendererResize(int x, int y)
    {
        ///Must be executed on the render thread :(
        import hip.hiprenderer;
        import hip.graphics.g2d.renderer2d;
        HipRenderer.setWindowSize(x, y);
        resizeRenderer2D(cast(uint)x, cast(uint)y);
        // HipEventQueue.post(0, HipEventQueue.EventType.windowResize, HipEventQueue.Resize(cast(uint)x, cast(uint)y));
    }

    mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, hip.systems.input, false);
    mixin javaGenerateModuleMethodsForPackage!(HipAndroidRenderer, hip.systems.input, false);
}
else version(QueuePopulatedExternally)
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
            import hip.event.dispatcher;
            HipEventQueue.post(0, HipEventQueue.EventType.keyDown, HipEventQueue.Key(cast(ushort)virtualKey.getHipKeyFromSystem));
        }
        void HipInputOnKeyUp(uint virtualKey)
        {
            import hip.event.dispatcher;
            HipEventQueue.post(0, HipEventQueue.EventType.keyUp, HipEventQueue.Key(cast(ushort)virtualKey.getHipKeyFromSystem));
        }
        void HipInputOnGamepadConnected(ubyte id, ubyte type)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.gamepadConnected, HipEventQueue.Gamepad(id, type));
        }
        void HipInputOnGamepadDisconnected(ubyte id, ubyte type)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.gamepadDisconnected, HipEventQueue.Gamepad(id, type));
        }
        void HipOnRendererResize(int x, int y)
        {
            HipEventQueue.post(0, HipEventQueue.EventType.windowResize, HipEventQueue.Resize(cast(uint)x, cast(uint)y));
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

    struct Gamepad
    {
        ubyte id;
        ///See hip.systems.gamepad.HipGamepadTypes
        ubyte type;
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
        import hip.util.conv:to;
        if(id >= controllers.length)
            ErrorHandler.assertExit(false, "Input controller out of range!(ID: "~id.to!string~", Type: "~ type.to!string ~ ")");
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
        import hip.util.conv:to;
        if(id >= controllers.length)
            ErrorHandler.assertExit(false, "Input controller out of range!(ID: "~id.to!string~", Type: "~ type.to!string ~ ")");
        controllers[id].post(cast(ubyte)type, ev);
    }

    /** Polls an input event for a specified controller */
    static InputEvent* poll(uint id)
    {
        import hip.util.conv:to;
        if(id >= controllers.length)
            ErrorHandler.assertExit(false, "Input controller out of range!(ID: "~id.to!string~")");
        return controllers[id].poll();
    }
    static void clear(uint id)
    {
        import hip.util.conv:to;
        if(id >= controllers.length)
        {
            ErrorHandler.assertExit(false, "Input controller out of range!(ID: "~id.to!string~")");
        }
        controllers[id].clear();
    }
    alias poll = EventQueue.poll;
    alias post = EventQueue.post;
    alias clear = EventQueue.clear;
}
