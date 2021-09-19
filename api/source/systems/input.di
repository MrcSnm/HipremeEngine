// D import file generated from 'source\systems\input.d'
module systems.input;
import util.data_structures;
import error.handler;
import jni.helper.androidlog;
import jni.jni;
import jni.helper.jnicall;
version (Android)
{
	alias HipAndroidInput = javaGetPackage!"com.hipremeengine.app.HipInput";
	@(JavaFunc!HipAndroidInput)void onMotionEventActionMove(int pointerId, float x, float y);
	@(JavaFunc!HipAndroidInput)void onMotionEventActionPointerDown(int pointerId, float x, float y);
	@(JavaFunc!HipAndroidInput)void onMotionEventActionPointerUp(int pointerId, float x, float y);
	@(JavaFunc!HipAndroidInput)void onMotionEventActionScroll(float x, float y);
	mixin javaGenerateModuleMethodsForPackage!(HipAndroidInput, systems.input, false);
}
else
{
}
class HipInput : EventQueue
{
	enum InputType : ubyte
	{
		TOUCH,
		TOUCH_DOWN,
		TOUCH_MOVE,
		TOUCH_UP,
		TOUCH_SCROLL,
		KEY,
		KEY_DOWN,
		KEY_UP,
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
		ushort id;
		float xPos;
		float yPos;
	}
	protected __gshared HipInput[] controllers;
	protected this(uint touchStructsCapacity = 126)
	{
		super(cast(uint)Touch.sizeof * touchStructsCapacity);
	}
	InputEvent* poll();
	static HipInput newController(uint touchStructsCapacity = 126);
	static void post(T)(uint id, InputType type, T ev)
	{
		ErrorHandler.assertExit(id < controllers.length, "Input controller out of range!");
		controllers[id].post(cast(ubyte)type, ev);
	}
	static InputEvent* poll(uint id);
	static void clear(uint id);
	alias poll = EventQueue.poll;
	alias post = EventQueue.post;
	alias clear = EventQueue.clear;
}
