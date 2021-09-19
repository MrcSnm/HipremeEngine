
module jni.android.input;
import core.stdc.stdint;
import jni.android.keycodes;
import jni.android.looper;
extern (C) 
{
	enum 
	{
		AKEY_STATE_UNKNOWN = -1,
		AKEY_STATE_UP = 0,
		AKEY_STATE_DOWN = 1,
		AKEY_STATE_VIRTUAL = 2,
	}
	enum 
	{
		AMETA_NONE = 0,
		AMETA_ALT_ON = 2,
		AMETA_ALT_LEFT_ON = 16,
		AMETA_ALT_RIGHT_ON = 32,
		AMETA_SHIFT_ON = 1,
		AMETA_SHIFT_LEFT_ON = 64,
		AMETA_SHIFT_RIGHT_ON = 128,
		AMETA_SYM_ON = 4,
		AMETA_FUNCTION_ON = 8,
		AMETA_CTRL_ON = 4096,
		AMETA_CTRL_LEFT_ON = 8192,
		AMETA_CTRL_RIGHT_ON = 16384,
		AMETA_META_ON = 65536,
		AMETA_META_LEFT_ON = 131072,
		AMETA_META_RIGHT_ON = 262144,
		AMETA_CAPS_LOCK_ON = 1048576,
		AMETA_NUM_LOCK_ON = 2097152,
		AMETA_SCROLL_LOCK_ON = 4194304,
	}
	struct AInputEvent;
	enum 
	{
		AINPUT_EVENT_TYPE_KEY = 1,
		AINPUT_EVENT_TYPE_MOTION = 2,
		AINPUT_EVENT_TYPE_FOCUS = 3,
	}
	enum 
	{
		AKEY_EVENT_ACTION_DOWN = 0,
		AKEY_EVENT_ACTION_UP = 1,
		AKEY_EVENT_ACTION_MULTIPLE = 2,
	}
	enum 
	{
		AKEY_EVENT_FLAG_WOKE_HERE = 1,
		AKEY_EVENT_FLAG_SOFT_KEYBOARD = 2,
		AKEY_EVENT_FLAG_KEEP_TOUCH_MODE = 4,
		AKEY_EVENT_FLAG_FROM_SYSTEM = 8,
		AKEY_EVENT_FLAG_EDITOR_ACTION = 16,
		AKEY_EVENT_FLAG_CANCELED = 32,
		AKEY_EVENT_FLAG_VIRTUAL_HARD_KEY = 64,
		AKEY_EVENT_FLAG_LONG_PRESS = 128,
		AKEY_EVENT_FLAG_CANCELED_LONG_PRESS = 256,
		AKEY_EVENT_FLAG_TRACKING = 512,
		AKEY_EVENT_FLAG_FALLBACK = 1024,
	}
	enum AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT = 8;
	enum 
	{
		AMOTION_EVENT_ACTION_MASK = 255,
		AMOTION_EVENT_ACTION_POINTER_INDEX_MASK = 65280,
		AMOTION_EVENT_ACTION_DOWN = 0,
		AMOTION_EVENT_ACTION_UP = 1,
		AMOTION_EVENT_ACTION_MOVE = 2,
		AMOTION_EVENT_ACTION_CANCEL = 3,
		AMOTION_EVENT_ACTION_OUTSIDE = 4,
		AMOTION_EVENT_ACTION_POINTER_DOWN = 5,
		AMOTION_EVENT_ACTION_POINTER_UP = 6,
		AMOTION_EVENT_ACTION_HOVER_MOVE = 7,
		AMOTION_EVENT_ACTION_SCROLL = 8,
		AMOTION_EVENT_ACTION_HOVER_ENTER = 9,
		AMOTION_EVENT_ACTION_HOVER_EXIT = 10,
		AMOTION_EVENT_ACTION_BUTTON_PRESS = 11,
		AMOTION_EVENT_ACTION_BUTTON_RELEASE = 12,
	}
	enum 
	{
		AMOTION_EVENT_FLAG_WINDOW_IS_OBSCURED = 1,
	}
	enum 
	{
		AMOTION_EVENT_EDGE_FLAG_NONE = 0,
		AMOTION_EVENT_EDGE_FLAG_TOP = 1,
		AMOTION_EVENT_EDGE_FLAG_BOTTOM = 2,
		AMOTION_EVENT_EDGE_FLAG_LEFT = 4,
		AMOTION_EVENT_EDGE_FLAG_RIGHT = 8,
	}
	enum 
	{
		AMOTION_EVENT_AXIS_X = 0,
		AMOTION_EVENT_AXIS_Y = 1,
		AMOTION_EVENT_AXIS_PRESSURE = 2,
		AMOTION_EVENT_AXIS_SIZE = 3,
		AMOTION_EVENT_AXIS_TOUCH_MAJOR = 4,
		AMOTION_EVENT_AXIS_TOUCH_MINOR = 5,
		AMOTION_EVENT_AXIS_TOOL_MAJOR = 6,
		AMOTION_EVENT_AXIS_TOOL_MINOR = 7,
		AMOTION_EVENT_AXIS_ORIENTATION = 8,
		AMOTION_EVENT_AXIS_VSCROLL = 9,
		AMOTION_EVENT_AXIS_HSCROLL = 10,
		AMOTION_EVENT_AXIS_Z = 11,
		AMOTION_EVENT_AXIS_RX = 12,
		AMOTION_EVENT_AXIS_RY = 13,
		AMOTION_EVENT_AXIS_RZ = 14,
		AMOTION_EVENT_AXIS_HAT_X = 15,
		AMOTION_EVENT_AXIS_HAT_Y = 16,
		AMOTION_EVENT_AXIS_LTRIGGER = 17,
		AMOTION_EVENT_AXIS_RTRIGGER = 18,
		AMOTION_EVENT_AXIS_THROTTLE = 19,
		AMOTION_EVENT_AXIS_RUDDER = 20,
		AMOTION_EVENT_AXIS_WHEEL = 21,
		AMOTION_EVENT_AXIS_GAS = 22,
		AMOTION_EVENT_AXIS_BRAKE = 23,
		AMOTION_EVENT_AXIS_DISTANCE = 24,
		AMOTION_EVENT_AXIS_TILT = 25,
		AMOTION_EVENT_AXIS_SCROLL = 26,
		AMOTION_EVENT_AXIS_RELATIVE_X = 27,
		AMOTION_EVENT_AXIS_RELATIVE_Y = 28,
		AMOTION_EVENT_AXIS_GENERIC_1 = 32,
		AMOTION_EVENT_AXIS_GENERIC_2 = 33,
		AMOTION_EVENT_AXIS_GENERIC_3 = 34,
		AMOTION_EVENT_AXIS_GENERIC_4 = 35,
		AMOTION_EVENT_AXIS_GENERIC_5 = 36,
		AMOTION_EVENT_AXIS_GENERIC_6 = 37,
		AMOTION_EVENT_AXIS_GENERIC_7 = 38,
		AMOTION_EVENT_AXIS_GENERIC_8 = 39,
		AMOTION_EVENT_AXIS_GENERIC_9 = 40,
		AMOTION_EVENT_AXIS_GENERIC_10 = 41,
		AMOTION_EVENT_AXIS_GENERIC_11 = 42,
		AMOTION_EVENT_AXIS_GENERIC_12 = 43,
		AMOTION_EVENT_AXIS_GENERIC_13 = 44,
		AMOTION_EVENT_AXIS_GENERIC_14 = 45,
		AMOTION_EVENT_AXIS_GENERIC_15 = 46,
		AMOTION_EVENT_AXIS_GENERIC_16 = 47,
	}
	enum 
	{
		AMOTION_EVENT_BUTTON_PRIMARY = 1 << 0,
		AMOTION_EVENT_BUTTON_SECONDARY = 1 << 1,
		AMOTION_EVENT_BUTTON_TERTIARY = 1 << 2,
		AMOTION_EVENT_BUTTON_BACK = 1 << 3,
		AMOTION_EVENT_BUTTON_FORWARD = 1 << 4,
		AMOTION_EVENT_BUTTON_STYLUS_PRIMARY = 1 << 5,
		AMOTION_EVENT_BUTTON_STYLUS_SECONDARY = 1 << 6,
	}
	enum 
	{
		AMOTION_EVENT_TOOL_TYPE_UNKNOWN = 0,
		AMOTION_EVENT_TOOL_TYPE_FINGER = 1,
		AMOTION_EVENT_TOOL_TYPE_STYLUS = 2,
		AMOTION_EVENT_TOOL_TYPE_MOUSE = 3,
		AMOTION_EVENT_TOOL_TYPE_ERASER = 4,
		AMOTION_EVENT_TOOL_TYPE_PALM = 5,
	}
	enum 
	{
		AINPUT_SOURCE_CLASS_MASK = 255,
		AINPUT_SOURCE_CLASS_NONE = 0,
		AINPUT_SOURCE_CLASS_BUTTON = 1,
		AINPUT_SOURCE_CLASS_POINTER = 2,
		AINPUT_SOURCE_CLASS_NAVIGATION = 4,
		AINPUT_SOURCE_CLASS_POSITION = 8,
		AINPUT_SOURCE_CLASS_JOYSTICK = 16,
	}
	enum 
	{
		AINPUT_SOURCE_UNKNOWN = 0,
		AINPUT_SOURCE_KEYBOARD = 256 | AINPUT_SOURCE_CLASS_BUTTON,
		AINPUT_SOURCE_DPAD = 512 | AINPUT_SOURCE_CLASS_BUTTON,
		AINPUT_SOURCE_GAMEPAD = 1024 | AINPUT_SOURCE_CLASS_BUTTON,
		AINPUT_SOURCE_TOUCHSCREEN = 4096 | AINPUT_SOURCE_CLASS_POINTER,
		AINPUT_SOURCE_MOUSE = 8192 | AINPUT_SOURCE_CLASS_POINTER,
		AINPUT_SOURCE_STYLUS = 16384 | AINPUT_SOURCE_CLASS_POINTER,
		AINPUT_SOURCE_BLUETOOTH_STYLUS = 32768 | AINPUT_SOURCE_STYLUS,
		AINPUT_SOURCE_TRACKBALL = 65536 | AINPUT_SOURCE_CLASS_NAVIGATION,
		AINPUT_SOURCE_MOUSE_RELATIVE = 131072 | AINPUT_SOURCE_CLASS_NAVIGATION,
		AINPUT_SOURCE_TOUCHPAD = 1048576 | AINPUT_SOURCE_CLASS_POSITION,
		AINPUT_SOURCE_TOUCH_NAVIGATION = 2097152 | AINPUT_SOURCE_CLASS_NONE,
		AINPUT_SOURCE_JOYSTICK = 16777216 | AINPUT_SOURCE_CLASS_JOYSTICK,
		AINPUT_SOURCE_ROTARY_ENCODER = 4194304 | AINPUT_SOURCE_CLASS_NONE,
		AINPUT_SOURCE_ANY = 4294967040u,
	}
	enum 
	{
		AINPUT_KEYBOARD_TYPE_NONE = 0,
		AINPUT_KEYBOARD_TYPE_NON_ALPHABETIC = 1,
		AINPUT_KEYBOARD_TYPE_ALPHABETIC = 2,
	}
	enum 
	{
		AINPUT_MOTION_RANGE_X = AMOTION_EVENT_AXIS_X,
		AINPUT_MOTION_RANGE_Y = AMOTION_EVENT_AXIS_Y,
		AINPUT_MOTION_RANGE_PRESSURE = AMOTION_EVENT_AXIS_PRESSURE,
		AINPUT_MOTION_RANGE_SIZE = AMOTION_EVENT_AXIS_SIZE,
		AINPUT_MOTION_RANGE_TOUCH_MAJOR = AMOTION_EVENT_AXIS_TOUCH_MAJOR,
		AINPUT_MOTION_RANGE_TOUCH_MINOR = AMOTION_EVENT_AXIS_TOUCH_MINOR,
		AINPUT_MOTION_RANGE_TOOL_MAJOR = AMOTION_EVENT_AXIS_TOOL_MAJOR,
		AINPUT_MOTION_RANGE_TOOL_MINOR = AMOTION_EVENT_AXIS_TOOL_MINOR,
		AINPUT_MOTION_RANGE_ORIENTATION = AMOTION_EVENT_AXIS_ORIENTATION,
	}
	int32_t AInputEvent_getType(const AInputEvent* event);
	int32_t AInputEvent_getDeviceId(const AInputEvent* event);
	int32_t AInputEvent_getSource(const AInputEvent* event);
	int32_t AKeyEvent_getAction(const AInputEvent* key_event);
	int32_t AKeyEvent_getFlags(const AInputEvent* key_event);
	int32_t AKeyEvent_getKeyCode(const AInputEvent* key_event);
	int32_t AKeyEvent_getScanCode(const AInputEvent* key_event);
	int32_t AKeyEvent_getMetaState(const AInputEvent* key_event);
	int32_t AKeyEvent_getRepeatCount(const AInputEvent* key_event);
	int64_t AKeyEvent_getDownTime(const AInputEvent* key_event);
	int64_t AKeyEvent_getEventTime(const AInputEvent* key_event);
	int32_t AMotionEvent_getAction(const AInputEvent* motion_event);
	int32_t AMotionEvent_getFlags(const AInputEvent* motion_event);
	int32_t AMotionEvent_getMetaState(const AInputEvent* motion_event);
	int32_t AMotionEvent_getButtonState(const AInputEvent* motion_event);
	int32_t AMotionEvent_getEdgeFlags(const AInputEvent* motion_event);
	int64_t AMotionEvent_getDownTime(const AInputEvent* motion_event);
	int64_t AMotionEvent_getEventTime(const AInputEvent* motion_event);
	float AMotionEvent_getXOffset(const AInputEvent* motion_event);
	float AMotionEvent_getYOffset(const AInputEvent* motion_event);
	float AMotionEvent_getXPrecision(const AInputEvent* motion_event);
	float AMotionEvent_getYPrecision(const AInputEvent* motion_event);
	size_t AMotionEvent_getPointerCount(const AInputEvent* motion_event);
	int32_t AMotionEvent_getPointerId(const AInputEvent* motion_event, size_t pointer_index);
	int32_t AMotionEvent_getToolType(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getRawX(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getRawY(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getX(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getY(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getPressure(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getSize(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getTouchMajor(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getTouchMinor(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getToolMajor(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getToolMinor(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getOrientation(const AInputEvent* motion_event, size_t pointer_index);
	float AMotionEvent_getAxisValue(const AInputEvent* motion_event, int32_t axis, size_t pointer_index);
	size_t AMotionEvent_getHistorySize(const AInputEvent* motion_event);
	int64_t AMotionEvent_getHistoricalEventTime(const AInputEvent* motion_event, size_t history_index);
	float AMotionEvent_getHistoricalRawX(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalRawY(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalX(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalY(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalPressure(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalSize(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalTouchMajor(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalTouchMinor(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalToolMajor(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalToolMinor(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalOrientation(const AInputEvent* motion_event, size_t pointer_index, size_t history_index);
	float AMotionEvent_getHistoricalAxisValue(const AInputEvent* motion_event, int32_t axis, size_t pointer_index, size_t history_index);
	struct AInputQueue;
	void AInputQueue_attachLooper(AInputQueue* queue, ALooper* looper, int ident, ALooper_callbackFunc callback, void* data);
	void AInputQueue_detachLooper(AInputQueue* queue);
	int32_t AInputQueue_hasEvents(AInputQueue* queue);
	int32_t AInputQueue_getEvent(AInputQueue* queue, AInputEvent** outEvent);
	int32_t AInputQueue_preDispatchEvent(AInputQueue* queue, AInputEvent* event);
	void AInputQueue_finishEvent(AInputQueue* queue, AInputEvent* event, int handled);
}
